package lk.bloodlink.service;

import lk.bloodlink.model.entity.BloodRequest;
import lk.bloodlink.model.entity.Donor;
import lk.bloodlink.model.entity.RequestMatch;
import lk.bloodlink.model.enums.BloodType;
import lk.bloodlink.model.enums.MatchStatus;
import lk.bloodlink.model.enums.RequestStatus;
import lk.bloodlink.repository.BloodCompatibilityRepository;
import lk.bloodlink.repository.BloodRequestRepository;
import lk.bloodlink.repository.DonorRepository;
import lk.bloodlink.repository.RequestMatchRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class MatchingService {

    private final DonorRepository donorRepository;
    private final BloodRequestRepository bloodRequestRepository;
    private final RequestMatchRepository requestMatchRepository;
    private final BloodCompatibilityRepository compatibilityRepository;
    private final NotificationService notificationService;

    @Value("${bloodlink.matching.weight-compat:0.5}")
    private double weightCompat;

    @Value("${bloodlink.matching.weight-proximity:0.3}")
    private double weightProximity;

    @Value("${bloodlink.matching.weight-reliability:0.2}")
    private double weightReliability;

    @Value("${bloodlink.matching.response-window-minutes:10}")
    private int responseWindowMinutes;

    @Transactional
    public List<RequestMatch> matchAndNotify(BloodRequest request, int radiusKm) {
        log.info("Running AI matching for request {} at radius {} km", request.getId(), radiusKm);

        List<BloodType> compatibleTypes = compatibilityRepository.findCompatibleDonorTypes(request.getBloodType());
        if (compatibleTypes.isEmpty()) {
            compatibleTypes = Collections.singletonList(request.getBloodType());
        }

        LocalDate cooldownLimit = LocalDate.now().minusDays(112);
        List<Donor> candidateDonors = new ArrayList<>();
        for (BloodType type : compatibleTypes) {
            candidateDonors.addAll(donorRepository.findByBloodTypeAndIsAvailableTrue(type));
        }

        List<ScoredCandidate> scoredList = new ArrayList<>();
        double reqLat = request.getLatitude() != null ? request.getLatitude() : 6.9271; // Default Colombo coords
        double reqLng = request.getLongitude() != null ? request.getLongitude() : 79.8612;

        for (Donor d : candidateDonors) {
            // Check cooldown
            if (d.getLastDonationDate() != null && d.getLastDonationDate().isAfter(cooldownLimit)) {
                continue;
            }
            // Check if already matched
            if (requestMatchRepository.existsByRequestIdAndDonorUserId(request.getId(), d.getUserId())) {
                continue;
            }

            double donorLat = d.getLatitude() != null ? d.getLatitude() : reqLat;
            double donorLng = d.getLongitude() != null ? d.getLongitude() : reqLng;

            double dist = calculateHaversineDistance(reqLat, reqLng, donorLat, donorLng);
            if (dist > radiusKm) {
                continue;
            }

            boolean exactMatch = d.getBloodType() == request.getBloodType();
            double compatScore = exactMatch ? 1.0 : 0.85;
            double proxScore = Math.max(0.0, 1.0 - (dist / Math.max(1.0, radiusKm)));
            double relScore = d.getReliabilityScore() != null ? d.getReliabilityScore().doubleValue() : 0.5;

            double totalScore = (weightCompat * compatScore) + (weightProximity * proxScore) + (weightReliability * relScore);

            scoredList.add(new ScoredCandidate(d, totalScore, compatScore, dist, relScore));
        }

        // Sort descending by score
        scoredList.sort((a, b) -> Double.compare(b.totalScore, a.totalScore));

        List<RequestMatch> createdMatches = new ArrayList<>();
        int maxToNotify = Math.min(15, scoredList.size());

        for (int i = 0; i < maxToNotify; i++) {
            ScoredCandidate sc = scoredList.get(i);
            RequestMatch match = RequestMatch.builder()
                    .request(request)
                    .donor(sc.donor)
                    .score(BigDecimal.valueOf(sc.totalScore).setScale(4, RoundingMode.HALF_UP))
                    .compatScore(BigDecimal.valueOf(sc.compatScore).setScale(4, RoundingMode.HALF_UP))
                    .distanceKm(BigDecimal.valueOf(sc.distanceKm).setScale(2, RoundingMode.HALF_UP))
                    .reliabilityScore(BigDecimal.valueOf(sc.reliabilityScore).setScale(3, RoundingMode.HALF_UP))
                    .status(MatchStatus.NOTIFIED)
                    .notifiedAt(Instant.now())
                    .build();

            match = requestMatchRepository.save(match);
            createdMatches.add(match);

            // Notify donor via STOMP and persistent notification
            notificationService.sendToUser(
                    sc.donor.getUser(),
                    "ALERT_BLOOD_REQUEST",
                    "Urgent " + request.getBloodType().getValue() + " Needed Nearby!",
                    request.getUnitsRequired() + " units requested at " + request.getHospitalName() + " (" + Math.round(sc.distanceKm) + " km away)",
                    "{\"requestId\":\"" + request.getId() + "\",\"matchId\":\"" + match.getId() + "\"}"
            );
        }

        if (!createdMatches.isEmpty() && request.getStatus() == RequestStatus.CREATED) {
            request.setStatus(RequestStatus.MATCHING);
            bloodRequestRepository.save(request);
        }

        return createdMatches;
    }

    @Scheduled(fixedRate = 60000) // Runs every minute
    @Transactional
    public void processMatchTimeoutsAndEscalation() {
        Instant cutoff = Instant.now().minus(responseWindowMinutes, ChronoUnit.MINUTES);
        List<RequestMatch> expiredList = requestMatchRepository.findByStatusAndNotifiedAtBefore(MatchStatus.NOTIFIED, cutoff);

        Set<UUID> affectedRequestIds = new HashSet<>();
        for (RequestMatch m : expiredList) {
            m.setStatus(MatchStatus.EXPIRED);
            m.setRespondedAt(Instant.now());
            requestMatchRepository.save(m);
            affectedRequestIds.add(m.getRequest().getId());
        }

        // For each affected request, check if any donor has accepted
        for (UUID reqId : affectedRequestIds) {
            bloodRequestRepository.findById(reqId).ifPresent(req -> {
                if (req.getStatus() == RequestStatus.MATCHING || req.getStatus() == RequestStatus.CREATED) {
                    // Check if all current matches are expired
                    List<RequestMatch> matches = requestMatchRepository.findByRequestIdOrderByScoreDesc(reqId);
                    boolean hasActiveMatch = matches.stream().anyMatch(m -> m.getStatus() == MatchStatus.ACCEPTED || m.getStatus() == MatchStatus.NOTIFIED);
                    if (!hasActiveMatch) {
                        log.info("Escalating search radius to 80 km for request {}", req.getId());
                        matchAndNotify(req, 80);
                    }
                }
            });
        }
    }

    private double calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // Earth radius in km
        double latDist = Math.toRadians(lat2 - lat1);
        double lonDist = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDist / 2) * Math.sin(latDist / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDist / 2) * Math.sin(lonDist / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    private static class ScoredCandidate {
        final Donor donor;
        final double totalScore;
        final double compatScore;
        final double distanceKm;
        final double reliabilityScore;

        ScoredCandidate(Donor donor, double totalScore, double compatScore, double distanceKm, double reliabilityScore) {
            this.donor = donor;
            this.totalScore = totalScore;
            this.compatScore = compatScore;
            this.distanceKm = distanceKm;
            this.reliabilityScore = reliabilityScore;
        }
    }
}

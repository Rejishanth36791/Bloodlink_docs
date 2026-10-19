package lk.bloodlink.service;

import jakarta.persistence.EntityNotFoundException;
import lk.bloodlink.dto.RequestDtos;
import lk.bloodlink.model.entity.*;
import lk.bloodlink.model.enums.*;
import lk.bloodlink.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class BloodRequestService {

    private final BloodRequestRepository bloodRequestRepository;
    private final RequestMatchRepository requestMatchRepository;
    private final DonorRepository donorRepository;
    private final BloodCompatibilityRepository compatibilityRepository;
    private final DonationRepository donationRepository;
    private final MatchingService matchingService;
    private final NotificationService notificationService;
    private final AuditLogService auditLogService;

    @Transactional
    public RequestDtos.RequestResponse createRequest(User requester, RequestDtos.CreateRequest req, String clientIp) {
        BloodRequest bloodRequest = BloodRequest.builder()
                .requester(requester)
                .patientName(req.getPatientName().trim())
                .relationship(req.getRelationship())
                .hospitalName(req.getHospitalName().trim())
                .ward(req.getWard())
                .bloodType(req.getBloodType())
                .component(req.getComponent() != null ? req.getComponent() : BloodComponent.WHOLE_BLOOD)
                .unitsRequired(req.getUnitsRequired())
                .unitsFulfilled(0)
                .urgency(req.getUrgency())
                .status(RequestStatus.CREATED)
                .neededBy(req.getNeededBy())
                .contactPhone(req.getContactPhone().trim())
                .notes(req.getNotes())
                .build();

        bloodRequest.setCoordinates(req.getLatitude(), req.getLongitude());
        bloodRequest = bloodRequestRepository.save(bloodRequest);

        auditLogService.log(requester, "CREATE_REQUEST", "BloodRequest", bloodRequest.getId().toString(), clientIp, null);

        // Run AI Matching immediately
        List<RequestMatch> matches = matchingService.matchAndNotify(bloodRequest, 40);

        return mapToResponse(bloodRequest, matches, requester);
    }

    public List<RequestDtos.RequestResponse> getMyRequests(User requester) {
        List<BloodRequest> list = bloodRequestRepository.findByRequesterIdOrderByCreatedAtDesc(requester.getId());
        return list.stream()
                .map(r -> {
                    List<RequestMatch> matches = requestMatchRepository.findByRequestIdOrderByScoreDesc(r.getId());
                    return mapToResponse(r, matches, requester);
                })
                .collect(Collectors.toList());
    }

    public RequestDtos.RequestResponse getRequestById(UUID id, User currentUser) {
        BloodRequest request = bloodRequestRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Blood request not found: " + id));
        List<RequestMatch> matches = requestMatchRepository.findByRequestIdOrderByScoreDesc(id);
        return mapToResponse(request, matches, currentUser);
    }

    @Transactional
    public void cancelRequest(UUID id, User requester) {
        BloodRequest request = bloodRequestRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Blood request not found: " + id));

        if (!request.getRequester().getId().equals(requester.getId()) && requester.getRole() != UserRole.ADMIN) {
            throw new AccessDeniedException("Not authorized to cancel this request.");
        }

        request.setStatus(RequestStatus.CANCELLED);
        bloodRequestRepository.save(request);
        auditLogService.log(requester, "CANCEL_REQUEST", "BloodRequest", id.toString(), null, null);
    }

    public List<RequestDtos.MatchResponse> getMatches(UUID requestId, User currentUser) {
        BloodRequest request = bloodRequestRepository.findById(requestId)
                .orElseThrow(() -> new EntityNotFoundException("Blood request not found: " + requestId));

        if (!currentUser.getId().equals(request.getRequester().getId()) && currentUser.getRole() != UserRole.ADMIN) {
            throw new org.springframework.security.access.AccessDeniedException("Not authorized to view matches for this request.");
        }

        List<RequestMatch> matches = requestMatchRepository.findByRequestIdOrderByScoreDesc(requestId);
        return matches.stream()
                .map(m -> mapToMatchResponse(m, currentUser))
                .collect(Collectors.toList());
    }

    @Transactional
    public void acceptMatch(UUID matchId, User donorUser, int etaMinutes) {
        RequestMatch match = requestMatchRepository.findById(matchId)
                .orElseThrow(() -> new EntityNotFoundException("Match alert not found: " + matchId));

        if (!match.getDonor().getUserId().equals(donorUser.getId())) {
            throw new AccessDeniedException("Not authorized to accept this match.");
        }

        if (match.getStatus() != MatchStatus.NOTIFIED) {
            throw new IllegalStateException("Match cannot be accepted; current status is: " + match.getStatus());
        }

        match.setStatus(MatchStatus.ACCEPTED);
        match.setEtaMinutes(etaMinutes);
        match.setRespondedAt(Instant.now());
        requestMatchRepository.save(match);

        BloodRequest request = match.getRequest();
        request.setStatus(RequestStatus.DONOR_ACCEPTED);
        bloodRequestRepository.save(request);

        // Create scheduled Donation entry
        Donation donation = Donation.builder()
                .donor(match.getDonor())
                .request(request)
                .component(request.getComponent())
                .status(DonationStatus.SCHEDULED)
                .build();
        donationRepository.save(donation);

        // Notify requester via STOMP + DB
        notificationService.sendToUser(
                request.getRequester(),
                "DONOR_ACCEPTED",
                "Donor Accepted Your Request!",
                donorUser.getFullName() + " accepted and is en route! Estimated arrival in " + etaMinutes + " minutes.",
                "{\"requestId\":\"" + request.getId() + "\",\"donorId\":\"" + donorUser.getId() + "\",\"etaMinutes\":" + etaMinutes + "}"
        );

        auditLogService.log(donorUser, "ACCEPT_MATCH", "RequestMatch", matchId.toString(), null, "{\"eta\":" + etaMinutes + "}");
    }

    @Transactional
    public void declineMatch(UUID matchId, User donorUser) {
        RequestMatch match = requestMatchRepository.findById(matchId)
                .orElseThrow(() -> new EntityNotFoundException("Match alert not found: " + matchId));

        if (!match.getDonor().getUserId().equals(donorUser.getId())) {
            throw new AccessDeniedException("Not authorized to decline this match.");
        }

        match.setStatus(MatchStatus.DECLINED);
        match.setRespondedAt(Instant.now());
        requestMatchRepository.save(match);
    }

    public List<RequestDtos.MatchResponse> getDonorAlerts(User donorUser) {
        List<RequestMatch> matches = requestMatchRepository.findByDonorUserIdAndStatus(donorUser.getId(), MatchStatus.NOTIFIED);
        return matches.stream()
                .map(m -> mapToMatchResponse(m, donorUser))
                .collect(Collectors.toList());
    }

    public List<RequestDtos.AppealDto> getNearbyAppeals(User donorUser, Double lat, Double lng, Double radiusKm) {
        Donor donor = donorRepository.findByUserId(donorUser.getId())
                .orElseThrow(() -> new EntityNotFoundException("Donor profile not found."));

        List<BloodType> compatibleTypes = compatibilityRepository.findCompatibleDonorTypes(donor.getBloodType());
        if (compatibleTypes.isEmpty()) {
            compatibleTypes = Collections.singletonList(donor.getBloodType());
        }

        List<BloodRequest> appeals = bloodRequestRepository.findAppealsByBloodTypes(compatibleTypes);
        double dLat = lat != null ? lat : (donor.getLatitude() != null ? donor.getLatitude() : 6.9271);
        double dLng = lng != null ? lng : (donor.getLongitude() != null ? donor.getLongitude() : 79.8612);

        return appeals.stream()
                .map(r -> {
                    double dist = 0.0;
                    if (r.getLatitude() != null && r.getLongitude() != null) {
                        dist = calculateHaversine(dLat, dLng, r.getLatitude(), r.getLongitude());
                    }
                    return RequestDtos.AppealDto.builder()
                            .id(r.getId())
                            .patientName(r.getPatientName())
                            .hospitalName(r.getHospitalName())
                            .ward(r.getWard())
                            .bloodType(r.getBloodType())
                            .component(r.getComponent())
                            .unitsRequired(r.getUnitsRequired())
                            .urgency(r.getUrgency())
                            .distanceKm(Math.round(dist * 10.0) / 10.0)
                            .neededBy(r.getNeededBy())
                            .contactPhone(r.getContactPhone())
                            .createdAt(r.getCreatedAt())
                            .build();
                })
                .sorted(Comparator.comparing(RequestDtos.AppealDto::getCreatedAt).reversed())
                .collect(Collectors.toList());
    }

    private RequestDtos.RequestResponse mapToResponse(BloodRequest r, List<RequestMatch> matches, User currentUser) {
        RequestDtos.MatchResponse acceptedMatch = null;
        for (RequestMatch m : matches) {
            if (m.getStatus() == MatchStatus.ACCEPTED || m.getStatus() == MatchStatus.ARRIVED || m.getStatus() == MatchStatus.DONATED) {
                acceptedMatch = mapToMatchResponse(m, currentUser);
                break;
            }
        }

        return RequestDtos.RequestResponse.builder()
                .id(r.getId())
                .requesterId(r.getRequester().getId())
                .requesterName(r.getRequester().getFullName())
                .patientName(r.getPatientName())
                .relationship(r.getRelationship())
                .hospitalName(r.getHospitalName())
                .ward(r.getWard())
                .hospitalLatitude(r.getLatitude())
                .hospitalLongitude(r.getLongitude())
                .bloodType(r.getBloodType())
                .component(r.getComponent())
                .unitsRequired(r.getUnitsRequired())
                .unitsFulfilled(r.getUnitsFulfilled())
                .urgency(r.getUrgency())
                .status(r.getStatus())
                .neededBy(r.getNeededBy())
                .contactPhone(r.getContactPhone())
                .notes(r.getNotes())
                .createdAt(r.getCreatedAt())
                .fulfilledAt(r.getFulfilledAt())
                .matchCount(matches.size())
                .acceptedDonor(acceptedMatch)
                .build();
    }

    private RequestDtos.MatchResponse mapToMatchResponse(RequestMatch m, User currentUser) {
        boolean isAccepted = (m.getStatus() == MatchStatus.ACCEPTED || m.getStatus() == MatchStatus.ARRIVED || m.getStatus() == MatchStatus.DONATED);
        boolean isDonorSelf = m.getDonor().getUserId().equals(currentUser.getId());
        boolean isAdmin = currentUser.getRole() == UserRole.ADMIN;

        // Privacy rule: Reveal phone and exact location ONLY after accepted or to donor themselves/admin
        String phone = (isAccepted || isDonorSelf || isAdmin) ? m.getDonor().getUser().getPhone() : null;

        Double lat = null;
        Double lng = null;
        if (m.getDonor().getLatitude() != null && m.getDonor().getLongitude() != null) {
            if (isAccepted || isDonorSelf || isAdmin) {
                lat = m.getDonor().getLatitude();
                lng = m.getDonor().getLongitude();
            } else {
                // Approximate coordinate (fuzzed by ~500m for privacy)
                lat = Math.round(m.getDonor().getLatitude() * 100.0) / 100.0;
                lng = Math.round(m.getDonor().getLongitude() * 100.0) / 100.0;
            }
        }

        return RequestDtos.MatchResponse.builder()
                .id(m.getId())
                .requestId(m.getRequest().getId())
                .donorId(m.getDonor().getUserId())
                .donorName(m.getDonor().getUser().getFullName())
                .donorPhone(phone)
                .bloodType(m.getDonor().getBloodType())
                .score(m.getScore())
                .compatScore(m.getCompatScore())
                .distanceKm(m.getDistanceKm())
                .reliabilityScore(m.getReliabilityScore())
                .status(m.getStatus())
                .etaMinutes(m.getEtaMinutes())
                .approximateLatitude(lat)
                .approximateLongitude(lng)
                .notifiedAt(m.getNotifiedAt())
                .respondedAt(m.getRespondedAt())
                .build();
    }

    private double calculateHaversine(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371;
        double latDist = Math.toRadians(lat2 - lat1);
        double lonDist = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDist / 2) * Math.sin(latDist / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDist / 2) * Math.sin(lonDist / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }
}

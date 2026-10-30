package lk.bloodlink.service;

import jakarta.persistence.EntityNotFoundException;
import lk.bloodlink.dto.BankDtos;
import lk.bloodlink.dto.ProfileDtos;
import lk.bloodlink.model.entity.*;
import lk.bloodlink.model.enums.*;
import lk.bloodlink.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;


@Slf4j
@Service
@RequiredArgsConstructor
public class BloodBankService {

    private final BloodBankRepository bloodBankRepository;
    private final InventoryRepository inventoryRepository;
    private final InventoryMovementRepository movementRepository;
    private final DonationRepository donationRepository;
    private final DonorRepository donorRepository;
    private final BloodRequestRepository bloodRequestRepository;
    private final DemandForecastRepository forecastRepository;
    private final NotificationService notificationService;
    private final AuditLogService auditLogService;

    public BankDtos.BankDashboard getDashboard(User bankUser) {
        BloodBank bank = bloodBankRepository.findByUserId(bankUser.getId())
                .orElseThrow(() -> new EntityNotFoundException("Blood bank profile not found for user."));

        List<Inventory> inventoryList = inventoryRepository.findByBankId(bank.getId());
        int totalUnits = inventoryList.stream().mapToInt(Inventory::getUnitsAvailable).sum();

        List<BankDtos.InventoryStock> matrix = new ArrayList<>();
        for (BloodType type : BloodType.values()) {
            Inventory inv = inventoryList.stream()
                    .filter(i -> i.getBloodType() == type && i.getComponent() == BloodComponent.WHOLE_BLOOD)
                    .findFirst()
                    .orElse(null);

            int units = inv != null ? inv.getUnitsAvailable() : 0;
            int threshold = inv != null ? inv.getReorderThreshold() : 10;
            boolean isLow = units < threshold;
            boolean isCritical = units <= (threshold / 2);

            matrix.add(BankDtos.InventoryStock.builder()
                    .bloodType(type)
                    .component(BloodComponent.WHOLE_BLOOD)
                    .unitsAvailable(units)
                    .reorderThreshold(threshold)
                    .isLow(isLow)
                    .isCritical(isCritical)
                    .build());
        }

        // Incoming donors
        List<Donation> scheduled = donationRepository.findByBankIdAndStatus(bank.getId(), DonationStatus.SCHEDULED);
        List<BankDtos.IncomingDonor> incoming = scheduled.stream().map(d -> {
            BloodRequest req = d.getRequest();
            return BankDtos.IncomingDonor.builder()
                    .donationId(d.getId())
                    .donorId(d.getDonor().getUserId())
                    .donorName(d.getDonor().getUser().getFullName())
                    .donorPhone(d.getDonor().getUser().getPhone())
                    .bloodType(d.getDonor().getBloodType())
                    .status(d.getStatus())
                    .scheduledAt(d.getCreatedAt())
                    .patientName(req != null ? req.getPatientName() : "General Drive")
                    .hospitalName(req != null ? req.getHospitalName() : bank.getInstitutionName())
                    .build();
        }).collect(Collectors.toList());

        // Forecasts
        List<DemandForecast> forecasts = forecastRepository.findByBankIdAndForecastDateGreaterThanEqualOrderByForecastDateAsc(
                bank.getId(), LocalDate.now());
        List<BankDtos.ForecastSummary> forecastSummaries = forecasts.stream().map(f -> {
            String trend = "STABLE";
            if (f.getLowerBound() != null && f.getPredictedUnits().compareTo(f.getLowerBound()) < 0) {
                trend = "DOWNWARD";
            }
            return BankDtos.ForecastSummary.builder()
                    .bloodType(f.getBloodType())
                    .district(f.getDistrict())
                    .predictedUnits(f.getPredictedUnits())
                    .lowerBound(f.getLowerBound())
                    .upperBound(f.getUpperBound())
                    .trend(trend)
                    .build();
        }).collect(Collectors.toList());

        int dailyTarget = 100;
        int quotaMet = (int) Math.min(100, Math.round(((double) totalUnits / dailyTarget) * 100));

        return BankDtos.BankDashboard.builder()
                .bankId(bank.getId())
                .institutionName(bank.getInstitutionName())
                .totalUnitsReady(totalUnits)
                .dailyTarget(dailyTarget)
                .dailyQuotaMetPercent(quotaMet)
                .activeDispatchesOut(incoming.size())
                .bloodMatrix(matrix)
                .incomingDonorsToday(incoming)
                .forecasts(forecastSummaries)
                .build();
    }

    @Transactional
    public void adjustInventory(User bankUser, BankDtos.InventoryAdjustment req) {
        BloodBank bank = bloodBankRepository.findByUserId(bankUser.getId())
                .orElseThrow(() -> new EntityNotFoundException("Blood bank profile not found for user."));

        Inventory inv = inventoryRepository.findByBankIdAndBloodTypeAndComponent(bank.getId(), req.getBloodType(), req.getComponent())
                .orElseGet(() -> Inventory.builder()
                        .bank(bank)
                        .bloodType(req.getBloodType())
                        .component(req.getComponent())
                        .unitsAvailable(0)
                        .reorderThreshold(10)
                        .build());

        int newUnits = inv.getUnitsAvailable() + req.getDelta();
        if (newUnits < 0) {
            throw new IllegalArgumentException("Inventory deduction cannot exceed available units (Current: " +
                    inv.getUnitsAvailable() + ", Deduct: " + Math.abs(req.getDelta()) + ").");
        }

        inv.setUnitsAvailable(newUnits);
        inv = inventoryRepository.save(inv);

        // Record ledger movement
        InventoryMovement movement = InventoryMovement.builder()
                .bank(bank)
                .bloodType(req.getBloodType())
                .component(req.getComponent())
                .delta(req.getDelta())
                .reason(req.getReason())
                .createdBy(bankUser)
                .build();
        movementRepository.save(movement);

        auditLogService.log(bankUser, "INVENTORY_ADJUST", "Inventory", inv.getId().toString(), null,
                "{\"bloodType\":\"" + req.getBloodType() + "\",\"delta\":" + req.getDelta() + ",\"reason\":\"" + req.getReason() + "\"}");

        // Broadcast STOMP dashboard update
        notificationService.broadcastToBankDashboard(bank.getId(), Map.of("event", "INVENTORY_UPDATED", "bloodType", req.getBloodType(), "units", newUnits));
    }

    @Transactional
    public void verifyDonation(User bankUser, UUID donationId, BankDtos.VerifyDonation req) {
        BloodBank bank = bloodBankRepository.findByUserId(bankUser.getId())
                .orElseThrow(() -> new EntityNotFoundException("Blood bank profile not found for user."));

        Donation donation = donationRepository.findById(donationId)
                .orElseThrow(() -> new EntityNotFoundException("Donation record not found: " + donationId));

        donation.setStatus(req.getStatus());
        donation.setVolumeMl(req.getVolumeMl());
        donation.setVerifiedBy(bankUser);
        donation.setDonatedAt(Instant.now());
        donation.setNotes(req.getNotes());
        donationRepository.save(donation);

        Donor donor = donation.getDonor();
        if (req.getStatus() == DonationStatus.COMPLETED) {
            // Update donor stats
            donor.setLastDonationDate(LocalDate.now());
            donor.setTotalDonations(donor.getTotalDonations() + 1);
            // Boost reliability score (+0.05 up to 1.0)
            BigDecimal currentRel = donor.getReliabilityScore() != null ? donor.getReliabilityScore() : new BigDecimal("0.500");
            BigDecimal newRel = currentRel.add(new BigDecimal("0.050")).min(BigDecimal.ONE);
            donor.setReliabilityScore(newRel);
            donorRepository.save(donor);

            // Update inventory
            BankDtos.InventoryAdjustment adj = new BankDtos.InventoryAdjustment();
            adj.setBloodType(donor.getBloodType());
            adj.setComponent(donation.getComponent() != null ? donation.getComponent() : BloodComponent.WHOLE_BLOOD);
            adj.setDelta(1);
            adj.setReason(MovementReason.DONATION);
            adj.setNotes("Donation collection verified for donor " + donor.getUser().getFullName());
            adjustInventory(bankUser, adj);

            // If linked to a request, fulfill units
            BloodRequest request = donation.getRequest();
            if (request != null) {
                request.setUnitsFulfilled(request.getUnitsFulfilled() + 1);
                if (request.getUnitsFulfilled() >= request.getUnitsRequired()) {
                    request.setStatus(RequestStatus.FULFILLED);
                    request.setFulfilledAt(Instant.now());
                }
                bloodRequestRepository.save(request);

                notificationService.sendToUser(
                        request.getRequester(),
                        "DONATION_VERIFIED",
                        "Units Received & Verified!",
                        "The hospital blood bank confirmed donor collection for patient " + request.getPatientName() + ".",
                        "{\"requestId\":\"" + request.getId() + "\"}"
                );
            }

            notificationService.sendToUser(
                    donor.getUser(),
                    "DONATION_COMPLETED",
                    "Thank You for Saving Lives!",
                    "Your blood donation was verified by " + bank.getInstitutionName() + ". Next eligible donation date: " + LocalDate.now().plusDays(112),
                    "{\"nextEligibleDate\":\"" + LocalDate.now().plusDays(112) + "\"}"
            );
        } else if (req.getStatus() == DonationStatus.NO_SHOW) {
            donor.setTotalNoShows(donor.getTotalNoShows() + 1);
            // Lower reliability score (-0.10 down to 0.0)
            BigDecimal currentRel = donor.getReliabilityScore() != null ? donor.getReliabilityScore() : new BigDecimal("0.500");
            BigDecimal newRel = currentRel.subtract(new BigDecimal("0.100")).max(BigDecimal.ZERO);
            donor.setReliabilityScore(newRel);
            donorRepository.save(donor);
        }

        auditLogService.log(bankUser, "VERIFY_DONATION", "Donation", donationId.toString(), null,
                "{\"status\":\"" + req.getStatus() + "\"}");
    }

    public List<ProfileDtos.BankDto> getNearbyBanks(Double lat, Double lng, Double radiusKm) {
        List<BloodBank> banks = bloodBankRepository.findByVerificationStatus(AccountStatus.ACTIVE);
        double dLat = lat != null ? lat : 6.9271;
        double dLng = lng != null ? lng : 79.8612;
        double maxRadius = radiusKm != null ? radiusKm : 50.0;

        return banks.stream()
                .filter(b -> b.getLatitude() == null || calculateHaversine(dLat, dLng, b.getLatitude(), b.getLongitude()) <= maxRadius)
                .map(b -> ProfileDtos.BankDto.builder()
                        .id(b.getId())
                        .institutionName(b.getInstitutionName())
                        .nbtsLicenseNo(b.getNbtsLicenseNo())
                        .hotline(b.getHotline())
                        .address(b.getAddress())
                        .district(b.getDistrict())
                        .latitude(b.getLatitude())
                        .longitude(b.getLongitude())
                        .directorName(b.getDirectorName())
                        .officialEmail(b.getOfficialEmail())
                        .is24h(b.is24h())
                        .verificationStatus(b.getVerificationStatus())
                        .build())
                .collect(Collectors.toList());
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

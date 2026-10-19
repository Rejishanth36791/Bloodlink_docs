package lk.bloodlink.service;

import jakarta.persistence.EntityNotFoundException;
import lk.bloodlink.dto.AdminDtos;
import lk.bloodlink.dto.ProfileDtos;
import lk.bloodlink.model.entity.*;
import lk.bloodlink.model.enums.*;
import lk.bloodlink.model.enums.BloodType;
import lk.bloodlink.model.enums.UserRole;
import lk.bloodlink.model.enums.RequestStatus;
import lk.bloodlink.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AdminService {

    private final BloodBankRepository bloodBankRepository;
    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final DonorRepository donorRepository;
    private final BloodRequestRepository bloodRequestRepository;
    private final DonationRepository donationRepository;
    private final AwarenessAlertRepository alertRepository;
    private final FraudFlagRepository flagRepository;
    private final NotificationService notificationService;
    private final AuditLogService auditLogService;

    public List<ProfileDtos.BankDto> getPendingBanks() {
        return bloodBankRepository.findByVerificationStatus(AccountStatus.PENDING).stream()
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

    @Transactional
    public void reviewBank(UUID bankId, User adminUser, AdminDtos.ApproveBank req) {
        BloodBank bank = bloodBankRepository.findById(bankId)
                .orElseThrow(() -> new EntityNotFoundException("Blood bank not found: " + bankId));

        User bankUser = bank.getUser();
        if (req.isApproved()) {
            bank.setVerificationStatus(AccountStatus.ACTIVE);
            bank.setVerifiedBy(adminUser);
            bank.setVerifiedAt(Instant.now());
            bank.setRejectionReason(null);
            bankUser.setStatus(AccountStatus.ACTIVE);

            notificationService.sendToUser(
                    bankUser,
                    "BANK_APPROVED",
                    "Institution Verified by National Blood Transfusion Service",
                    "Your blood bank portal is now active. You may now manage blood inventory, verify donations, and run mobile donation camps.",
                    "{}"
            );
        } else {
            bank.setVerificationStatus(AccountStatus.REJECTED);
            bank.setRejectionReason(req.getRejectionReason());
            bankUser.setStatus(AccountStatus.REJECTED);

            notificationService.sendToUser(
                    bankUser,
                    "BANK_REJECTED",
                    "Application Update: Registration Unsuccessful",
                    "Reason: " + (req.getRejectionReason() != null ? req.getRejectionReason() : "Documentation incomplete."),
                    "{}"
            );
        }

        bloodBankRepository.save(bank);
        userRepository.save(bankUser);

        auditLogService.log(adminUser, "REVIEW_BANK", "BloodBank", bankId.toString(), null,
                "{\"approved\":" + req.isApproved() + "}");
    }

    @Transactional
    public void suspendUser(UUID userId, User adminUser, AdminDtos.SuspendUser req) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found: " + userId));

        user.setStatus(AccountStatus.SUSPENDED);
        userRepository.save(user);

        // Revoke all active refresh tokens immediately
        refreshTokenRepository.deleteByUserId(userId);

        auditLogService.log(adminUser, "SUSPEND_USER", "User", userId.toString(), null,
                "{\"reason\":\"" + req.getReason() + "\"}");
    }

    @Transactional
    public AdminDtos.AwarenessAlertResponse createAwarenessAlert(User adminUser, AdminDtos.CreateAwarenessAlert req) {
        AwarenessAlert alert = AwarenessAlert.builder()
                .admin(adminUser)
                .title(req.getTitle().trim())
                .body(req.getBody().trim())
                .district(req.getDistrict())
                .bloodType(req.getBloodType())
                .build();
        alert = alertRepository.save(alert);

        auditLogService.log(adminUser, "CREATE_AWARENESS_ALERT", "AwarenessAlert", alert.getId().toString(), null, null);

        return AdminDtos.AwarenessAlertResponse.builder()
                .id(alert.getId())
                .title(alert.getTitle())
                .body(alert.getBody())
                .district(alert.getDistrict())
                .bloodType(alert.getBloodType())
                .createdAt(alert.getCreatedAt())
                .build();
    }

    public List<AdminDtos.AwarenessAlertResponse> getAwarenessAlerts() {
        return alertRepository.findAllByOrderByCreatedAtDesc().stream()
                .map(a -> AdminDtos.AwarenessAlertResponse.builder()
                        .id(a.getId())
                        .title(a.getTitle())
                        .body(a.getBody())
                        .district(a.getDistrict())
                        .bloodType(a.getBloodType())
                        .createdAt(a.getCreatedAt())
                        .build())
                .collect(Collectors.toList());
    }

    public List<AdminDtos.FraudFlagResponse> getFraudFlags() {
        return flagRepository.findAll().stream()
                .map(f -> AdminDtos.FraudFlagResponse.builder()
                        .id(f.getId())
                        .userId(f.getUser().getId())
                        .userName(f.getUser().getFullName())
                        .userRole(f.getUser().getRole().name())
                        .reason(f.getReason())
                        .status(f.getStatus())
                        .createdAt(f.getCreatedAt())
                        .build())
                .collect(Collectors.toList());
    }

    public AdminDtos.AdminAnalytics getAnalytics() {
        long donors = userRepository.countByRole(UserRole.DONOR);
        long requesters = userRepository.countByRole(UserRole.REQUESTER);
        long banks = userRepository.countByRole(UserRole.BLOOD_BANK);
        long totalReqs = bloodRequestRepository.count();
        long fulfilled = bloodRequestRepository.findByStatusOrderByCreatedAtDesc(RequestStatus.FULFILLED).size();
        long donations = donationRepository.count();

        Map<String, Long> bloodTypes = new HashMap<>();
        for (BloodType bt : BloodType.values()) {
            long c = donorRepository.findByBloodTypeAndIsAvailableTrue(bt).size();
            bloodTypes.put(bt.getValue(), c);
        }

        Map<String, Long> districts = new HashMap<>();
        districts.put("Colombo", (long) donorRepository.findByDistrictAndIsAvailableTrue("Colombo").size());
        districts.put("Gampaha", (long) donorRepository.findByDistrictAndIsAvailableTrue("Gampaha").size());
        districts.put("Kandy", (long) donorRepository.findByDistrictAndIsAvailableTrue("Kandy").size());

        return AdminDtos.AdminAnalytics.builder()
                .totalDonors(donors)
                .totalRequesters(requesters)
                .totalBanks(banks)
                .totalRequests(totalReqs)
                .fulfilledRequests(fulfilled)
                .totalDonations(donations)
                .bloodTypeDistribution(bloodTypes)
                .regionalDistribution(districts)
                .build();
    }
}

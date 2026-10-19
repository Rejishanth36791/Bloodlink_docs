package lk.bloodlink.dto;

import jakarta.validation.constraints.NotNull;
import lk.bloodlink.model.enums.AccountStatus;
import lk.bloodlink.model.enums.BloodType;
import lk.bloodlink.model.enums.UserRole;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public class ProfileDtos {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserProfile {
        private UUID id;
        private UserRole role;
        private String email;
        private String phone;
        private String fullName;
        private AccountStatus status;
        private boolean phoneVerified;
        private boolean emailVerified;
        private Instant createdAt;
        private DonorDto donorProfile;
        private RequesterDto requesterProfile;
        private BankDto bankProfile;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DonorDto {
        private BloodType bloodType;
        private LocalDate dateOfBirth;
        private String gender;
        private BigDecimal weightKg;
        private String district;
        private String city;
        private Double latitude;
        private Double longitude;
        private boolean isAvailable;
        private LocalDate lastDonationDate;
        private BigDecimal reliabilityScore;
        private int totalDonations;
        private int totalNoShows;
        private boolean consentHealthData;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RequesterDto {
        private String requesterType;
        private String district;
        private String city;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class BankDto {
        private UUID id;
        private String institutionName;
        private String nbtsLicenseNo;
        private String hotline;
        private String address;
        private String district;
        private Double latitude;
        private Double longitude;
        private String directorName;
        private String officialEmail;
        private boolean is24h;
        private AccountStatus verificationStatus;
        private String rejectionReason;
    }

    @Data
    public static class UpdateAvailability {
        private boolean isAvailable;
    }

    @Data
    public static class UpdateLocation {
        @NotNull(message = "Latitude is required")
        private Double latitude;

        @NotNull(message = "Longitude is required")
        private Double longitude;

        private String district;
        private String city;
    }

    @Data
    public static class RegisterDevice {
        @NotNull(message = "FCM token is required")
        private String fcmToken;

        @NotNull(message = "Platform is required (android/ios)")
        private String platform;
    }
}

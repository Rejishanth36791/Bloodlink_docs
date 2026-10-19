package lk.bloodlink.dto;

import jakarta.validation.constraints.*;
import lk.bloodlink.model.enums.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public class BankDtos {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class BankDashboard {
        private UUID bankId;
        private String institutionName;
        private int totalUnitsReady;
        private int dailyTarget;
        private int dailyQuotaMetPercent;
        private int activeDispatchesOut;
        private List<InventoryStock> bloodMatrix;
        private List<IncomingDonor> incomingDonorsToday;
        private List<ForecastSummary> forecasts;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class InventoryStock {
        private BloodType bloodType;
        private BloodComponent component;
        private int unitsAvailable;
        private int reorderThreshold;
        private boolean isLow;
        private boolean isCritical;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class IncomingDonor {
        private UUID donationId;
        private UUID matchId;
        private UUID donorId;
        private String donorName;
        private String donorPhone;
        private BloodType bloodType;
        private Integer etaMinutes;
        private DonationStatus status;
        private Instant scheduledAt;
        private String patientName;
        private String hospitalName;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ForecastSummary {
        private BloodType bloodType;
        private String district;
        private BigDecimal predictedUnits;
        private BigDecimal lowerBound;
        private BigDecimal upperBound;
        private String trend; // "DOWNWARD", "STABLE", "UPWARD"
    }

    @Data
    public static class InventoryAdjustment {
        @NotNull(message = "Blood type is required")
        private BloodType bloodType;

        @NotNull(message = "Blood component is required")
        private BloodComponent component;

        @NotNull(message = "Delta is required (positive or negative non-zero)")
        private Integer delta;

        @NotNull(message = "Movement reason is required")
        private MovementReason reason;

        private String notes;
    }

    @Data
    public static class VerifyDonation {
        @NotNull(message = "Volume in ml is required")
        @Min(value = 100, message = "Volume must be at least 100ml")
        @Max(value = 600, message = "Volume cannot exceed 600ml")
        private Integer volumeMl;

        @NotNull(message = "Donation status is required (COMPLETED/REJECTED)")
        private DonationStatus status;

        private String notes;
    }

    @Data
    public static class CreateCamp {
        @NotBlank(message = "Title is required")
        private String title;

        @NotBlank(message = "Venue is required")
        private String venue;

        @NotBlank(message = "District is required")
        private String district;

        @NotNull(message = "Latitude is required")
        private Double latitude;

        @NotNull(message = "Longitude is required")
        private Double longitude;

        @NotNull(message = "Start time is required")
        private Instant startsAt;

        @NotNull(message = "End time is required")
        private Instant endsAt;

        @Min(value = 1, message = "Target units must be positive")
        private Integer targetUnits;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CampDto {
        private UUID id;
        private UUID bankId;
        private String bankName;
        private String title;
        private String venue;
        private String district;
        private Double latitude;
        private Double longitude;
        private Instant startsAt;
        private Instant endsAt;
        private Integer targetUnits;
        private CampStatus status;
        private long registeredCount;
        private boolean isUserRegistered;
    }
}

package lk.bloodlink.dto;

import jakarta.validation.constraints.*;
import lk.bloodlink.model.enums.BloodType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public class AiDtos {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class EligibilityCheckRequest {
        @Min(value = 16, message = "Age must be at least 16")
        @Max(value = 100, message = "Age must be under 100")
        private int age;

        @NotBlank(message = "Gender is required")
        private String gender;

        @Positive(message = "Weight must be positive")
        private double weightKg;

        private LocalDate lastDonationDate;
        private boolean hasRecentFeverInfection;
        private boolean hasRecentMedications;
        private boolean hasRecentTravel;
        private boolean hasRecentTattooPiercing;
        private boolean isPregnantOrNursing;
        private Double hemoglobin;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class EligibilityResult {
        private boolean isEligible;
        private int readinessScore;
        private List<String> reasons;
        private LocalDate nextEligibleDate;
        private String modelVersion;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CandidateInput {
        private String donorId;
        private String bloodType;
        private double distanceKm;
        private double reliabilityScore;
        private boolean exactMatch;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RankedCandidate {
        private String donorId;
        private String bloodType;
        private double distanceKm;
        private double reliabilityScore;
        private double compatScore;
        private double finalScore;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RankRequest {
        private String targetBloodType;
        @Builder.Default
        private double maxRadiusKm = 40.0;
        @Builder.Default
        private double weightCompat = 0.5;
        @Builder.Default
        private double weightProximity = 0.3;
        @Builder.Default
        private double weightReliability = 0.2;
        private List<CandidateInput> candidates;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DemandDataPoint {
        private LocalDate day;
        private int unitsRequested;
        private int unitsFulfilled;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ForecastPoint {
        private LocalDate forecastDate;
        private BigDecimal predictedUnits;
        private BigDecimal lowerBound;
        private BigDecimal upperBound;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ForecastRequest {
        private String district;
        private BloodType bloodType;
        private List<DemandDataPoint> history;
        @Builder.Default
        private int forecastDays = 7;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ForecastResponse {
        private String district;
        private BloodType bloodType;
        private String status; // "SUCCESS" or "INSUFFICIENT_DATA"
        private String message;
        private String modelVersion;
        private List<ForecastPoint> forecasts;
    }
}


package lk.bloodlink.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

public class AiDtos {

    @Data
    public static class EligibilityCheckRequest {
        private int age;
        private String gender;
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
}

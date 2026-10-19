package lk.bloodlink.dto;

import jakarta.validation.constraints.NotBlank;
import lk.bloodlink.model.enums.BloodType;
import lk.bloodlink.model.enums.FlagStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

public class AdminDtos {

    @Data
    public static class ApproveBank {
        private boolean approved;
        private String rejectionReason;
    }

    @Data
    public static class SuspendUser {
        @NotBlank(message = "Reason for suspension is required")
        private String reason;
    }

    @Data
    public static class CreateAwarenessAlert {
        @NotBlank(message = "Title is required")
        private String title;

        @NotBlank(message = "Body is required")
        private String body;

        private String district;
        private BloodType bloodType;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AwarenessAlertResponse {
        private UUID id;
        private String title;
        private String body;
        private String district;
        private BloodType bloodType;
        private Instant createdAt;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class FraudFlagResponse {
        private UUID id;
        private UUID userId;
        private String userName;
        private String userRole;
        private String reason;
        private FlagStatus status;
        private Instant createdAt;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AdminAnalytics {
        private long totalDonors;
        private long totalRequesters;
        private long totalBanks;
        private long totalRequests;
        private long fulfilledRequests;
        private long totalDonations;
        private Map<String, Long> bloodTypeDistribution;
        private Map<String, Long> regionalDistribution;
    }
}

package lk.bloodlink.dto;

import jakarta.validation.constraints.*;
import lk.bloodlink.model.enums.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public class RequestDtos {

    @Data
    public static class CreateRequest {
        @NotBlank(message = "Patient name is required")
        private String patientName;

        private String relationship;

        @NotBlank(message = "Hospital name is required")
        private String hospitalName;

        private String ward;

        @NotNull(message = "Hospital latitude is required")
        private Double latitude;

        @NotNull(message = "Hospital longitude is required")
        private Double longitude;

        @NotNull(message = "Blood type is required")
        private BloodType bloodType;

        private BloodComponent component = BloodComponent.WHOLE_BLOOD;

        @Min(value = 1, message = "At least 1 unit required")
        @Max(value = 20, message = "Maximum 20 units per request")
        private int unitsRequired;

        @NotNull(message = "Urgency level is required")
        private UrgencyLevel urgency;

        @NotNull(message = "Needed by time is required")
        private Instant neededBy;

        @NotBlank(message = "Contact phone is required")
        private String contactPhone;

        private String notes;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RequestResponse {
        private UUID id;
        private UUID requesterId;
        private String requesterName;
        private String patientName;
        private String relationship;
        private String hospitalName;
        private String ward;
        private Double hospitalLatitude;
        private Double hospitalLongitude;
        private BloodType bloodType;
        private BloodComponent component;
        private int unitsRequired;
        private int unitsFulfilled;
        private UrgencyLevel urgency;
        private RequestStatus status;
        private Instant neededBy;
        private String contactPhone;
        private String notes;
        private Instant createdAt;
        private Instant fulfilledAt;
        private int matchCount;
        private MatchResponse acceptedDonor;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MatchResponse {
        private UUID id;
        private UUID requestId;
        private UUID donorId;
        private String donorName;
        private String donorPhone; // only revealed once ACCEPTED
        private BloodType bloodType;
        private BigDecimal score;
        private BigDecimal compatScore;
        private BigDecimal distanceKm;
        private BigDecimal reliabilityScore;
        private MatchStatus status;
        private Integer etaMinutes;
        private Double approximateLatitude; // exact hidden until accepted
        private Double approximateLongitude;
        private Instant notifiedAt;
        private Instant respondedAt;
    }

    @Data
    public static class AcceptMatch {
        @Min(value = 5, message = "ETA must be at least 5 minutes")
        @Max(value = 360, message = "ETA cannot exceed 6 hours")
        private int etaMinutes;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AppealDto {
        private UUID id;
        private String patientName;
        private String hospitalName;
        private String ward;
        private BloodType bloodType;
        private BloodComponent component;
        private int unitsRequired;
        private UrgencyLevel urgency;
        private Double distanceKm;
        private Instant neededBy;
        private String contactPhone;
        private Instant createdAt;
    }
}

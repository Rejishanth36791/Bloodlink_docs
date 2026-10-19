package lk.bloodlink.model.entity;

import jakarta.persistence.*;
import lk.bloodlink.model.enums.MatchStatus;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "request_matches", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"request_id", "donor_id"})
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RequestMatch {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "request_id", nullable = false)
    private BloodRequest request;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "donor_id", nullable = false)
    private Donor donor;

    @Column(precision = 5, scale = 4, nullable = false)
    private BigDecimal score;

    @Column(name = "compat_score", precision = 5, scale = 4, nullable = false)
    private BigDecimal compatScore;

    @Column(name = "distance_km", precision = 7, scale = 2, nullable = false)
    private BigDecimal distanceKm;

    @Column(name = "reliability_score", precision = 4, scale = 3, nullable = false)
    private BigDecimal reliabilityScore;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private MatchStatus status = MatchStatus.NOTIFIED;

    @Column(name = "eta_minutes")
    private Integer etaMinutes;

    @CreationTimestamp
    @Column(name = "notified_at", nullable = false, updatable = false)
    private Instant notifiedAt;

    @Column(name = "responded_at")
    private Instant respondedAt;
}

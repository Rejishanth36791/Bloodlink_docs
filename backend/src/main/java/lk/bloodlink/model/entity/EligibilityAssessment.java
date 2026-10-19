package lk.bloodlink.model.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "eligibility_assessments")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EligibilityAssessment {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "donor_id", nullable = false)
    private Donor donor;

    @Column(name = "answers", columnDefinition = "jsonb", nullable = false)
    private String answers;

    @Column(name = "is_eligible", nullable = false)
    private boolean isEligible;

    @Column(name = "readiness_score", nullable = false)
    private short readinessScore;

    @Column(name = "reasons", columnDefinition = "jsonb", nullable = false)
    private String reasons;

    @Column(name = "next_eligible_date")
    private LocalDate nextEligibleDate;

    @Column(name = "model_version", nullable = false)
    private String modelVersion;

    @CreationTimestamp
    @Column(name = "assessed_at", nullable = false, updatable = false)
    private Instant assessedAt;
}

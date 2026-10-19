package lk.bloodlink.model.entity;

import jakarta.persistence.*;
import lk.bloodlink.model.enums.BloodComponent;
import lk.bloodlink.model.enums.DonationStatus;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "donations")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Donation {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "donor_id", nullable = false)
    private Donor donor;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "request_id")
    private BloodRequest request;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bank_id")
    private BloodBank bank;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "camp_id")
    private DonationCamp camp;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private BloodComponent component = BloodComponent.WHOLE_BLOOD;

    @Column(name = "volume_ml")
    private Integer volumeMl;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private DonationStatus status = DonationStatus.SCHEDULED;

    @Column(name = "donated_at")
    private Instant donatedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "verified_by")
    private User verifiedBy;

    private String notes;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}

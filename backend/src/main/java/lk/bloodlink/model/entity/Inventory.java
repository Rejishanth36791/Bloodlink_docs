package lk.bloodlink.model.entity;

import jakarta.persistence.*;
import lk.bloodlink.model.enums.BloodComponent;
import lk.bloodlink.model.enums.BloodType;
import lombok.*;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "inventory", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"bank_id", "blood_type", "component"})
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Inventory {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "bank_id", nullable = false)
    private BloodBank bank;

    @org.hibernate.annotations.Type(BloodTypeUserType.class)
    @Column(name = "blood_type", nullable = false)
    private BloodType bloodType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private BloodComponent component = BloodComponent.WHOLE_BLOOD;

    @Column(name = "units_available", nullable = false)
    @Builder.Default
    private int unitsAvailable = 0;

    @Column(name = "reorder_threshold", nullable = false)
    @Builder.Default
    private int reorderThreshold = 10;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}

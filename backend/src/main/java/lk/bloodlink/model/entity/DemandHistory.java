package lk.bloodlink.model.entity;

import jakarta.persistence.*;
import lk.bloodlink.model.enums.BloodType;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "demand_history", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"district", "blood_type", "\"day\""})
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class DemandHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String district;

    @org.hibernate.annotations.Type(BloodTypeUserType.class)
    @Column(name = "blood_type", nullable = false)
    private BloodType bloodType;

    @Column(name = "\"day\"", nullable = false)
    private LocalDate day;

    @Column(name = "units_requested", nullable = false)
    private int unitsRequested;

    @Column(name = "units_fulfilled", nullable = false)
    private int unitsFulfilled;
}

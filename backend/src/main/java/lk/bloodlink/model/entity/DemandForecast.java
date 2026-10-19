package lk.bloodlink.model.entity;

import jakarta.persistence.*;
import lk.bloodlink.model.enums.BloodType;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;

@Entity
@Table(name = "demand_forecasts", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"bank_id", "district", "blood_type", "forecast_date", "model_version"})
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DemandForecast {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bank_id")
    private BloodBank bank;

    @Column(nullable = false)
    private String district;

    @org.hibernate.annotations.Type(BloodTypeUserType.class)
    @Column(name = "blood_type", nullable = false)
    private BloodType bloodType;

    @Column(name = "forecast_date", nullable = false)
    private LocalDate forecastDate;

    @Column(name = "predicted_units", precision = 8, scale = 2, nullable = false)
    private BigDecimal predictedUnits;

    @Column(name = "lower_bound", precision = 8, scale = 2)
    private BigDecimal lowerBound;

    @Column(name = "upper_bound", precision = 8, scale = 2)
    private BigDecimal upperBound;

    @Column(name = "model_version", nullable = false)
    private String modelVersion;

    @CreationTimestamp
    @Column(name = "generated_at", nullable = false, updatable = false)
    private Instant generatedAt;
}

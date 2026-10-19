package lk.bloodlink.model.entity;

import jakarta.persistence.*;
import lk.bloodlink.model.enums.BloodType;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.locationtech.jts.geom.PrecisionModel;

import java.math.BigDecimal;
import java.time.Instant;
import org.springframework.data.domain.Persistable;

import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "donors")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Donor implements Persistable<UUID> {

    @Id
    @Column(name = "user_id")
    private UUID userId;

    @Transient
    @Builder.Default
    private boolean isNewRecord = true;

    @Override
    public UUID getId() {
        return userId;
    }

    @Override
    public boolean isNew() {
        return isNewRecord || createdAt == null;
    }

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private User user;

    @org.hibernate.annotations.Type(BloodTypeUserType.class)
    @Column(name = "blood_type", nullable = false)
    private BloodType bloodType;

    @Column(name = "date_of_birth", nullable = false)
    private LocalDate dateOfBirth;

    private String gender;

    @Column(name = "weight_kg", precision = 5, scale = 2)
    private BigDecimal weightKg;

    @Column(nullable = false)
    private String district;

    @Column(nullable = false)
    private String city;

    @Column(name = "location", columnDefinition = "geography")
    private Point location;

    @Column(name = "is_available", nullable = false)
    @Builder.Default
    private boolean isAvailable = true;

    @Column(name = "last_donation_date")
    private LocalDate lastDonationDate;

    @Column(name = "reliability_score", precision = 4, scale = 3, nullable = false)
    @Builder.Default
    private BigDecimal reliabilityScore = new BigDecimal("0.500");

    @Column(name = "total_donations", nullable = false)
    @Builder.Default
    private int totalDonations = 0;

    @Column(name = "total_no_shows", nullable = false)
    @Builder.Default
    private int totalNoShows = 0;

    @Column(name = "consent_health_data", nullable = false)
    @Builder.Default
    private boolean consentHealthData = false;

    @Column(name = "consent_at")
    private Instant consentAt;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    public Double getLatitude() {
        return location != null ? location.getY() : null;
    }

    public Double getLongitude() {
        return location != null ? location.getX() : null;
    }

    public void setCoordinates(double latitude, double longitude) {
        GeometryFactory gf = new GeometryFactory(new PrecisionModel(), 4326);
        this.location = gf.createPoint(new Coordinate(longitude, latitude));
    }
}

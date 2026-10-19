package lk.bloodlink.model.entity;

import jakarta.persistence.*;
import lk.bloodlink.model.enums.AccountStatus;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.Type;
import org.hibernate.annotations.UpdateTimestamp;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.locationtech.jts.geom.PrecisionModel;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "blood_banks")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BloodBank {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "institution_name", nullable = false)
    private String institutionName;

    @Column(name = "nbts_license_no", nullable = false, unique = true)
    private String nbtsLicenseNo;

    @Column(nullable = false)
    private String hotline;

    @Column(nullable = false)
    private String address;

    @Column(nullable = false)
    private String district;

    @Column(name = "location", columnDefinition = "geography", nullable = false)
    private Point location;

    @Column(name = "director_name")
    private String directorName;

    @Column(name = "official_email", columnDefinition = "citext")
    @Type(CitextType.class)
    private String officialEmail;

    @Column(name = "is_24h", nullable = false)
    @Builder.Default
    private boolean is24h = false;

    @Enumerated(EnumType.STRING)
    @Column(name = "verification_status", nullable = false)
    @Builder.Default
    private AccountStatus verificationStatus = AccountStatus.PENDING;

    @Column(name = "rejection_reason")
    private String rejectionReason;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "verified_by")
    private User verifiedBy;

    @Column(name = "verified_at")
    private Instant verifiedAt;

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

package lk.bloodlink.model.entity;

import jakarta.persistence.*;
import lk.bloodlink.model.enums.BloodComponent;
import lk.bloodlink.model.enums.BloodType;
import lk.bloodlink.model.enums.RequestStatus;
import lk.bloodlink.model.enums.UrgencyLevel;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.locationtech.jts.geom.PrecisionModel;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "blood_requests")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BloodRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "requester_id", nullable = false)
    private User requester;

    @Column(name = "patient_name", nullable = false)
    private String patientName;

    private String relationship;

    @Column(name = "hospital_name", nullable = false)
    private String hospitalName;

    private String ward;

    @Column(name = "hospital_location", columnDefinition = "geography", nullable = false)
    private Point hospitalLocation;

    @org.hibernate.annotations.Type(BloodTypeUserType.class)
    @Column(name = "blood_type", nullable = false)
    private BloodType bloodType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private BloodComponent component = BloodComponent.WHOLE_BLOOD;

    @Column(name = "units_required", nullable = false)
    private int unitsRequired;

    @Column(name = "units_fulfilled", nullable = false)
    @Builder.Default
    private int unitsFulfilled = 0;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UrgencyLevel urgency;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private RequestStatus status = RequestStatus.CREATED;

    @Column(name = "needed_by", nullable = false)
    private Instant neededBy;

    @Column(name = "contact_phone", nullable = false)
    private String contactPhone;

    private String notes;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assigned_bank_id")
    private BloodBank assignedBank;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @Column(name = "fulfilled_at")
    private Instant fulfilledAt;

    public Double getLatitude() {
        return hospitalLocation != null ? hospitalLocation.getY() : null;
    }

    public Double getLongitude() {
        return hospitalLocation != null ? hospitalLocation.getX() : null;
    }

    public void setCoordinates(double latitude, double longitude) {
        GeometryFactory gf = new GeometryFactory(new PrecisionModel(), 4326);
        this.hospitalLocation = gf.createPoint(new Coordinate(longitude, latitude));
    }
}

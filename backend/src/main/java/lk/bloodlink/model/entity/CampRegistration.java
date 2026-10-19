package lk.bloodlink.model.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.io.Serializable;
import java.time.Instant;
import java.util.Objects;
import java.util.UUID;

@Entity
@Table(name = "camp_registrations")
@IdClass(CampRegistration.CampRegistrationId.class)
public class CampRegistration {

    @Id
    @Column(name = "camp_id")
    private UUID campId;

    @Id
    @Column(name = "donor_id")
    private UUID donorId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "camp_id", insertable = false, updatable = false)
    private DonationCamp camp;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "donor_id", insertable = false, updatable = false)
    private Donor donor;

    @CreationTimestamp
    @Column(name = "registered_at", nullable = false, updatable = false)
    private Instant registeredAt;

    private Boolean attended;

    public CampRegistration() {
    }

    public CampRegistration(UUID campId, UUID donorId, DonationCamp camp, Donor donor, Instant registeredAt, Boolean attended) {
        this.campId = campId;
        this.donorId = donorId;
        this.camp = camp;
        this.donor = donor;
        this.registeredAt = registeredAt;
        this.attended = attended;
    }

    public static CampRegistrationBuilder builder() {
        return new CampRegistrationBuilder();
    }

    public UUID getCampId() { return campId; }
    public void setCampId(UUID campId) { this.campId = campId; }

    public UUID getDonorId() { return donorId; }
    public void setDonorId(UUID donorId) { this.donorId = donorId; }

    public DonationCamp getCamp() { return camp; }
    public void setCamp(DonationCamp camp) { this.camp = camp; }

    public Donor getDonor() { return donor; }
    public void setDonor(Donor donor) { this.donor = donor; }

    public Instant getRegisteredAt() { return registeredAt; }
    public void setRegisteredAt(Instant registeredAt) { this.registeredAt = registeredAt; }

    public Boolean getAttended() { return attended; }
    public void setAttended(Boolean attended) { this.attended = attended; }

    public static class CampRegistrationBuilder {
        private UUID campId;
        private UUID donorId;
        private DonationCamp camp;
        private Donor donor;
        private Instant registeredAt;
        private Boolean attended;

        public CampRegistrationBuilder campId(UUID campId) { this.campId = campId; return this; }
        public CampRegistrationBuilder donorId(UUID donorId) { this.donorId = donorId; return this; }
        public CampRegistrationBuilder camp(DonationCamp camp) { this.camp = camp; return this; }
        public CampRegistrationBuilder donor(Donor donor) { this.donor = donor; return this; }
        public CampRegistrationBuilder registeredAt(Instant registeredAt) { this.registeredAt = registeredAt; return this; }
        public CampRegistrationBuilder attended(Boolean attended) { this.attended = attended; return this; }

        public CampRegistration build() {
            return new CampRegistration(campId, donorId, camp, donor, registeredAt, attended);
        }
    }

    public static class CampRegistrationId implements Serializable {
        private UUID campId;
        private UUID donorId;

        public CampRegistrationId() {
        }

        public CampRegistrationId(UUID campId, UUID donorId) {
            this.campId = campId;
            this.donorId = donorId;
        }

        public UUID getCampId() { return campId; }
        public void setCampId(UUID campId) { this.campId = campId; }

        public UUID getDonorId() { return donorId; }
        public void setDonorId(UUID donorId) { this.donorId = donorId; }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            CampRegistrationId that = (CampRegistrationId) o;
            return Objects.equals(campId, that.campId) && Objects.equals(donorId, that.donorId);
        }

        @Override
        public int hashCode() {
            return Objects.hash(campId, donorId);
        }
    }
}

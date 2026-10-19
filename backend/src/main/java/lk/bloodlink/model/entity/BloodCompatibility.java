package lk.bloodlink.model.entity;

import jakarta.persistence.*;
import lk.bloodlink.model.enums.BloodType;

import java.io.Serializable;
import java.util.Objects;

@Entity
@Table(name = "blood_compatibility")
@IdClass(BloodCompatibility.BloodCompatibilityId.class)
public class BloodCompatibility {

    @Id
    @org.hibernate.annotations.Type(BloodTypeUserType.class)
    @Column(name = "donor_type", nullable = false)
    private BloodType donorType;

    @Id
    @org.hibernate.annotations.Type(BloodTypeUserType.class)
    @Column(name = "recipient_type", nullable = false)
    private BloodType recipientType;

    public BloodCompatibility() {
    }

    public BloodCompatibility(BloodType donorType, BloodType recipientType) {
        this.donorType = donorType;
        this.recipientType = recipientType;
    }

    public BloodType getDonorType() { return donorType; }
    public void setDonorType(BloodType donorType) { this.donorType = donorType; }

    public BloodType getRecipientType() { return recipientType; }
    public void setRecipientType(BloodType recipientType) { this.recipientType = recipientType; }

    public static class BloodCompatibilityId implements Serializable {
        @org.hibernate.annotations.Type(BloodTypeUserType.class)
        private BloodType donorType;

        @org.hibernate.annotations.Type(BloodTypeUserType.class)
        private BloodType recipientType;

        public BloodCompatibilityId() {
        }

        public BloodCompatibilityId(BloodType donorType, BloodType recipientType) {
            this.donorType = donorType;
            this.recipientType = recipientType;
        }

        public BloodType getDonorType() { return donorType; }
        public void setDonorType(BloodType donorType) { this.donorType = donorType; }

        public BloodType getRecipientType() { return recipientType; }
        public void setRecipientType(BloodType recipientType) { this.recipientType = recipientType; }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            BloodCompatibilityId that = (BloodCompatibilityId) o;
            return donorType == that.donorType && recipientType == that.recipientType;
        }

        @Override
        public int hashCode() {
            return Objects.hash(donorType, recipientType);
        }
    }
}

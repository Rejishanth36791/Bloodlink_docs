package lk.bloodlink.repository;

import lk.bloodlink.model.entity.BloodCompatibility;
import lk.bloodlink.model.enums.BloodType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BloodCompatibilityRepository extends JpaRepository<BloodCompatibility, BloodCompatibility.BloodCompatibilityId> {
    List<BloodCompatibility> findByRecipientType(BloodType recipientType);

    @Query("SELECT bc.donorType FROM BloodCompatibility bc WHERE bc.recipientType = :recipientType")
    List<BloodType> findCompatibleDonorTypes(@Param("recipientType") BloodType recipientType);

    boolean existsByDonorTypeAndRecipientType(BloodType donorType, BloodType recipientType);
}

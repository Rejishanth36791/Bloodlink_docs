package lk.bloodlink.repository;

import lk.bloodlink.model.entity.Donor;
import lk.bloodlink.model.enums.BloodType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface DonorRepository extends JpaRepository<Donor, UUID> {
    Optional<Donor> findByUserId(UUID userId);
    List<Donor> findByBloodTypeAndIsAvailableTrue(BloodType bloodType);
    List<Donor> findByDistrictAndIsAvailableTrue(String district);

    @Query(value = "SELECT d.user_id FROM donors d " +
            "JOIN users u ON u.id = d.user_id " +
            "WHERE u.status = 'ACTIVE' AND d.is_available = true " +
            "AND (:bloodType IS NULL OR d.blood_type = :bloodType) " +
            "AND (:lastDonationBefore IS NULL OR d.last_donation_date IS NULL OR d.last_donation_date <= :lastDonationBefore)",
            nativeQuery = true)
    List<UUID> findEligibleDonorIds(@Param("bloodType") String bloodType,
                                   @Param("lastDonationBefore") LocalDate lastDonationBefore);

    @Query(value = "SELECT donor_id, blood_type, distance_km, reliability_score, exact_match " +
            "FROM find_candidate_donors(:requestId, :radiusKm, :cooldownDays)",
            nativeQuery = true)
    List<Object[]> findCandidateDonorsRaw(@Param("requestId") UUID requestId,
                                         @Param("radiusKm") int radiusKm,
                                         @Param("cooldownDays") int cooldownDays);
}

package lk.bloodlink.repository;

import lk.bloodlink.model.entity.BloodBank;
import lk.bloodlink.model.enums.AccountStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface BloodBankRepository extends JpaRepository<BloodBank, UUID> {
    Optional<BloodBank> findByUserId(UUID userId);
    List<BloodBank> findByVerificationStatus(AccountStatus status);
    boolean existsByNbtsLicenseNo(String nbtsLicenseNo);

    @Query(value = "SELECT b.* FROM blood_banks b " +
            "WHERE b.verification_status = 'ACTIVE' " +
            "AND ST_DWithin(b.location, ST_SetSRID(ST_Point(:lng, :lat), 4326)::geography, :radiusMeters)",
            nativeQuery = true)
    List<BloodBank> findNearbyActiveBanks(@Param("lat") double lat,
                                         @Param("lng") double lng,
                                         @Param("radiusMeters") double radiusMeters);
}

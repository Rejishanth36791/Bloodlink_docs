package lk.bloodlink.repository;

import lk.bloodlink.model.entity.DonationCamp;
import lk.bloodlink.model.enums.CampStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface DonationCampRepository extends JpaRepository<DonationCamp, UUID> {
    List<DonationCamp> findByBankIdOrderByStartsAtDesc(UUID bankId);
    List<DonationCamp> findByStatusOrderByStartsAtAsc(CampStatus status);

    @Query(value = "SELECT c.* FROM donation_camps c " +
            "WHERE c.status IN ('UPCOMING', 'ONGOING') " +
            "AND ST_DWithin(c.location, ST_SetSRID(ST_Point(:lng, :lat), 4326)::geography, :radiusMeters) " +
            "ORDER BY c.starts_at ASC",
            nativeQuery = true)
    List<DonationCamp> findNearbyActiveCamps(@Param("lat") double lat,
                                            @Param("lng") double lng,
                                            @Param("radiusMeters") double radiusMeters);
}

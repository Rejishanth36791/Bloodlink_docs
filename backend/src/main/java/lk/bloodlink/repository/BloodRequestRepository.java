package lk.bloodlink.repository;

import lk.bloodlink.model.entity.BloodRequest;
import lk.bloodlink.model.enums.BloodType;
import lk.bloodlink.model.enums.RequestStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface BloodRequestRepository extends JpaRepository<BloodRequest, UUID> {
    List<BloodRequest> findByRequesterIdOrderByCreatedAtDesc(UUID requesterId);
    List<BloodRequest> findByStatusOrderByCreatedAtDesc(RequestStatus status);
    List<BloodRequest> findByStatusInOrderByCreatedAtDesc(List<RequestStatus> statuses);

    @Query(value = "SELECT r.* FROM blood_requests r " +
            "JOIN blood_compatibility bc ON bc.recipient_type = r.blood_type " +
            "WHERE r.status IN ('CREATED', 'MATCHING') " +
            "AND bc.donor_type = :donorBloodType " +
            "AND ST_DWithin(r.hospital_location, ST_SetSRID(ST_Point(:lng, :lat), 4326)::geography, :radiusMeters) " +
            "ORDER BY r.created_at DESC",
            nativeQuery = true)
    List<BloodRequest> findCompatibleAppealsNearby(@Param("donorBloodType") String donorBloodType,
                                                  @Param("lat") double lat,
                                                  @Param("lng") double lng,
                                                  @Param("radiusMeters") double radiusMeters);

    @Query("SELECT r FROM BloodRequest r WHERE r.status IN ('CREATED', 'MATCHING') AND r.bloodType IN :compatibleTypes ORDER BY r.createdAt DESC")
    List<BloodRequest> findAppealsByBloodTypes(@Param("compatibleTypes") List<BloodType> compatibleTypes);
}

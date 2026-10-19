package lk.bloodlink.repository;

import lk.bloodlink.model.entity.CampRegistration;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface CampRegistrationRepository extends JpaRepository<CampRegistration, CampRegistration.CampRegistrationId> {
    List<CampRegistration> findByCampId(UUID campId);
    List<CampRegistration> findByDonorUserId(UUID donorId);
    long countByCampId(UUID campId);
    Optional<CampRegistration> findByCampIdAndDonorUserId(UUID campId, UUID donorId);
}

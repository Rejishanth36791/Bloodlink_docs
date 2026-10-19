package lk.bloodlink.repository;

import lk.bloodlink.model.entity.EligibilityAssessment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface EligibilityAssessmentRepository extends JpaRepository<EligibilityAssessment, UUID> {
    List<EligibilityAssessment> findByDonorUserIdOrderByAssessedAtDesc(UUID donorId);
    Optional<EligibilityAssessment> findFirstByDonorUserIdOrderByAssessedAtDesc(UUID donorId);
}

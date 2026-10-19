package lk.bloodlink.repository;

import lk.bloodlink.model.entity.AwarenessAlert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface AwarenessAlertRepository extends JpaRepository<AwarenessAlert, UUID> {
    List<AwarenessAlert> findAllByOrderByCreatedAtDesc();
    List<AwarenessAlert> findByDistrictOrDistrictIsNullOrderByCreatedAtDesc(String district);
}

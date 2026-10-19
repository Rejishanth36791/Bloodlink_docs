package lk.bloodlink.repository;

import lk.bloodlink.model.entity.FraudFlag;
import lk.bloodlink.model.enums.FlagStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface FraudFlagRepository extends JpaRepository<FraudFlag, UUID> {
    List<FraudFlag> findByStatusOrderByCreatedAtDesc(FlagStatus status);
    List<FraudFlag> findByUserIdOrderByCreatedAtDesc(UUID userId);
}

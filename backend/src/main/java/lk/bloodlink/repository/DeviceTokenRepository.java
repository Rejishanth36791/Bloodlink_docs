package lk.bloodlink.repository;

import lk.bloodlink.model.entity.DeviceToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface DeviceTokenRepository extends JpaRepository<DeviceToken, UUID> {
    Optional<DeviceToken> findByFcmToken(String fcmToken);
    List<DeviceToken> findByUserId(UUID userId);
    List<DeviceToken> findByUserIdIn(List<UUID> userIds);
    void deleteByFcmToken(String fcmToken);
}

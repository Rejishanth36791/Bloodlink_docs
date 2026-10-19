package lk.bloodlink.service;

import lk.bloodlink.model.entity.DeviceToken;
import lk.bloodlink.model.entity.Notification;
import lk.bloodlink.model.entity.User;
import lk.bloodlink.repository.DeviceTokenRepository;
import lk.bloodlink.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationService {

    private final SimpMessagingTemplate messagingTemplate;
    private final NotificationRepository notificationRepository;
    private final DeviceTokenRepository deviceTokenRepository;

    @Transactional
    public void sendToUser(User user, String type, String title, String body, String dataJson) {
        // Save to Database
        Notification notification = Notification.builder()
                .user(user)
                .type(type)
                .title(title)
                .body(body)
                .data(dataJson != null ? dataJson : "{}")
                .isRead(false)
                .build();
        notificationRepository.save(notification);

        // Send via WebSocket STOMP
        try {
            String destination = type.startsWith("ALERT") ? "/queue/alerts" : "/queue/requests";
            messagingTemplate.convertAndSendToUser(user.getId().toString(), destination, notification);
        } catch (Exception e) {
            log.warn("Could not dispatch STOMP event to user {}: {}", user.getId(), e.getMessage());
        }
    }

    public void broadcastToBankDashboard(UUID bankId, Object payload) {
        try {
            messagingTemplate.convertAndSend("/topic/bank-dashboard/" + bankId, payload);
        } catch (Exception e) {
            log.warn("Could not broadcast to bank dashboard {}: {}", bankId, e.getMessage());
        }
    }

    @Transactional
    public void registerDeviceToken(User user, String fcmToken, String platform) {
        Optional<DeviceToken> existing = deviceTokenRepository.findByFcmToken(fcmToken);
        if (existing.isPresent()) {
            DeviceToken token = existing.get();
            token.setUser(user);
            token.setPlatform(platform);
            token.setLastSeen(Instant.now());
            deviceTokenRepository.save(token);
        } else {
            DeviceToken newToken = DeviceToken.builder()
                    .user(user)
                    .fcmToken(fcmToken)
                    .platform(platform)
                    .lastSeen(Instant.now())
                    .build();
            deviceTokenRepository.save(newToken);
        }
    }

    public List<Notification> getUserNotifications(UUID userId) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    @Transactional
    public void markAsRead(UUID notificationId, UUID userId) {
        notificationRepository.findById(notificationId).ifPresent(n -> {
            if (n.getUser().getId().equals(userId)) {
                n.setRead(true);
                notificationRepository.save(n);
            }
        });
    }
}

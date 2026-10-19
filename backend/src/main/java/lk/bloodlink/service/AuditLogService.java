package lk.bloodlink.service;

import lk.bloodlink.model.entity.AuditLog;
import lk.bloodlink.model.entity.User;
import lk.bloodlink.repository.AuditLogRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuditLogService {

    private final AuditLogRepository auditLogRepository;

    public void log(User actor, String action, String entityType, String entityId, String ip, String metaJson) {
        try {
            AuditLog auditLog = AuditLog.builder()
                    .actorUser(actor)
                    .action(action)
                    .entityType(entityType)
                    .entityId(entityId)
                    .ip(ip)
                    .meta(metaJson != null ? metaJson : "{}")
                    .build();
            auditLogRepository.save(auditLog);
        } catch (Exception e) {
            log.error("Failed to write audit log for action: {}", action, e);
        }
    }
}

package lk.bloodlink.service;

import lk.bloodlink.model.entity.AuditLog;
import lk.bloodlink.model.entity.User;
import lk.bloodlink.repository.AuditLogRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.regex.Pattern;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuditLogService {

    private final AuditLogRepository auditLogRepository;

    private static final Pattern IPV4_PATTERN = Pattern.compile("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$");
    private static final Pattern IPV6_PATTERN = Pattern.compile("^[0-9a-fA-F:]+$");

    @Transactional
    public void log(User actor, String action, String entityType, String entityId, String ip, String metaJson) {
        try {
            String sanitizedIp = sanitizeIp(ip);
            String sanitizedMeta = (StringUtils.hasText(metaJson) && (metaJson.trim().startsWith("{") || metaJson.trim().startsWith("[")))
                    ? metaJson.trim()
                    : "{}";

            AuditLog auditLog = AuditLog.builder()
                    .actorUser(actor)
                    .action(action)
                    .entityType(entityType)
                    .entityId(entityId)
                    .ip(sanitizedIp)
                    .meta(sanitizedMeta)
                    .build();

            auditLogRepository.save(auditLog);
        } catch (Exception e) {
            log.error("Failed to write audit log for action: {}", action, e);
        }
    }

    private String sanitizeIp(String ip) {
        if (!StringUtils.hasText(ip)) {
            return null;
        }

        String cleaned = ip.trim();
        // If multiple IPs (X-Forwarded-For header), take the first one
        if (cleaned.contains(",")) {
            cleaned = cleaned.split(",")[0].trim();
        }

        // Strip port if present in IPv4 (e.g. 192.168.1.1:8080)
        if (cleaned.contains(":") && !cleaned.contains("::") && cleaned.indexOf(':') == cleaned.lastIndexOf(':')) {
            cleaned = cleaned.split(":")[0].trim();
        }

        if (IPV4_PATTERN.matcher(cleaned).matches() || IPV6_PATTERN.matcher(cleaned).matches()) {
            return cleaned;
        }

        return null;
    }
}


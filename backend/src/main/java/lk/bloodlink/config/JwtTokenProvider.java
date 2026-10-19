package lk.bloodlink.config;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lk.bloodlink.model.enums.UserRole;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.UUID;

@Slf4j
@Component
public class JwtTokenProvider {

    private final SecretKey key;
    private final long accessExpirationMinutes;
    private final long refreshExpirationDays;

    public JwtTokenProvider(
            @Value("${bloodlink.jwt.secret}") String secret,
            @Value("${bloodlink.jwt.access-expiration-minutes:15}") long accessExpirationMinutes,
            @Value("${bloodlink.jwt.refresh-expiration-days:7}") long refreshExpirationDays) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.accessExpirationMinutes = accessExpirationMinutes;
        this.refreshExpirationDays = refreshExpirationDays;
    }

    public String generateAccessToken(UUID userId, String email, String phone, UserRole role) {
        Instant now = Instant.now();
        Instant expiry = now.plus(accessExpirationMinutes, ChronoUnit.MINUTES);

        return Jwts.builder()
                .subject(userId.toString())
                .claim("email", email)
                .claim("phone", phone)
                .claim("role", role.name())
                .issuedAt(Date.from(now))
                .expiration(Date.from(expiry))
                .signWith(key)
                .compact();
    }

    public String generateRefreshToken() {
        return UUID.randomUUID().toString().replace("-", "") + UUID.randomUUID().toString().replace("-", "");
    }

    public long getAccessExpirationMinutes() {
        return accessExpirationMinutes;
    }

    public long getRefreshExpirationDays() {
        return refreshExpirationDays;
    }

    public Claims parseClaims(String token) {
        return Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parser().verifyWith(key).build().parseSignedClaims(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            log.warn("Invalid JWT token: {}", e.getMessage());
            return false;
        }
    }

    public UUID getUserIdFromToken(String token) {
        return UUID.fromString(parseClaims(token).getSubject());
    }

    public UserRole getRoleFromToken(String token) {
        String roleStr = parseClaims(token).get("role", String.class);
        return UserRole.valueOf(roleStr);
    }
}

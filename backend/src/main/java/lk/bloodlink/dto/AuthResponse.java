package lk.bloodlink.dto;

import lk.bloodlink.model.enums.AccountStatus;
import lk.bloodlink.model.enums.UserRole;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    private String accessToken;
    private String refreshToken;
    private String tokenType;
    private long expiresIn;
    private UUID userId;
    private String email;
    private String phone;
    private String fullName;
    private UserRole role;
    private AccountStatus status;
    private boolean phoneVerified;
    private boolean emailVerified;
    private String rejectionReason;
}

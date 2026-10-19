package lk.bloodlink.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class VerifyPhoneRequest {
    @NotBlank(message = "Firebase ID token or verification code is required")
    private String idToken;
    private String code;
}

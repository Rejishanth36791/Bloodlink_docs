package lk.bloodlink.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lk.bloodlink.dto.*;
import lk.bloodlink.model.entity.User;
import lk.bloodlink.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Endpoints for registration, login, phone OTP, and token refresh")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register/donor")
    @Operation(summary = "Register a new Blood Donor")
    public ResponseEntity<AuthResponse> registerDonor(@Valid @RequestBody RegisterDonorRequest req, HttpServletRequest request) {
        return ResponseEntity.ok(authService.registerDonor(req, request.getRemoteAddr()));
    }

    @PostMapping("/register/requester")
    @Operation(summary = "Register a new Blood Requester (Patient/Family or Hospital Staff)")
    public ResponseEntity<AuthResponse> registerRequester(@Valid @RequestBody RegisterRequesterRequest req, HttpServletRequest request) {
        return ResponseEntity.ok(authService.registerRequester(req, request.getRemoteAddr()));
    }

    @PostMapping("/register/bank")
    @Operation(summary = "Register a Blood Bank (Account starts PENDING for NBTS admin review)")
    public ResponseEntity<AuthResponse> registerBank(@Valid @RequestBody RegisterBankRequest req, HttpServletRequest request) {
        return ResponseEntity.ok(authService.registerBank(req, request.getRemoteAddr()));
    }

    @PostMapping("/login")
    @Operation(summary = "Authenticate user with email/phone and password")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest req, HttpServletRequest request) {
        return ResponseEntity.ok(authService.login(req, request.getRemoteAddr()));
    }

    @PostMapping("/refresh")
    @Operation(summary = "Rotate refresh token and issue new short-lived access token")
    public ResponseEntity<AuthResponse> refresh(@Valid @RequestBody TokenRefreshRequest req, HttpServletRequest request) {
        return ResponseEntity.ok(authService.refresh(req, request.getRemoteAddr()));
    }

    @PostMapping("/logout")
    @Operation(summary = "Revoke refresh token and logout")
    public ResponseEntity<Void> logout(@RequestBody(required = false) TokenRefreshRequest req) {
        if (req != null) {
            authService.logout(req.getRefreshToken());
        }
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/verify-phone")
    @Operation(summary = "Verify phone with 6-digit SMS OTP")
    public ResponseEntity<Void> verifyPhone(@AuthenticationPrincipal User user, @Valid @RequestBody VerifyPhoneRequest req) {
        authService.verifyPhone(user, req);
        return ResponseEntity.ok().build();
    }
}

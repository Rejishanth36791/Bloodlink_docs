package lk.bloodlink.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lk.bloodlink.dto.AdminDtos;
import lk.bloodlink.dto.ProfileDtos;
import lk.bloodlink.model.entity.User;
import lk.bloodlink.service.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
@Tag(name = "Admin Portal", description = "Endpoints for bank verification, moderation, awareness broadcasts, and analytics")
public class AdminController {

    private final AdminService adminService;

    @GetMapping("/banks")
    @Operation(summary = "Get list of pending blood bank applications")
    public ResponseEntity<List<ProfileDtos.BankDto>> getPendingBanks(
            @RequestParam(defaultValue = "PENDING") String status) {
        return ResponseEntity.ok(adminService.getPendingBanks());
    }

    @PostMapping("/banks/{id}/approve")
    @Operation(summary = "Approve blood bank NBTS accreditation")
    public ResponseEntity<Void> approveBank(
            @AuthenticationPrincipal User user,
            @PathVariable UUID id) {
        AdminDtos.ApproveBank req = new AdminDtos.ApproveBank();
        req.setApproved(true);
        adminService.reviewBank(id, user, req);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/banks/{id}/reject")
    @Operation(summary = "Reject blood bank application with stated reason")
    public ResponseEntity<Void> rejectBank(
            @AuthenticationPrincipal User user,
            @PathVariable UUID id,
            @RequestBody(required = false) AdminDtos.ApproveBank req) {
        if (req == null) req = new AdminDtos.ApproveBank();
        req.setApproved(false);
        adminService.reviewBank(id, user, req);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/users/{id}/suspend")
    @Operation(summary = "Suspend user account and revoke all sessions")
    public ResponseEntity<Void> suspendUser(
            @AuthenticationPrincipal User user,
            @PathVariable UUID id,
            @Valid @RequestBody AdminDtos.SuspendUser req) {
        adminService.suspendUser(id, user, req);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/alerts")
    @Operation(summary = "Broadcast emergency or awareness alert")
    public ResponseEntity<AdminDtos.AwarenessAlertResponse> createAlert(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody AdminDtos.CreateAwarenessAlert req) {
        return ResponseEntity.ok(adminService.createAwarenessAlert(user, req));
    }

    @GetMapping("/alerts")
    @Operation(summary = "Get recent awareness alerts")
    public ResponseEntity<List<AdminDtos.AwarenessAlertResponse>> getAlerts() {
        return ResponseEntity.ok(adminService.getAwarenessAlerts());
    }

    @GetMapping("/fraud-flags")
    @Operation(summary = "Get suspicious activities and no-show flags")
    public ResponseEntity<List<AdminDtos.FraudFlagResponse>> getFraudFlags() {
        return ResponseEntity.ok(adminService.getFraudFlags());
    }

    @GetMapping("/analytics")
    @Operation(summary = "Get platform-wide donor, bank and inventory analytics")
    public ResponseEntity<AdminDtos.AdminAnalytics> getAnalytics() {
        return ResponseEntity.ok(adminService.getAnalytics());
    }
}

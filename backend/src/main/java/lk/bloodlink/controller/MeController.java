package lk.bloodlink.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.Valid;
import lk.bloodlink.dto.ProfileDtos;
import lk.bloodlink.model.entity.Donor;
import lk.bloodlink.model.entity.Notification;
import lk.bloodlink.model.entity.User;
import lk.bloodlink.repository.DonorRepository;
import lk.bloodlink.service.AuthService;
import lk.bloodlink.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
@Tag(name = "User Profile & Device", description = "Endpoints for managing user profile, donor availability, and devices")
public class MeController {

    private final AuthService authService;
    private final DonorRepository donorRepository;
    private final NotificationService notificationService;

    @GetMapping("/me")
    @Operation(summary = "Get current authenticated user profile")
    public ResponseEntity<ProfileDtos.UserProfile> getMyProfile(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(authService.getProfile(user));
    }

    @PutMapping("/donors/me/availability")
    @PreAuthorize("hasRole('DONOR')")
    @Operation(summary = "Toggle donor donation availability")
    public ResponseEntity<Void> updateAvailability(
            @AuthenticationPrincipal User user,
            @RequestBody ProfileDtos.UpdateAvailability req) {
        Donor donor = donorRepository.findByUserId(user.getId())
                .orElseThrow(() -> new EntityNotFoundException("Donor profile not found"));
        donor.setAvailable(req.isAvailable());
        donorRepository.save(donor);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/donors/me/location")
    @PreAuthorize("hasRole('DONOR')")
    @Operation(summary = "Update donor GPS coordinates and city")
    public ResponseEntity<Void> updateLocation(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody ProfileDtos.UpdateLocation req) {
        Donor donor = donorRepository.findByUserId(user.getId())
                .orElseThrow(() -> new EntityNotFoundException("Donor profile not found"));
        donor.setCoordinates(req.getLatitude(), req.getLongitude());
        if (req.getDistrict() != null) donor.setDistrict(req.getDistrict());
        if (req.getCity() != null) donor.setCity(req.getCity());
        donorRepository.save(donor);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/devices")
    @Operation(summary = "Register FCM device token for push notifications")
    public ResponseEntity<Void> registerDevice(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody ProfileDtos.RegisterDevice req) {
        notificationService.registerDeviceToken(user, req.getFcmToken(), req.getPlatform());
        return ResponseEntity.ok().build();
    }

    @GetMapping("/me/notifications")
    @Operation(summary = "Get user notification history")
    public ResponseEntity<List<Notification>> getNotifications(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(notificationService.getUserNotifications(user.getId()));
    }

    @PutMapping("/me/notifications/{id}/read")
    @Operation(summary = "Mark a notification as read")
    public ResponseEntity<Void> markNotificationRead(
            @AuthenticationPrincipal User user,
            @PathVariable UUID id) {
        notificationService.markAsRead(id, user.getId());
        return ResponseEntity.ok().build();
    }
}

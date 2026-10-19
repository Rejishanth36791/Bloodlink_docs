package lk.bloodlink.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lk.bloodlink.dto.RequestDtos;
import lk.bloodlink.model.entity.User;
import lk.bloodlink.service.BloodRequestService;
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
@Tag(name = "Blood Requests & Matching", description = "Endpoints for creating requests, AI matching, alerts and live tracking")
public class BloodRequestController {

    private final BloodRequestService requestService;

    @PostMapping("/requests")
    @PreAuthorize("hasAnyRole('REQUESTER', 'ADMIN')")
    @Operation(summary = "Create blood request and trigger AI donor matching")
    public ResponseEntity<RequestDtos.RequestResponse> createRequest(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody RequestDtos.CreateRequest req,
            HttpServletRequest request) {
        return ResponseEntity.ok(requestService.createRequest(user, req, request.getRemoteAddr()));
    }

    @GetMapping("/requests/mine")
    @PreAuthorize("hasAnyRole('REQUESTER', 'ADMIN')")
    @Operation(summary = "Get blood requests created by the current user")
    public ResponseEntity<List<RequestDtos.RequestResponse>> getMyRequests(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(requestService.getMyRequests(user));
    }

    @GetMapping("/requests/{id}")
    @Operation(summary = "Get single blood request details (donor location masked until accepted)")
    public ResponseEntity<RequestDtos.RequestResponse> getRequestById(
            @AuthenticationPrincipal User user,
            @PathVariable UUID id) {
        return ResponseEntity.ok(requestService.getRequestById(id, user));
    }

    @PostMapping("/requests/{id}/cancel")
    @Operation(summary = "Cancel an active blood request")
    public ResponseEntity<Void> cancelRequest(
            @AuthenticationPrincipal User user,
            @PathVariable UUID id) {
        requestService.cancelRequest(id, user);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/requests/{id}/matches")
    @Operation(summary = "Get ranked AI matched donors for this request")
    public ResponseEntity<List<RequestDtos.MatchResponse>> getMatches(
            @AuthenticationPrincipal User user,
            @PathVariable UUID id) {
        return ResponseEntity.ok(requestService.getMatches(id, user));
    }

    @GetMapping("/donors/me/alerts")
    @PreAuthorize("hasRole('DONOR')")
    @Operation(summary = "Get active matched request alerts for the logged-in donor")
    public ResponseEntity<List<RequestDtos.MatchResponse>> getDonorAlerts(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(requestService.getDonorAlerts(user));
    }

    @PostMapping("/matches/{id}/accept")
    @PreAuthorize("hasRole('DONOR')")
    @Operation(summary = "Accept an urgent donation request with ETA in minutes")
    public ResponseEntity<Void> acceptMatch(
            @AuthenticationPrincipal User user,
            @PathVariable UUID id,
            @Valid @RequestBody RequestDtos.AcceptMatch req) {
        requestService.acceptMatch(id, user, req.getEtaMinutes());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/matches/{id}/decline")
    @PreAuthorize("hasRole('DONOR')")
    @Operation(summary = "Decline a donation request alert")
    public ResponseEntity<Void> declineMatch(
            @AuthenticationPrincipal User user,
            @PathVariable UUID id) {
        requestService.declineMatch(id, user);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/appeals/nearby")
    @Operation(summary = "Get compatible open blood appeals near location")
    public ResponseEntity<List<RequestDtos.AppealDto>> getNearbyAppeals(
            @AuthenticationPrincipal User user,
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lng,
            @RequestParam(defaultValue = "40.0") Double radiusKm) {
        return ResponseEntity.ok(requestService.getNearbyAppeals(user, lat, lng, radiusKm));
    }
}

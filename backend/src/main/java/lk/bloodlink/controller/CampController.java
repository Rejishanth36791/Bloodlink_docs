package lk.bloodlink.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lk.bloodlink.dto.BankDtos;
import lk.bloodlink.model.entity.User;
import lk.bloodlink.service.CampService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/camps")
@RequiredArgsConstructor
@Tag(name = "Donation Camps", description = "Endpoints for scheduling mobile camps and donor RSVPs")
public class CampController {

    private final CampService campService;

    @PostMapping
    @PreAuthorize("hasRole('BLOOD_BANK')")
    @Operation(summary = "Create a new mobile donation camp")
    public ResponseEntity<BankDtos.CampDto> createCamp(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody BankDtos.CreateCamp req) {
        return ResponseEntity.ok(campService.createCamp(user, req));
    }

    @GetMapping("/nearby")
    @Operation(summary = "Find upcoming mobile donation camps near location")
    public ResponseEntity<List<BankDtos.CampDto>> getNearbyCamps(
            @AuthenticationPrincipal(errorOnInvalidType = false) User user,
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lng,
            @RequestParam(defaultValue = "50.0") Double radiusKm) {
        return ResponseEntity.ok(campService.getNearbyCamps(user, lat, lng, radiusKm));
    }

    @PostMapping("/{id}/rsvp")
    @PreAuthorize("hasRole('DONOR')")
    @Operation(summary = "Register RSVP for a mobile donation camp")
    public ResponseEntity<Void> registerRsvp(
            @AuthenticationPrincipal User user,
            @PathVariable UUID id) {
        campService.registerForCamp(user, id);
        return ResponseEntity.ok().build();
    }
}

package lk.bloodlink.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lk.bloodlink.dto.BankDtos;
import lk.bloodlink.dto.ProfileDtos;
import lk.bloodlink.model.entity.User;
import lk.bloodlink.service.BloodBankService;
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
@Tag(name = "Blood Bank & Inventory", description = "Endpoints for blood bank dashboard, inventory ledger, and donation verification")
public class BloodBankController {

    private final BloodBankService bloodBankService;

    @GetMapping("/bank/dashboard")
    @PreAuthorize("hasAnyRole('BLOOD_BANK', 'ADMIN')")
    @Operation(summary = "Get blood bank live dashboard, inventory matrix, incoming donors, and AI forecasts")
    public ResponseEntity<BankDtos.BankDashboard> getDashboard(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(bloodBankService.getDashboard(user));
    }

    @PostMapping("/bank/inventory/adjust")
    @PreAuthorize("hasRole('BLOOD_BANK')")
    @Operation(summary = "Adjust inventory with ledger tracking (non-negative stock guarantee)")
    public ResponseEntity<Void> adjustInventory(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody BankDtos.InventoryAdjustment req) {
        bloodBankService.adjustInventory(user, req);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/bank/donations/{id}/verify")
    @PreAuthorize("hasRole('BLOOD_BANK')")
    @Operation(summary = "Verify donor donation arrival and collection, update inventory ledger and request progress")
    public ResponseEntity<Void> verifyDonation(
            @AuthenticationPrincipal User user,
            @PathVariable UUID id,
            @Valid @RequestBody BankDtos.VerifyDonation req) {
        bloodBankService.verifyDonation(user, id, req);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/banks/nearby")
    @Operation(summary = "Find verified blood banks near a geographic point")
    public ResponseEntity<List<ProfileDtos.BankDto>> getNearbyBanks(
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lng,
            @RequestParam(defaultValue = "50.0") Double radiusKm) {
        return ResponseEntity.ok(bloodBankService.getNearbyBanks(lat, lng, radiusKm));
    }
}

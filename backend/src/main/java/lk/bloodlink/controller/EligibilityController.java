package lk.bloodlink.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.Valid;
import lk.bloodlink.dto.AiDtos;
import lk.bloodlink.model.entity.Donor;
import lk.bloodlink.model.entity.User;
import lk.bloodlink.repository.DonorRepository;
import lk.bloodlink.service.AiIntegrationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/donors/me/eligibility")
@RequiredArgsConstructor
@Tag(name = "AI Eligibility Check", description = "Clinical AI evaluation based on NBTS Sri Lanka rules")
public class EligibilityController {

    private final DonorRepository donorRepository;
    private final AiIntegrationService aiIntegrationService;

    @PostMapping
    @PreAuthorize("hasRole('DONOR')")
    @Operation(summary = "Assess donor eligibility with questionnaire and history")
    public ResponseEntity<AiDtos.EligibilityResult> checkEligibility(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody AiDtos.EligibilityCheckRequest request) {
        Donor donor = donorRepository.findByUserId(user.getId())
                .orElseThrow(() -> new EntityNotFoundException("Donor profile not found"));
        return ResponseEntity.ok(aiIntegrationService.checkEligibility(donor, request));
    }
}

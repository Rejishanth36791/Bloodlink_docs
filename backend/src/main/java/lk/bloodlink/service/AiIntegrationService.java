package lk.bloodlink.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import lk.bloodlink.dto.AiDtos;
import lk.bloodlink.model.entity.Donor;
import lk.bloodlink.model.entity.EligibilityAssessment;
import lk.bloodlink.repository.EligibilityAssessmentRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.time.Instant;
import java.time.LocalDate;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class AiIntegrationService {

    private final EligibilityAssessmentRepository assessmentRepository;
    private final ObjectMapper objectMapper;
    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${bloodlink.ai-service.url:http://localhost:8000}")
    private String aiServiceUrl;

    @Transactional
    public AiDtos.EligibilityResult checkEligibility(Donor donor, AiDtos.EligibilityCheckRequest request) {
        String url = aiServiceUrl + "/eligibility";
        AiDtos.EligibilityResult result;

        try {
            Map<String, Object> payload = new HashMap<>();
            payload.put("age", request.getAge());
            payload.put("gender", request.getGender());
            payload.put("weight_kg", request.getWeightKg());
            payload.put("last_donation_date", donor.getLastDonationDate() != null ? donor.getLastDonationDate().toString() : null);
            payload.put("has_recent_fever_infection", request.isHasRecentFeverInfection());
            payload.put("has_recent_medications", request.isHasRecentMedications());
            payload.put("has_recent_travel", request.isHasRecentTravel());
            payload.put("has_recent_tattoo_piercing", request.isHasRecentTattooPiercing());
            payload.put("is_pregnant_or_nursing", request.isPregnantOrNursing());
            payload.put("hemoglobin", request.getHemoglobin());

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);

            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                    url,
                    HttpMethod.POST,
                    entity,
                    new org.springframework.core.ParameterizedTypeReference<Map<String, Object>>() {}
            );
            Map<String, Object> body = response.getBody();

            boolean eligible = body != null && Boolean.TRUE.equals(body.get("isEligible"));
            int score = (body != null && body.get("readinessScore") instanceof Number n) ? n.intValue() : 0;
            List<String> reasons = Collections.emptyList();
            if (body != null && body.get("reasons") instanceof List<?> list) {
                reasons = list.stream().map(Object::toString).toList();
            }
            String nextDateStr = body != null ? (String) body.get("nextEligibleDate") : null;
            LocalDate nextDate = nextDateStr != null ? LocalDate.parse(nextDateStr) : LocalDate.now();
            String modelVersion = body != null ? (String) body.get("modelVersion") : null;

            result = AiDtos.EligibilityResult.builder()
                    .isEligible(eligible)
                    .readinessScore(score)
                    .reasons(reasons)
                    .nextEligibleDate(nextDate)
                    .modelVersion(modelVersion != null ? modelVersion : "nbts-sl-v1.0")
                    .build();

        } catch (RestClientException ex) {
            log.warn("FastAPI AI Service unavailable at {}. Running clinical fallback engine.", url);
            result = runLocalClinicalRuleCheck(donor, request);
        }

        // Persist assessment
        try {
            EligibilityAssessment assessment = EligibilityAssessment.builder()
                    .donor(donor)
                    .answers(objectMapper.writeValueAsString(request))
                    .isEligible(result.isEligible())
                    .readinessScore((short) result.getReadinessScore())
                    .reasons(objectMapper.writeValueAsString(result.getReasons()))
                    .nextEligibleDate(result.getNextEligibleDate())
                    .modelVersion(result.getModelVersion())
                    .assessedAt(Instant.now())
                    .build();
            assessmentRepository.save(assessment);
        } catch (Exception e) {
            log.error("Failed to persist eligibility assessment", e);
        }

        return result;
    }

    private AiDtos.EligibilityResult runLocalClinicalRuleCheck(Donor donor, AiDtos.EligibilityCheckRequest req) {
        List<String> reasons = new ArrayList<>();
        boolean eligible = true;
        int deductions = 0;
        LocalDate today = LocalDate.now();
        LocalDate nextDate = today;

        if (req.getAge() < 18) {
            eligible = false;
            reasons.add("Minimum age for donation is 18 years (current: " + req.getAge() + ").");
            deductions += 40;
        } else if (req.getAge() > 60) {
            eligible = false;
            reasons.add("Maximum age without special clearance is 60 years.");
            deductions += 30;
        }

        if (req.getWeightKg() < 50.0) {
            eligible = false;
            reasons.add("Weight must be at least 50.0 kg (current: " + req.getWeightKg() + " kg).");
            deductions += 35;
        }

        if (donor.getLastDonationDate() != null) {
            long daysPassed = java.time.temporal.ChronoUnit.DAYS.between(donor.getLastDonationDate(), today);
            if (daysPassed < 112) {
                eligible = false;
                long remaining = 112 - daysPassed;
                nextDate = donor.getLastDonationDate().plusDays(112);
                reasons.add("Mandatory cooldown period in progress (" + daysPassed + "/112 days, " + remaining + " days remaining).");
                deductions += (int) (40 * ((double) remaining / 112));
            }
        }

        if (req.isHasRecentFeverInfection()) {
            eligible = false;
            reasons.add("Reported fever or infection symptoms within 14 days.");
            deductions += 30;
            if (today.plusDays(14).isAfter(nextDate)) nextDate = today.plusDays(14);
        }

        if (req.isHasRecentMedications()) {
            eligible = false;
            reasons.add("Recent medication or antibiotic course active.");
            deductions += 25;
            if (today.plusDays(7).isAfter(nextDate)) nextDate = today.plusDays(7);
        }

        if (req.isHasRecentTravel()) {
            eligible = false;
            reasons.add("Recent exposure to designated malaria/dengue endemic zone.");
            deductions += 20;
            if (today.plusDays(28).isAfter(nextDate)) nextDate = today.plusDays(28);
        }

        if (req.isHasRecentTattooPiercing()) {
            eligible = false;
            reasons.add("Tattoo, body piercing or acupuncture within past 12 months.");
            deductions += 40;
        }

        if (req.isPregnantOrNursing()) {
            eligible = false;
            reasons.add("Currently pregnant or nursing (deferred until 6 months post-delivery).");
            deductions += 50;
        }

        if (req.getHemoglobin() != null) {
            double minHb = "FEMALE".equalsIgnoreCase(req.getGender()) ? 12.5 : 13.0;
            if (req.getHemoglobin() < minHb) {
                eligible = false;
                reasons.add("Hemoglobin level (" + req.getHemoglobin() + " g/dL) is below clinical minimum " + minHb + " g/dL.");
                deductions += 30;
            }
        }

        if (eligible) {
            reasons.add("Meets all NBTS criteria: Optimal weight, age, cadence, and clear screening.");
        }

        int score = eligible ? Math.max(80, 100 - deductions) : Math.max(0, 100 - deductions);

        return AiDtos.EligibilityResult.builder()
                .isEligible(eligible)
                .readinessScore(score)
                .reasons(reasons)
                .nextEligibleDate(eligible ? today : nextDate)
                .modelVersion("nbts-rule-engine-v1.0")
                .build();
    }
}

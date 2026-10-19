package lk.bloodlink.service;

import jakarta.persistence.EntityNotFoundException;
import lk.bloodlink.dto.BankDtos;
import lk.bloodlink.model.entity.*;
import lk.bloodlink.model.enums.CampStatus;
import lk.bloodlink.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class CampService {

    private final DonationCampRepository campRepository;
    private final CampRegistrationRepository registrationRepository;
    private final BloodBankRepository bloodBankRepository;
    private final DonorRepository donorRepository;
    private final AuditLogService auditLogService;

    @Transactional
    public BankDtos.CampDto createCamp(User bankUser, BankDtos.CreateCamp req) {
        BloodBank bank = bloodBankRepository.findByUserId(bankUser.getId())
                .orElseThrow(() -> new EntityNotFoundException("Blood bank profile not found for user."));

        DonationCamp camp = DonationCamp.builder()
                .bank(bank)
                .title(req.getTitle().trim())
                .venue(req.getVenue().trim())
                .district(req.getDistrict().trim())
                .startsAt(req.getStartsAt())
                .endsAt(req.getEndsAt())
                .targetUnits(req.getTargetUnits())
                .status(CampStatus.UPCOMING)
                .build();

        camp.setCoordinates(req.getLatitude(), req.getLongitude());
        camp = campRepository.save(camp);

        auditLogService.log(bankUser, "CREATE_CAMP", "DonationCamp", camp.getId().toString(), null, null);

        return mapToDto(camp, null);
    }

    public List<BankDtos.CampDto> getNearbyCamps(User currentUser, Double lat, Double lng, Double radiusKm) {
        List<DonationCamp> camps = campRepository.findByStatusOrderByStartsAtAsc(CampStatus.UPCOMING);
        double dLat = lat != null ? lat : 6.9271;
        double dLng = lng != null ? lng : 79.8612;
        double maxRadius = radiusKm != null ? radiusKm : 50.0;

        return camps.stream()
                .filter(c -> {
                    if (c.getLatitude() == null || c.getLongitude() == null) return true;
                    return calculateHaversine(dLat, dLng, c.getLatitude(), c.getLongitude()) <= maxRadius;
                })
                .map(c -> mapToDto(c, currentUser != null ? currentUser.getId() : null))
                .collect(Collectors.toList());
    }

    @Transactional
    public void registerForCamp(User donorUser, UUID campId) {
        DonationCamp camp = campRepository.findById(campId)
                .orElseThrow(() -> new EntityNotFoundException("Donation camp not found: " + campId));

        Donor donor = donorRepository.findByUserId(donorUser.getId())
                .orElseThrow(() -> new EntityNotFoundException("Donor profile not found."));

        if (!registrationRepository.existsById(new CampRegistration.CampRegistrationId(campId, donor.getUserId()))) {
            CampRegistration registration = CampRegistration.builder()
                    .campId(campId)
                    .donorId(donor.getUserId())
                    .camp(camp)
                    .donor(donor)
                    .registeredAt(Instant.now())
                    .build();
            registrationRepository.save(registration);
            auditLogService.log(donorUser, "CAMP_RSVP", "CampRegistration", campId.toString(), null, null);
        }
    }

    private BankDtos.CampDto mapToDto(DonationCamp c, UUID currentUserId) {
        long count = registrationRepository.countByCampId(c.getId());
        boolean isRegistered = false;
        if (currentUserId != null) {
            isRegistered = registrationRepository.existsById(new CampRegistration.CampRegistrationId(c.getId(), currentUserId));
        }

        return BankDtos.CampDto.builder()
                .id(c.getId())
                .bankId(c.getBank().getId())
                .bankName(c.getBank().getInstitutionName())
                .title(c.getTitle())
                .venue(c.getVenue())
                .district(c.getDistrict())
                .latitude(c.getLatitude())
                .longitude(c.getLongitude())
                .startsAt(c.getStartsAt())
                .endsAt(c.getEndsAt())
                .targetUnits(c.getTargetUnits())
                .status(c.getStatus())
                .registeredCount(count)
                .isUserRegistered(isRegistered)
                .build();
    }

    private double calculateHaversine(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371;
        double latDist = Math.toRadians(lat2 - lat1);
        double lonDist = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDist / 2) * Math.sin(latDist / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDist / 2) * Math.sin(lonDist / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }
}

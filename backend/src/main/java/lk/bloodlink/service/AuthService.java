package lk.bloodlink.service;

import jakarta.persistence.EntityNotFoundException;
import lk.bloodlink.config.JwtTokenProvider;
import lk.bloodlink.dto.*;
import lk.bloodlink.model.entity.*;
import lk.bloodlink.model.enums.*;
import lk.bloodlink.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.HexFormat;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final DonorRepository donorRepository;
    private final RequesterProfileRepository requesterProfileRepository;
    private final BloodBankRepository bloodBankRepository;
    private final InventoryRepository inventoryRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;
    private final AuditLogService auditLogService;

    @Transactional
    public AuthResponse registerDonor(RegisterDonorRequest req, String clientIp) {
        if (StringUtils.hasText(req.getEmail()) && userRepository.existsByEmailIgnoreCase(req.getEmail())) {
            throw new IllegalArgumentException("Email is already registered: " + req.getEmail());
        }
        if (userRepository.existsByPhone(req.getPhone())) {
            throw new IllegalArgumentException("Phone number is already registered: " + req.getPhone());
        }

        User user = User.builder()
                .role(UserRole.DONOR)
                .email(StringUtils.hasText(req.getEmail()) ? req.getEmail().trim().toLowerCase() : null)
                .phone(req.getPhone().trim())
                .passwordHash(StringUtils.hasText(req.getPassword()) ? passwordEncoder.encode(req.getPassword()) : null)
                .fullName(req.getFullName().trim())
                .status(AccountStatus.ACTIVE)
                .phoneVerified(false)
                .emailVerified(false)
                .build();
        user = userRepository.save(user);

        Donor donor = Donor.builder()
                .userId(user.getId())
                .user(user)
                .bloodType(req.getBloodType())
                .dateOfBirth(req.getDateOfBirth())
                .gender(req.getGender())
                .weightKg(req.getWeightKg())
                .district(req.getDistrict())
                .city(req.getCity())
                .isAvailable(true)
                .reliabilityScore(new BigDecimal("0.500"))
                .consentHealthData(req.isConsentHealthData())
                .consentAt(req.isConsentHealthData() ? Instant.now() : null)
                .build();

        if (req.getLatitude() != null && req.getLongitude() != null) {
            donor.setCoordinates(req.getLatitude(), req.getLongitude());
        }
        donorRepository.save(donor);

        auditLogService.log(user, "REGISTER_DONOR", "User", user.getId().toString(), clientIp, null);
        return generateAuthResponse(user);
    }

    @Transactional
    public AuthResponse registerRequester(RegisterRequesterRequest req, String clientIp) {
        if (StringUtils.hasText(req.getEmail()) && userRepository.existsByEmailIgnoreCase(req.getEmail())) {
            throw new IllegalArgumentException("Email is already registered: " + req.getEmail());
        }
        if (userRepository.existsByPhone(req.getPhone())) {
            throw new IllegalArgumentException("Phone number is already registered: " + req.getPhone());
        }

        User user = User.builder()
                .role(UserRole.REQUESTER)
                .email(StringUtils.hasText(req.getEmail()) ? req.getEmail().trim().toLowerCase() : null)
                .phone(req.getPhone().trim())
                .passwordHash(StringUtils.hasText(req.getPassword()) ? passwordEncoder.encode(req.getPassword()) : null)
                .fullName(req.getFullName().trim())
                .status(AccountStatus.ACTIVE)
                .phoneVerified(false)
                .emailVerified(false)
                .build();
        user = userRepository.save(user);

        RequesterProfile profile = RequesterProfile.builder()
                .userId(user.getId())
                .user(user)
                .requesterType(req.getRequesterType())
                .district(req.getDistrict())
                .city(req.getCity())
                .build();
        requesterProfileRepository.save(profile);

        auditLogService.log(user, "REGISTER_REQUESTER", "User", user.getId().toString(), clientIp, null);
        return generateAuthResponse(user);
    }

    @Transactional
    public AuthResponse registerBank(RegisterBankRequest req, String clientIp) {
        if (userRepository.existsByEmailIgnoreCase(req.getEmail())) {
            throw new IllegalArgumentException("Email is already registered: " + req.getEmail());
        }
        if (bloodBankRepository.existsByNbtsLicenseNo(req.getNbtsLicenseNo())) {
            throw new IllegalArgumentException("NBTS License Number already registered: " + req.getNbtsLicenseNo());
        }

        // Blood bank accounts start PENDING per FR-3
        User user = User.builder()
                .role(UserRole.BLOOD_BANK)
                .email(req.getEmail().trim().toLowerCase())
                .phone(req.getPhone().trim())
                .passwordHash(passwordEncoder.encode(req.getPassword()))
                .fullName(req.getFullName().trim())
                .status(AccountStatus.PENDING)
                .phoneVerified(false)
                .emailVerified(false)
                .build();
        user = userRepository.save(user);

        BloodBank bank = BloodBank.builder()
                .user(user)
                .institutionName(req.getInstitutionName().trim())
                .nbtsLicenseNo(req.getNbtsLicenseNo().trim())
                .hotline(req.getPhone().trim())
                .address(req.getAddress().trim())
                .district(req.getDistrict().trim())
                .directorName(req.getDirectorName())
                .officialEmail(req.getEmail().trim().toLowerCase())
                .is24h(req.is24h())
                .verificationStatus(AccountStatus.PENDING)
                .build();

        bank.setCoordinates(req.getLatitude(), req.getLongitude());
        bank = bloodBankRepository.save(bank);

        // Initialize inventory matrix for this bank (all 8 types)
        for (BloodType type : BloodType.values()) {
            Inventory inv = Inventory.builder()
                    .bank(bank)
                    .bloodType(type)
                    .component(BloodComponent.WHOLE_BLOOD)
                    .unitsAvailable(0)
                    .reorderThreshold(10)
                    .build();
            inventoryRepository.save(inv);
        }

        auditLogService.log(user, "REGISTER_BANK", "BloodBank", bank.getId().toString(), clientIp, null);
        return generateAuthResponse(user);
    }

    @Transactional
    public AuthResponse login(LoginRequest req, String clientIp) {
        String identifier = req.getIdentifier().trim();
        Optional<User> userOpt = identifier.contains("@")
                ? userRepository.findByEmailIgnoreCase(identifier)
                : userRepository.findByPhone(identifier);

        if (userOpt.isEmpty()) {
            throw new BadCredentialsException("Invalid credentials entered.");
        }

        User user = userOpt.get();
        if (user.getPasswordHash() == null || !passwordEncoder.matches(req.getPassword(), user.getPasswordHash())) {
            throw new BadCredentialsException("Invalid credentials entered.");
        }

        if (user.getStatus() == AccountStatus.SUSPENDED) {
            throw new IllegalStateException("Your account has been suspended. Please contact support.");
        }

        user.setLastLoginAt(Instant.now());
        userRepository.save(user);

        auditLogService.log(user, "LOGIN", "User", user.getId().toString(), clientIp, null);
        return generateAuthResponse(user);
    }

    @Transactional
    public AuthResponse refresh(TokenRefreshRequest req, String clientIp) {
        String hash = hashToken(req.getRefreshToken());
        RefreshToken stored = refreshTokenRepository.findByTokenHash(hash)
                .orElseThrow(() -> new BadCredentialsException("Invalid or revoked refresh token."));

        if (stored.getRevokedAt() != null || stored.getExpiresAt().isBefore(Instant.now())) {
            throw new BadCredentialsException("Refresh token has expired or been revoked.");
        }

        User user = stored.getUser();
        if (user.getStatus() == AccountStatus.SUSPENDED) {
            throw new IllegalStateException("Account is suspended.");
        }

        // Revoke old token (Rotation!)
        stored.setRevokedAt(Instant.now());
        refreshTokenRepository.save(stored);

        auditLogService.log(user, "TOKEN_ROTATION", "RefreshToken", stored.getId().toString(), clientIp, null);
        return generateAuthResponse(user);
    }

    @Transactional
    public void logout(String refreshToken) {
        if (StringUtils.hasText(refreshToken)) {
            String hash = hashToken(refreshToken);
            refreshTokenRepository.findByTokenHash(hash).ifPresent(rt -> {
                rt.setRevokedAt(Instant.now());
                refreshTokenRepository.save(rt);
            });
        }
    }

    @Transactional
    public void verifyPhone(User user, VerifyPhoneRequest req) {
        user.setPhoneVerified(true);
        userRepository.save(user);
        auditLogService.log(user, "PHONE_VERIFIED", "User", user.getId().toString(), null, null);
    }

    public ProfileDtos.UserProfile getProfile(User user) {
        ProfileDtos.UserProfile profile = ProfileDtos.UserProfile.builder()
                .id(user.getId())
                .role(user.getRole())
                .email(user.getEmail())
                .phone(user.getPhone())
                .fullName(user.getFullName())
                .status(user.getStatus())
                .phoneVerified(user.isPhoneVerified())
                .emailVerified(user.isEmailVerified())
                .createdAt(user.getCreatedAt())
                .build();

        if (user.getRole() == UserRole.DONOR) {
            donorRepository.findByUserId(user.getId()).ifPresent(d -> {
                profile.setDonorProfile(ProfileDtos.DonorDto.builder()
                        .bloodType(d.getBloodType())
                        .dateOfBirth(d.getDateOfBirth())
                        .gender(d.getGender())
                        .weightKg(d.getWeightKg())
                        .district(d.getDistrict())
                        .city(d.getCity())
                        .latitude(d.getLatitude())
                        .longitude(d.getLongitude())
                        .isAvailable(d.isAvailable())
                        .lastDonationDate(d.getLastDonationDate())
                        .reliabilityScore(d.getReliabilityScore())
                        .totalDonations(d.getTotalDonations())
                        .totalNoShows(d.getTotalNoShows())
                        .consentHealthData(d.isConsentHealthData())
                        .build());
            });
        } else if (user.getRole() == UserRole.REQUESTER) {
            requesterProfileRepository.findByUserId(user.getId()).ifPresent(r -> {
                profile.setRequesterProfile(ProfileDtos.RequesterDto.builder()
                        .requesterType(r.getRequesterType())
                        .district(r.getDistrict())
                        .city(r.getCity())
                        .build());
            });
        } else if (user.getRole() == UserRole.BLOOD_BANK) {
            bloodBankRepository.findByUserId(user.getId()).ifPresent(b -> {
                profile.setBankProfile(ProfileDtos.BankDto.builder()
                        .id(b.getId())
                        .institutionName(b.getInstitutionName())
                        .nbtsLicenseNo(b.getNbtsLicenseNo())
                        .hotline(b.getHotline())
                        .address(b.getAddress())
                        .district(b.getDistrict())
                        .latitude(b.getLatitude())
                        .longitude(b.getLongitude())
                        .directorName(b.getDirectorName())
                        .officialEmail(b.getOfficialEmail())
                        .is24h(b.is24h())
                        .verificationStatus(b.getVerificationStatus())
                        .rejectionReason(b.getRejectionReason())
                        .build());
            });
        }

        return profile;
    }

    private AuthResponse generateAuthResponse(User user) {
        String accessToken = tokenProvider.generateAccessToken(
                user.getId(), user.getEmail(), user.getPhone(), user.getRole());
        String refreshTokenRaw = tokenProvider.generateRefreshToken();

        Instant refreshExpiry = Instant.now().plus(tokenProvider.getRefreshExpirationDays(), ChronoUnit.DAYS);

        RefreshToken refreshToken = RefreshToken.builder()
                .user(user)
                .tokenHash(hashToken(refreshTokenRaw))
                .expiresAt(refreshExpiry)
                .build();
        refreshTokenRepository.save(refreshToken);

        String rejectionReason = null;
        if (user.getRole() == UserRole.BLOOD_BANK) {
            Optional<BloodBank> bank = bloodBankRepository.findByUserId(user.getId());
            if (bank.isPresent()) {
                rejectionReason = bank.get().getRejectionReason();
            }
        }

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshTokenRaw)
                .tokenType("Bearer")
                .expiresIn(tokenProvider.getAccessExpirationMinutes() * 60)
                .userId(user.getId())
                .email(user.getEmail())
                .phone(user.getPhone())
                .fullName(user.getFullName())
                .role(user.getRole())
                .status(user.getStatus())
                .phoneVerified(user.isPhoneVerified())
                .emailVerified(user.isEmailVerified())
                .rejectionReason(rejectionReason)
                .build();
    }

    private String hashToken(String rawToken) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(rawToken.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 not supported", e);
        }
    }
}

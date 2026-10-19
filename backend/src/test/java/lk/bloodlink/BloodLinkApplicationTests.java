package lk.bloodlink;

import lk.bloodlink.dto.AuthResponse;
import lk.bloodlink.dto.RegisterDonorRequest;
import lk.bloodlink.dto.RegisterRequesterRequest;
import lk.bloodlink.model.enums.BloodType;
import lk.bloodlink.service.AuthService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

import java.math.BigDecimal;
import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@TestPropertySource(locations = "classpath:application-test.properties")
class BloodLinkApplicationTests {

    @Autowired
    private AuthService authService;

    @Test
    void contextLoads() {
    }

    @Test
    void testDonorRegistration() {
        RegisterDonorRequest req = new RegisterDonorRequest();
        req.setFullName("Kasun Mendis");
        req.setEmail("kasun@example.com");
        req.setPhone("+94771234567");
        req.setPassword("Password123!");
        req.setBloodType(BloodType.O_POS);
        req.setDateOfBirth(LocalDate.of(1998, 5, 20));
        req.setGender("MALE");
        req.setWeightKg(new BigDecimal("68.50"));
        req.setDistrict("Colombo");
        req.setCity("Colombo 07");
        req.setLatitude(6.9271);
        req.setLongitude(79.8612);
        req.setConsentHealthData(true);

        AuthResponse res = authService.registerDonor(req, "127.0.0.1");

        assertNotNull(res);
        assertNotNull(res.getAccessToken());
        assertNotNull(res.getRefreshToken());
        assertEquals("Kasun Mendis", res.getFullName());
        assertEquals("DONOR", res.getRole().name());
    }

    @Test
    void testRequesterRegistration() {
        RegisterRequesterRequest req = new RegisterRequesterRequest();
        req.setFullName("Amara Perera");
        req.setEmail("amara@example.com");
        req.setPhone("+94779876543");
        req.setPassword("Password123!");
        req.setRequesterType("PATIENT_FAMILY");
        req.setDistrict("Colombo");
        req.setCity("Nugegoda");

        AuthResponse res = authService.registerRequester(req, "127.0.0.1");

        assertNotNull(res);
        assertNotNull(res.getAccessToken());
        assertEquals("REQUESTER", res.getRole().name());
    }
}

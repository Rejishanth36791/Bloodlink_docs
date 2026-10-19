package lk.bloodlink.dto;

import jakarta.validation.constraints.*;
import lk.bloodlink.model.enums.BloodType;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class RegisterDonorRequest {
    @NotBlank(message = "Full name is required")
    private String fullName;

    @Email(message = "Invalid email format")
    private String email;

    @NotBlank(message = "Phone number is required")
    private String phone;

    @Size(min = 8, message = "Password must be at least 8 characters")
    private String password;

    @NotNull(message = "Blood type is required")
    private BloodType bloodType;

    @NotNull(message = "Date of birth is required")
    @Past(message = "Date of birth must be in the past")
    private LocalDate dateOfBirth;

    private String gender;

    @DecimalMin(value = "30.0", message = "Weight must be at least 30kg")
    @DecimalMax(value = "250.0", message = "Weight must not exceed 250kg")
    private BigDecimal weightKg;

    @NotBlank(message = "District is required")
    private String district;

    @NotBlank(message = "City is required")
    private String city;

    private Double latitude;
    private Double longitude;

    private boolean consentHealthData;
}

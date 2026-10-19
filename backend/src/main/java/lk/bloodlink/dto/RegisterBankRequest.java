package lk.bloodlink.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterBankRequest {
    @NotBlank(message = "Contact administrator name is required")
    private String fullName;

    @Email(message = "Official email format required")
    @NotBlank(message = "Official email is required")
    private String email;

    @NotBlank(message = "Hotline / phone number is required")
    private String phone;

    @Size(min = 8, message = "Password must be at least 8 characters")
    private String password;

    @NotBlank(message = "Institution name is required")
    private String institutionName;

    @NotBlank(message = "NBTS license number is required")
    private String nbtsLicenseNo;

    @NotBlank(message = "Physical address is required")
    private String address;

    @NotBlank(message = "District is required")
    private String district;

    @NotNull(message = "Latitude is required")
    private Double latitude;

    @NotNull(message = "Longitude is required")
    private Double longitude;

    private String directorName;
    private boolean is24h;
}

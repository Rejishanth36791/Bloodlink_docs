package lk.bloodlink.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterRequesterRequest {
    @NotBlank(message = "Full name is required")
    private String fullName;

    @Email(message = "Invalid email format")
    private String email;

    @NotBlank(message = "Phone number is required")
    private String phone;

    @Size(min = 8, message = "Password must be at least 8 characters")
    private String password;

    @NotBlank(message = "Requester type is required")
    @Pattern(regexp = "PATIENT_FAMILY|HOSPITAL_STAFF", message = "Requester type must be PATIENT_FAMILY or HOSPITAL_STAFF")
    private String requesterType;

    private String district;
    private String city;
}

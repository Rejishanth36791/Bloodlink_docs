package lk.bloodlink;

import lk.bloodlink.model.entity.User;
import lk.bloodlink.model.enums.AccountStatus;
import lk.bloodlink.model.enums.UserRole;
import lk.bloodlink.repository.UserRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.util.StringUtils;

import java.util.Arrays;

@Slf4j
@EnableScheduling
@SpringBootApplication
public class BloodLinkApplication {

    public static void main(String[] args) {
        SpringApplication.run(BloodLinkApplication.class, args);
    }

    @Bean
    public CommandLineRunner bootstrapAdmin(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            @org.springframework.beans.factory.annotation.Value("${bloodlink.admin.email:admin@bloodlink.lk}") String defaultAdminEmail,
            @org.springframework.beans.factory.annotation.Value("${bloodlink.admin.password:AdminSecurePassword123!}") String defaultAdminPassword) {
        return args -> {
            boolean shouldBootstrap = Arrays.asList(args).contains("--bootstrap-admin") ||
                    "true".equalsIgnoreCase(System.getenv("BOOTSTRAP_ADMIN")) ||
                    StringUtils.hasText(defaultAdminEmail);

            String adminEmail = StringUtils.hasText(System.getenv("ADMIN_EMAIL")) ? System.getenv("ADMIN_EMAIL") : defaultAdminEmail;
            String adminPassword = StringUtils.hasText(System.getenv("ADMIN_PASSWORD")) ? System.getenv("ADMIN_PASSWORD") : defaultAdminPassword;

            if (shouldBootstrap && StringUtils.hasText(adminEmail) && StringUtils.hasText(adminPassword)) {
                if (!userRepository.existsByEmailIgnoreCase(adminEmail)) {
                    User admin = User.builder()
                            .role(UserRole.ADMIN)
                            .email(adminEmail.toLowerCase())
                            .phone("+94770000000")
                            .passwordHash(passwordEncoder.encode(adminPassword))
                            .fullName("BloodLink Master Admin")
                            .status(AccountStatus.ACTIVE)
                            .emailVerified(true)
                            .phoneVerified(true)
                            .build();
                    userRepository.save(admin);
                    log.info(">>> Bootstrap: First Admin account created for: {}", adminEmail);
                } else {
                    log.info(">>> Bootstrap: Admin account already exists for: {}", adminEmail);
                }
            }
        };
    }
}

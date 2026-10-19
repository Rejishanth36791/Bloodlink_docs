package lk.bloodlink.repository;

import lk.bloodlink.model.entity.User;
import lk.bloodlink.model.enums.UserRole;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {
    @Query("SELECT u FROM User u WHERE u.email = :email")
    Optional<User> findByEmailIgnoreCase(@Param("email") String email);

    Optional<User> findByPhone(String phone);
    Optional<User> findByFirebaseUid(String firebaseUid);

    @Query("SELECT CASE WHEN COUNT(u) > 0 THEN true ELSE false END FROM User u WHERE u.email = :email")
    boolean existsByEmailIgnoreCase(@Param("email") String email);

    boolean existsByPhone(String phone);
    long countByRole(UserRole role);
}

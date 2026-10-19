package lk.bloodlink.repository;

import lk.bloodlink.model.entity.RequesterProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface RequesterProfileRepository extends JpaRepository<RequesterProfile, UUID> {
    Optional<RequesterProfile> findByUserId(UUID userId);
}

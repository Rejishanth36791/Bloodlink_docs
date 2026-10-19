package lk.bloodlink.repository;

import lk.bloodlink.model.entity.RequestMatch;
import lk.bloodlink.model.enums.MatchStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface RequestMatchRepository extends JpaRepository<RequestMatch, UUID> {
    List<RequestMatch> findByRequestIdOrderByScoreDesc(UUID requestId);
    List<RequestMatch> findByDonorUserIdAndStatus(UUID donorId, MatchStatus status);
    List<RequestMatch> findByDonorUserIdOrderByNotifiedAtDesc(UUID donorId);
    Optional<RequestMatch> findByRequestIdAndDonorUserId(UUID requestId, UUID donorId);
    List<RequestMatch> findByStatusAndNotifiedAtBefore(MatchStatus status, Instant cutoff);
    boolean existsByRequestIdAndDonorUserId(UUID requestId, UUID donorId);
}

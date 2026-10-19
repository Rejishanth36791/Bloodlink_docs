package lk.bloodlink.model.entity;

import jakarta.persistence.*;
import lombok.*;

import org.springframework.data.domain.Persistable;

import java.util.UUID;

@Entity
@Table(name = "requester_profiles")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RequesterProfile implements Persistable<UUID> {

    @Id
    @Column(name = "user_id")
    private UUID userId;

    @Transient
    @Builder.Default
    private boolean isNewRecord = true;

    @Override
    public UUID getId() {
        return userId;
    }

    @Override
    public boolean isNew() {
        return isNewRecord;
    }

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private User user;

    @Column(name = "requester_type", nullable = false)
    private String requesterType;

    private String district;

    private String city;
}

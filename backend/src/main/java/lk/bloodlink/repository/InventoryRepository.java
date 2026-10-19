package lk.bloodlink.repository;

import lk.bloodlink.model.entity.Inventory;
import lk.bloodlink.model.enums.BloodComponent;
import lk.bloodlink.model.enums.BloodType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface InventoryRepository extends JpaRepository<Inventory, UUID> {
    List<Inventory> findByBankId(UUID bankId);
    Optional<Inventory> findByBankIdAndBloodTypeAndComponent(UUID bankId, BloodType bloodType, BloodComponent component);
    List<Inventory> findByBankIdAndUnitsAvailableLessThan(UUID bankId, int threshold);
}

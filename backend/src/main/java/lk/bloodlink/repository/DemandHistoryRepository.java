package lk.bloodlink.repository;

import lk.bloodlink.model.entity.DemandHistory;
import lk.bloodlink.model.enums.BloodType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface DemandHistoryRepository extends JpaRepository<DemandHistory, Long> {
    List<DemandHistory> findByDistrictAndBloodTypeOrderByDayAsc(String district, BloodType bloodType);
    Optional<DemandHistory> findByDistrictAndBloodTypeAndDay(String district, BloodType bloodType, LocalDate day);
}

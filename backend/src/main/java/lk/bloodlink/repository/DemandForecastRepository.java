package lk.bloodlink.repository;

import lk.bloodlink.model.entity.DemandForecast;
import lk.bloodlink.model.enums.BloodType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
public interface DemandForecastRepository extends JpaRepository<DemandForecast, Long> {
    List<DemandForecast> findByBankIdAndForecastDateGreaterThanEqualOrderByForecastDateAsc(UUID bankId, LocalDate fromDate);
    List<DemandForecast> findByDistrictAndBloodTypeAndForecastDateGreaterThanEqualOrderByForecastDateAsc(
            String district, BloodType bloodType, LocalDate fromDate);
}

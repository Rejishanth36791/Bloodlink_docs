from datetime import date, timedelta
from app.eligibility import evaluate_eligibility, EligibilityRequest
from app.ranking import rank_candidates, RankRequest, CandidateInput
from app.forecasting import generate_forecast, ForecastRequest, DemandDataPoint

def test_eligibility_healthy_donor():
    req = EligibilityRequest(
        age=25,
        gender="MALE",
        weight_kg=68.0,
        last_donation_date=date.today() - timedelta(days=120),
        has_recent_fever_infection=False,
        has_recent_medications=False,
        has_recent_travel=False,
        has_recent_tattoo_piercing=False,
        is_pregnant_or_nursing=False,
        hemoglobin=14.5
    )
    res = evaluate_eligibility(req)
    assert res.isEligible is True
    assert res.readinessScore >= 80

def test_eligibility_underweight():
    req = EligibilityRequest(
        age=22,
        weight_kg=45.0,
        has_recent_fever_infection=False
    )
    res = evaluate_eligibility(req)
    assert res.isEligible is False
    assert any("weight" in r.lower() for r in res.reasons)

def test_eligibility_cooldown_active():
    req = EligibilityRequest(
        age=30,
        weight_kg=72.0,
        last_donation_date=date.today() - timedelta(days=30)
    )
    res = evaluate_eligibility(req)
    assert res.isEligible is False
    assert any("cooldown" in r.lower() for r in res.reasons)

def test_ranking():
    candidates = [
        CandidateInput(donor_id="d1", blood_type="O+", distance_km=2.0, reliability_score=0.95, exact_match=True),
        CandidateInput(donor_id="d2", blood_type="O-", distance_km=15.0, reliability_score=0.80, exact_match=False),
        CandidateInput(donor_id="d3", blood_type="O+", distance_km=5.0, reliability_score=0.90, exact_match=True)
    ]
    req = RankRequest(target_blood_type="O+", max_radius_km=40.0, candidates=candidates)
    res = rank_candidates(req)
    assert len(res) == 3
    # First candidate should be d1 because closest, exact match and highest reliability
    assert res[0].donor_id == "d1"

def test_forecast_insufficient_data():
    req = ForecastRequest(
        district="Colombo",
        blood_type="O+",
        history=[
            DemandDataPoint(day=date.today() - timedelta(days=2), units_requested=5, units_fulfilled=4)
        ]
    )
    res = generate_forecast(req)
    assert res.status == "INSUFFICIENT_DATA"
    assert len(res.forecasts) == 0

def test_forecast_with_baseline():
    history = [
        DemandDataPoint(day=date.today() - timedelta(days=i), units_requested=10 + (i % 3), units_fulfilled=8)
        for i in range(20, 0, -1)
    ]
    req = ForecastRequest(
        district="Colombo",
        blood_type="O+",
        history=history,
        forecast_days=7
    )
    res = generate_forecast(req)
    assert res.status == "SUCCESS"
    assert len(res.forecasts) == 7

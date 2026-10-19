import yaml
from pathlib import Path
from datetime import date, timedelta
from typing import List, Optional
from pydantic import BaseModel

CONFIG_PATH = Path(__file__).parent.parent / "config" / "eligibility_rules.yaml"

def load_rules():
    if CONFIG_PATH.exists():
        with open(CONFIG_PATH, "r") as f:
            return yaml.safe_load(f)
    return {
        "version": "1.0.0-default",
        "general": {"min_age": 18, "max_age": 60, "min_weight_kg": 50.0, "cooldown_days": 112},
        "deferral_rules": {"fever_infection_days": 14, "aspirin_hours": 48, "antibiotics_days": 7}
    }

class EligibilityRequest(BaseModel):
    age: int
    gender: Optional[str] = "MALE"
    weight_kg: float
    last_donation_date: Optional[date] = None
    has_recent_fever_infection: bool = False
    has_recent_medications: bool = False
    has_recent_travel: bool = False
    has_recent_tattoo_piercing: bool = False
    is_pregnant_or_nursing: bool = False
    hemoglobin: Optional[float] = None

class EligibilityResponse(BaseModel):
    isEligible: bool
    readinessScore: int
    reasons: List[str]
    nextEligibleDate: Optional[date]
    modelVersion: str

def evaluate_eligibility(req: EligibilityRequest) -> EligibilityResponse:
    rules = load_rules()
    reasons = []
    is_eligible = True
    deductions = 0
    today = date.today()
    next_date = today

    gen = rules.get("general", {})
    if req.age < gen.get("min_age", 18):
        is_eligible = False
        reasons.append(f"Minimum age for donation is {gen.get('min_age', 18)} years (current: {req.age}).")
        deductions += 40
    elif req.age > gen.get("max_age", 60):
        is_eligible = False
        reasons.append(f"Maximum age without special clearance is {gen.get('max_age', 60)} years.")
        deductions += 30

    if req.weight_kg < gen.get("min_weight_kg", 50.0):
        is_eligible = False
        reasons.append(f"Body weight must be at least {gen.get('min_weight_kg', 50.0)} kg (current: {req.weight_kg:.1f} kg).")
        deductions += 35

    cooldown = gen.get("cooldown_days", 112)
    if req.last_donation_date:
        days_since = (today - req.last_donation_date).days
        if days_since < cooldown:
            is_eligible = False
            remaining = cooldown - days_since
            next_allowed = req.last_donation_date + timedelta(days=cooldown)
            if next_allowed > next_date:
                next_date = next_allowed
            reasons.append(f"Mandatory cooldown period in progress ({days_since}/{cooldown} days passed, {remaining} days remaining).")
            deductions += int(40 * (remaining / cooldown))

    if req.has_recent_fever_infection:
        is_eligible = False
        reasons.append("Reported fever, flu or infection symptoms within the past 14 days.")
        deductions += 30
        potential_next = today + timedelta(days=14)
        if potential_next > next_date:
            next_date = potential_next

    if req.has_recent_medications:
        is_eligible = False
        reasons.append("Recent medication or antibiotic course active.")
        deductions += 25
        potential_next = today + timedelta(days=7)
        if potential_next > next_date:
            next_date = potential_next

    if req.has_recent_travel:
        is_eligible = False
        reasons.append("Recent exposure to designated malaria/dengue endemic zone.")
        deductions += 20
        potential_next = today + timedelta(days=28)
        if potential_next > next_date:
            next_date = potential_next

    if req.has_recent_tattoo_piercing:
        is_eligible = False
        reasons.append("Tattoo, body piercing or acupuncture within the past 12 months.")
        deductions += 40

    if req.is_pregnant_or_nursing:
        is_eligible = False
        reasons.append("Currently pregnant or nursing (deferred until 6 months post-delivery).")
        deductions += 50

    if req.hemoglobin is not None:
        min_hb = gen.get("min_hemoglobin_female", 12.5) if req.gender == "FEMALE" else gen.get("min_hemoglobin_male", 13.0)
        if req.hemoglobin < min_hb:
            is_eligible = False
            reasons.append(f"Hemoglobin level ({req.hemoglobin:.1f} g/dL) is below the clinical threshold of {min_hb} g/dL.")
            deductions += 30

    if is_eligible:
        reasons.append("Meets all NBTS criteria: Optimal weight, age, cadence, and clear screening.")
        readiness_score = max(80, 100 - deductions)
        final_next_date = today
    else:
        readiness_score = max(0, 100 - deductions)
        final_next_date = next_date

    return EligibilityResponse(
        isEligible=is_eligible,
        readinessScore=readiness_score,
        reasons=reasons,
        nextEligibleDate=final_next_date,
        modelVersion=rules.get("version", "1.0.0-nbts-sl")
    )

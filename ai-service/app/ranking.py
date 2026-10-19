from typing import List
from pydantic import BaseModel

class CandidateInput(BaseModel):
    donor_id: str
    blood_type: str
    distance_km: float
    reliability_score: float
    exact_match: bool

class RankedCandidate(BaseModel):
    donor_id: str
    blood_type: str
    distance_km: float
    reliability_score: float
    compat_score: float
    final_score: float

class RankRequest(BaseModel):
    target_blood_type: str
    max_radius_km: float = 40.0
    weight_compat: float = 0.5
    weight_proximity: float = 0.3
    weight_reliability: float = 0.2
    candidates: List[CandidateInput]

def calculate_proximity_score(distance_km: float, max_radius_km: float) -> float:
    if max_radius_km <= 0:
        return 0.0
    return max(0.0, min(1.0, 1.0 - (distance_km / max_radius_km)))

def rank_candidates(req: RankRequest) -> List[RankedCandidate]:
    results = []
    for c in req.candidates:
        compat_score = 1.0 if c.exact_match else 0.85
        prox_score = calculate_proximity_score(c.distance_km, req.max_radius_km)
        rel_score = max(0.0, min(1.0, c.reliability_score))

        final_score = (
            req.weight_compat * compat_score +
            req.weight_proximity * prox_score +
            req.weight_reliability * rel_score
        )

        results.append(RankedCandidate(
            donor_id=c.donor_id,
            blood_type=c.blood_type,
            distance_km=round(c.distance_km, 2),
            reliability_score=round(rel_score, 3),
            compat_score=round(compat_score, 3),
            final_score=round(final_score, 4)
        ))

    # Sort descending by final_score
    results.sort(key=lambda x: x.final_score, reverse=True)
    return results

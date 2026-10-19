from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List

from app.eligibility import evaluate_eligibility, EligibilityRequest, EligibilityResponse
from app.ranking import rank_candidates, RankRequest, RankedCandidate
from app.forecasting import generate_forecast, ForecastRequest, ForecastResponse

app = FastAPI(
    title="BloodLink AI Service",
    description="Microservice for Blood Donor Eligibility, Candidate Ranking, and Demand Forecasting",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def health_check():
    return {"status": "UP", "service": "bloodlink-ai-service"}

@app.post("/eligibility", response_model=EligibilityResponse)
def check_eligibility(payload: EligibilityRequest):
    return evaluate_eligibility(payload)

@app.post("/rank", response_model=List[RankedCandidate])
def rank(payload: RankRequest):
    return rank_candidates(payload)

@app.post("/forecast/run", response_model=ForecastResponse)
def forecast(payload: ForecastRequest):
    return generate_forecast(payload)

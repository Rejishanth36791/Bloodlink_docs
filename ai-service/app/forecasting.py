from datetime import date, timedelta
from typing import List, Optional, Dict
from pydantic import BaseModel
import pandas as pd
import numpy as np

class DemandDataPoint(BaseModel):
    day: date
    units_requested: int
    units_fulfilled: int

class ForecastPoint(BaseModel):
    forecast_date: date
    predicted_units: float
    lower_bound: Optional[float] = None
    upper_bound: Optional[float] = None

class ForecastRequest(BaseModel):
    district: str
    blood_type: str
    history: List[DemandDataPoint]
    forecast_days: int = 7

class ForecastResponse(BaseModel):
    district: str
    blood_type: str
    status: str  # "SUCCESS" or "INSUFFICIENT_DATA"
    message: str
    model_version: str
    forecasts: List[ForecastPoint] = []

def generate_forecast(req: ForecastRequest) -> ForecastResponse:
    if not req.history or len(req.history) < 14:
        return ForecastResponse(
            district=req.district,
            blood_type=req.blood_type,
            status="INSUFFICIENT_DATA",
            message=f"Insufficient history data ({len(req.history)} records found, minimum 14 daily records required for statistical baseline, 56 for Holt-Winters).",
            model_version="holt-winters-v1.0",
            forecasts=[]
        )

    # Convert to DataFrame
    data = [{"day": d.day, "units": d.units_requested} for d in req.history]
    df = pd.DataFrame(data)
    df["day"] = pd.to_datetime(df["day"])
    df = df.sort_values("day").set_index("day")
    # Resample daily
    df = df.asfreq("D", fill_value=0)

    last_date = df.index[-1].date()
    forecasts = []

    # If at least 56 days (8 weeks) of data, we attempt Holt-Winters
    if len(df) >= 56:
        try:
            from statsmodels.tsa.holtwinters import ExponentialSmoothing
            # Weekly seasonality (7 days)
            model = ExponentialSmoothing(
                df["units"],
                trend="add",
                seasonal="add",
                seasonal_periods=7
            ).fit()
            pred = model.forecast(req.forecast_days)
            std_err = np.std(model.resid)

            for i, val in enumerate(pred):
                f_date = last_date + timedelta(days=i + 1)
                predicted = max(0.0, float(val))
                forecasts.append(ForecastPoint(
                    forecast_date=f_date,
                    predicted_units=round(predicted, 2),
                    lower_bound=round(max(0.0, predicted - 1.96 * std_err), 2),
                    upper_bound=round(predicted + 1.96 * std_err, 2)
                ))
            return ForecastResponse(
                district=req.district,
                blood_type=req.blood_type,
                status="SUCCESS",
                message="Holt-Winters additive seasonal model fitted successfully.",
                model_version="holt-winters-v1.0",
                forecasts=forecasts
            )
        except Exception:
            # Fallback to seasonal naive below
            pass

    # Seasonal naive baseline: compare with same day last week or rolling average
    rolling_mean = df["units"].tail(14).mean()
    rolling_std = df["units"].tail(14).std()
    if np.isnan(rolling_std):
        rolling_std = 1.0

    for i in range(req.forecast_days):
        f_date = last_date + timedelta(days=i + 1)
        day_of_week = f_date.weekday()
        # Find matching weekdays in history
        matching = df[df.index.weekday == day_of_week]
        if not matching.empty:
            predicted = float(matching["units"].tail(4).mean())
        else:
            predicted = float(rolling_mean)

        predicted = max(0.0, predicted)
        forecasts.append(ForecastPoint(
            forecast_date=f_date,
            predicted_units=round(predicted, 2),
            lower_bound=round(max(0.0, predicted - 1.5 * rolling_std), 2),
            upper_bound=round(predicted + 1.5 * rolling_std, 2)
        ))

    return ForecastResponse(
        district=req.district,
        blood_type=req.blood_type,
        status="SUCCESS",
        message="Seasonal-naive baseline forecast generated.",
        model_version="seasonal-naive-v1.0",
        forecasts=forecasts
    )

"""Investor input schema and validation."""

from enum import Enum
from math import isfinite

from pydantic import BaseModel, ConfigDict, Field, field_validator


class RiskType(str, Enum):
    LOW = "Low"
    MEDIUM_HIGH = "MediumHigh"


class RiskAnalysisRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    risk_type: RiskType = Field(description="Low or MediumHigh risk preference")
    investment_amount: float = Field(gt=0, allow_inf_nan=False, description="Positive investment amount")
    investment_tenure: int = Field(gt=0, strict=True, description="Positive whole-year investment tenure")

    @field_validator("investment_amount", mode="before")
    @classmethod
    def validate_amount_type(cls, value: object) -> object:
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            raise ValueError("investment_amount must be a JSON number")
        try:
            finite = isfinite(value)
        except OverflowError:
            finite = False
        if not finite:
            raise ValueError("investment_amount must be finite")
        return value

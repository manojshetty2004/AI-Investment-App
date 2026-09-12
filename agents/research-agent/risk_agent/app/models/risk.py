"""Public risk analysis contract."""

from enum import Enum
from math import isfinite

from pydantic import BaseModel, ConfigDict, Field, field_validator


class RiskLevel(str, Enum):
    LOW = "Low"
    MEDIUM = "Medium"
    HIGH = "High"


class RiskRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    risk_level: RiskLevel = Field(description="Selected risk tolerance")
    investment_amount: float = Field(gt=0, allow_inf_nan=False, description="Positive investment amount")
    investment_tenure_years: int = Field(ge=1, strict=True, description="Whole years, at least one")

    @field_validator("investment_amount", mode="before")
    @classmethod
    def require_numeric_amount(cls, value: object) -> object:
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            raise ValueError("investment_amount must be a number")
        try:
            finite = isfinite(value)
        except OverflowError:
            finite = False
        if not finite:
            raise ValueError("investment_amount must be finite")
        return value


class RiskResponse(BaseModel):
    risk_level: RiskLevel
    investment_amount: float
    investment_tenure_years: int
    investment_strategy: str
    risk_profile: str
    recommended_assets: list[str]
    allocation: dict[str, int] = Field(description="Asset allocation percentages summing to 100")
    expected_return: str = Field(description="Illustrative annual return range; not guaranteed")
    next_agent: str = Field(description="Next agent in the TradeX workflow")

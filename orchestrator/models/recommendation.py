from decimal import Decimal
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field, field_validator


class RecommendRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")
    risk_type: Literal["Low", "MediumHigh"]
    investment_amount: Decimal = Field(gt=0, allow_inf_nan=False)
    investment_tenure: int = Field(gt=0, strict=True)

    @field_validator("investment_amount", mode="before")
    @classmethod
    def check_amount_type(cls, value: object) -> object:
        if isinstance(value, bool) or not isinstance(value, (int, float, Decimal)):
            raise ValueError("investment_amount must be a JSON number")
        return value

    @field_validator("investment_amount")
    @classmethod
    def check_precision(cls, value: Decimal) -> Decimal:
        if value.as_tuple().exponent < -2:
            raise ValueError("investment_amount supports at most two decimal places")
        return value


class RecommendResponse(BaseModel):
    risk_analysis: dict
    research_results: dict | None
    portfolio_allocation: list[dict]
    expected_return: str
    final_recommendation: str
    portfolio: dict

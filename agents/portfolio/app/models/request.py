"""Discriminated requests for low and medium/high risk flows."""

from decimal import Decimal
from typing import Annotated, Literal, Union

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator


class LowAllocation(BaseModel):
    model_config = ConfigDict(extra="forbid")

    mutual_funds: int = Field(ge=0, le=100, strict=True)
    etfs: int = Field(ge=0, le=100, strict=True)
    debt_funds: int = Field(ge=0, le=100, strict=True)

    @model_validator(mode="after")
    def check_total(self) -> "LowAllocation":
        if self.mutual_funds + self.etfs + self.debt_funds != 100:
            raise ValueError("allocation percentages must total 100")
        return self


class BasePortfolioRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    investment_amount: Decimal = Field(gt=0, allow_inf_nan=False, description="Positive amount with up to two decimal places")
    investment_tenure: int = Field(gt=0, strict=True, description="Positive whole-year tenure")

    @field_validator("investment_amount", mode="before")
    @classmethod
    def validate_amount_type(cls, value: object) -> object:
        if isinstance(value, bool) or not isinstance(value, (int, float, Decimal)):
            raise ValueError("investment_amount must be a JSON number")
        return value

    @field_validator("investment_amount")
    @classmethod
    def validate_currency_precision(cls, value: Decimal) -> Decimal:
        if value.as_tuple().exponent < -2:
            raise ValueError("investment_amount supports at most two decimal places")
        return value


class LowPortfolioRequest(BasePortfolioRequest):
    risk_type: Literal["Low"]
    allocation: LowAllocation


class MediumHighPortfolioRequest(BasePortfolioRequest):
    risk_type: Literal["MediumHigh"]
    recommended_stocks: list[str] = Field(min_length=2, max_length=100)

    @field_validator("recommended_stocks")
    @classmethod
    def validate_stocks(cls, stocks: list[str]) -> list[str]:
        cleaned = [stock.strip().upper() for stock in stocks]
        if any(not stock or len(stock) > 20 or not stock.isascii() or not all(c.isalnum() or c in ".-" for c in stock) for stock in cleaned):
            raise ValueError("recommended_stocks must contain valid ticker symbols")
        if len(set(cleaned)) != len(cleaned):
            raise ValueError("recommended_stocks must be unique")
        return cleaned


PortfolioRequest = Annotated[
    Union[LowPortfolioRequest, MediumHighPortfolioRequest],
    Field(discriminator="risk_type"),
]

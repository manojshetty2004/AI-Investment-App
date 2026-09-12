"""Final portfolio response contract."""

from typing import Literal, Union

from pydantic import BaseModel, Field


class FundPosition(BaseModel):
    instrument: str
    allocation_percentage: int = Field(ge=0, le=100)
    allocation_amount: float = Field(ge=0)


class StockPosition(BaseModel):
    stock: str
    allocation_percentage: int = Field(ge=0, le=100)
    allocation_amount: float = Field(ge=0)


class PortfolioResponse(BaseModel):
    risk_type: Literal["Low", "MediumHigh"]
    investment_amount: float
    investment_tenure: int
    portfolio: list[Union[FundPosition, StockPosition]]
    expected_return: str = Field(description="Illustrative annual range, not guaranteed")
    summary: str

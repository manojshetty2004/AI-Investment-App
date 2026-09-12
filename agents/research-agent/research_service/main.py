"""Local sample-data Research Agent for the TradeX integration workflow."""

import logging
import os
from decimal import Decimal
from enum import Enum

from fastapi import FastAPI
from pydantic import BaseModel, ConfigDict, Field, field_validator

logging.basicConfig(level=os.getenv("RESEARCH_AGENT_LOG_LEVEL", "INFO").upper())
logger = logging.getLogger(__name__)


class RiskType(str, Enum):
    MEDIUM_HIGH = "MediumHigh"


class ResearchRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")
    risk_type: RiskType
    investment_amount: Decimal = Field(gt=0, allow_inf_nan=False)
    investment_tenure: int = Field(gt=0, strict=True)

    @field_validator("investment_amount", mode="before")
    @classmethod
    def numeric_amount(cls, value: object) -> object:
        if isinstance(value, bool) or not isinstance(value, (int, float, Decimal)):
            raise ValueError("investment_amount must be a JSON number")
        return value


class ResearchResponse(BaseModel):
    recommended_stocks: list[str] = Field(min_length=2)
    market_sentiment: str
    data_status: str = Field(description="Identifies whether recommendations use live or sample data")
    summary: str


def sample_stocks() -> list[str]:
    """Read user-supplied example symbols; fail clearly if configuration is invalid."""
    raw = os.getenv("RESEARCH_SAMPLE_STOCKS", "TCS,INFY,RELIANCE,HDFCBANK")
    stocks = [value.strip().upper() for value in raw.split(",")]
    if len(stocks) < 2 or len(stocks) > 100 or len(set(stocks)) != len(stocks):
        raise ValueError("RESEARCH_SAMPLE_STOCKS must contain 2-100 unique symbols")
    if any(not stock or len(stock) > 20 or not stock.isascii() or not all(character.isalnum() or character in ".-" for character in stock) for stock in stocks):
        raise ValueError("RESEARCH_SAMPLE_STOCKS contains an invalid symbol")
    return stocks


app = FastAPI(
    title="TradeX Research Agent (Sample Data)",
    description="Provides clearly labeled sample symbols for local workflow testing; no live market analysis.",
    version="0.1.0",
)


@app.post("/research/analyze", response_model=ResearchResponse, tags=["Research"])
async def analyze(request: ResearchRequest) -> ResearchResponse:
    logger.info("Generated sample research for tenure=%s", request.investment_tenure)
    return ResearchResponse(
        recommended_stocks=sample_stocks(),
        market_sentiment="Not assessed",
        data_status="sample",
        summary="Sample stock symbols for local integration testing; no live research or market sentiment assessment.",
    )

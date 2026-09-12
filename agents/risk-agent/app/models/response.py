"""Strategy response schema shared with downstream consumers."""

from pydantic import BaseModel, Field

from app.models.request import RiskType


class RiskAnalysisResponse(BaseModel):
    risk_type: RiskType
    investment_amount: float
    investment_tenure: int
    strategy: str
    allocation: dict[str, int] = Field(description="Percentages totaling 100")
    expected_return: str = Field(description="Illustrative annual range, not guaranteed")
    risk_summary: str
    next_agent: str = Field(description="portfolio_agent or research_agent")

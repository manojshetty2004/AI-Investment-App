"""Generate a strategy based on the selected risk type."""

import logging

from app.core.config import STRATEGIES
from app.models.request import RiskAnalysisRequest
from app.models.response import RiskAnalysisResponse

logger = logging.getLogger(__name__)


def analyze_risk(request: RiskAnalysisRequest) -> RiskAnalysisResponse:
    config = STRATEGIES[request.risk_type]
    summary = (
        f"User selected {request.risk_type.value} Risk with "
        f"{request.investment_tenure}-year tenure. "
        f"{config.name} investment strategy recommended."
    )
    logger.info(
        "Generated risk strategy risk_type=%s tenure=%s next_agent=%s",
        request.risk_type.value,
        request.investment_tenure,
        config.next_agent,
    )
    return RiskAnalysisResponse(
        risk_type=request.risk_type,
        investment_amount=request.investment_amount,
        investment_tenure=request.investment_tenure,
        strategy=config.name,
        allocation=dict(config.allocation),
        expected_return=config.expected_return,
        risk_summary=summary,
        next_agent=config.next_agent,
    )

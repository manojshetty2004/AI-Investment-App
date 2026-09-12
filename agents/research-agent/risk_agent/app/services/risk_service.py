"""Risk profiling and allocation business logic."""

import logging

from app.config.strategies import STRATEGIES
from app.models.risk import RiskRequest, RiskResponse

logger = logging.getLogger(__name__)


def analyze_risk(request: RiskRequest) -> RiskResponse:
    strategy = STRATEGIES[request.risk_level]
    logger.info("Generated risk strategy for level=%s tenure=%s", request.risk_level.value, request.investment_tenure_years)
    return RiskResponse(
        risk_level=request.risk_level,
        investment_amount=request.investment_amount,
        investment_tenure_years=request.investment_tenure_years,
        investment_strategy=strategy.name,
        risk_profile=strategy.profile,
        recommended_assets=list(strategy.assets),
        allocation=dict(strategy.allocation),
        expected_return=strategy.expected_return,
        next_agent=strategy.next_agent,
    )

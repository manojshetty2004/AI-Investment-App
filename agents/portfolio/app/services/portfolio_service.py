"""Deterministic portfolio construction and currency allocation."""

import logging
from decimal import Decimal, ROUND_DOWN

from app.core.config import EXPECTED_RETURNS, FOUR_STOCK_WEIGHTS, LOW_INSTRUMENTS
from app.models.request import LowPortfolioRequest, PortfolioRequest
from app.models.response import FundPosition, PortfolioResponse, StockPosition

logger = logging.getLogger(__name__)
CENT = Decimal("0.01")


def calculate_allocation_amounts(amount: Decimal, percentages: list[int]) -> list[Decimal]:
    """Distribute whole cents by largest fractional remainder, preserving the total."""
    if not percentages or sum(percentages) != 100 or any(p < 0 for p in percentages):
        raise ValueError("percentages must be nonnegative and sum to 100")
    if amount <= 0 or amount != amount.quantize(CENT):
        raise ValueError("amount must be positive with at most two decimal places")
    exact_cents = [amount * percentage / 100 / CENT for percentage in percentages]
    whole_cents = [int(value.to_integral_value(rounding=ROUND_DOWN)) for value in exact_cents]
    remaining = int(amount / CENT) - sum(whole_cents)
    order = sorted(range(len(percentages)), key=lambda index: (-(exact_cents[index] - whole_cents[index]), index))
    for index in order[:remaining]:
        whole_cents[index] += 1
    return [Decimal(cents) * CENT for cents in whole_cents]


def stock_weights(count: int) -> list[int]:
    """Use sample weights for four stocks; otherwise split evenly in whole percentages."""
    if count < 2 or count > 100:
        raise ValueError("stock count must be between 2 and 100")
    if count == 4:
        return list(FOUR_STOCK_WEIGHTS)
    base, remainder = divmod(100, count)
    return [base + (1 if index < remainder else 0) for index in range(count)]


def build_portfolio(request: PortfolioRequest) -> PortfolioResponse:
    if isinstance(request, LowPortfolioRequest):
        allocation = request.allocation.model_dump()
        keys = list(LOW_INSTRUMENTS)
        percentages = [allocation[key] for key in keys]
        amounts = calculate_allocation_amounts(request.investment_amount, percentages)
        positions = [
            FundPosition(
                instrument=LOW_INSTRUMENTS[key],
                allocation_percentage=percentage,
                allocation_amount=float(amount),
            )
            for key, percentage, amount in zip(keys, percentages, amounts)
        ]
        summary = "Portfolio generated using Risk Agent allocation and user risk profile."
    else:
        percentages = stock_weights(len(request.recommended_stocks))
        amounts = calculate_allocation_amounts(request.investment_amount, percentages)
        positions = [
            StockPosition(stock=stock, allocation_percentage=percentage, allocation_amount=float(amount))
            for stock, percentage, amount in zip(request.recommended_stocks, percentages, amounts)
        ]
        summary = "Portfolio generated using Research Agent stock recommendations and user risk profile."

    logger.info("Generated portfolio risk_type=%s tenure=%s positions=%s", request.risk_type, request.investment_tenure, len(positions))
    return PortfolioResponse(
        risk_type=request.risk_type,
        investment_amount=float(request.investment_amount),
        investment_tenure=request.investment_tenure,
        portfolio=positions,
        expected_return=EXPECTED_RETURNS[request.risk_type],
        summary=summary,
    )

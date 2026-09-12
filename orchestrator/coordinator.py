"""Route a validated request through the required agent sequence."""

import httpx

from orchestrator.models.recommendation import RecommendRequest, RecommendResponse
from orchestrator.services import portfolio_client, research_client, risk_client
from orchestrator.services.base import AgentError


async def coordinate(request: RecommendRequest, client: httpx.AsyncClient) -> RecommendResponse:
    base = {
        "risk_type": request.risk_type,
        "investment_amount": float(request.investment_amount),
        "investment_tenure": request.investment_tenure,
    }
    risk = await risk_client.analyze(client, base)
    if risk.get("risk_type") != request.risk_type or risk.get("next_agent") != ("portfolio_agent" if request.risk_type == "Low" else "research_agent"):
        raise AgentError("risk_agent", "inconsistent routing response")

    research = None
    portfolio_payload = dict(base)
    if request.risk_type == "Low":
        allocation = risk.get("allocation")
        if not isinstance(allocation, dict):
            raise AgentError("risk_agent", "missing allocation")
        portfolio_payload["allocation"] = allocation
    else:
        research = await research_client.research(client, base)
        stocks = research.get("recommended_stocks")
        if not isinstance(stocks, list) or len(stocks) < 2:
            raise AgentError("research_agent", "missing stock recommendations")
        portfolio_payload["recommended_stocks"] = stocks

    portfolio = await portfolio_client.generate(client, portfolio_payload)
    positions = portfolio.get("portfolio")
    if not isinstance(positions, list) or not isinstance(portfolio.get("expected_return"), str):
        raise AgentError("portfolio_agent", "invalid portfolio response")
    final_recommendation = portfolio.get("summary", "Portfolio generated.")
    if research is not None and research.get("data_status") == "sample":
        final_recommendation += " Sample stock symbols only; no live market research was performed."
    return RecommendResponse(
        risk_analysis=risk,
        research_results=research,
        portfolio_allocation=positions,
        expected_return=portfolio["expected_return"],
        final_recommendation=final_recommendation,
        portfolio=portfolio,
    )

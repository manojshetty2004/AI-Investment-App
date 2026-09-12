"""Portfolio generation route."""

from fastapi import APIRouter

from app.models.request import PortfolioRequest
from app.models.response import PortfolioResponse
from app.services.portfolio_service import build_portfolio

router = APIRouter(prefix="/portfolio", tags=["Portfolio"])


@router.post(
    "/generate",
    response_model=PortfolioResponse,
    summary="Generate final investment portfolio",
    responses={422: {"description": "Invalid risk allocation or stock recommendations"}},
)
async def generate(request: PortfolioRequest) -> PortfolioResponse:
    """Build the final recommendation for the selected risk route."""
    return build_portfolio(request)

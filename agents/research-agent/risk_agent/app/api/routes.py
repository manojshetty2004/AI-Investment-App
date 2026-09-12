"""Risk analysis HTTP route."""

from fastapi import APIRouter

from app.models.risk import RiskRequest, RiskResponse
from app.services.risk_service import analyze_risk

router = APIRouter(prefix="/risk", tags=["Risk"])


@router.post(
    "/analyze",
    response_model=RiskResponse,
    summary="Generate an investment risk strategy",
    responses={422: {"description": "Invalid request fields"}},
)
async def analyze(request: RiskRequest) -> RiskResponse:
    """Validate inputs and return the allocation for the selected risk level."""
    return analyze_risk(request)

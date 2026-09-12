"""Risk analysis API routes."""

from fastapi import APIRouter

from app.models.request import RiskAnalysisRequest
from app.models.response import RiskAnalysisResponse
from app.services.risk_service import analyze_risk

router = APIRouter(prefix="/risk", tags=["Risk"])


@router.post(
    "/analyze",
    response_model=RiskAnalysisResponse,
    summary="Generate an investment strategy",
    responses={422: {"description": "Invalid investor input"}},
)
async def analyze(request: RiskAnalysisRequest) -> RiskAnalysisResponse:
    """Return a deterministic risk strategy and downstream routing target."""
    return analyze_risk(request)

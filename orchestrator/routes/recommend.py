import logging
from collections import deque
from datetime import datetime, timezone

import httpx
from fastapi import APIRouter, HTTPException, Request

from orchestrator.coordinator import coordinate
from orchestrator.models.recommendation import RecommendRequest, RecommendResponse
from orchestrator.services.base import AgentError, agent_url

router = APIRouter()
logger = logging.getLogger(__name__)
events: deque[dict] = deque(maxlen=200)


def record(agent: str, status: str) -> None:
    events.append({"timestamp": datetime.now(timezone.utc).isoformat(), "agent": agent, "status": status})


@router.post("/recommend", response_model=RecommendResponse)
async def recommend(payload: RecommendRequest, request: Request) -> RecommendResponse:
    try:
        result = await coordinate(payload, request.app.state.http_client)
        record("risk_agent", "completed")
        if result.research_results is not None:
            record("research_agent", "completed")
        record("portfolio_agent", "completed")
        record("orchestrator", "completed")
        return result
    except AgentError as exc:
        logger.warning("Recommendation failed at %s: %s", exc.agent, exc.reason)
        record(exc.agent, "failed")
        raise HTTPException(status_code=503, detail={"agent": exc.agent, "message": exc.reason}) from exc


@router.get("/agents/status")
async def agent_status(request: Request) -> dict:
    urls = {
        "risk_agent": agent_url("risk", "http://127.0.0.1:8001"),
        "research_agent": agent_url("research", "http://127.0.0.1:8003"),
        "portfolio_agent": agent_url("portfolio", "http://127.0.0.1:8002"),
    }
    result = {}
    for name, url in urls.items():
        try:
            response = await request.app.state.http_client.get(f"{url}/openapi.json", timeout=2.0)
            result[name] = "available" if response.status_code == 200 else "unavailable"
        except httpx.HTTPError:
            result[name] = "unavailable"
    return {"agents": result}


@router.get("/agents/logs")
async def agent_logs() -> list[dict]:
    """Return recent in-process workflow events without investment amounts or secrets."""
    return list(events)

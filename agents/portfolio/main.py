"""Standalone ASGI entry point: uvicorn main:app."""

import logging
import os

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from app.api.routes import router

logging.basicConfig(
    level=os.getenv("PORTFOLIO_AGENT_LOG_LEVEL", "INFO").upper(),
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="TradeX Portfolio Agent",
    description="Generate a final investment allocation from Risk Agent and optional Research Agent output.",
    version="1.0.0",
)
app.include_router(router)


@app.exception_handler(Exception)
async def handle_unexpected_error(request: Request, exc: Exception) -> JSONResponse:
    logger.exception("Unexpected error handling %s %s", request.method, request.url.path)
    return JSONResponse(status_code=500, content={"detail": "Internal server error"})

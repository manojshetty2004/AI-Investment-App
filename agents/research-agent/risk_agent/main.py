"""ASGI entry point: uvicorn main:app."""

from app.api.routes import router
from app.utils.logging import configure_logging
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import logging

configure_logging()
logger = logging.getLogger(__name__)

app = FastAPI(
    title="TradeX Risk Agent",
    description="Deterministic risk profiling and allocation for TradeX agents.",
    version="1.0.0",
)
app.include_router(router)


@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    logger.exception("Unhandled error while processing %s %s", request.method, request.url.path)
    return JSONResponse(status_code=500, content={"detail": "Internal server error"})

"""Run from repository root: uvicorn orchestrator.main:app --port 8000."""

import logging
import os
from contextlib import asynccontextmanager

import httpx
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from orchestrator.routes.recommend import router

logging.basicConfig(level=os.getenv("ORCHESTRATOR_LOG_LEVEL", "INFO").upper())


@asynccontextmanager
async def lifespan(app: FastAPI):
    async with httpx.AsyncClient(timeout=httpx.Timeout(10.0, connect=3.0)) as client:
        app.state.http_client = client
        yield


app = FastAPI(title="TradeX Orchestrator", version="1.0.0", lifespan=lifespan)
origins = [origin.strip() for origin in os.getenv("TRADEX_CORS_ORIGINS", "http://localhost:8080,http://127.0.0.1:8080").split(",") if origin.strip()]
app.add_middleware(CORSMiddleware, allow_origins=origins, allow_methods=["GET", "POST"], allow_headers=["Content-Type"])
app.include_router(router)

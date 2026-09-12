import httpx

from orchestrator.services.base import agent_url, post_agent


async def analyze(client: httpx.AsyncClient, payload: dict) -> dict:
    return await post_agent(client, "risk_agent", f"{agent_url('risk', 'http://127.0.0.1:8001')}/risk/analyze", payload)

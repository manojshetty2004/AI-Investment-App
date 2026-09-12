import httpx

from orchestrator.services.base import agent_url, post_agent


async def generate(client: httpx.AsyncClient, payload: dict) -> dict:
    return await post_agent(client, "portfolio_agent", f"{agent_url('portfolio', 'http://127.0.0.1:8002')}/portfolio/generate", payload)

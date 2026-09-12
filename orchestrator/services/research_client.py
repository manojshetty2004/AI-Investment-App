import httpx

from orchestrator.services.base import agent_url, post_agent


async def research(client: httpx.AsyncClient, payload: dict) -> dict:
    return await post_agent(client, "research_agent", f"{agent_url('research', 'http://127.0.0.1:8003')}/research/analyze", payload)

import os

import httpx


class AgentError(Exception):
    def __init__(self, agent: str, reason: str):
        self.agent = agent
        self.reason = reason
        super().__init__(f"{agent}: {reason}")


def agent_url(name: str, default: str) -> str:
    return os.getenv(f"{name.upper()}_AGENT_URL", default).rstrip("/")


async def post_agent(client: httpx.AsyncClient, agent: str, url: str, payload: dict) -> dict:
    try:
        response = await client.post(url, json=payload)
        response.raise_for_status()
        result = response.json()
        if not isinstance(result, dict):
            raise ValueError("response must be an object")
        return result
    except (httpx.HTTPError, ValueError) as exc:
        raise AgentError(agent, "unavailable or returned an invalid response") from exc

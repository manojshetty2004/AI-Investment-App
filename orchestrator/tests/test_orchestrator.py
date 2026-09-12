import httpx
from fastapi.testclient import TestClient

from orchestrator.main import app


def run_request(risk_type: str, research_available: bool = True):
    calls = []

    def handle(request: httpx.Request) -> httpx.Response:
        calls.append(request.url.path)
        if request.url.path == "/risk/analyze":
            return httpx.Response(200, json={
                "risk_type": risk_type,
                "allocation": {"mutual_funds": 60, "etfs": 25, "debt_funds": 15},
                "strategy": "Conservative" if risk_type == "Low" else "Growth",
                "risk_summary": "Risk analysis complete.",
                "next_agent": "portfolio_agent" if risk_type == "Low" else "research_agent",
            })
        if request.url.path == "/research/analyze":
            if not research_available:
                return httpx.Response(503)
            return httpx.Response(200, json={"recommended_stocks": ["TCS", "INFY"], "market_sentiment": "Not assessed", "data_status": "sample"})
        if request.url.path == "/portfolio/generate":
            return httpx.Response(200, json={
                "portfolio": [{"stock": "TCS", "allocation_percentage": 50, "allocation_amount": 50000}],
                "expected_return": "12-18%",
                "summary": "Portfolio generated.",
            })
        if request.url.path == "/openapi.json":
            return httpx.Response(200, json={"openapi": "3.1.0"})
        return httpx.Response(404)

    with TestClient(app) as client:
        app.state.http_client = httpx.AsyncClient(transport=httpx.MockTransport(handle))
        response = client.post("/recommend", json={"risk_type": risk_type, "investment_amount": 100000, "investment_tenure": 5})
        logs = client.get("/agents/logs")
        status = client.get("/agents/status")
    return response, calls, logs, status


def test_low_route_skips_research():
    response, calls, logs, status = run_request("Low")
    assert response.status_code == 200
    assert calls[:2] == ["/risk/analyze", "/portfolio/generate"]
    body = response.json()
    assert body["research_results"] is None
    assert body["risk_analysis"]["strategy"] == "Conservative"
    assert body["portfolio_allocation"][0]["stock"] == "TCS"
    assert logs.status_code == 200 and logs.json()[-1]["status"] == "completed"
    assert status.json()["agents"]["risk_agent"] == "available"


def test_medium_high_route_calls_research():
    response, calls, _, _ = run_request("MediumHigh")
    assert response.status_code == 200
    assert calls[:3] == ["/risk/analyze", "/research/analyze", "/portfolio/generate"]
    assert response.json()["research_results"]["recommended_stocks"] == ["TCS", "INFY"]
    assert "Sample stock symbols" in response.json()["final_recommendation"]


def test_research_failure_is_reported_without_portfolio_call():
    response, calls, _, _ = run_request("MediumHigh", research_available=False)
    assert response.status_code == 503
    assert response.json()["detail"]["agent"] == "research_agent"
    assert calls[:2] == ["/risk/analyze", "/research/analyze"]
    assert "/portfolio/generate" not in calls


def test_invalid_request_returns_422():
    with TestClient(app) as client:
        response = client.post("/recommend", json={"risk_type": "High", "investment_amount": 0, "investment_tenure": 0})
    assert response.status_code == 422

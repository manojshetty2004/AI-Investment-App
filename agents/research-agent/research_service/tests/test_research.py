from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


def test_sample_research_contract():
    response = client.post("/research/analyze", json={
        "risk_type": "MediumHigh", "investment_amount": 100000, "investment_tenure": 5,
    })
    assert response.status_code == 200
    assert response.json() == {
        "recommended_stocks": ["TCS", "INFY", "RELIANCE", "HDFCBANK"],
        "market_sentiment": "Not assessed",
        "data_status": "sample",
        "summary": "Sample stock symbols for local integration testing; no live research or market sentiment assessment.",
    }


def test_rejects_low_risk_and_invalid_amount():
    assert client.post("/research/analyze", json={
        "risk_type": "Low", "investment_amount": 100000, "investment_tenure": 5,
    }).status_code == 422
    assert client.post("/research/analyze", json={
        "risk_type": "MediumHigh", "investment_amount": 0, "investment_tenure": 5,
    }).status_code == 422

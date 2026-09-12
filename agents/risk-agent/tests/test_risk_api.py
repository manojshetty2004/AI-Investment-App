"""API contract tests for upstream and downstream integrations."""

import pytest
from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


@pytest.mark.parametrize(
    ("risk_type", "strategy", "allocation", "expected_return", "next_agent"),
    [
        ("Low", "Conservative", {"mutual_funds": 60, "etfs": 25, "debt_funds": 15}, "8-10%", "portfolio_agent"),
        ("MediumHigh", "Growth", {"stocks": 70, "etfs": 20, "cash": 10}, "12-18%", "research_agent"),
    ],
)
def test_analyze(risk_type, strategy, allocation, expected_return, next_agent):
    response = client.post("/risk/analyze", json={
        "risk_type": risk_type,
        "investment_amount": 100000,
        "investment_tenure": 5,
    })
    assert response.status_code == 200
    body = response.json()
    assert body == {
        "risk_type": risk_type,
        "investment_amount": 100000,
        "investment_tenure": 5,
        "strategy": strategy,
        "allocation": allocation,
        "expected_return": expected_return,
        "risk_summary": f"User selected {risk_type} Risk with 5-year tenure. {strategy} investment strategy recommended.",
        "next_agent": next_agent,
    }
    assert sum(body["allocation"].values()) == 100


@pytest.mark.parametrize("field,value", [
    ("risk_type", "High"),
    ("risk_type", "low"),
    ("investment_amount", 0),
    ("investment_amount", -1),
    ("investment_amount", "100000"),
    ("investment_amount", True),
    ("investment_tenure", 0),
    ("investment_tenure", -1),
    ("investment_tenure", 1.5),
    ("investment_tenure", True),
])
def test_invalid_input_returns_422(field, value):
    payload = {"risk_type": "Low", "investment_amount": 100000, "investment_tenure": 5}
    payload[field] = value
    assert client.post("/risk/analyze", json=payload).status_code == 422


def test_missing_or_unknown_field_returns_422():
    assert client.post("/risk/analyze", json={}).status_code == 422
    assert client.post("/risk/analyze", json={
        "risk_type": "Low", "investment_amount": 100, "investment_tenure": 1, "extra": 1,
    }).status_code == 422


def test_very_large_amount_returns_422():
    payload = '{"risk_type":"Low","investment_amount":' + ('9' * 400) + ',"investment_tenure":5}'
    assert client.post("/risk/analyze", content=payload, headers={"Content-Type": "application/json"}).status_code == 422


def test_openapi_documents_endpoint():
    response = client.get("/openapi.json")
    assert response.status_code == 200
    assert "/risk/analyze" in response.json()["paths"]

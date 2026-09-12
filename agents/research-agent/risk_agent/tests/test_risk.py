"""Public contract and allocation tests."""

import pytest
from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


@pytest.mark.parametrize(
    ("level", "name", "allocation", "return_range", "next_agent"),
    [
        ("Low", "Conservative", {"mutual_funds": 60, "etf": 25, "bonds": 15}, "8-10%", "portfolio_agent"),
        ("Medium", "Balanced", {"stocks": 50, "mutual_funds": 30, "etf": 20}, "10-12%", "research_agent"),
        ("High", "Aggressive", {"stocks": 70, "etf": 20, "cash": 10}, "12-15%", "research_agent"),
    ],
)
def test_analyze_contract(level, name, allocation, return_range, next_agent):
    response = client.post("/risk/analyze", json={
        "risk_level": level,
        "investment_amount": 100000,
        "investment_tenure_years": 5,
    })
    assert response.status_code == 200
    body = response.json()
    assert body["risk_level"] == level
    assert body["investment_amount"] == 100000
    assert body["investment_tenure_years"] == 5
    assert body["investment_strategy"] == name
    assert body["allocation"] == allocation
    assert sum(body["allocation"].values()) == 100
    assert body["expected_return"] == return_range
    assert body["next_agent"] == next_agent
    assert body["risk_profile"]
    assert body["recommended_assets"]


@pytest.mark.parametrize("field,value", [
    ("investment_amount", 0),
    ("investment_amount", -1),
    ("investment_amount", "100000"),
    ("investment_amount", True),
    ("investment_tenure_years", 0),
    ("investment_tenure_years", 1.5),
    ("investment_tenure_years", True),
    ("risk_level", "Extreme"),
    ("risk_level", "low"),
])
def test_invalid_input_returns_422(field, value):
    payload = {"risk_level": "Low", "investment_amount": 100000, "investment_tenure_years": 5}
    payload[field] = value
    assert client.post("/risk/analyze", json=payload).status_code == 422


def test_missing_and_extra_fields_return_422():
    assert client.post("/risk/analyze", json={}).status_code == 422
    assert client.post("/risk/analyze", json={
        "risk_level": "Low", "investment_amount": 100, "investment_tenure_years": 1, "unknown": 1,
    }).status_code == 422


def test_extremely_large_amount_returns_422():
    payload = '{"risk_level":"Low","investment_amount":' + ('9' * 400) + ',"investment_tenure_years":5}'
    assert client.post("/risk/analyze", content=payload, headers={"Content-Type": "application/json"}).status_code == 422


def test_openapi_exposes_endpoint():
    response = client.get("/openapi.json")
    assert response.status_code == 200
    assert "/risk/analyze" in response.json()["paths"]

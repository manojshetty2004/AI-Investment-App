"""Portfolio API and accounting tests."""

from decimal import Decimal

import pytest
from fastapi.testclient import TestClient

from app.services.portfolio_service import calculate_allocation_amounts, stock_weights
from main import app

client = TestClient(app)

LOW = {
    "risk_type": "Low", "investment_amount": 100000, "investment_tenure": 5,
    "allocation": {"mutual_funds": 60, "etfs": 25, "debt_funds": 15},
}
MEDIUM_HIGH = {
    "risk_type": "MediumHigh", "investment_amount": 100000, "investment_tenure": 5,
    "recommended_stocks": ["TCS", "INFY", "RELIANCE", "HDFCBANK"],
}


def test_low_risk_contract():
    response = client.post("/portfolio/generate", json=LOW)
    assert response.status_code == 200
    assert response.json() == {
        "risk_type": "Low", "investment_amount": 100000, "investment_tenure": 5,
        "portfolio": [
            {"instrument": "Index Mutual Fund", "allocation_percentage": 60, "allocation_amount": 60000},
            {"instrument": "Nifty ETF", "allocation_percentage": 25, "allocation_amount": 25000},
            {"instrument": "Debt Fund", "allocation_percentage": 15, "allocation_amount": 15000},
        ],
        "expected_return": "8-10%",
        "summary": "Portfolio generated using Risk Agent allocation and user risk profile.",
    }


def test_medium_high_contract():
    response = client.post("/portfolio/generate", json=MEDIUM_HIGH)
    assert response.status_code == 200
    assert response.json() == {
        "risk_type": "MediumHigh", "investment_amount": 100000, "investment_tenure": 5,
        "portfolio": [
            {"stock": "TCS", "allocation_percentage": 30, "allocation_amount": 30000},
            {"stock": "INFY", "allocation_percentage": 25, "allocation_amount": 25000},
            {"stock": "RELIANCE", "allocation_percentage": 25, "allocation_amount": 25000},
            {"stock": "HDFCBANK", "allocation_percentage": 20, "allocation_amount": 20000},
        ],
        "expected_return": "12-18%",
        "summary": "Portfolio generated using Research Agent stock recommendations and user risk profile.",
    }


def test_other_stock_counts_are_diversified_and_fully_allocated():
    payload = {**MEDIUM_HIGH, "investment_amount": 100.01, "recommended_stocks": ["TCS", "INFY", "RELIANCE"]}
    response = client.post("/portfolio/generate", json=payload)
    assert response.status_code == 200
    positions = response.json()["portfolio"]
    assert [p["allocation_percentage"] for p in positions] == [34, 33, 33]
    assert sum(Decimal(str(p["allocation_amount"])) for p in positions) == Decimal("100.01")


def test_low_risk_uses_supplied_allocation():
    payload = {**LOW, "investment_amount": 10.01, "allocation": {"mutual_funds": 50, "etfs": 30, "debt_funds": 20}}
    response = client.post("/portfolio/generate", json=payload)
    assert response.status_code == 200
    positions = response.json()["portfolio"]
    assert [p["allocation_percentage"] for p in positions] == [50, 30, 20]
    assert sum(Decimal(str(p["allocation_amount"])) for p in positions) == Decimal("10.01")


@pytest.mark.parametrize("payload", [
    {**LOW, "investment_amount": 0},
    {**LOW, "investment_amount": -1},
    {**LOW, "investment_amount": 1.001},
    {**LOW, "investment_amount": "100"},
    {**LOW, "investment_tenure": 0},
    {**LOW, "investment_tenure": 1.5},
    {**LOW, "allocation": {"mutual_funds": 60, "etfs": 25, "debt_funds": 14}},
    {**LOW, "allocation": {"mutual_funds": 60, "etfs": 25, "debt_funds": -1}},
    {**LOW, "recommended_stocks": ["TCS", "INFY"]},
    {**MEDIUM_HIGH, "recommended_stocks": []},
    {**MEDIUM_HIGH, "recommended_stocks": ["TCS", "TCS"]},
    {**MEDIUM_HIGH, "recommended_stocks": ["TCS"]},
    {**MEDIUM_HIGH, "allocation": LOW["allocation"]},
    {**MEDIUM_HIGH, "risk_type": "High"},
])
def test_invalid_requests_return_422(payload):
    assert client.post("/portfolio/generate", json=payload).status_code == 422


def test_missing_fields_return_422():
    assert client.post("/portfolio/generate", json={}).status_code == 422


def test_allocation_math():
    assert calculate_allocation_amounts(Decimal("0.01"), [50, 30, 20]) == [Decimal("0.01"), Decimal("0.00"), Decimal("0.00")]
    tiny_positions = calculate_allocation_amounts(Decimal("0.50"), [1] * 100)
    assert sum(tiny_positions) == Decimal("0.50")
    assert all(value >= 0 for value in tiny_positions)
    assert stock_weights(3) == [34, 33, 33]


def test_openapi_exposes_portfolio_route():
    response = client.get("/openapi.json")
    assert response.status_code == 200
    assert "/portfolio/generate" in response.json()["paths"]

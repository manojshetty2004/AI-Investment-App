# TradeX Portfolio Agent

Independent Python 3.11+ FastAPI service that turns Risk Agent output, plus Research Agent stock recommendations when applicable, into a final portfolio. The TradeX orchestrator calls this service after the other agents; this service does not make outbound agent calls.

## Run

```bash
cd agents/portfolio
python3.11 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8002
```

Swagger UI is at `http://localhost:8002/docs`; OpenAPI JSON is at `/openapi.json`.

## Low risk

```bash
curl -X POST http://localhost:8002/portfolio/generate \
  -H 'Content-Type: application/json' \
  -d '{"risk_type":"Low","investment_amount":100000,"investment_tenure":5,"allocation":{"mutual_funds":60,"etfs":25,"debt_funds":15}}'
```

Response:

```json
{
  "risk_type": "Low",
  "investment_amount": 100000,
  "investment_tenure": 5,
  "portfolio": [
    {"instrument": "Index Mutual Fund", "allocation_percentage": 60, "allocation_amount": 60000},
    {"instrument": "Nifty ETF", "allocation_percentage": 25, "allocation_amount": 25000},
    {"instrument": "Debt Fund", "allocation_percentage": 15, "allocation_amount": 15000}
  ],
  "expected_return": "8-10%",
  "summary": "Portfolio generated using Risk Agent allocation and user risk profile."
}
```

The orchestrator passes `risk_type`, `investment_amount`, `investment_tenure`, and `allocation` from the Risk Agent response. Allocation must contain exactly `mutual_funds`, `etfs`, and `debt_funds`; integer percentages must total 100.

## Medium/high risk

```bash
curl -X POST http://localhost:8002/portfolio/generate \
  -H 'Content-Type: application/json' \
  -d '{"risk_type":"MediumHigh","investment_amount":100000,"investment_tenure":5,"recommended_stocks":["TCS","INFY","RELIANCE","HDFCBANK"]}'
```

Response:

```json
{
  "risk_type": "MediumHigh",
  "investment_amount": 100000,
  "investment_tenure": 5,
  "portfolio": [
    {"stock": "TCS", "allocation_percentage": 30, "allocation_amount": 30000},
    {"stock": "INFY", "allocation_percentage": 25, "allocation_amount": 25000},
    {"stock": "RELIANCE", "allocation_percentage": 25, "allocation_amount": 25000},
    {"stock": "HDFCBANK", "allocation_percentage": 20, "allocation_amount": 20000}
  ],
  "expected_return": "12-18%",
  "summary": "Portfolio generated using Research Agent stock recommendations and user risk profile."
}
```

The orchestrator combines the Risk Agent's amount and tenure with Research Agent `recommended_stocks`. At least two unique symbols are required. Four stocks receive the example 30/25/25/20 split in supplied order; other counts receive the most even whole-percentage split possible. Symbol order is meaningful. Position amounts are calculated to cents using the largest-remainder method so the total always equals the investment amount.

Invalid requests return HTTP 422. The amount must be a positive JSON number with at most two decimal places; tenure must be a positive whole number. Amounts and return ranges are illustrative; this service does not fetch live prices or estimate security-specific returns. Review the fixed return assumptions before presenting recommendations to investors.

## Tests

```bash
pytest -q
```

Set `PORTFOLIO_AGENT_LOG_LEVEL` to adjust logging verbosity; the default is `INFO`.

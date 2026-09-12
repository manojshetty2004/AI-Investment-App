# TradeX Risk Agent

Independent FastAPI service that validates an investor's selected risk level, amount, and whole-year tenure, then returns a deterministic strategy for downstream agents. Requires Python 3.11+.

## Run

```bash
cd agents/research-agent/risk_agent
python3.11 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8001
```

Swagger UI is available at `http://localhost:8001/docs`; the OpenAPI document is at `/openapi.json`.

## API

`POST /risk/analyze` accepts:

```json
{"risk_level":"Low","investment_amount":100000,"investment_tenure_years":5}
```

It returns:

```json
{
  "risk_level": "Low",
  "investment_amount": 100000,
  "investment_tenure_years": 5,
  "investment_strategy": "Conservative",
  "risk_profile": "Focus on capital preservation",
  "recommended_assets": ["Mutual Funds", "ETFs", "Bonds"],
  "allocation": {"mutual_funds": 60, "etf": 25, "bonds": 15},
  "expected_return": "8-10%",
  "next_agent": "portfolio_agent"
}
```

Amounts must be positive numeric JSON values; tenure must be an integer of at least one year; risk level must be exactly `Low`, `Medium`, or `High`. Invalid input receives HTTP 422. Allocation values are percentages that sum to 100. The amount and tenure are passed through unchanged; the selected risk level determines allocation. `next_agent` tells the caller where to route the result: Low goes directly to the Portfolio Agent; Medium and High go to the Research Agent before the Portfolio Agent. This service does not invoke downstream agents itself.

The expected return ranges are illustrative annual estimates, not forecasts or guarantees. Review them against current market assumptions before presenting them to investors.

## Test

```bash
pytest -q
```

Set `RISK_AGENT_LOG_LEVEL` to change logging verbosity (default `INFO`).

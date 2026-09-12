# TradeX Risk Agent

Independent FastAPI service for the first step of the TradeX investment workflow. Requires Python 3.11 or newer.

## Setup

```bash
cd agents/risk-agent
python3.11 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8001
```

Swagger UI: `http://localhost:8001/docs`. OpenAPI schema: `http://localhost:8001/openapi.json`.

## Analyze risk

```bash
curl -X POST http://localhost:8001/risk/analyze \
  -H 'Content-Type: application/json' \
  -d '{"risk_type":"Low","investment_amount":100000,"investment_tenure":5}'
```

Low response:

```json
{
  "risk_type": "Low",
  "investment_amount": 100000,
  "investment_tenure": 5,
  "strategy": "Conservative",
  "allocation": {"mutual_funds": 60, "etfs": 25, "debt_funds": 15},
  "expected_return": "8-10%",
  "risk_summary": "User selected Low Risk with 5-year tenure. Conservative investment strategy recommended.",
  "next_agent": "portfolio_agent"
}
```

MediumHigh request:

```bash
curl -X POST http://localhost:8001/risk/analyze \
  -H 'Content-Type: application/json' \
  -d '{"risk_type":"MediumHigh","investment_amount":100000,"investment_tenure":5}'
```

MediumHigh response:

```json
{
  "risk_type": "MediumHigh",
  "investment_amount": 100000,
  "investment_tenure": 5,
  "strategy": "Growth",
  "allocation": {"stocks": 70, "etfs": 20, "cash": 10},
  "expected_return": "12-18%",
  "risk_summary": "User selected MediumHigh Risk with 5-year tenure. Growth investment strategy recommended.",
  "next_agent": "research_agent"
}
```

Risk type must be exactly `Low` or `MediumHigh`; amount must be a finite positive JSON number; tenure must be a positive whole number of years. Invalid requests return HTTP 422. Allocation values are percentages totaling 100. The allocation policy depends on risk type; amount and tenure are passed through for downstream planning and tenure is included in the summary.

Consumers can route the full response using `next_agent`: Low goes to Portfolio Agent, MediumHigh goes to Research Agent and then Portfolio Agent. The Risk Agent does not call downstream services, so it can run and scale independently. Expected return ranges are illustrative annual estimates, not guarantees; review them against current market assumptions before displaying them as guidance.

## Tests

```bash
pytest -q
```

Set `RISK_AGENT_LOG_LEVEL` to configure logging verbosity; the default is `INFO`.

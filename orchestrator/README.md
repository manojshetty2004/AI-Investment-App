# TradeX Orchestrator

Run from the repository root with Python 3.11+:

```bash
python3.11 -m venv .venv
source .venv/bin/activate
pip install -r orchestrator/requirements.txt
uvicorn orchestrator.main:app --host 0.0.0.0 --port 8000
```

Run the Risk Agent on port 8001, Portfolio Agent on port 8002, and the local sample-data Research Agent in `agents/research-agent/research_service` on port 8003 using their individual READMEs. The medium/high route returns HTTP 503 naming `research_agent` if that service is not running. Sample research is explicitly labeled and must be replaced with live, reviewed research before use as investment guidance.

Agent URLs are configurable through `RISK_AGENT_URL`, `RESEARCH_AGENT_URL`, and `PORTFOLIO_AGENT_URL`. The values are base URLs without endpoint paths. `TRADEX_CORS_ORIGINS` accepts comma-separated Flutter web origins; the defaults are `http://localhost:8080` and `http://127.0.0.1:8080`. Use HTTPS URLs for deployed apps.

`POST /recommend` accepts `risk_type` (`Low` or `MediumHigh`), a positive numeric `investment_amount` with up to two decimal places, and a positive integer `investment_tenure` in years:

```json
{"risk_type":"Low","investment_amount":100000,"investment_tenure":5}
```

The response contains `risk_analysis`, optional `research_results`, `portfolio_allocation`, `expected_return`, `final_recommendation`, and the full `portfolio` response. Validation failures return 422; downstream failures return 503 with the agent name. `GET /agents/status` checks each agent's OpenAPI endpoint. `GET /agents/logs` returns the last 200 in-process workflow events, without investment amounts. Events reset when the process restarts and are per-worker; use centralized logging if persistence is required.

Research Agent contract expected by the orchestrator: `POST /research/analyze` accepts the same three input fields as `/recommend` and returns an object containing `recommended_stocks` with at least two symbols. It may also return `market_sentiment`. The orchestrator forwards the stock list to Portfolio Agent.

For Flutter, run with `--dart-define=TRADEX_API_BASE_URL=https://your-orchestrator.example` in deployment. The development default is `http://127.0.0.1:8000` (Android emulator: `http://10.0.2.2:8000`). The existing six-month option is rejected with a message because the current agent APIs accept positive whole-year tenures only.

Run orchestrator tests from the repository root with `python -m pytest -q orchestrator/tests`.

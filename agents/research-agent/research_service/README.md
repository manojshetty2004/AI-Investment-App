# TradeX Research Agent (local sample data)

This standalone FastAPI service completes the MediumHigh workflow for local testing. It returns the four stock symbols from the TradeX example input and explicitly marks them as `data_status: "sample"`. It does not fetch prices, analyze fundamentals, or assess market sentiment. Replace its sample-data implementation with a real research provider before using recommendations as investment guidance.

Run with Python 3.11+:

```bash
cd agents/research-agent/research_service
python3.11 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --host 127.0.0.1 --port 8003
```

`POST /research/analyze` accepts `risk_type: "MediumHigh"`, positive numeric `investment_amount`, and positive integer `investment_tenure`. It returns `recommended_stocks`, `market_sentiment`, `data_status`, and `summary`. Set `RESEARCH_SAMPLE_STOCKS` to a comma-separated list of 2–100 unique symbols to change the local sample list. Swagger UI is at `/docs`.

"""Instrument names and illustrative return ranges."""

from types import MappingProxyType

LOW_INSTRUMENTS = MappingProxyType({
    "mutual_funds": "Index Mutual Fund",
    "etfs": "Nifty ETF",
    "debt_funds": "Debt Fund",
})

EXPECTED_RETURNS = MappingProxyType({"Low": "8-10%", "MediumHigh": "12-18%"})

# Preserve the requested four-stock example. Other stock counts use an even split.
FOUR_STOCK_WEIGHTS = (30, 25, 25, 20)

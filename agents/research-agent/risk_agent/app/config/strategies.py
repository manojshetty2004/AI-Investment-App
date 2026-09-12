"""Versioned, deterministic risk-level strategy definitions."""

from dataclasses import dataclass
from types import MappingProxyType
from typing import Mapping

from app.models.risk import RiskLevel


@dataclass(frozen=True)
class Strategy:
    name: str
    profile: str
    assets: tuple[str, ...]
    allocation: Mapping[str, int]
    expected_return: str
    next_agent: str


STRATEGIES: Mapping[RiskLevel, Strategy] = MappingProxyType({
    RiskLevel.LOW: Strategy(
        "Conservative", "Focus on capital preservation",
        ("Mutual Funds", "ETFs", "Bonds"),
        MappingProxyType({"mutual_funds": 60, "etf": 25, "bonds": 15}),
        "8-10%", "portfolio_agent",
    ),
    RiskLevel.MEDIUM: Strategy(
        "Balanced", "Balanced growth strategy",
        ("Large Cap Stocks", "ETFs", "Mutual Funds"),
        MappingProxyType({"stocks": 50, "mutual_funds": 30, "etf": 20}),
        "10-12%", "research_agent",
    ),
    RiskLevel.HIGH: Strategy(
        "Aggressive", "Aggressive growth strategy",
        ("Stocks", "Sector-based Investments"),
        MappingProxyType({"stocks": 70, "etf": 20, "cash": 10}),
        "12-15%", "research_agent",
    ),
})

assert all(sum(strategy.allocation.values()) == 100 for strategy in STRATEGIES.values())

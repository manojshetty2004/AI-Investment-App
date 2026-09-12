"""Immutable, auditable allocation policy."""

from dataclasses import dataclass
from types import MappingProxyType
from typing import Mapping

from app.models.request import RiskType


@dataclass(frozen=True)
class StrategyConfig:
    name: str
    allocation: Mapping[str, int]
    expected_return: str
    next_agent: str


STRATEGIES: Mapping[RiskType, StrategyConfig] = MappingProxyType({
    RiskType.LOW: StrategyConfig(
        name="Conservative",
        allocation=MappingProxyType({"mutual_funds": 60, "etfs": 25, "debt_funds": 15}),
        expected_return="8-10%",
        next_agent="portfolio_agent",
    ),
    RiskType.MEDIUM_HIGH: StrategyConfig(
        name="Growth",
        allocation=MappingProxyType({"stocks": 70, "etfs": 20, "cash": 10}),
        expected_return="12-18%",
        next_agent="research_agent",
    ),
})

assert all(sum(config.allocation.values()) == 100 for config in STRATEGIES.values())

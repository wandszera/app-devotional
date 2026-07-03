from __future__ import annotations

from datetime import UTC, timedelta, timezone, tzinfo
from zoneinfo import ZoneInfo


FALLBACK_TIMEZONES: dict[str, tzinfo] = {
    "UTC": UTC,
    "America/Sao_Paulo": timezone(timedelta(hours=-3)),
}


def get_timezone(name: str) -> tzinfo:
    if name in FALLBACK_TIMEZONES:
        return FALLBACK_TIMEZONES[name]

    return ZoneInfo(name)

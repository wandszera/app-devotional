from __future__ import annotations

from datetime import UTC, date, datetime

from sqlalchemy.orm import Session

from app.core.timezones import get_timezone
from app.db.models import NotificationSettingsModel


def get_user_local_date(
    session: Session,
    user_id: int,
    *,
    now_utc: datetime | None = None,
) -> date:
    settings = session.get(NotificationSettingsModel, user_id)
    timezone_name = settings.timezone if settings is not None else "UTC"
    current_time = now_utc or datetime.now(UTC)
    if current_time.tzinfo is None:
        current_time = current_time.replace(tzinfo=UTC)
    return current_time.astimezone(get_timezone(timezone_name)).date()

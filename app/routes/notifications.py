from __future__ import annotations

from datetime import UTC, datetime

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db, require_admin
from app.models.schemas import (
    DueNotificationsResponse,
    NotificationDeliveryListResponse,
    NotificationDispatchResponse,
    NotificationSettings,
    NotificationSettingsUpdateRequest,
    User,
)
from app.services.notification_service import notification_service


router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.get("/settings", response_model=NotificationSettings)
def get_notification_settings(
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db),
) -> NotificationSettings:
    settings = notification_service.get_or_create_settings(session, current_user.id)
    if settings is None:
        raise HTTPException(status_code=404, detail="user not found")
    return settings


@router.put("/settings", response_model=NotificationSettings)
def update_notification_settings(
    payload: NotificationSettingsUpdateRequest,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db),
) -> NotificationSettings:
    settings = notification_service.update_settings(
        session,
        current_user.id,
        enabled=payload.enabled,
        reminder_time=payload.reminder_time,
        timezone=payload.timezone,
        push_token=payload.push_token,
    )
    if settings is None:
        raise HTTPException(status_code=404, detail="user not found")
    return settings


@router.get("/admin/due", response_model=DueNotificationsResponse)
def get_due_notifications(
    current_time: datetime | None = None,
    admin_user: User = Depends(require_admin),
    session: Session = Depends(get_db),
) -> DueNotificationsResponse:
    del admin_user
    checked_at = current_time or datetime.now(UTC)
    due_notifications = notification_service.get_due_notifications(session, checked_at)
    return DueNotificationsResponse(checked_at=checked_at, due_notifications=due_notifications)


@router.post("/admin/dispatch", response_model=NotificationDispatchResponse)
def dispatch_due_notifications(
    current_time: datetime | None = None,
    admin_user: User = Depends(require_admin),
    session: Session = Depends(get_db),
) -> NotificationDispatchResponse:
    del admin_user
    dispatched_at = current_time or datetime.now(UTC)
    deliveries = notification_service.dispatch_due_notifications(session, dispatched_at)
    return NotificationDispatchResponse(
        dispatched_at=dispatched_at,
        processed=len(deliveries),
        deliveries=deliveries,
    )


@router.get("/admin/deliveries", response_model=NotificationDeliveryListResponse)
def list_notification_deliveries(
    user_id: int | None = None,
    admin_user: User = Depends(require_admin),
    session: Session = Depends(get_db),
) -> NotificationDeliveryListResponse:
    del admin_user
    deliveries = notification_service.list_deliveries(session, user_id=user_id)
    return NotificationDeliveryListResponse(deliveries=deliveries)


@router.post("/admin/{user_id}/mark-sent", response_model=NotificationSettings)
def mark_notification_sent(
    user_id: int,
    sent_at: datetime | None = None,
    admin_user: User = Depends(require_admin),
    session: Session = Depends(get_db),
) -> NotificationSettings:
    del admin_user
    timestamp = sent_at or datetime.now(UTC)
    settings = notification_service.mark_sent(session, user_id, timestamp)
    if settings is None:
        raise HTTPException(status_code=404, detail="notification settings not found")
    return settings

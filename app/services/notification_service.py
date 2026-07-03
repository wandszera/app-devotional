from __future__ import annotations

from datetime import UTC, date, datetime

from sqlalchemy.orm import Session

from app.core.timezones import get_timezone
from app.db.models import (
    DevotionalModel,
    NotificationDeliveryModel,
    NotificationSettingsModel,
    UserModel,
    UserProgressModel,
)
from app.models.schemas import (
    DueNotificationItem,
    NotificationDelivery,
    NotificationDispatchItem,
    NotificationSettings,
)
from app.services.push_service import push_service


class NotificationService:
    milestone_days = (3, 7, 14, 30, 60, 100)

    def get_or_create_settings(self, session: Session, user_id: int) -> NotificationSettings | None:
        user = session.get(UserModel, user_id)
        if user is None:
            return None

        settings = self._ensure_settings(session, user_id)
        return NotificationSettings.model_validate(settings)

    def update_settings(
        self,
        session: Session,
        user_id: int,
        enabled: bool,
        reminder_time: str,
        timezone: str,
        push_token: str,
    ) -> NotificationSettings | None:
        user = session.get(UserModel, user_id)
        if user is None:
            return None

        settings = self._ensure_settings(session, user_id)
        settings.enabled = enabled
        settings.reminder_time = reminder_time
        settings.timezone = timezone
        settings.push_token = push_token
        session.add(settings)
        session.commit()
        session.refresh(settings)
        return NotificationSettings.model_validate(settings)

    def get_due_notifications(self, session: Session, now_utc: datetime) -> list[DueNotificationItem]:
        settings_list = (
            session.query(NotificationSettingsModel)
            .join(UserModel, UserModel.id == NotificationSettingsModel.user_id)
            .filter(NotificationSettingsModel.enabled.is_(True))
            .all()
        )

        due_items: list[DueNotificationItem] = []
        for settings in settings_list:
            if not settings.push_token:
                continue

            timezone = get_timezone(settings.timezone)
            local_now = now_utc.astimezone(timezone)
            local_date = local_now.date()
            local_hhmm = local_now.strftime("%H:%M")
            if local_hhmm != settings.reminder_time:
                continue

            if settings.last_sent_at is not None:
                last_sent_local_date = settings.last_sent_at.astimezone(timezone).date()
                if last_sent_local_date >= local_date:
                    continue

            completed_today = (
                session.query(UserProgressModel)
                .filter(
                    UserProgressModel.user_id == settings.user_id,
                    UserProgressModel.date == local_date,
                )
                .first()
                is not None
            )
            if completed_today:
                continue

            devotional = (
                session.query(DevotionalModel)
                .filter(DevotionalModel.date == local_date)
                .first()
            )
            streak = settings.user.streak
            devotional_title = devotional.title if devotional is not None else "Seu devocional de hoje"
            tone, message, next_milestone = self._build_message(
                local_date=local_date,
                devotional_title=devotional_title,
                streak=streak,
            )
            due_items.append(
                DueNotificationItem(
                    user_id=settings.user_id,
                    email=settings.user.email,
                    reminder_time=settings.reminder_time,
                    timezone=settings.timezone,
                    tone=tone,
                    current_streak=streak.current_streak if streak is not None else 0,
                    next_milestone=next_milestone,
                    message=message,
                    devotional_title=devotional_title,
                )
            )

        return due_items

    def mark_sent(self, session: Session, user_id: int, sent_at: datetime) -> NotificationSettings | None:
        settings = session.get(NotificationSettingsModel, user_id)
        if settings is None:
            return None

        settings.last_sent_at = sent_at
        session.add(settings)
        session.commit()
        session.refresh(settings)
        return NotificationSettings.model_validate(settings)

    def dispatch_due_notifications(
        self,
        session: Session,
        now_utc: datetime,
    ) -> list[NotificationDispatchItem]:
        due_items = self.get_due_notifications(session, now_utc)
        dispatched: list[NotificationDispatchItem] = []

        for item in due_items:
            settings = session.get(NotificationSettingsModel, item.user_id)
            if settings is None:
                continue

            result = push_service.send(
                push_token=settings.push_token,
                title=item.devotional_title,
                message=item.message,
            )
            delivery = NotificationDeliveryModel(
                user_id=item.user_id,
                scheduled_for=now_utc,
                status=result.status,
                provider="mock",
                title=item.devotional_title,
                message=item.message,
                push_token_snapshot=settings.push_token,
                provider_message_id=result.provider_message_id,
                error_message=result.error_message,
                sent_at=now_utc if result.status == "sent" else None,
            )
            session.add(delivery)

            if result.status == "sent":
                settings.last_sent_at = now_utc
                session.add(settings)

            session.commit()
            session.refresh(delivery)
            dispatched.append(
                NotificationDispatchItem(
                    user_id=item.user_id,
                    status=result.status,
                    delivery=NotificationDelivery.model_validate(delivery),
                )
            )

        return dispatched

    def list_deliveries(self, session: Session, user_id: int | None = None) -> list[NotificationDelivery]:
        query = session.query(NotificationDeliveryModel)
        if user_id is not None:
            query = query.filter(NotificationDeliveryModel.user_id == user_id)
        deliveries = query.order_by(NotificationDeliveryModel.created_at.desc()).all()
        return [NotificationDelivery.model_validate(item) for item in deliveries]

    def _ensure_settings(self, session: Session, user_id: int) -> NotificationSettingsModel:
        settings = session.get(NotificationSettingsModel, user_id)
        if settings is not None:
            return settings

        settings = NotificationSettingsModel(
            user_id=user_id,
            enabled=True,
            reminder_time="08:00",
            timezone="UTC",
            push_token="",
            last_sent_at=None,
        )
        session.add(settings)
        session.commit()
        session.refresh(settings)
        return settings

    def _build_message(
        self,
        *,
        local_date: date,
        devotional_title: str,
        streak,
    ) -> tuple[str, str, int | None]:
        current_streak = streak.current_streak if streak is not None else 0
        last_activity_date = streak.last_activity_date if streak is not None else None
        next_milestone = self._next_milestone(current_streak)
        days_since_last_activity = (
            (local_date - last_activity_date).days if last_activity_date is not None else None
        )

        if current_streak <= 0 or last_activity_date is None:
            return (
                "starter",
                f"{devotional_title} ja esta disponivel. Comece hoje seu primeiro passo de constancia.",
                next_milestone,
            )

        if days_since_last_activity == 1 and next_milestone is not None:
            remaining = next_milestone - current_streak
            if remaining == 1:
                return (
                    "milestone",
                    f"{devotional_title} ja esta pronto. Falta so hoje para voce chegar a {next_milestone} dias seguidos.",
                    next_milestone,
                )

            if current_streak >= 7:
                return (
                    "strong_streak",
                    f"{devotional_title} ja esta disponivel. Proteja seu streak de {current_streak} dias e siga firme rumo a {next_milestone}.",
                    next_milestone,
                )

            return (
                "building",
                f"{devotional_title} ja esta disponivel. Conclua hoje para manter seu streak de {current_streak} dias.",
                next_milestone,
            )

        if days_since_last_activity is not None and days_since_last_activity > 1:
            return (
                "restart",
                f"{devotional_title} ja esta disponivel. Recomece hoje com calma e construa um novo ritmo.",
                next_milestone,
            )

        return (
            "default",
            f"{devotional_title} ja esta disponivel. Reserve alguns minutos para seu devocional de hoje.",
            next_milestone,
        )

    def _next_milestone(self, current_streak: int) -> int | None:
        for milestone in self.milestone_days:
            if milestone > current_streak:
                return milestone
        return None


notification_service = NotificationService()

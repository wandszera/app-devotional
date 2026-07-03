from __future__ import annotations

from datetime import UTC, date, datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, EmailStr, Field, ValidationInfo, field_validator
from zoneinfo import ZoneInfoNotFoundError

from app.core.timezones import get_timezone


def utc_now() -> datetime:
    return datetime.now(UTC)


class User(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    email: EmailStr
    name: str = ""
    bio: str = ""
    is_admin: bool = False
    created_at: datetime

class UserProfileUpdateRequest(BaseModel):
    name: str
    bio: str


class Devotional(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    content: str
    date: date


class DevotionalCreateRequest(BaseModel):
    title: str
    content: str
    date: date


class DevotionalUpdateRequest(BaseModel):
    title: str | None = None
    content: str | None = None
    date: Optional[date] = None


class DevotionalListResponse(BaseModel):
    devotionals: list[Devotional]


class UserProgress(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    user_id: int
    date: date
    completed: bool = True
    completed_at: datetime = Field(default_factory=utc_now)


class UserStreak(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    user_id: int
    current_streak: int
    longest_streak: int
    last_activity_date: Optional[date] = None
    latest_milestone: Optional[int] = None


class LoginRequest(BaseModel):
    email: EmailStr
    password: str

    @field_validator("password")
    @classmethod
    def validate_password(cls, value: str, info: ValidationInfo) -> str:
        if len(value) < 8:
            raise ValueError("password must be at least 8 characters long")
        return value


class RegisterRequest(LoginRequest):
    pass


class LoginResponse(BaseModel):
    user: User
    message: str
    access_token: str
    token_type: str = "bearer"


class DevotionalGuidance(BaseModel):
    title: str
    body: str
    accent_label: str
    tone: str = "building"
    current_streak: int = 0
    next_milestone: Optional[int] = None


class DevotionalCompletionFeedback(BaseModel):
    title: str
    body: str
    tone: str = "progress"
    current_streak: int = 0
    longest_streak: int = 0
    milestone_hit: Optional[int] = None
    next_milestone: Optional[int] = None


class DevotionalWithCompletion(BaseModel):
    devotional: Devotional
    completed: bool
    is_favorited: bool = False
    guidance: DevotionalGuidance


class FavoriteToggleResponse(BaseModel):
    devotional_id: int
    is_favorited: bool


class DevotionalCompletionResponse(BaseModel):
    message: str
    devotional_id: int
    streak: Optional[UserStreak] = None
    feedback: DevotionalCompletionFeedback


class ProgressResponse(BaseModel):
    user_id: int
    completed_days: list[UserProgress]


class AuthenticatedUserResponse(BaseModel):
    user: User


class NotificationSettings(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    user_id: int
    enabled: bool
    reminder_time: str
    timezone: str
    push_token: str = ""
    last_sent_at: Optional[datetime] = None

    @field_validator("reminder_time")
    @classmethod
    def validate_reminder_time(cls, value: str) -> str:
        try:
            datetime.strptime(value, "%H:%M")
        except ValueError as exc:
            raise ValueError("reminder_time must be in HH:MM format") from exc
        return value

    @field_validator("timezone")
    @classmethod
    def validate_timezone(cls, value: str) -> str:
        try:
            get_timezone(value)
        except (ZoneInfoNotFoundError, ValueError) as exc:
            raise ValueError("timezone must be a valid IANA timezone") from exc
        return value


class NotificationSettingsUpdateRequest(BaseModel):
    enabled: bool = True
    reminder_time: str = "08:00"
    timezone: str = "UTC"
    push_token: str = ""

    @field_validator("reminder_time")
    @classmethod
    def validate_reminder_time(cls, value: str) -> str:
        try:
            datetime.strptime(value, "%H:%M")
        except ValueError as exc:
            raise ValueError("reminder_time must be in HH:MM format") from exc
        return value

    @field_validator("timezone")
    @classmethod
    def validate_timezone(cls, value: str) -> str:
        try:
            get_timezone(value)
        except (ZoneInfoNotFoundError, ValueError) as exc:
            raise ValueError("timezone must be a valid IANA timezone") from exc
        return value


class DueNotificationItem(BaseModel):
    user_id: int
    email: EmailStr
    reminder_time: str
    timezone: str
    tone: str = "default"
    current_streak: int = 0
    next_milestone: Optional[int] = None
    message: str
    devotional_title: str


class DueNotificationsResponse(BaseModel):
    checked_at: datetime
    due_notifications: list[DueNotificationItem]


class NotificationDelivery(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    scheduled_for: datetime
    status: str
    provider: str
    title: str
    message: str
    push_token_snapshot: str
    provider_message_id: str = ""
    error_message: str = ""
    created_at: datetime
    sent_at: Optional[datetime] = None


class NotificationDispatchItem(BaseModel):
    user_id: int
    status: str
    delivery: NotificationDelivery


class NotificationDispatchResponse(BaseModel):
    dispatched_at: datetime
    processed: int
    deliveries: list[NotificationDispatchItem]


class NotificationDeliveryListResponse(BaseModel):
    deliveries: list[NotificationDelivery]

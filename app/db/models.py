from datetime import UTC, date, datetime
from sqlalchemy import Boolean, Date, DateTime, ForeignKey, Integer, String, Text, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.session import Base


def utc_now() -> datetime:
    return datetime.now(UTC)


class UserModel(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    name: Mapped[str] = mapped_column(String(255), default="", nullable=False)
    bio: Mapped[str] = mapped_column(Text, default="", nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    is_admin: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)

    streak: Mapped["UserStreakModel"] = relationship(back_populates="user", uselist=False)
    progress_entries: Mapped[list["UserProgressModel"]] = relationship(back_populates="user")
    notification_settings: Mapped["NotificationSettingsModel"] = relationship(
        back_populates="user",
        uselist=False,
    )


class DevotionalModel(Base):
    __tablename__ = "devotionals"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    date: Mapped[date] = mapped_column(Date, unique=True, index=True, nullable=False)


class UserProgressModel(Base):
    __tablename__ = "user_progress"
    __table_args__ = (UniqueConstraint("user_id", "date", name="uq_user_progress_user_date"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    date: Mapped[date] = mapped_column(Date, nullable=False, index=True)
    completed: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    completed_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)

    user: Mapped[UserModel] = relationship(back_populates="progress_entries")


class UserStreakModel(Base):
    __tablename__ = "user_streaks"

    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), primary_key=True)
    current_streak: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    longest_streak: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    last_activity_date: Mapped[date] = mapped_column(Date, nullable=True)

    user: Mapped[UserModel] = relationship(back_populates="streak")


class NotificationSettingsModel(Base):
    __tablename__ = "notification_settings"

    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), primary_key=True)
    enabled: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    reminder_time: Mapped[str] = mapped_column(String(5), default="08:00", nullable=False)
    timezone: Mapped[str] = mapped_column(String(64), default="UTC", nullable=False)
    push_token: Mapped[str] = mapped_column(String(255), default="", nullable=False)
    last_sent_at: Mapped[datetime] = mapped_column(DateTime, nullable=True)

    user: Mapped[UserModel] = relationship(back_populates="notification_settings")
    deliveries: Mapped[list["NotificationDeliveryModel"]] = relationship(
        back_populates="notification_settings"
    )


class NotificationDeliveryModel(Base):
    __tablename__ = "notification_deliveries"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("notification_settings.user_id"), nullable=False, index=True)
    scheduled_for: Mapped[datetime] = mapped_column(DateTime, nullable=False, index=True)
    status: Mapped[str] = mapped_column(String(32), default="pending", nullable=False, index=True)
    provider: Mapped[str] = mapped_column(String(64), default="mock", nullable=False)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    message: Mapped[str] = mapped_column(Text, nullable=False)
    push_token_snapshot: Mapped[str] = mapped_column(String(255), default="", nullable=False)
    provider_message_id: Mapped[str] = mapped_column(String(255), default="", nullable=False)
    error_message: Mapped[str] = mapped_column(Text, default="", nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)
    sent_at: Mapped[datetime] = mapped_column(DateTime, nullable=True)

    notification_settings: Mapped[NotificationSettingsModel] = relationship(back_populates="deliveries")


class UserFavoriteModel(Base):
    __tablename__ = "user_favorites"
    __table_args__ = (UniqueConstraint("user_id", "devotional_id", name="uq_user_favorite_user_devotional"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    devotional_id: Mapped[int] = mapped_column(ForeignKey("devotionals.id"), nullable=False, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)

    user: Mapped[UserModel] = relationship()
    devotional: Mapped[DevotionalModel] = relationship()

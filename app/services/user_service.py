from __future__ import annotations

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.security import create_access_token, hash_password, verify_password
from app.db.models import NotificationSettingsModel, UserModel, UserStreakModel
from app.models.schemas import User


class UserService:
    def register(self, session: Session, email: str, password: str) -> User:
        existing_user = session.query(UserModel).filter(UserModel.email == email).first()
        if existing_user is not None:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="email already registered",
            )

        user = UserModel(
            email=email,
            password_hash=hash_password(password),
            is_admin=email.lower() in settings.admin_emails,
        )
        session.add(user)
        session.flush()

        session.add(
            UserStreakModel(
                user_id=user.id,
                current_streak=0,
                longest_streak=0,
                last_activity_date=None,
            )
        )
        session.add(
            NotificationSettingsModel(
                user_id=user.id,
                enabled=True,
                reminder_time="08:00",
                timezone="UTC",
                push_token="",
                last_sent_at=None,
            )
        )
        session.commit()
        session.refresh(user)
        return User.model_validate(user)

    def authenticate(self, session: Session, email: str, password: str) -> User:
        user = session.query(UserModel).filter(UserModel.email == email).first()
        if user is None or not verify_password(password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="invalid email or password",
            )
        return User.model_validate(user)

    def get_by_email(self, session: Session, email: str) -> User | None:
        user = session.query(UserModel).filter(UserModel.email == email).first()
        if user is None:
            return None
        return User.model_validate(user)

    def create_token(self, user: User) -> str:
        return create_access_token(str(user.id))


user_service = UserService()

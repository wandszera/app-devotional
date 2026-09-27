from __future__ import annotations

import secrets

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.firebase import (
    FirebaseAuthUnavailableError,
    InvalidFirebaseTokenError,
    verify_google_id_token,
)
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

        return self._create_user(
            session,
            email=email,
            password_hash=hash_password(password),
            auth_provider="password",
        )

    def authenticate_with_google(self, session: Session, id_token: str) -> User:
        try:
            identity = verify_google_id_token(id_token)
        except FirebaseAuthUnavailableError as exc:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="google sign-in is not configured on the server",
            ) from exc
        except InvalidFirebaseTokenError as exc:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="invalid Google sign-in token",
            ) from exc

        user = session.query(UserModel).filter(UserModel.firebase_uid == identity.uid).first()
        if user is None:
            user = session.query(UserModel).filter(UserModel.email == identity.email).first()
            if user is None:
                return self._create_user(
                    session,
                    email=identity.email,
                    name=identity.name,
                    password_hash=hash_password(secrets.token_urlsafe(32)),
                    firebase_uid=identity.uid,
                    auth_provider="google",
                )

            if user.firebase_uid not in (None, identity.uid):
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="this email is already linked to another Google account",
                )
            user.firebase_uid = identity.uid
            user.auth_provider = "google"
            session.commit()
            session.refresh(user)

        return User.model_validate(user)

    def _create_user(
        self,
        session: Session,
        *,
        email: str,
        password_hash: str,
        auth_provider: str,
        firebase_uid: str | None = None,
        name: str = "",
    ) -> User:
        user = UserModel(
            email=email,
            name=name,
            password_hash=password_hash,
            firebase_uid=firebase_uid,
            auth_provider=auth_provider,
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

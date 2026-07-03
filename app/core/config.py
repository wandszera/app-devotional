from __future__ import annotations

import os


class Settings:
    secret_key: str = os.getenv("APP_SECRET_KEY", "dev-secret-change-me")
    access_token_expire_minutes: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "60"))
    admin_emails: set[str] = {
        email.strip().lower()
        for email in os.getenv("APP_ADMIN_EMAILS", "").split(",")
        if email.strip()
    }


settings = Settings()

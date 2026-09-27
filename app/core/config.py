from __future__ import annotations

import os
import warnings


class Settings:
    environment: str = os.getenv("APP_ENV", "development").strip().lower()
    secret_key: str = os.getenv("APP_SECRET_KEY", "dev-secret-change-me")
    access_token_expire_minutes: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "60"))
    admin_emails: set[str] = {
        email.strip().lower()
        for email in os.getenv("APP_ADMIN_EMAILS", "").split(",")
        if email.strip()
    }
    firebase_service_account_path: str = os.getenv(
        "FIREBASE_SERVICE_ACCOUNT_PATH",
        "",
    ).strip()

    def validate(self) -> None:
        if self.environment == "production":
            if self.secret_key == "dev-secret-change-me" or len(self.secret_key) < 32:
                raise ValueError(
                    "APP_SECRET_KEY deve ser definida com pelo menos 32 caracteres em producao"
                )
        elif self.secret_key == "dev-secret-change-me":
            warnings.warn(
                "Usando secret_key padrao de desenvolvimento. Defina APP_SECRET_KEY em producao.",
                stacklevel=2,
            )


settings = Settings()

import logging
import os
from dataclasses import dataclass

import firebase_admin
from firebase_admin import auth, credentials

from app.core.config import settings

logger = logging.getLogger(__name__)


class FirebaseAuthUnavailableError(Exception):
    """Raised when the server has no Firebase Admin credentials configured."""


class InvalidFirebaseTokenError(Exception):
    """Raised when a Firebase ID token cannot be used to identify a Google user."""


@dataclass(frozen=True)
class GoogleIdentity:
    uid: str
    email: str
    name: str

def init_firebase() -> bool:
    service_account_path = settings.firebase_service_account_path

    if service_account_path and os.path.exists(service_account_path):
        try:
            cred = credentials.Certificate(service_account_path)
            if not firebase_admin._apps:
                firebase_admin.initialize_app(cred)
            logger.info("Firebase Admin inicializado com sucesso.")
            return True
        except Exception as e:
            logger.error(f"Erro ao inicializar Firebase Admin: {e}")
            return False
    else:
        logger.warning(
            "FIREBASE_SERVICE_ACCOUNT_PATH nao configurado ou arquivo nao encontrado. "
            "Notificacoes reais e login com Google nao vao funcionar."
        )
        return False


def verify_google_id_token(id_token: str) -> GoogleIdentity:
    """Validate a Firebase token and extract a verified Google identity."""
    if not firebase_admin._apps:
        raise FirebaseAuthUnavailableError

    try:
        decoded = auth.verify_id_token(id_token, check_revoked=True)
    except Exception as exc:
        logger.info("Token Firebase rejeitado durante login Google: %s", type(exc).__name__)
        raise InvalidFirebaseTokenError from exc

    provider = decoded.get("firebase", {}).get("sign_in_provider")
    email = decoded.get("email")
    if (
        provider != "google.com"
        or decoded.get("email_verified") is not True
        or not isinstance(email, str)
        or not email
    ):
        raise InvalidFirebaseTokenError

    uid = decoded.get("uid") or decoded.get("sub")
    if not isinstance(uid, str) or not uid:
        raise InvalidFirebaseTokenError

    name = decoded.get("name")
    return GoogleIdentity(
        uid=uid,
        email=email.lower(),
        name=name[:255] if isinstance(name, str) else "",
    )

from __future__ import annotations

import base64
import hashlib
import hmac
import json
import secrets
from datetime import UTC, datetime, timedelta

from app.core.config import settings


def _b64encode(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode("utf-8")


def _b64decode(data: str) -> bytes:
    padding = "=" * (-len(data) % 4)
    return base64.urlsafe_b64decode(data + padding)


def create_access_token(subject: str) -> str:
    expires_at = datetime.now(UTC) + timedelta(minutes=settings.access_token_expire_minutes)
    payload = {
        "sub": subject,
        "exp": int(expires_at.timestamp()),
    }
    payload_segment = _b64encode(json.dumps(payload, separators=(",", ":")).encode("utf-8"))
    signature = hmac.new(
        settings.secret_key.encode("utf-8"),
        payload_segment.encode("utf-8"),
        hashlib.sha256,
    ).digest()
    signature_segment = _b64encode(signature)
    return f"{payload_segment}.{signature_segment}"


def decode_access_token(token: str) -> dict[str, object] | None:
    try:
        payload_segment, signature_segment = token.split(".", maxsplit=1)
        expected_signature = hmac.new(
            settings.secret_key.encode("utf-8"),
            payload_segment.encode("utf-8"),
            hashlib.sha256,
        ).digest()
        provided_signature = _b64decode(signature_segment)
        if not hmac.compare_digest(provided_signature, expected_signature):
            return None

        payload = json.loads(_b64decode(payload_segment).decode("utf-8"))
        expires_at = int(payload["exp"])
        if expires_at < int(datetime.now(UTC).timestamp()):
            return None
        if "sub" not in payload:
            return None
        return payload
    except (ValueError, KeyError, json.JSONDecodeError, TypeError):
        return None


def hash_password(password: str) -> str:
    salt = secrets.token_bytes(16)
    digest = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt, 100000)
    return f"{_b64encode(salt)}:{_b64encode(digest)}"


def verify_password(password: str, password_hash: str) -> bool:
    try:
        salt_segment, digest_segment = password_hash.split(":", maxsplit=1)
        salt = _b64decode(salt_segment)
        expected_digest = _b64decode(digest_segment)
    except ValueError:
        return False

    candidate_digest = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt, 100000)
    return hmac.compare_digest(candidate_digest, expected_digest)

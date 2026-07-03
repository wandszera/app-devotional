from __future__ import annotations

import logging
from dataclasses import dataclass

import firebase_admin
from firebase_admin import messaging

logger = logging.getLogger(__name__)

@dataclass
class PushSendResult:
    status: str
    provider_message_id: str
    error_message: str = ""


class PushService:
    def send(self, push_token: str, title: str, message: str) -> PushSendResult:
        if not push_token:
            return PushSendResult(
                status="failed",
                provider_message_id="",
                error_message="missing push token",
            )

        if not firebase_admin._apps:
            logger.warning("Simulando push: Firebase não está configurado.")
            sanitized = push_token.replace(" ", "_")
            message_id = f"mock:{sanitized}:{len(title)}:{len(message)}"
            return PushSendResult(status="sent", provider_message_id=message_id)

        try:
            fcm_msg = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=message,
                ),
                token=push_token,
            )
            response = messaging.send(fcm_msg)
            return PushSendResult(status="sent", provider_message_id=response)
        except Exception as e:
            logger.error(f"Erro ao enviar FCM: {e}")
            return PushSendResult(
                status="failed",
                provider_message_id="",
                error_message=str(e),
            )


push_service = PushService()

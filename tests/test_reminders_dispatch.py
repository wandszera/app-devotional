from fastapi.testclient import TestClient

from app.core.config import settings
from app.db.init_db import init_db
from app.db.models import NotificationSettingsModel
from app.db.session import Base, DATABASE_URL, SessionLocal, engine
from app.main import app
from app.services import push_service as push_module
from app.services.push_service import PushSendResult

client = TestClient(app)


def setup_function() -> None:
    assert "app_devocional_tests_" in DATABASE_URL
    Base.metadata.drop_all(bind=engine)
    init_db()
    settings.dispatch_token = "cron-secret"


def teardown_function() -> None:
    settings.dispatch_token = ""


def _user_with_token(token: str = "device-token-1") -> int:
    r = client.post(
        "/auth/register",
        json={"email": "u@example.com", "password": "segredo123"},
    )
    headers = {"Authorization": f"Bearer {r.json()['access_token']}"}
    client.put(
        "/notifications/settings",
        headers=headers,
        json={
            "enabled": True,
            "reminder_time": "00:00",
            "timezone": "UTC",
            "push_token": token,
        },
    )
    return r.json()["user"]["id"]


def test_internal_dispatch_requires_the_shared_secret() -> None:
    assert client.post("/notifications/internal/dispatch").status_code == 403
    bad = client.post(
        "/notifications/internal/dispatch", headers={"X-Dispatch-Token": "x"}
    )
    assert bad.status_code == 403


def test_internal_dispatch_is_disabled_when_secret_not_configured() -> None:
    settings.dispatch_token = ""
    r = client.post("/notifications/internal/dispatch", headers={"X-Dispatch-Token": ""})
    assert r.status_code == 403


def test_internal_dispatch_sends_due_reminders() -> None:
    _user_with_token()
    r = client.post(
        "/notifications/internal/dispatch", headers={"X-Dispatch-Token": "cron-secret"}
    )
    assert r.status_code == 200
    assert r.json()["processed"] == 1


def test_invalid_fcm_token_is_cleared_after_dispatch(monkeypatch) -> None:
    user_id = _user_with_token("dead-token")
    monkeypatch.setattr(
        push_module.push_service,
        "send",
        lambda **kw: PushSendResult(
            status="invalid_token", provider="firebase", provider_message_id="", error_message="x"
        ),
    )
    r = client.post(
        "/notifications/internal/dispatch", headers={"X-Dispatch-Token": "cron-secret"}
    )
    assert r.json()["deliveries"][0]["status"] == "invalid_token"
    with SessionLocal() as s:
        assert s.get(NotificationSettingsModel, user_id).push_token == ""
    again = client.post(
        "/notifications/internal/dispatch", headers={"X-Dispatch-Token": "cron-secret"}
    )
    assert again.json()["processed"] == 0

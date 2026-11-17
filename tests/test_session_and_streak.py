from datetime import UTC, datetime, timedelta

from fastapi.testclient import TestClient

from app.core.config import settings
from app.db.init_db import init_db
from app.db.models import RefreshTokenModel, UserStreakModel
from app.db.session import Base, DATABASE_URL, SessionLocal, engine
from app.main import app


client = TestClient(app)


def setup_function() -> None:
    assert "app_devocional_tests_" in DATABASE_URL
    settings.admin_emails = {"admin@example.com"}
    Base.metadata.drop_all(bind=engine)
    init_db()


def _register(email: str = "user@example.com") -> dict:
    response = client.post(
        "/auth/register", json={"email": email, "password": "segredo123"}
    )
    assert response.status_code == 201
    return response.json()


def _bearer(token: str) -> dict[str, str]:
    return {"Authorization": f"Bearer {token}"}


def test_login_and_register_return_refresh_token() -> None:
    registered = _register()
    assert len(registered["refresh_token"]) >= 20

    login = client.post(
        "/auth/login", json={"email": "user@example.com", "password": "segredo123"}
    ).json()
    assert login["refresh_token"] != registered["refresh_token"]


def test_refresh_rotates_tokens_and_new_access_token_works() -> None:
    first = _register()
    response = client.post("/auth/refresh", json={"refresh_token": first["refresh_token"]})

    assert response.status_code == 200
    pair = response.json()
    assert pair["refresh_token"] != first["refresh_token"]
    assert client.get("/auth/me", headers=_bearer(pair["access_token"])).status_code == 200


def test_reusing_a_rotated_refresh_token_revokes_the_whole_session() -> None:
    first = _register()
    rotated = client.post(
        "/auth/refresh", json={"refresh_token": first["refresh_token"]}
    ).json()

    replay = client.post("/auth/refresh", json={"refresh_token": first["refresh_token"]})
    assert replay.status_code == 401

    after_replay = client.post(
        "/auth/refresh", json={"refresh_token": rotated["refresh_token"]}
    )
    assert after_replay.status_code == 401


def test_expired_unknown_and_logged_out_refresh_tokens_are_rejected() -> None:
    first = _register()
    unknown = client.post("/auth/refresh", json={"refresh_token": "x" * 40})
    assert unknown.status_code == 401

    with SessionLocal() as session:
        record = session.query(RefreshTokenModel).one()
        record.expires_at = datetime.now(UTC).replace(tzinfo=None) - timedelta(seconds=1)
        session.commit()
    expired = client.post("/auth/refresh", json={"refresh_token": first["refresh_token"]})
    assert expired.status_code == 401

    second = _register("other@example.com")
    out = client.post("/auth/logout", json={"refresh_token": second["refresh_token"]})
    assert out.status_code == 204
    after = client.post("/auth/refresh", json={"refresh_token": second["refresh_token"]})
    assert after.status_code == 401


def _set_streak(user_id: int, current: int, longest: int, last_days_ago: int | None) -> None:
    with SessionLocal() as session:
        streak = session.get(UserStreakModel, user_id)
        streak.current_streak = current
        streak.longest_streak = longest
        streak.last_activity_date = (
            None
            if last_days_ago is None
            else datetime.now(UTC).date() - timedelta(days=last_days_ago)
        )
        session.commit()


def test_streak_is_zero_when_last_activity_was_before_yesterday() -> None:
    registered = _register()
    headers = _bearer(registered["access_token"])
    _set_streak(registered["user"]["id"], current=5, longest=9, last_days_ago=3)

    streak = client.get("/streak", headers=headers).json()
    assert streak["current_streak"] == 0
    assert streak["longest_streak"] == 9

    guidance = client.get("/devotional/today", headers=headers).json()["guidance"]
    assert guidance["current_streak"] == 0
    assert guidance["title"] == "Primeiro passo"


def test_streak_is_kept_when_last_activity_was_yesterday_or_today() -> None:
    registered = _register()
    headers = _bearer(registered["access_token"])
    for days_ago in (0, 1):
        _set_streak(registered["user"]["id"], current=5, longest=9, last_days_ago=days_ago)
        assert client.get("/streak", headers=headers).json()["current_streak"] == 5

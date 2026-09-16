from datetime import UTC, date, datetime, timedelta

from fastapi.testclient import TestClient

from app.core.config import settings
from app.core.firebase import GoogleIdentity
from app.db.models import (
    NotificationSettingsModel,
    UserModel,
    UserProgressModel,
    UserStreakModel,
)
from app.db.init_db import init_db
from app.db.session import Base, DATABASE_URL, SessionLocal, engine
from app.main import app
from app.services.devotional_service import devotional_service


client = TestClient(app)


def setup_function() -> None:
    assert "app_devocional_tests_" in DATABASE_URL, (
        "refusing to reset a database outside the isolated test directory"
    )
    settings.admin_emails = {"admin@example.com"}
    Base.metadata.drop_all(bind=engine)
    init_db()


def test_healthcheck() -> None:
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_devotional_flow() -> None:
    register_response = client.post(
        "/auth/register",
        json={"email": "user@example.com", "password": "segredo123"},
    )
    assert register_response.status_code == 201

    payload = register_response.json()
    token = payload["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    me_response = client.get("/auth/me", headers=headers)
    assert me_response.status_code == 200
    assert me_response.json()["user"]["email"] == "user@example.com"

    devotional_response = client.get("/devotional/today", headers=headers)
    assert devotional_response.status_code == 200
    assert devotional_response.json()["completed"] is False
    assert devotional_response.json()["guidance"]["title"] == "Primeiro passo"

    complete_response = client.post("/devotional/complete", headers=headers)
    assert complete_response.status_code == 200
    assert complete_response.json()["streak"]["current_streak"] == 1
    assert complete_response.json()["feedback"]["title"] == "Primeiro passo concluido"
    assert complete_response.json()["feedback"]["tone"] == "starter"

    streak_response = client.get("/streak", headers=headers)
    assert streak_response.status_code == 200
    assert streak_response.json()["longest_streak"] == 1
    assert streak_response.json()["latest_milestone"] is None

    progress_response = client.get("/progress", headers=headers)
    assert progress_response.status_code == 200
    assert len(progress_response.json()["completed_days"]) == 1

    devotional_response_after_completion = client.get(
        "/devotional/today",
        headers=headers,
    )
    assert devotional_response_after_completion.status_code == 200
    assert devotional_response_after_completion.json()["completed"] is True
    assert devotional_response_after_completion.json()["guidance"]["title"] == "Ritmo protegido"


def test_today_devotional_returns_backend_guidance_for_milestone_edge() -> None:
    register_response = client.post(
        "/auth/register",
        json={"email": "user@example.com", "password": "segredo123"},
    )
    headers = {"Authorization": f"Bearer {register_response.json()['access_token']}"}
    user_id = register_response.json()["user"]["id"]

    session = SessionLocal()
    try:
        streak = session.get(UserStreakModel, user_id)
        assert streak is not None
        streak.current_streak = 2
        streak.longest_streak = 2
        session.add(streak)
        session.commit()
    finally:
        session.close()

    devotional_response = client.get("/devotional/today", headers=headers)

    assert devotional_response.status_code == 200
    guidance = devotional_response.json()["guidance"]
    assert guidance["title"] == "Marco proximo"
    assert guidance["tone"] == "milestone"
    assert guidance["current_streak"] == 2
    assert guidance["next_milestone"] == 3


def test_streak_returns_latest_official_milestone_from_backend() -> None:
    register_response = client.post(
        "/auth/register",
        json={"email": "user@example.com", "password": "segredo123"},
    )
    headers = {"Authorization": f"Bearer {register_response.json()['access_token']}"}
    user_id = register_response.json()["user"]["id"]

    session = SessionLocal()
    try:
        streak = session.get(UserStreakModel, user_id)
        assert streak is not None
        streak.current_streak = 9
        streak.longest_streak = 9
        session.add(streak)
        session.commit()
    finally:
        session.close()

    streak_response = client.get("/streak", headers=headers)

    assert streak_response.status_code == 200
    assert streak_response.json()["latest_milestone"] == 7


def test_completion_returns_milestone_feedback_when_user_hits_three_days() -> None:
    register_response = client.post(
        "/auth/register",
        json={"email": "user@example.com", "password": "segredo123"},
    )
    headers = {"Authorization": f"Bearer {register_response.json()['access_token']}"}
    user_id = register_response.json()["user"]["id"]

    session = SessionLocal()
    try:
        streak = session.get(UserStreakModel, user_id)
        assert streak is not None
        streak.current_streak = 2
        streak.longest_streak = 2
        streak.last_activity_date = datetime.now(UTC).date() - timedelta(days=1)
        session.add(streak)
        session.commit()
    finally:
        session.close()

    complete_response = client.post("/devotional/complete", headers=headers)

    assert complete_response.status_code == 200
    feedback = complete_response.json()["feedback"]
    assert feedback["title"] == "Marco alcançado"
    assert feedback["tone"] == "milestone"
    assert feedback["milestone_hit"] == 3


def test_protected_routes_require_token() -> None:
    response = client.get("/streak")

    assert response.status_code == 401
    assert response.json()["detail"] == "authentication required"


def test_favoriting_unknown_devotional_returns_not_found() -> None:
    register_response = client.post(
        "/auth/register",
        json={"email": "user@example.com", "password": "segredo123"},
    )
    headers = {"Authorization": f"Bearer {register_response.json()['access_token']}"}

    response = client.post("/devotional/999999/favorite", headers=headers)

    assert response.status_code == 404
    assert response.json()["detail"] == "devotional not found"


def test_devotional_uses_the_users_configured_timezone() -> None:
    register_response = client.post(
        "/auth/register",
        json={"email": "timezone@example.com", "password": "segredo123"},
    )
    user_id = register_response.json()["user"]["id"]

    session = SessionLocal()
    try:
        settings = session.get(NotificationSettingsModel, user_id)
        assert settings is not None
        settings.timezone = "Pacific/Kiritimati"
        session.commit()

        response = devotional_service.get_today_devotional(
            session,
            user_id,
            now_utc=datetime(2026, 4, 29, 12, 0, tzinfo=UTC),
        )
        assert response is not None
        assert response.devotional.date == date(2026, 4, 30)
    finally:
        session.close()


def test_login_rejects_invalid_password() -> None:
    client.post(
        "/auth/register",
        json={"email": "user@example.com", "password": "segredo123"},
    )

    response = client.post(
        "/auth/login",
        json={"email": "user@example.com", "password": "senha_errada"},
    )

    assert response.status_code == 401
    assert response.json()["detail"] == "invalid email or password"


def test_login_success() -> None:
    # Registra
    client.post(
        "/auth/register",
        json={"email": "login@example.com", "password": "password123"},
    )

    # Loga
    resp = client.post(
        "/auth/login",
        json={"email": "login@example.com", "password": "password123"},
    )
    assert resp.status_code == 200
    data = resp.json()
    assert data["message"] == "user authenticated"
    assert "access_token" in data


def test_google_login_creates_then_reuses_the_local_account(monkeypatch) -> None:
    identity = GoogleIdentity(
        uid="firebase-google-user-1",
        email="google@example.com",
        name="Pessoa Google",
    )
    monkeypatch.setattr(
        "app.services.user_service.verify_google_id_token",
        lambda _id_token: identity,
    )

    first_response = client.post("/auth/google", json={"id_token": "a" * 32})

    assert first_response.status_code == 200
    first_payload = first_response.json()
    assert first_payload["user"]["email"] == "google@example.com"
    assert first_payload["user"]["name"] == "Pessoa Google"

    second_response = client.post("/auth/google", json={"id_token": "b" * 32})

    assert second_response.status_code == 200
    assert second_response.json()["user"]["id"] == first_payload["user"]["id"]

    session = SessionLocal()
    try:
        user = session.query(UserModel).filter(UserModel.email == "google@example.com").one()
        assert user.firebase_uid == "firebase-google-user-1"
        assert user.auth_provider == "google"
        assert session.get(UserStreakModel, user.id) is not None
        assert session.get(NotificationSettingsModel, user.id) is not None
    finally:
        session.close()


def test_google_login_links_an_existing_password_account(monkeypatch) -> None:
    register_response = client.post(
        "/auth/register",
        json={"email": "existing@example.com", "password": "segredo123"},
    )
    existing_id = register_response.json()["user"]["id"]
    monkeypatch.setattr(
        "app.services.user_service.verify_google_id_token",
        lambda _id_token: GoogleIdentity(
            uid="firebase-existing-user",
            email="existing@example.com",
            name="Nome não substitui perfil",
        ),
    )

    response = client.post("/auth/google", json={"id_token": "c" * 32})

    assert response.status_code == 200
    assert response.json()["user"]["id"] == existing_id


def test_google_login_returns_service_unavailable_when_firebase_is_unconfigured(
    monkeypatch,
) -> None:
    from app.core.firebase import FirebaseAuthUnavailableError

    def unavailable(_id_token: str) -> GoogleIdentity:
        raise FirebaseAuthUnavailableError

    monkeypatch.setattr("app.services.user_service.verify_google_id_token", unavailable)

    response = client.post("/auth/google", json={"id_token": "a" * 32})

    assert response.status_code == 503
    assert response.json()["detail"] == "google sign-in is not configured on the server"


def test_update_profile() -> None:
    # Registra e Loga
    reg_resp = client.post(
        "/auth/register",
        json={"email": "profile@example.com", "password": "password123"},
    )
    token = reg_resp.json()["access_token"]
    
    # Atualiza o perfil
    resp = client.put(
        "/auth/me",
        headers={"Authorization": f"Bearer {token}"},
        json={"name": "Wanderson", "bio": "Desenvolvedor Flutter e Python."},
    )
    assert resp.status_code == 200
    data = resp.json()
    assert data["user"]["name"] == "Wanderson"
    assert data["user"]["bio"] == "Desenvolvedor Flutter e Python."
    
    # Busca de novo para garantir
    me_resp = client.get(
        "/auth/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    me_data = me_resp.json()
    assert me_data["user"]["name"] == "Wanderson"
    assert me_data["user"]["bio"] == "Desenvolvedor Flutter e Python."


def test_login_accepts_registered_user() -> None:
    client.post(
        "/auth/register",
        json={"email": "user@example.com", "password": "segredo123"},
    )

    response = client.post(
        "/auth/login",
        json={"email": "user@example.com", "password": "segredo123"},
    )

    assert response.status_code == 200
    assert response.json()["token_type"] == "bearer"


def test_admin_can_manage_devotionals() -> None:
    register_response = client.post(
        "/auth/register",
        json={"email": "admin@example.com", "password": "segredo123"},
    )
    headers = {"Authorization": f"Bearer {register_response.json()['access_token']}"}

    create_response = client.post(
        "/devotional/admin",
        headers=headers,
        json={
            "title": "Esperanca para amanha",
            "content": "Permaneça firme e confiante.",
            "date": "2030-01-01",
        },
    )
    assert create_response.status_code == 201
    devotional_id = create_response.json()["id"]

    list_response = client.get(
        "/devotional/admin",
        headers=headers,
        params={"start_date": "2030-01-01", "end_date": "2030-01-02"},
    )
    assert list_response.status_code == 200
    assert len(list_response.json()["devotionals"]) == 1

    update_response = client.put(
        f"/devotional/admin/{devotional_id}",
        headers=headers,
        json={"title": "Esperanca renovada"},
    )
    assert update_response.status_code == 200
    assert update_response.json()["title"] == "Esperanca renovada"

    delete_response = client.delete(f"/devotional/admin/{devotional_id}", headers=headers)
    assert delete_response.status_code == 200
    assert delete_response.json()["message"] == "devotional deleted"


def test_non_admin_cannot_manage_devotionals() -> None:
    register_response = client.post(
        "/auth/register",
        json={"email": "user@example.com", "password": "segredo123"},
    )
    headers = {"Authorization": f"Bearer {register_response.json()['access_token']}"}

    response = client.post(
        "/devotional/admin",
        headers=headers,
        json={
            "title": "Teste",
            "content": "Conteudo",
            "date": "2030-01-01",
        },
    )

    assert response.status_code == 403
    assert response.json()["detail"] == "admin access required"


def test_user_can_update_notification_settings() -> None:
    register_response = client.post(
        "/auth/register",
        json={"email": "user@example.com", "password": "segredo123"},
    )
    headers = {"Authorization": f"Bearer {register_response.json()['access_token']}"}

    default_response = client.get("/notifications/settings", headers=headers)
    assert default_response.status_code == 200
    assert default_response.json()["reminder_time"] == "08:00"

    update_response = client.put(
        "/notifications/settings",
        headers=headers,
        json={
            "enabled": True,
            "reminder_time": "09:15",
            "timezone": "America/Sao_Paulo",
            "push_token": "device-token-123",
        },
    )
    assert update_response.status_code == 200
    assert update_response.json()["timezone"] == "America/Sao_Paulo"
    assert update_response.json()["push_token"] == "device-token-123"


def test_admin_can_check_due_notifications() -> None:
    admin_response = client.post(
        "/auth/register",
        json={"email": "admin@example.com", "password": "segredo123"},
    )
    admin_headers = {"Authorization": f"Bearer {admin_response.json()['access_token']}"}

    user_response = client.post(
        "/auth/register",
        json={"email": "user@example.com", "password": "segredo123"},
    )
    user_headers = {"Authorization": f"Bearer {user_response.json()['access_token']}"}
    user_id = user_response.json()["user"]["id"]

    client.put(
        "/notifications/settings",
        headers=user_headers,
        json={
            "enabled": True,
            "reminder_time": "08:00",
            "timezone": "UTC",
            "push_token": "device-token-123",
        },
    )

    due_response = client.get(
        "/notifications/admin/due",
        headers=admin_headers,
        params={"current_time": "2026-04-29T08:00:00Z"},
    )
    assert due_response.status_code == 200
    assert len(due_response.json()["due_notifications"]) == 1
    assert due_response.json()["due_notifications"][0]["user_id"] == user_id

    mark_response = client.post(
        f"/notifications/admin/{user_id}/mark-sent",
        headers=admin_headers,
        params={"sent_at": "2026-04-29T08:00:00Z"},
    )
    assert mark_response.status_code == 200

    due_response_after_mark = client.get(
        "/notifications/admin/due",
        headers=admin_headers,
        params={"current_time": "2026-04-29T08:00:00Z"},
    )
    assert due_response_after_mark.status_code == 200
    assert due_response_after_mark.json()["due_notifications"] == []


def test_admin_can_dispatch_and_list_notification_deliveries() -> None:
    admin_response = client.post(
        "/auth/register",
        json={"email": "admin@example.com", "password": "segredo123"},
    )
    admin_headers = {"Authorization": f"Bearer {admin_response.json()['access_token']}"}

    user_response = client.post(
        "/auth/register",
        json={"email": "user@example.com", "password": "segredo123"},
    )
    user_headers = {"Authorization": f"Bearer {user_response.json()['access_token']}"}
    user_id = user_response.json()["user"]["id"]

    client.put(
        "/notifications/settings",
        headers=user_headers,
        json={
            "enabled": True,
            "reminder_time": "08:00",
            "timezone": "UTC",
            "push_token": "device-token-123",
        },
    )

    dispatch_response = client.post(
        "/notifications/admin/dispatch",
        headers=admin_headers,
        params={"current_time": "2026-04-29T08:00:00Z"},
    )
    assert dispatch_response.status_code == 200
    assert dispatch_response.json()["processed"] == 1
    assert dispatch_response.json()["deliveries"][0]["status"] == "simulated"
    assert dispatch_response.json()["deliveries"][0]["delivery"]["provider"] == "mock"

    deliveries_response = client.get(
        "/notifications/admin/deliveries",
        headers=admin_headers,
        params={"user_id": user_id},
    )
    assert deliveries_response.status_code == 200
    assert len(deliveries_response.json()["deliveries"]) == 1
    assert deliveries_response.json()["deliveries"][0]["user_id"] == user_id


def test_due_notifications_include_streak_aware_message_for_active_user() -> None:
    admin_response = client.post(
        "/auth/register",
        json={"email": "admin@example.com", "password": "segredo123"},
    )
    admin_headers = {"Authorization": f"Bearer {admin_response.json()['access_token']}"}

    user_response = client.post(
        "/auth/register",
        json={"email": "user@example.com", "password": "segredo123"},
    )
    user_headers = {"Authorization": f"Bearer {user_response.json()['access_token']}"}
    user_id = user_response.json()["user"]["id"]

    client.put(
        "/notifications/settings",
        headers=user_headers,
        json={
            "enabled": True,
            "reminder_time": "08:00",
            "timezone": "UTC",
            "push_token": "device-token-123",
        },
    )

    session = SessionLocal()
    try:
        session.add(
            UserProgressModel(
                user_id=user_id,
                date=date(2026, 4, 29),
                completed=True,
            )
        )
        streak = session.get(UserStreakModel, user_id)
        assert streak is not None
        streak.current_streak = 2
        streak.longest_streak = 2
        streak.last_activity_date = date(2026, 4, 29)
        session.add(streak)
        session.commit()
    finally:
        session.close()

    due_response = client.get(
        "/notifications/admin/due",
        headers=admin_headers,
        params={"current_time": "2026-04-30T08:00:00Z"},
    )

    assert due_response.status_code == 200
    item = due_response.json()["due_notifications"][0]
    assert item["user_id"] == user_id
    assert item["tone"] in {"building", "milestone", "strong_streak"}
    assert item["current_streak"] == 2
    assert item["next_milestone"] == 3
    assert "chegar a 3 dias" in item["message"]


def test_due_notifications_encourage_restart_after_gap() -> None:
    admin_response = client.post(
        "/auth/register",
        json={"email": "admin@example.com", "password": "segredo123"},
    )
    admin_headers = {"Authorization": f"Bearer {admin_response.json()['access_token']}"}

    user_response = client.post(
        "/auth/register",
        json={"email": "user@example.com", "password": "segredo123"},
    )
    user_headers = {"Authorization": f"Bearer {user_response.json()['access_token']}"}

    client.put(
        "/notifications/settings",
        headers=user_headers,
        json={
            "enabled": True,
            "reminder_time": "08:00",
            "timezone": "UTC",
            "push_token": "device-token-123",
        },
    )

    session = SessionLocal()
    try:
        session.add(
            UserProgressModel(
                user_id=user_response.json()["user"]["id"],
                date=date(2026, 4, 29),
                completed=True,
            )
        )
        streak = session.get(UserStreakModel, user_response.json()["user"]["id"])
        assert streak is not None
        streak.current_streak = 5
        streak.longest_streak = 5
        streak.last_activity_date = date(2026, 4, 29)
        session.add(streak)
        session.commit()
    finally:
        session.close()

    due_response = client.get(
        "/notifications/admin/due",
        headers=admin_headers,
        params={"current_time": "2026-05-03T08:00:00Z"},
    )

    assert due_response.status_code == 200
    item = due_response.json()["due_notifications"][0]
    assert item["tone"] == "restart"
    assert "Recomece hoje" in item["message"]

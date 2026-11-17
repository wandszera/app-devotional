from datetime import date
from pathlib import Path

from fastapi.testclient import TestClient

from app.core.config import settings
from app.db.init_db import init_db
from app.db.models import DevotionalModel
from app.db.session import Base, DATABASE_URL, SessionLocal, engine
from app.main import app
from app.services.catalogue_import_service import import_catalogue, load_catalogue


client = TestClient(app)
CATALOGUE_PATH = (
    Path(__file__).resolve().parents[1]
    / "mobile"
    / "assets"
    / "liturgy"
    / "gospel_catalogue.json"
)


def setup_function() -> None:
    assert "app_devocional_tests_" in DATABASE_URL
    settings.admin_emails = {"admin@example.com"}
    Base.metadata.drop_all(bind=engine)
    init_db()


def _entry(day: str, reference: str = "Lc 1,1-4", reflection: str = "Reflexão") -> dict:
    return {
        "date": day,
        "liturgical_title": "Tempo Comum",
        "gospel_reference": reference,
        "reflection": reflection,
    }


def _token(email: str = "user@example.com") -> dict[str, str]:
    response = client.post(
        "/auth/register", json={"email": email, "password": "segredo123"}
    )
    return {"Authorization": f"Bearer {response.json()['access_token']}"}


def test_import_creates_then_is_idempotent() -> None:
    entries = [_entry("2027-01-10"), _entry("2027-01-11")]
    with SessionLocal() as session:
        first = import_catalogue(session, entries, "https://example.org")
        second = import_catalogue(session, entries, "https://example.org")

    assert (first.created, first.updated, first.skipped) == (2, 0, 0)
    assert (second.created, second.updated, second.skipped) == (0, 0, 2)


def test_import_never_overwrites_admin_edit_without_flag() -> None:
    with SessionLocal() as session:
        import_catalogue(session, [_entry("2027-01-10")], "u")
        item = session.query(DevotionalModel).filter_by(date=date(2027, 1, 10)).one()
        item.content = "Edição do administrador"
        session.commit()

        kept = import_catalogue(session, [_entry("2027-01-10")], "u")
        assert kept.skipped == 1
        session.refresh(item)
        assert item.content == "Edição do administrador"

        forced = import_catalogue(session, [_entry("2027-01-10")], "u", overwrite=True)
        assert forced.updated == 1
        session.refresh(item)
        assert item.content == "Reflexão"


def test_import_fills_placeholder_and_dry_run_changes_nothing() -> None:
    with SessionLocal() as session:
        session.add(
            DevotionalModel(
                title="Evangelho do dia",
                content="placeholder",
                date=date(2027, 2, 1),
                gospel_reference="",
            )
        )
        session.commit()

        dry = import_catalogue(session, [_entry("2027-02-01")], "u", dry_run=True)
        assert dry.updated == 1
        placeholder = session.query(DevotionalModel).filter_by(date=date(2027, 2, 1)).one()
        assert placeholder.gospel_reference == ""

        real = import_catalogue(session, [_entry("2027-02-01")], "u")
        assert real.updated == 1
        session.refresh(placeholder)
        assert placeholder.gospel_reference == "Lc 1,1-4"


def test_bundled_catalogue_imports_all_entries_and_is_idempotent() -> None:
    source_url, entries = load_catalogue(CATALOGUE_PATH)
    assert len(entries) == 30
    with SessionLocal() as session:
        first = import_catalogue(session, entries, source_url)
        second = import_catalogue(session, entries, source_url)
        total = session.query(DevotionalModel).count()

    assert first.created + first.updated + first.skipped == 30
    assert (second.created, second.updated) == (0, 0)
    assert total == 30


def test_calendar_requires_authentication() -> None:
    assert client.get("/devotional/calendar").status_code == 401


def test_calendar_lists_published_entries_and_hides_placeholders() -> None:
    headers = _token()
    with SessionLocal() as session:
        import_catalogue(
            session, [_entry("2027-01-10"), _entry("2027-01-11")], "https://example.org"
        )

    # Cria um placeholder persistido para hoje: não pode aparecer no calendário.
    assert client.get("/devotional/today", headers=headers).status_code == 200

    response = client.get(
        "/devotional/calendar",
        params={"start_date": "2027-01-10", "end_date": "2027-01-10"},
        headers=headers,
    )
    assert response.status_code == 200
    items = response.json()["devotionals"]
    assert [item["date"] for item in items] == ["2027-01-10"]
    assert items[0]["gospel_reference"] == "Lc 1,1-4"

    everything = client.get("/devotional/calendar", headers=headers).json()["devotionals"]
    assert all(item["gospel_reference"] for item in everything)

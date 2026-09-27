from datetime import date

from app.db.init_db import CNBB_DAILY_LITURGY_URL, init_db
from app.db.models import DevotionalModel
from app.db.session import Base, DATABASE_URL, SessionLocal, engine


def setup_function() -> None:
    assert "app_devocional_tests_" in DATABASE_URL
    Base.metadata.drop_all(bind=engine)
    init_db()


def test_initial_gospel_catalogue_uses_citation_and_official_source() -> None:
    session = SessionLocal()
    try:
        item = (
            session.query(DevotionalModel)
            .filter(DevotionalModel.date == date(2026, 9, 3))
            .one()
        )
        assert item.title == "Evangelho do dia"
        assert item.liturgical_title.startswith("São Gregório Magno")
        assert item.gospel_reference == "Lc 5,1-11"
        assert item.source_url == CNBB_DAILY_LITURGY_URL
        assert "Peça a coragem" in item.content
    finally:
        session.close()

from __future__ import annotations

from datetime import UTC, date, datetime

from sqlalchemy import inspect, text
from sqlalchemy.orm import Session

from app.core.config import settings
from app.db.models import DevotionalModel
from app.db.session import Base, DATABASE_URL, SessionLocal, engine


CNBB_DAILY_LITURGY_URL = "https://liturgiadiaria.edicoescnbb.com.br/"


# Initial, reviewed local catalogue.  The citations below are the Gospel only
# (not a copy of the biblical text), following the Brazilian Roman Rite shown
# by Edições CNBB's Igreja em Oração.  The Flutter application uses its
# versioned bundled catalogue as the public editorial source; this seed keeps
# the API compatible with the first verified entries.
INITIAL_GOSPEL_CATALOGUE = (
    (
        date(2026, 9, 1),
        "22ª Semana do Tempo Comum",
        "Lc 4,31-37",
        "Peça a graça de acolher a palavra de Jesus com atenção e liberdade.",
    ),
    (
        date(2026, 9, 2),
        "22ª Semana do Tempo Comum",
        "Lc 4,38-44",
        "Apresente a Jesus as pessoas e as situações que hoje precisam de cuidado.",
    ),
    (
        date(2026, 9, 3),
        "São Gregório Magno, papa e doutor da Igreja, Memória",
        "Lc 5,1-11",
        "Peça a coragem de lançar as redes de novo e seguir Jesus com confiança.",
    ),
    (
        date(2026, 9, 4),
        "22ª Semana do Tempo Comum",
        "Lc 5,33-39",
        "Peça um coração disponível para reconhecer a novidade que Cristo traz.",
    ),
    (
        date(2026, 9, 5),
        "22ª Semana do Tempo Comum",
        "Lc 6,1-5",
        "Contemple Jesus, Senhor do sábado, e entregue a ele o ritmo do seu dia.",
    ),
    (
        date(2026, 9, 6),
        "23º Domingo do Tempo Comum, Ano A",
        "Mt 18,15-20",
        "Reze por diálogo, reconciliação e unidade nas relações que Deus lhe confiou.",
    ),
    (
        date(2026, 9, 7),
        "23ª Semana do Tempo Comum",
        "Lc 6,6-11",
        "Peça a graça de escolher a vida e o bem, mesmo nas pequenas decisões.",
    ),
)


def seed_devotionals(session: Session) -> None:
    for devotional_date, liturgical_title, gospel_reference, reflection in INITIAL_GOSPEL_CATALOGUE:
        existing = (
            session.query(DevotionalModel)
            .filter(DevotionalModel.date == devotional_date)
            .first()
        )
        if existing is not None:
            continue
        session.add(
            DevotionalModel(
                title="Evangelho do dia",
                content=reflection,
                date=devotional_date,
                liturgical_title=liturgical_title,
                gospel_reference=gospel_reference,
                source_url=CNBB_DAILY_LITURGY_URL,
            )
        )
    session.commit()


def init_db() -> None:
    Base.metadata.create_all(bind=engine)
    _ensure_legacy_columns()
    session = SessionLocal()
    try:
        seed_devotionals(session)
    finally:
        session.close()


def _ensure_legacy_columns() -> None:
    """Keep pre-Alembic SQLite development databases usable.

    Production deployments should still run the migration.  These safe,
    idempotent additions avoid making a local development database unreadable
    immediately after an app update.
    """
    if not DATABASE_URL.startswith("sqlite"):
        return
    inspector = inspect(engine)
    tables = set(inspector.get_table_names())
    with engine.begin() as connection:
        if "users" in tables:
            user_columns = {column["name"] for column in inspector.get_columns("users")}
            if "password_hash" not in user_columns:
                connection.execute(
                    text("ALTER TABLE users ADD COLUMN password_hash VARCHAR(255) NOT NULL DEFAULT ''")
                )
            if "is_admin" not in user_columns:
                connection.execute(
                    text("ALTER TABLE users ADD COLUMN is_admin BOOLEAN NOT NULL DEFAULT 0")
                )
        if "devotionals" in tables:
            devotional_columns = {
                column["name"] for column in inspector.get_columns("devotionals")
            }
            missing_columns = (
                ("liturgical_title", "VARCHAR(255) NOT NULL DEFAULT ''"),
                ("gospel_reference", "VARCHAR(128) NOT NULL DEFAULT ''"),
                ("source_url", "VARCHAR(1024) NOT NULL DEFAULT ''"),
            )
            for column_name, column_type in missing_columns:
                if column_name not in devotional_columns:
                    connection.execute(
                        text(f"ALTER TABLE devotionals ADD COLUMN {column_name} {column_type}")
                    )

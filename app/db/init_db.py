from __future__ import annotations

from datetime import date, timedelta

from sqlalchemy import inspect, text
from sqlalchemy.orm import Session

from app.db.models import DevotionalModel
from app.db.session import Base, DATABASE_URL, SessionLocal, engine


def seed_devotionals(session: Session) -> None:
    if session.query(DevotionalModel).count() > 0:
        return

    today = date.today()
    samples = [
        (
            "Constancia no secreto",
            "Reserve a few quiet minutes today and remember that faithful daily presence matters more than intensity.",
        ),
        (
            "Gratitude in practice",
            "Write down one blessing from today and turn it into a short prayer before you move on with your routine.",
        ),
        (
            "Peace for this moment",
            "Breathe, slow down, and hand over your worries one by one in prayer before starting the next task.",
        ),
    ]

    for index, (title, content) in enumerate(samples):
        session.add(
            DevotionalModel(
                title=title,
                content=content,
                date=today + timedelta(days=index),
            )
        )

    session.commit()


def init_db() -> None:
    Base.metadata.create_all(bind=engine)
    _ensure_user_columns()
    session = SessionLocal()
    try:
        seed_devotionals(session)
    finally:
        session.close()


def _ensure_user_columns() -> None:
    if not DATABASE_URL.startswith("sqlite"):
        return

    inspector = inspect(engine)
    columns = {column["name"] for column in inspector.get_columns("users")} if "users" in inspector.get_table_names() else set()
    if "users" in columns:
        with engine.begin() as connection:
            if "password_hash" not in columns:
                connection.execute(
                    text("ALTER TABLE users ADD COLUMN password_hash VARCHAR(255) NOT NULL DEFAULT ''")
                )
            if "is_admin" not in columns:
                connection.execute(
                    text("ALTER TABLE users ADD COLUMN is_admin BOOLEAN NOT NULL DEFAULT 0")
                )

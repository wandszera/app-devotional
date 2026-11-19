from __future__ import annotations

import os

from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker


def normalize_database_url(url: str) -> str:
    """Hosts like Render/Railway/Heroku return postgres:// or postgresql://,
    which SQLAlchemy 2 would map to psycopg2. Force the psycopg (v3) driver."""
    if url.startswith("postgres://"):
        url = "postgresql://" + url[len("postgres://"):]
    if url.startswith("postgresql://"):
        url = "postgresql+psycopg://" + url[len("postgresql://"):]
    return url


DATABASE_URL = normalize_database_url(os.getenv("DATABASE_URL", "sqlite:///./devotional.db"))

connect_args = {"check_same_thread": False} if DATABASE_URL.startswith("sqlite") else {}

engine = create_engine(DATABASE_URL, connect_args=connect_args)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

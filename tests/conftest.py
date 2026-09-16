from __future__ import annotations

import os
import tempfile
from pathlib import Path


_test_directory = tempfile.TemporaryDirectory(prefix="app_devocional_tests_")
_test_database = Path(_test_directory.name) / "test.db"

# Configure this before application modules are imported during collection so
# the destructive schema reset can never target the developer database.
os.environ["DATABASE_URL"] = f"sqlite:///{_test_database.as_posix()}"
os.environ["APP_ENV"] = "test"


def pytest_sessionfinish() -> None:
    from app.db.session import engine

    engine.dispose()
    _test_directory.cleanup()

from __future__ import annotations

import json
from dataclasses import dataclass
from datetime import date
from pathlib import Path
from typing import Any

from sqlalchemy.orm import Session

from app.db.models import DevotionalModel


DEFAULT_TITLE = "Evangelho do dia"


@dataclass
class ImportResult:
    created: int = 0
    updated: int = 0
    skipped: int = 0


def load_catalogue(path: Path) -> tuple[str, list[dict[str, Any]]]:
    """Lê o catálogo editorial (mesmo JSON empacotado no app) sem alterá-lo."""
    data = json.loads(path.read_text(encoding="utf-8"))
    source = data.get("source") or {}
    return str(source.get("url", "")), list(data.get("entries") or [])


def import_catalogue(
    session: Session,
    entries: list[dict[str, Any]],
    source_url: str,
    *,
    overwrite: bool = False,
    dry_run: bool = False,
) -> ImportResult:
    """Publica entradas do catálogo no banco (fonte canônica: API).

    - data inexistente: cria;
    - placeholder (sem referência do Evangelho): preenche;
    - registro já editorial: só é alterado com ``overwrite=True``, para nunca
      desfazer uma edição feita pelo administrador sem pedido explícito.
    """
    result = ImportResult()
    for entry in entries:
        entry_date = date.fromisoformat(entry["date"])
        values = {
            "title": DEFAULT_TITLE,
            "content": entry.get("reflection", ""),
            "liturgical_title": entry.get("liturgical_title", ""),
            "gospel_reference": entry.get("gospel_reference", ""),
            "source_url": source_url,
        }
        existing = (
            session.query(DevotionalModel)
            .filter(DevotionalModel.date == entry_date)
            .first()
        )
        if existing is None:
            if not dry_run:
                session.add(DevotionalModel(date=entry_date, **values))
            result.created += 1
            continue

        is_placeholder = not existing.gospel_reference
        unchanged = all(getattr(existing, key) == value for key, value in values.items())
        if unchanged or not (is_placeholder or overwrite):
            result.skipped += 1
            continue
        if not dry_run:
            for key, value in values.items():
                setattr(existing, key, value)
        result.updated += 1

    if dry_run:
        session.rollback()
    else:
        session.commit()
    return result

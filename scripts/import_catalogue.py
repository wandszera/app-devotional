"""Publica o catálogo litúrgico (JSON do app) no banco da API.

Uso (a partir da raiz do repositório, com as migrações já aplicadas):

    python scripts/import_catalogue.py --dry-run
    python scripts/import_catalogue.py
    python scripts/import_catalogue.py --overwrite   # sobrescreve edições do admin

Não gera nem altera texto editorial: apenas copia o que está no arquivo.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from app.db.session import SessionLocal  # noqa: E402
from app.services.catalogue_import_service import (  # noqa: E402
    import_catalogue,
    load_catalogue,
)

DEFAULT_PATH = ROOT / "mobile" / "assets" / "liturgy" / "gospel_catalogue.json"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("path", nargs="?", type=Path, default=DEFAULT_PATH)
    parser.add_argument("--overwrite", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    source_url, entries = load_catalogue(args.path)
    session = SessionLocal()
    try:
        result = import_catalogue(
            session,
            entries,
            source_url,
            overwrite=args.overwrite,
            dry_run=args.dry_run,
        )
    finally:
        session.close()

    mode = " (dry-run)" if args.dry_run else ""
    print(
        f"{len(entries)} entradas{mode}: criadas={result.created} "
        f"atualizadas={result.updated} ignoradas={result.skipped}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

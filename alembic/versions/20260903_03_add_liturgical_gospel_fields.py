"""add local Gospel catalogue fields to devotionals

Revision ID: 20260903_03
Revises: 20260901_02
Create Date: 2026-09-03
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "20260903_03"
down_revision: Union[str, Sequence[str], None] = "20260901_02"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "devotionals",
        sa.Column("liturgical_title", sa.String(length=255), nullable=False, server_default=""),
    )
    op.add_column(
        "devotionals",
        sa.Column("gospel_reference", sa.String(length=128), nullable=False, server_default=""),
    )
    op.add_column(
        "devotionals",
        sa.Column("source_url", sa.String(length=1024), nullable=False, server_default=""),
    )


def downgrade() -> None:
    op.drop_column("devotionals", "source_url")
    op.drop_column("devotionals", "gospel_reference")
    op.drop_column("devotionals", "liturgical_title")

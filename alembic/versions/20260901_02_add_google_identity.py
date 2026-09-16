"""add Google identity fields to users

Revision ID: 20260901_02
Revises: 20260901_01
Create Date: 2026-09-01
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "20260901_02"
down_revision: Union[str, Sequence[str], None] = "20260901_01"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("users", sa.Column("firebase_uid", sa.String(length=128), nullable=True))
    op.add_column(
        "users",
        sa.Column(
            "auth_provider",
            sa.String(length=32),
            nullable=False,
            server_default="password",
        ),
    )
    op.create_index("ix_users_firebase_uid", "users", ["firebase_uid"], unique=True)


def downgrade() -> None:
    op.drop_index("ix_users_firebase_uid", table_name="users")
    op.drop_column("users", "auth_provider")
    op.drop_column("users", "firebase_uid")

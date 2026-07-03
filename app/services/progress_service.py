from __future__ import annotations

from sqlalchemy.orm import Session

from app.db.models import UserModel, UserProgressModel
from app.models.schemas import ProgressResponse, UserProgress


class ProgressService:
    def get_progress(self, session: Session, user_id: int) -> ProgressResponse | None:
        user = session.get(UserModel, user_id)
        if user is None:
            return None

        progress_entries = (
            session.query(UserProgressModel)
            .filter(UserProgressModel.user_id == user_id)
            .order_by(UserProgressModel.date.desc())
            .all()
        )
        return ProgressResponse(
            user_id=user_id,
            completed_days=[UserProgress.model_validate(item) for item in progress_entries],
        )


progress_service = ProgressService()

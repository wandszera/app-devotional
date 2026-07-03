from __future__ import annotations

from datetime import date, timedelta

from sqlalchemy.orm import Session

from app.db.models import UserStreakModel
from app.models.schemas import UserStreak


class StreakService:
    milestone_days = (3, 7, 14, 30, 60, 100)

    def get_streak(self, session: Session, user_id: int) -> UserStreak | None:
        streak = session.get(UserStreakModel, user_id)
        if streak is None:
            return None
        return self._to_schema(streak)

    def update_streak(self, session: Session, user_id: int, activity_date: date) -> UserStreak | None:
        streak = session.get(UserStreakModel, user_id)
        if streak is None:
            return None

        if streak.last_activity_date == activity_date:
            return self._to_schema(streak)

        previous_day = activity_date - timedelta(days=1)
        if streak.last_activity_date == previous_day:
            streak.current_streak += 1
        else:
            streak.current_streak = 1

        streak.last_activity_date = activity_date

        if streak.current_streak > streak.longest_streak:
            streak.longest_streak = streak.current_streak

        session.add(streak)
        session.commit()
        session.refresh(streak)
        return self._to_schema(streak)

    def _to_schema(self, streak: UserStreakModel) -> UserStreak:
        latest_milestone = None
        for milestone in self.milestone_days:
            if streak.longest_streak >= milestone:
                latest_milestone = milestone

        return UserStreak(
            user_id=streak.user_id,
            current_streak=streak.current_streak,
            longest_streak=streak.longest_streak,
            last_activity_date=streak.last_activity_date,
            latest_milestone=latest_milestone,
        )


streak_service = StreakService()

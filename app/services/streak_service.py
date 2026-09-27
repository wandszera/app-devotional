from __future__ import annotations

from datetime import date, timedelta

from sqlalchemy.orm import Session

from app.db.models import UserProgressModel, UserStreakModel
from app.models.schemas import UserStreak


class StreakService:
    milestone_days = (3, 7, 14, 30, 60, 100)

    def get_streak(self, session: Session, user_id: int) -> UserStreak | None:
        streak = session.get(UserStreakModel, user_id)
        if streak is None:
            return None
        return self._to_schema(streak)

    def update_streak(
        self,
        session: Session,
        user_id: int,
        activity_date: date,
        *,
        commit: bool = True,
    ) -> UserStreak | None:
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
        if commit:
            session.commit()
            session.refresh(streak)
        else:
            session.flush()
        return self._to_schema(streak)

    def recalculate_streak(
        self,
        session: Session,
        user_id: int,
        *,
        commit: bool = True,
    ) -> UserStreak | None:
        streak = session.get(UserStreakModel, user_id)
        if streak is None:
            return None
        completed_dates = [
            item.date
            for item in session.query(UserProgressModel)
            .filter(
                UserProgressModel.user_id == user_id,
                UserProgressModel.completed.is_(True),
            )
            .order_by(UserProgressModel.date.asc())
            .all()
        ]
        if not completed_dates:
            return self._to_schema(streak)
        current_run = longest_run = 1
        for previous, current in zip(completed_dates, completed_dates[1:]):
            current_run = current_run + 1 if current == previous + timedelta(days=1) else 1
            longest_run = max(longest_run, current_run)
        ending_run = 1
        for index in range(len(completed_dates) - 1, 0, -1):
            if completed_dates[index] == completed_dates[index - 1] + timedelta(days=1):
                ending_run += 1
            else:
                break
        streak.current_streak = ending_run
        streak.longest_streak = longest_run
        streak.last_activity_date = completed_dates[-1]
        session.add(streak)
        if commit:
            session.commit()
            session.refresh(streak)
        else:
            session.flush()
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

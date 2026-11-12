from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.models.schemas import User, UserStreak
from app.services.streak_service import streak_service
from app.services.user_day_service import get_user_local_date


router = APIRouter(tags=["streak"])


@router.get("/streak", response_model=UserStreak)
def get_streak(
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db),
) -> UserStreak:
    today = get_user_local_date(session, current_user.id)
    streak = streak_service.get_streak(session, current_user.id, today=today)
    if streak is None:
        raise HTTPException(status_code=404, detail="user not found")
    return streak

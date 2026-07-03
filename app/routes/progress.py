from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.models.schemas import ProgressResponse, User
from app.services.progress_service import progress_service


router = APIRouter(tags=["progress"])


@router.get("/progress", response_model=ProgressResponse)
def get_progress(
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db),
) -> ProgressResponse:
    progress = progress_service.get_progress(session, current_user.id)
    if progress is None:
        raise HTTPException(status_code=404, detail="user not found")
    return progress

from datetime import date

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db, require_admin
from app.models.schemas import (
    Devotional,
    DevotionalCompletionResponse,
    DevotionalCreateRequest,
    DevotionalListResponse,
    DevotionalUpdateRequest,
    DevotionalWithCompletion,
    FavoriteToggleResponse,
    User,
)
from app.services.devotional_service import devotional_service


router = APIRouter(prefix="/devotional", tags=["devotional"])


@router.get("/today", response_model=DevotionalWithCompletion)
def get_today_devotional(
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db),
) -> DevotionalWithCompletion:
    devotional = devotional_service.get_today_devotional(session, current_user.id)
    if devotional is None:
        raise HTTPException(status_code=404, detail="devotional not found")
    return devotional


@router.post("/complete", response_model=DevotionalCompletionResponse)
def complete_today_devotional(
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db),
) -> DevotionalCompletionResponse:
    result = devotional_service.complete_today_devotional(session, current_user.id)
    if result is None:
        raise HTTPException(status_code=404, detail="user or devotional not found")
    return result


@router.post("/{devotional_id}/favorite", response_model=FavoriteToggleResponse)
def toggle_devotional_favorite(
    devotional_id: int,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db),
) -> FavoriteToggleResponse:
    is_favorited = devotional_service.toggle_favorite(session, current_user.id, devotional_id)
    return FavoriteToggleResponse(devotional_id=devotional_id, is_favorited=is_favorited)


@router.get("/favorites", response_model=DevotionalListResponse)
def get_user_favorites(
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db),
) -> DevotionalListResponse:
    favorites = devotional_service.get_favorites(session, current_user.id)
    return DevotionalListResponse(devotionals=favorites)


@router.get("/admin", response_model=DevotionalListResponse)
def list_devotionals(
    start_date: date | None = None,
    end_date: date | None = None,
    admin_user: User = Depends(require_admin),
    session: Session = Depends(get_db),
) -> DevotionalListResponse:
    del admin_user
    devotionals = devotional_service.list_devotionals(session, start_date, end_date)
    return DevotionalListResponse(devotionals=devotionals)


@router.post("/admin", response_model=Devotional, status_code=201)
def create_devotional(
    payload: DevotionalCreateRequest,
    admin_user: User = Depends(require_admin),
    session: Session = Depends(get_db),
):
    del admin_user
    try:
        return devotional_service.create_devotional(session, payload.title, payload.content, payload.date)
    except ValueError as exc:
        raise HTTPException(status_code=409, detail=str(exc)) from exc


@router.put("/admin/{devotional_id}", response_model=Devotional)
def update_devotional(
    devotional_id: int,
    payload: DevotionalUpdateRequest,
    admin_user: User = Depends(require_admin),
    session: Session = Depends(get_db),
):
    del admin_user
    try:
        devotional = devotional_service.update_devotional(
            session,
            devotional_id,
            title=payload.title,
            content=payload.content,
            devotional_date=payload.date,
        )
    except ValueError as exc:
        raise HTTPException(status_code=409, detail=str(exc)) from exc

    if devotional is None:
        raise HTTPException(status_code=404, detail="devotional not found")
    return devotional


@router.delete("/admin/{devotional_id}")
def delete_devotional(
    devotional_id: int,
    admin_user: User = Depends(require_admin),
    session: Session = Depends(get_db),
) -> dict[str, str]:
    del admin_user
    deleted = devotional_service.delete_devotional(session, devotional_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="devotional not found")
    return {"message": "devotional deleted"}

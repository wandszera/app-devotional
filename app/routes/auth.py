from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.models.schemas import (
    AuthenticatedUserResponse,
    LoginRequest,
    LoginResponse,
    RegisterRequest,
    User,
    UserProfileUpdateRequest,
)
from app.services.user_service import user_service


router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=LoginResponse, status_code=201)
def register(payload: RegisterRequest, session: Session = Depends(get_db)) -> LoginResponse:
    user = user_service.register(session, payload.email, payload.password)
    return LoginResponse(
        user=user,
        message="user created",
        access_token=user_service.create_token(user),
    )


@router.post("/login", response_model=LoginResponse)
def login(payload: LoginRequest, session: Session = Depends(get_db)) -> LoginResponse:
    user = user_service.authenticate(session, payload.email, payload.password)
    return LoginResponse(
        user=user,
        message="user authenticated",
        access_token=user_service.create_token(user),
    )


@router.get("/me", response_model=AuthenticatedUserResponse)
def me(current_user: User = Depends(get_current_user)) -> AuthenticatedUserResponse:
    return AuthenticatedUserResponse(user=current_user)


@router.put("/me", response_model=AuthenticatedUserResponse)
def update_me(
    payload: UserProfileUpdateRequest,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db),
) -> AuthenticatedUserResponse:
    from app.db.models import UserModel
    
    user_model = session.query(UserModel).filter(UserModel.email == current_user.email).first()
    if not user_model:
        raise ValueError("User not found")
        
    user_model.name = payload.name
    user_model.bio = payload.bio
    session.commit()
    session.refresh(user_model)
    
    updated_user = User.model_validate(user_model)
    return AuthenticatedUserResponse(user=updated_user)

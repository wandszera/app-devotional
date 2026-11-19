from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.models.schemas import (
    AuthenticatedUserResponse,
    DeleteAccountRequest,
    GoogleLoginRequest,
    LoginRequest,
    LoginResponse,
    RefreshRequest,
    TokenRefreshResponse,
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
        refresh_token=user_service.issue_refresh_token(session, user.id),
    )


@router.post("/login", response_model=LoginResponse)
def login(payload: LoginRequest, session: Session = Depends(get_db)) -> LoginResponse:
    user = user_service.authenticate(session, payload.email, payload.password)
    return LoginResponse(
        user=user,
        message="user authenticated",
        access_token=user_service.create_token(user),
        refresh_token=user_service.issue_refresh_token(session, user.id),
    )


@router.post("/google", response_model=LoginResponse)
def login_with_google(
    payload: GoogleLoginRequest,
    session: Session = Depends(get_db),
) -> LoginResponse:
    user = user_service.authenticate_with_google(session, payload.id_token)
    return LoginResponse(
        user=user,
        message="user authenticated with Google",
        access_token=user_service.create_token(user),
        refresh_token=user_service.issue_refresh_token(session, user.id),
    )


@router.post("/refresh", response_model=TokenRefreshResponse)
def refresh_session(
    payload: RefreshRequest,
    session: Session = Depends(get_db),
) -> TokenRefreshResponse:
    _, access_token, refresh_token = user_service.rotate_refresh_token(
        session, payload.refresh_token
    )
    return TokenRefreshResponse(access_token=access_token, refresh_token=refresh_token)


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
def logout(payload: RefreshRequest, session: Session = Depends(get_db)) -> Response:
    user_service.revoke_refresh_token(session, payload.refresh_token)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get("/me", response_model=AuthenticatedUserResponse)
def me(current_user: User = Depends(get_current_user)) -> AuthenticatedUserResponse:
    return AuthenticatedUserResponse(user=current_user)


@router.delete("/me", status_code=status.HTTP_204_NO_CONTENT)
def delete_me(
    payload: DeleteAccountRequest,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db),
) -> Response:
    user_service.delete_account(
        session,
        current_user.id,
        password=payload.password,
        id_token=payload.id_token,
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.put("/me", response_model=AuthenticatedUserResponse)
def update_me(
    payload: UserProfileUpdateRequest,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db),
) -> AuthenticatedUserResponse:
    from app.db.models import UserModel
    
    user_model = session.query(UserModel).filter(UserModel.email == current_user.email).first()
    if not user_model:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="user not found",
        )
        
    user_model.name = payload.name
    user_model.bio = payload.bio
    session.commit()
    session.refresh(user_model)
    
    updated_user = User.model_validate(user_model)
    return AuthenticatedUserResponse(user=updated_user)

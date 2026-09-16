from __future__ import annotations

from datetime import date, datetime

from sqlalchemy import and_
from sqlalchemy.orm import Session

from app.db.models import DevotionalModel, UserModel, UserFavoriteModel, UserProgressModel, UserStreakModel
from app.models.schemas import (
    Devotional,
    DevotionalCompletionFeedback,
    DevotionalCompletionResponse,
    DevotionalGuidance,
    DevotionalWithCompletion,
)
from app.services.streak_service import streak_service
from app.services.user_day_service import get_user_local_date


class DevotionalService:
    milestone_days = (3, 7, 14, 30, 60, 100)

    def get_today_devotional(
        self,
        session: Session,
        user_id: int,
        *,
        now_utc: datetime | None = None,
    ) -> DevotionalWithCompletion | None:
        user = session.get(UserModel, user_id)
        if user is None:
            return None

        today = get_user_local_date(session, user_id, now_utc=now_utc)
        devotional = self._get_or_create_today_devotional(session, today)
        completed = (
            session.query(UserProgressModel)
            .filter(UserProgressModel.user_id == user_id, UserProgressModel.date == today)
            .first()
            is not None
        )
        is_favorited = (
            session.query(UserFavoriteModel)
            .filter(UserFavoriteModel.user_id == user_id, UserFavoriteModel.devotional_id == devotional.id)
            .first()
            is not None
        )
        streak = session.get(UserStreakModel, user_id)
        return DevotionalWithCompletion(
            devotional=Devotional.model_validate(devotional),
            completed=completed,
            is_favorited=is_favorited,
            guidance=self._build_guidance(
                completed=completed,
                streak=streak,
            ),
        )

    def complete_today_devotional(
        self,
        session: Session,
        user_id: int,
        *,
        completed_date: date | None = None,
        now_utc: datetime | None = None,
    ) -> DevotionalCompletionResponse | None:
        user = session.get(UserModel, user_id)
        if user is None:
            return None

        today = get_user_local_date(session, user_id, now_utc=now_utc)
        activity_date = completed_date or today
        if activity_date > today:
            raise ValueError("completed_date cannot be in the future")
        devotional = self._get_or_create_today_devotional(session, activity_date)
        progress = (
            session.query(UserProgressModel)
            .filter(
                UserProgressModel.user_id == user_id,
                UserProgressModel.date == activity_date,
            )
            .first()
        )
        if progress is None:
            session.add(
                UserProgressModel(
                    user_id=user_id,
                    date=activity_date,
                    completed=True,
                )
            )
            session.flush()

        streak = (
            streak_service.update_streak(
                session,
                user_id,
                activity_date=activity_date,
                commit=False,
            )
            if activity_date == today
            else streak_service.recalculate_streak(session, user_id, commit=False)
        )
        session.commit()
        return DevotionalCompletionResponse(
            message="devotional completed",
            devotional_id=devotional.id,
            streak=streak,
            feedback=self._build_completion_feedback(streak),
        )

    def _get_or_create_today_devotional(
        self,
        session: Session,
        devotional_date: date,
    ) -> DevotionalModel:
        devotional = (
            session.query(DevotionalModel)
            .filter(DevotionalModel.date == devotional_date)
            .first()
        )
        if devotional is not None:
            return devotional

        # A missing catalogue item must never be replaced by an invented
        # devotional or an unsourced Bible passage.  The app can still direct
        # the person to the official daily liturgy while an administrator adds
        # the citation to the local catalogue.
        devotional = DevotionalModel(
            title="Evangelho do dia",
            content=(
                "A referência do Evangelho ainda não foi adicionada ao catálogo "
                "local. Consulte a Liturgia Diária oficial da CNBB."
            ),
            date=devotional_date,
            liturgical_title="Liturgia diária",
            gospel_reference="",
            source_url="https://liturgiadiaria.edicoescnbb.com.br/",
        )
        session.add(devotional)
        session.commit()
        session.refresh(devotional)
        return devotional

    def list_devotionals(
        self,
        session: Session,
        start_date: date | None = None,
        end_date: date | None = None,
    ) -> list[Devotional]:
        query = session.query(DevotionalModel)
        filters = []
        if start_date is not None:
            filters.append(DevotionalModel.date >= start_date)
        if end_date is not None:
            filters.append(DevotionalModel.date <= end_date)
        if filters:
            query = query.filter(and_(*filters))

        devotionals = query.order_by(DevotionalModel.date.asc()).all()
        return [Devotional.model_validate(item) for item in devotionals]

    def create_devotional(
        self,
        session: Session,
        title: str,
        content: str,
        devotional_date: date,
        *,
        liturgical_title: str = "",
        gospel_reference: str = "",
        source_url: str = "",
    ) -> Devotional:
        existing = session.query(DevotionalModel).filter(DevotionalModel.date == devotional_date).first()
        if existing is not None:
            raise ValueError("a devotional already exists for this date")

        devotional = DevotionalModel(
            title=title,
            content=content,
            date=devotional_date,
            liturgical_title=liturgical_title,
            gospel_reference=gospel_reference,
            source_url=source_url,
        )
        session.add(devotional)
        session.commit()
        session.refresh(devotional)
        return Devotional.model_validate(devotional)

    def update_devotional(
        self,
        session: Session,
        devotional_id: int,
        title: str | None = None,
        content: str | None = None,
        devotional_date: date | None = None,
        liturgical_title: str | None = None,
        gospel_reference: str | None = None,
        source_url: str | None = None,
    ) -> Devotional | None:
        devotional = session.get(DevotionalModel, devotional_id)
        if devotional is None:
            return None

        if devotional_date is not None and devotional_date != devotional.date:
            existing = session.query(DevotionalModel).filter(DevotionalModel.date == devotional_date).first()
            if existing is not None:
                raise ValueError("a devotional already exists for this date")
            devotional.date = devotional_date

        if title is not None:
            devotional.title = title
        if content is not None:
            devotional.content = content
        if liturgical_title is not None:
            devotional.liturgical_title = liturgical_title
        if gospel_reference is not None:
            devotional.gospel_reference = gospel_reference
        if source_url is not None:
            devotional.source_url = source_url

        session.add(devotional)
        session.commit()
        session.refresh(devotional)
        return Devotional.model_validate(devotional)

    def delete_devotional(self, session: Session, devotional_id: int) -> bool:
        devotional = session.get(DevotionalModel, devotional_id)
        if devotional is None:
            return False

        session.query(UserFavoriteModel).filter(
            UserFavoriteModel.devotional_id == devotional_id
        ).delete(synchronize_session=False)
        session.delete(devotional)
        session.commit()
        return True

    def toggle_favorite(self, session: Session, user_id: int, devotional_id: int) -> bool:
        if session.get(DevotionalModel, devotional_id) is None:
            raise LookupError("devotional not found")

        favorite = (
            session.query(UserFavoriteModel)
            .filter(UserFavoriteModel.user_id == user_id, UserFavoriteModel.devotional_id == devotional_id)
            .first()
        )
        if favorite:
            session.delete(favorite)
            session.commit()
            return False
        else:
            new_fav = UserFavoriteModel(user_id=user_id, devotional_id=devotional_id)
            session.add(new_fav)
            session.commit()
            return True

    def get_favorites(self, session: Session, user_id: int) -> list[Devotional]:
        favorites = (
            session.query(UserFavoriteModel)
            .filter(UserFavoriteModel.user_id == user_id)
            .order_by(UserFavoriteModel.created_at.desc())
            .all()
        )
        return [Devotional.model_validate(f.devotional) for f in favorites if f.devotional]

    def _build_guidance(
        self,
        *,
        completed: bool,
        streak: UserStreakModel | None,
    ) -> DevotionalGuidance:
        current_streak = streak.current_streak if streak is not None else 0
        next_milestone = self._next_milestone(current_streak)

        if completed:
            return DevotionalGuidance(
                title="Ritmo protegido",
                body=(
                    "Voce ja concluiu o devocional de hoje. Esse tipo de constancia tranquila "
                    "e o que faz o habito durar."
                ),
                accent_label="Hoje contado",
                tone="success",
                current_streak=current_streak,
                next_milestone=next_milestone,
            )

        if current_streak == 0:
            return DevotionalGuidance(
                title="Primeiro passo",
                body=(
                    "O mais importante agora nao e velocidade. E voltar hoje e criar um ponto "
                    "de partida real."
                ),
                accent_label="Comece com poucos minutos",
                tone="starter",
                current_streak=current_streak,
                next_milestone=next_milestone,
            )

        if next_milestone is not None and next_milestone - current_streak == 1:
            return DevotionalGuidance(
                title="Marco proximo",
                body=(
                    f"Falta so hoje para voce chegar a {next_milestone} dias seguidos. "
                    "Vale a pena proteger esse ritmo."
                ),
                accent_label="Meta curta e clara",
                tone="milestone",
                current_streak=current_streak,
                next_milestone=next_milestone,
            )

        if current_streak >= 7:
            return DevotionalGuidance(
                title="Ritmo forte",
                body=(
                    "Seu habito ja ganhou corpo. O foco de hoje e manter a consistencia "
                    "sem complicar a rotina."
                ),
                accent_label=f"Streak atual de {current_streak} dias",
                tone="strong",
                current_streak=current_streak,
                next_milestone=next_milestone,
            )

        return DevotionalGuidance(
            title="Habito em construcao",
            body=(
                f"Voce ja tem {current_streak} dias seguidos. Continue simples hoje para "
                "transformar repeticao em estabilidade."
            ),
            accent_label=(
                f"Proximo marco: {next_milestone} dias"
                if next_milestone is not None
                else "Continue no ritmo"
            ),
            tone="building",
            current_streak=current_streak,
            next_milestone=next_milestone,
        )

    def _next_milestone(self, current_streak: int) -> int | None:
        for milestone in self.milestone_days:
            if milestone > current_streak:
                return milestone
        return None

    def _build_completion_feedback(
        self,
        streak,
    ) -> DevotionalCompletionFeedback:
        current_streak = streak.current_streak if streak is not None else 0
        longest_streak = streak.longest_streak if streak is not None else 0
        next_milestone = self._next_milestone(current_streak)
        milestone_hit = current_streak if current_streak in self.milestone_days else None

        if milestone_hit is not None:
            return DevotionalCompletionFeedback(
                title="Marco alcançado",
                body=(
                    f"Voce chegou a {milestone_hit} dias seguidos. Continue firme nesse ritmo "
                    "simples e constante."
                ),
                tone="milestone",
                current_streak=current_streak,
                longest_streak=longest_streak,
                milestone_hit=milestone_hit,
                next_milestone=next_milestone,
            )

        if current_streak >= 7:
            return DevotionalCompletionFeedback(
                title="Ritmo fortalecido",
                body=(
                    f"Hoje contou para seu streak de {current_streak} dias. O importante agora "
                    "e proteger esse ritmo sem complicar a rotina."
                ),
                tone="strong",
                current_streak=current_streak,
                longest_streak=longest_streak,
                milestone_hit=None,
                next_milestone=next_milestone,
            )

        if current_streak <= 1:
            return DevotionalCompletionFeedback(
                title="Primeiro passo concluido",
                body=(
                    "Seu primeiro dia foi registrado. O foco agora e voltar amanha e transformar "
                    "esse passo em repeticao."
                ),
                tone="starter",
                current_streak=current_streak,
                longest_streak=longest_streak,
                milestone_hit=None,
                next_milestone=next_milestone,
            )

        return DevotionalCompletionFeedback(
            title="Dia concluido",
            body=(
                f"Hoje contou para seu streak de {current_streak} dias. Continue simples e siga "
                "na direcao do proximo marco."
            ),
            tone="progress",
            current_streak=current_streak,
            longest_streak=longest_streak,
            milestone_hit=None,
            next_milestone=next_milestone,
        )


devotional_service = DevotionalService()

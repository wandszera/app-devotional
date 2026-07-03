from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.db.init_db import init_db
from app.routes.auth import router as auth_router
from app.routes.devotional import router as devotional_router
from app.routes.notifications import router as notifications_router
from app.routes.progress import router as progress_router
from app.routes.streak import router as streak_router


app = FastAPI(
    title="App Devocional API",
    version="0.1.0",
    description="Initial MVP backend for the devotional app.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(devotional_router)
app.include_router(notifications_router)
app.include_router(streak_router)
app.include_router(progress_router)

from app.core.firebase import init_firebase
from app.db.init_db import init_db

init_db()
init_firebase()

@app.get("/health")
def healthcheck() -> dict[str, str]:
    return {"status": "ok"}

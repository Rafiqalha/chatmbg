import structlog
import sentry_sdk
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager

from app.config import settings
from app.api.router import api_router
from app.core.exceptions import MBGBrainException

log = structlog.get_logger()

if settings.SENTRY_DSN and settings.SENTRY_DSN.startswith("https://") and "..." not in settings.SENTRY_DSN:
    sentry_sdk.init(
        dsn=settings.SENTRY_DSN,
        environment=settings.ENVIRONMENT,
        traces_sample_rate=0.1,
    )

@asynccontextmanager
async def lifespan(app: FastAPI):
    log.info("MBGBrain API starting", version=settings.APP_VERSION)
    yield
    log.info("MBGBrain API shutting down")

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="AI Intelligence Infrastructure untuk program Makan Bergizi Gratis Indonesia",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
    lifespan=lifespan,
)

# ─── Middleware ────────────────────────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        "https://mbgbrain.id",
        "https://chatmbg.id",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["X-Regulation-Version", "X-Cache-Hit", "X-Request-Id"],
)
app.add_middleware(GZipMiddleware, minimum_size=1000)

# ─── Exception Handlers ────────────────────────────────────────────────────────
@app.exception_handler(MBGBrainException)
async def mbgbrain_exception_handler(req: Request, exc: MBGBrainException):
    return JSONResponse(
        status_code=exc.status_code,
        content={"error": exc.message, "code": exc.code},
    )

# ─── Routes ───────────────────────────────────────────────────────────────────
app.include_router(api_router, prefix="/api/v1")

@app.get("/health")
async def health():
    return {"status": "ok", "version": settings.APP_VERSION}

from functools import lru_cache
from pathlib import Path

from pydantic import AliasChoices, Field
from pydantic_settings import BaseSettings, SettingsConfigDict

ROOT_DIR = Path(__file__).resolve().parents[3]
ENV_FILE = ROOT_DIR / ".env"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=str(ENV_FILE),
        env_file_encoding="utf-8",
        extra="ignore",
    )

    # App
    APP_NAME: str = "MBGBrain API"
    APP_VERSION: str = "0.1.0"
    DEBUG: bool = False
    ENVIRONMENT: str = "development"

    # Supabase
    SUPABASE_URL: str = Field(
        default="",
        validation_alias=AliasChoices("SUPABASE_URL", "NEXT_PUBLIC_SUPABASE_URL"),
    )
    SUPABASE_SERVICE_ROLE_KEY: str = ""
    SUPABASE_DB_URL: str = ""

    # LLM (Groq) — .env.example memakai GROQ_API_KEY / ANTHROPIC_API_KEY (nilai Groq)
    GROQ_API_KEY: str = Field(
        default="",
        validation_alias=AliasChoices("GROQ_API_KEY", "ANTHROPIC_API_KEY"),
    )
    GROQ_MODEL: str = "llama-3.3-70b-versatile"
    GROQ_TEMP: float = 0.2
    GROQ_MAX_TOKENS: int = 2048

    # Local embedding (fastembed) — selaras dengan vector(384) di migration
    EMBED_MODEL: str = "BAAI/bge-small-en-v1.5"
    EMBED_DIM: int = 384

    # RAG config
    RAG_TOP_K: int = 5
    RAG_THRESHOLD: float = 0.5
    RAG_CHUNK_SIZE: int = 512
    RAG_CHUNK_OVERLAP: int = 64

    # Rate limits
    DEFAULT_RATE_LIMIT_PER_MIN: int = 100
    FREE_TIER_MONTHLY_QUERIES: int = 50

    # Sentry
    SENTRY_DSN: str = ""


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()

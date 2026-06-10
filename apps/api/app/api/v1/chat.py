from fastapi import APIRouter, Depends, Request
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field
import structlog

from app.services.rag.pipeline import run_rag_pipeline
from app.core.auth import get_current_user
from app.core.rate_limiter import check_rate_limit
from app.dependencies import get_supabase

log = structlog.get_logger()
router = APIRouter(tags=["Chat"])

class ChatRequest(BaseModel):
    message:     str = Field(..., min_length=1, max_length=2000)
    session_id:  str | None = None
    language:    str = "id"

@router.post("/chat")
async def chat(
    req:      ChatRequest,
    request:  Request,
    user:     dict = Depends(get_current_user),
    supabase       = Depends(get_supabase),
):
    await check_rate_limit(user["id"])
    log.info("Chat request", user_id=user["id"][:8], query_len=len(req.message))

    # Log ke database (async, non-blocking)
    # Commenting out insert query log for dev if table doesn't exist
    try:
        supabase.table("query_logs").insert({
            "user_id":   user["id"] if user["id"] != "00000000-0000-0000-0000-000000000000" else None,
            "module":    "chat",
            "query_text": req.message,
        }).execute()
    except Exception:
        pass

    return StreamingResponse(
        run_rag_pipeline(req.message, module="chat"),
        media_type="text/event-stream",
        headers={
            "Cache-Control":          "no-cache",
            "X-Accel-Buffering":      "no",
            "X-Regulation-Version":   "2025-05",
        },
    )

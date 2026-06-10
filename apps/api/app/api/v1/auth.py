from fastapi import APIRouter, Request, HTTPException
import structlog
from app.dependencies import get_supabase_service

log = structlog.get_logger()
router = APIRouter(tags=["Auth Webhook"])

@router.post("/auth/webhook")
async def auth_webhook(request: Request):
    """Webhook for Supabase Auth to handle user creation/updates."""
    try:
        payload = await request.json()
        log.info("Auth webhook received", type=payload.get("type"))
        
        # Here we could sync to organizations/profiles tables
        # For MVP, we just log it.
        return {"status": "ok"}
    except Exception as e:
        log.error("Auth webhook error", error=str(e))
        raise HTTPException(status_code=400, detail="Invalid payload")

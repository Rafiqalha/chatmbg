from fastapi import APIRouter, Depends

from app.dependencies import get_supabase_service
from app.core.auth import get_current_user

router = APIRouter(tags=["Regulations"])


@router.get("/regulations/latest")
async def regulations_latest(
    limit: int = 10,
    user: dict = Depends(get_current_user),
):
    supabase = get_supabase_service()
    res = (
        supabase.table("regulation_documents")
        .select("id, title, short_code, type, issuer, effective_date, version, summary")
        .eq("is_superseded", False)
        .order("effective_date", desc=True)
        .limit(limit)
        .execute()
    )
    return {"regulations": res.data or []}

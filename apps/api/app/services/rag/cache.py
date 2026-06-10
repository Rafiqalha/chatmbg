import hashlib
import structlog
from app.dependencies import get_supabase_service

log = structlog.get_logger()


async def get_cached(cache_key: str) -> dict | None:
    try:
        supabase = get_supabase_service()
        res = (
            supabase.table("query_cache")
            .select("response_text, citations, expires_at")
            .eq("query_hash", cache_key)
            .limit(1)
            .execute()
        )
        if res.data:
            row = res.data[0]
            return {
                "response": row["response_text"],
                "citations": row.get("citations") or [],
            }
    except Exception as e:
        log.debug("Cache miss", error=str(e))
    return None


async def set_cached(cache_key: str, data: dict, module: str = "chat", query_text: str = ""):
    try:
        supabase = get_supabase_service()
        supabase.table("query_cache").upsert(
            {
                "query_hash": cache_key,
                "query_text": query_text[:500],
                "response_text": data.get("response", ""),
                "citations": data.get("citations", []),
                "module": module,
            },
            on_conflict="query_hash",
        ).execute()
    except Exception as e:
        log.debug("Cache write skipped", error=str(e))

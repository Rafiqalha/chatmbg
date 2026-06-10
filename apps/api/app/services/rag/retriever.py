from app.dependencies import get_supabase_service
from app.config import settings
import structlog

log = structlog.get_logger()


def _normalize_chunks(rows: list[dict]) -> list[dict]:
    normalized = []
    for row in rows:
        reg = row.get("regulation_documents") or {}
        normalized.append({
            "id": row.get("id"),
            "doc_id": row.get("doc_id"),
            "chunk_text": row.get("chunk_text"),
            "metadata": row.get("metadata") or {},
            "regulation_code": reg.get("short_code") or row.get("regulation_code", ""),
            "similarity": row.get("similarity", 0.75),
        })
    return normalized


async def _fts_fallback(supabase, query: str, top_k: int) -> list[dict]:
    """Fallback bila embedding belum diisi — cari lewat full-text."""
    try:
        response = (
            supabase.table("knowledge_chunks")
            .select("id, doc_id, chunk_text, metadata, regulation_documents(short_code)")
            .text_search("fts_vector", query, options={"type": "websearch", "config": "indonesian"})
            .limit(top_k)
            .execute()
        )
        return _normalize_chunks(response.data or [])
    except Exception as e:
        log.warning("FTS fallback failed", error=str(e))
        return []


async def retrieve_chunks(query_embedding: list[float], top_k: int = 5, query_text: str = ""):
    supabase = get_supabase_service()

    try:
        response = supabase.rpc(
            "match_knowledge_chunks",
            {
                "query_embedding": query_embedding,
                "match_threshold": settings.RAG_THRESHOLD,
                "match_count": top_k * 2,
            },
        ).execute()

        chunks = response.data or []
        if chunks:
            return chunks[:top_k]
    except Exception as e:
        log.error("Vector retrieval error", error=str(e))

    if query_text:
        fts_chunks = await _fts_fallback(supabase, query_text, top_k)
        if fts_chunks:
            log.info("Using FTS fallback", count=len(fts_chunks))
            return fts_chunks

    return []

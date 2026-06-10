"""Generate embedding untuk chunk seed SK 244 (jalankan sekali setelah migration)."""
import asyncio
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "apps" / "api"))

from dotenv import load_dotenv

load_dotenv(ROOT / ".env")

from app.dependencies import get_supabase_service
from app.services.rag.embedder import embed_query


async def main():
    supabase = get_supabase_service()
    chunks = (
        supabase.table("knowledge_chunks")
        .select("id, chunk_text")
        .is_("embedding", "null")
        .limit(50)
        .execute()
    )
    for row in chunks.data or []:
        emb = await embed_query(row["chunk_text"])
        supabase.table("knowledge_chunks").update({"embedding": emb}).eq("id", row["id"]).execute()
        print(f"Embedded chunk {row['id'][:8]}...")
    print("Done.")


if __name__ == "__main__":
    asyncio.run(main())

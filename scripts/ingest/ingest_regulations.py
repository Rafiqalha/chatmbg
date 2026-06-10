import argparse
import asyncio
import re
import structlog
from pathlib import Path

log = structlog.get_logger()
ROOT = Path(__file__).resolve().parents[2]


def extract_text_from_pdf(pdf_path: str) -> str:
    import pdfplumber

    text_parts = []
    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            text = page.extract_text()
            if text:
                text_parts.append(text.strip())
    return "\n\n".join(text_parts)


def extract_text_from_file(file_path: str) -> str:
    path = Path(file_path)
    if path.suffix.lower() == ".pdf":
        return extract_text_from_pdf(file_path)
    return path.read_text(encoding="utf-8")


def clean_text(text: str) -> str:
    text = re.sub(r"\n{3,}", "\n\n", text)
    text = re.sub(r"[ \t]+", " ", text)
    return text.strip()


def chunk_text(text: str, chunk_size: int = 512, overlap: int = 64) -> list[dict]:
    chunks = []
    pasal_pattern = re.compile(r"(?=Pasal\s+\d+)", re.IGNORECASE)
    sections = pasal_pattern.split(text)

    if len(sections) > 3:
        for i, section in enumerate(sections):
            if not section.strip():
                continue
            words = section.split()
            if len(words) <= chunk_size:
                chunks.append({
                    "text": section.strip(),
                    "chunk_index": i,
                    "metadata": {"has_pasal": True, "pasal_number": i},
                })
            else:
                for j in range(0, len(words), chunk_size - overlap):
                    chunk_words = words[j : j + chunk_size]
                    chunks.append({
                        "text": " ".join(chunk_words),
                        "chunk_index": len(chunks),
                        "metadata": {"has_pasal": True, "pasal_number": i, "sub_chunk": j},
                    })
    else:
        words = text.split()
        for i in range(0, len(words), chunk_size - overlap):
            chunk_words = words[i : i + chunk_size]
            chunks.append({
                "text": " ".join(chunk_words),
                "chunk_index": i // (chunk_size - overlap),
                "metadata": {},
            })

    return chunks


async def embed_chunks(chunks: list[dict]) -> list[dict]:
    from fastembed import TextEmbedding

    embedding_model = TextEmbedding(model_name="BAAI/bge-small-en-v1.5")
    texts = [c["text"] for c in chunks]
    embeddings = list(embedding_model.embed(texts))

    for i, emb in enumerate(embeddings):
        chunks[i]["embedding"] = emb.tolist()

    return chunks


async def store_to_supabase(doc_id: str, chunks: list[dict], client):
    records = [
        {
            "doc_id": doc_id,
            "chunk_index": c["chunk_index"],
            "chunk_text": c["text"],
            "embedding": c["embedding"],
            "metadata": c.get("metadata", {}),
            "token_count": len(c["text"].split()),
        }
        for c in chunks
    ]

    for i in range(0, len(records), 50):
        client.table("knowledge_chunks").insert(records[i : i + 50]).execute()
        log.info("Stored chunks", batch=i // 50 + 1)


async def ingest_document(file_path: str, doc_info: dict):
    from dotenv import load_dotenv
    from supabase import create_client

    load_dotenv(ROOT / ".env")

    supabase = create_client(
        __import__("os").getenv("SUPABASE_URL")
        or __import__("os").getenv("NEXT_PUBLIC_SUPABASE_URL", ""),
        __import__("os").getenv("SUPABASE_SERVICE_ROLE_KEY", ""),
    )

    log.info("Starting ingestion", file=file_path)

    raw_text = extract_text_from_file(file_path)
    clean = clean_text(raw_text)
    log.info("Text extracted", chars=len(clean))

    doc_result = (
        supabase.table("regulation_documents")
        .upsert(
            {
                "short_code": doc_info["short_code"],
                "title": doc_info["title"],
                "type": doc_info["type"],
                "issuer": doc_info["issuer"],
                "effective_date": doc_info["effective_date"],
                "full_text": clean,
            },
            on_conflict="short_code",
        )
        .execute()
    )

    doc_id = doc_result.data[0]["id"]
    supabase.table("knowledge_chunks").delete().eq("doc_id", doc_id).execute()

    chunks = chunk_text(clean)
    chunks = await embed_chunks(chunks)
    await store_to_supabase(doc_id, chunks, supabase)
    log.info("Ingestion complete", doc_id=doc_id, chunks=len(chunks))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Ingest regulation document into ChatMBG knowledge base")
    parser.add_argument("--file", required=True, help="Path to PDF or TXT file")
    parser.add_argument("--code", required=True, help="Short code, e.g. SK_244_2025")
    parser.add_argument("--title", required=True, help="Document title")
    parser.add_argument("--type", default="sk", help="Document type")
    parser.add_argument("--issuer", default="BGN", help="Issuer")
    parser.add_argument("--date", required=True, help="Effective date YYYY-MM-DD")
    args = parser.parse_args()

    asyncio.run(
        ingest_document(
            args.file,
            {
                "short_code": args.code,
                "title": args.title,
                "type": args.type,
                "issuer": args.issuer,
                "effective_date": args.date,
            },
        )
    )

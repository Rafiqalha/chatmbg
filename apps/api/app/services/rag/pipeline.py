import hashlib
import json
import asyncio
import structlog
from typing import AsyncGenerator
from groq import AsyncGroq
from app.config import settings
from app.services.rag.embedder import embed_query
from app.services.rag.retriever import retrieve_chunks
from app.services.rag.cache import get_cached, set_cached

log = structlog.get_logger()

SYSTEM_PROMPT = """Kamu adalah MBGBrain, asisten AI khusus untuk program Makan Bergizi Gratis (MBG) Indonesia.

PERAN:
- Menjawab pertanyaan tentang regulasi, prosedur, dan panduan operasional MBG
- Membantu SPPG, UMKM, dan pemangku kepentingan program MBG
- Memberikan informasi akurat berdasarkan dokumen regulasi resmi

ATURAN:
1. Jawab HANYA berdasarkan konteks regulasi yang diberikan
2. Selalu sertakan referensi spesifik (nama regulasi, nomor pasal)
3. Gunakan bahasa Indonesia yang jelas dan mudah dipahami
4. Jika tidak tahu, katakan "Informasi ini belum tersedia di database saya" - JANGAN mengarang
5. Posisikan dirimu sebagai "asisten", bukan pengganti konsultan hukum resmi
6. Berikan disclaimer jika pertanyaan menyentuh interpretasi hukum yang kompleks

FORMAT JAWABAN:
- Mulai dengan jawaban langsung dan ringkas
- Gunakan bullet points untuk daftar persyaratan
- Akhiri dengan referensi regulasi dalam format: [Sumber: Nama Regulasi, Pasal X]
- Maksimal 400 kata kecuali pertanyaan membutuhkan detail lebih
"""

async def run_rag_pipeline(
    query: str,
    module: str = "chat",
    stream: bool = True,
) -> AsyncGenerator[str, None]:
    cache_key = hashlib.sha256(f"{module}:{query.lower().strip()}".encode()).hexdigest()
    cached = await get_cached(cache_key)

    if cached:
        log.info("Cache hit", key=cache_key[:8])
        response_text = cached['response']
        
        # Simulate streaming for cached response
        chunk_size = 12
        for i in range(0, len(response_text), chunk_size):
            chunk = response_text[i:i+chunk_size]
            payload = {'delta': chunk}
            if i == 0:
                payload['citations'] = cached.get('citations', [])
                payload['cached'] = True
            yield f"data: {json.dumps(payload)}\n\n"
            await asyncio.sleep(0.02)
            
        yield "data: [DONE]\n\n"
        return

    # Embed & Retrieve
    query_embedding = await embed_query(query)
    chunks = await retrieve_chunks(
        query_embedding,
        top_k=settings.RAG_TOP_K,
        query_text=query,
    )

    if not chunks:
        yield f"data: {json.dumps({'delta': 'Maaf, tidak ditemukan informasi yang relevan dalam database regulasi MBG. Coba reformulasikan pertanyaan Anda.'})}\n\n"
        yield "data: [DONE]\n\n"
        return

    context_parts = []
    citations = []

    for i, chunk in enumerate(chunks):
        context_parts.append(f"[Dokumen {i+1}] {chunk['regulation_code']}\n{chunk['chunk_text']}")
        citations.append({
            "regulation": chunk['regulation_code'],
            "article": chunk.get('metadata', {}).get('article', ''),
            "excerpt": chunk['chunk_text'][:200] + "...",
        })

    context = "\n\n---\n\n".join(context_parts)
    prompt = f"KONTEKS REGULASI:\n{context}\n\nPERTANYAAN: {query}"

    client = AsyncGroq(api_key=settings.GROQ_API_KEY)
    full_response = ""

    yield f"data: {json.dumps({'citations': citations})}\n\n"

    try:
        stream = await client.chat.completions.create(
            model=settings.GROQ_MODEL,
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": prompt}
            ],
            temperature=settings.GROQ_TEMP,
            max_tokens=settings.GROQ_MAX_TOKENS,
            stream=True,
        )

        async for chunk in stream:
            if chunk.choices[0].delta.content is not None:
                text = chunk.choices[0].delta.content
                full_response += text
                yield f"data: {json.dumps({'delta': text})}\n\n"
    except Exception as e:
        log.error("Groq generation error", error=str(e))
        yield f"data: {json.dumps({'delta': 'Maaf, terjadi kesalahan saat menghubungi AI provider.'})}\n\n"

    yield "data: [DONE]\n\n"

    await set_cached(
        cache_key,
        {"response": full_response, "citations": citations},
        module=module,
        query_text=query,
    )

    log.info("RAG pipeline complete", query_len=len(query), chunks=len(chunks), response_len=len(full_response))

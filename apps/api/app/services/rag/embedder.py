from fastembed import TextEmbedding
from app.config import settings

# Initialize globally to keep model loaded
# This will download the model weights on first run
embedding_model = TextEmbedding(model_name=settings.EMBED_MODEL)

async def embed_query(query: str) -> list[float]:
    # Fastembed returns a generator of numpy arrays
    embeddings = list(embedding_model.embed([query]))
    return embeddings[0].tolist()

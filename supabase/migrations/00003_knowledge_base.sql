-- ─── Regulation Documents ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS regulation_documents (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title            TEXT NOT NULL,
  short_code       TEXT NOT NULL UNIQUE,  -- e.g. 'SK_244_2025', 'PERPRES_83_2024'
  type             TEXT NOT NULL,         -- 'sk' | 'perpres' | 'permen' | 'pedoman'
  issuer           TEXT NOT NULL,         -- 'BGN' | 'Kemenkes' | 'BPOM' | 'Kemensetneg'
  effective_date   DATE NOT NULL,
  version          TEXT NOT NULL DEFAULT '1.0',
  is_superseded    BOOLEAN NOT NULL DEFAULT false,
  superseded_by_id UUID REFERENCES regulation_documents(id),
  source_url       TEXT,
  storage_path     TEXT,   -- path di Supabase Storage
  full_text        TEXT,
  summary          TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── Knowledge Chunks (RAG) ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS knowledge_chunks (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  doc_id        UUID NOT NULL REFERENCES regulation_documents(id) ON DELETE CASCADE,
  chunk_index   INTEGER NOT NULL,
  chunk_text    TEXT NOT NULL,
  -- Embedding vector 384 dimensi (fastembed BAAI/bge-small-en-v1.5)
  embedding     vector(384),
  -- Metadata untuk filtering dan re-ranking
  metadata      JSONB DEFAULT '{}',
  -- Untuk hybrid search: full-text search vector
  fts_vector    tsvector GENERATED ALWAYS AS (
    to_tsvector('indonesian', chunk_text)
  ) STORED,
  token_count   INTEGER,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- IVFFlat dibuat setelah ada baris embedding (lihat 00006)
CREATE INDEX IF NOT EXISTS idx_knowledge_chunks_fts
  ON knowledge_chunks USING gin (fts_vector);

CREATE INDEX IF NOT EXISTS idx_knowledge_chunks_doc_id ON knowledge_chunks(doc_id);

-- ─── Query Cache (mengurangi biaya LLM) ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS query_cache (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  query_hash      TEXT NOT NULL UNIQUE,  -- SHA256 dari normalized query
  query_text      TEXT NOT NULL,
  response_text   TEXT NOT NULL,
  citations       JSONB DEFAULT '[]',
  module          TEXT NOT NULL,
  hit_count       INTEGER NOT NULL DEFAULT 1,
  last_hit_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at      TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '7 days')
);

CREATE INDEX IF NOT EXISTS idx_query_cache_hash    ON query_cache(query_hash);
CREATE INDEX IF NOT EXISTS idx_query_cache_expires ON query_cache(expires_at);

-- Auto-cleanup expired cache
CREATE OR REPLACE FUNCTION cleanup_expired_cache()
RETURNS void AS $$
BEGIN
  DELETE FROM query_cache WHERE expires_at < NOW();
END;
$$ LANGUAGE plpgsql;

-- ─── Food Database (TKPI) ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS food_items (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kode_pangan       TEXT UNIQUE,         -- kode TKPI
  nama_pangan       TEXT NOT NULL,
  nama_alias        TEXT[],              -- sinonim (ayam goreng, ayam bakar, dll)
  kategori          TEXT NOT NULL,       -- 'serealia' | 'daging' | 'sayuran' | 'buah' | dll
  -- Nilai gizi per 100g
  energi_kkal       DECIMAL(8,2),
  protein_g         DECIMAL(8,2),
  lemak_g           DECIMAL(8,2),
  karbohidrat_g     DECIMAL(8,2),
  serat_g           DECIMAL(8,2),
  kalsium_mg        DECIMAL(8,2),
  zat_besi_mg       DECIMAL(8,2),
  vitamin_c_mg      DECIMAL(8,2),
  vitamin_a_mcg     DECIMAL(8,2),
  -- FTS untuk matching nama makanan
  fts_vector        tsvector GENERATED ALWAYS AS (
    to_tsvector('indonesian', nama_pangan)
  ) STORED,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_food_items_fts ON food_items USING gin(fts_vector);
CREATE INDEX IF NOT EXISTS idx_food_items_nama ON food_items USING gin(nama_pangan gin_trgm_ops);

-- ─── Nutrition Standards per Group ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS nutrition_standards (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipient_group  TEXT NOT NULL,  -- 'sd' | 'smp' | 'balita' | 'bumil'
  energi_min_kkal  DECIMAL(8,2),
  energi_max_kkal  DECIMAL(8,2),
  protein_min_g    DECIMAL(8,2),
  lemak_min_g      DECIMAL(8,2),
  karbohidrat_min_g DECIMAL(8,2),
  regulation_ref   TEXT,  -- referensi regulasi
  effective_date   DATE NOT NULL,
  is_current       BOOLEAN NOT NULL DEFAULT true
);

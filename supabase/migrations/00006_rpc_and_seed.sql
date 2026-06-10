-- ─── Vector similarity RPC (fastembed 384-dim) ───────────────────────────────
CREATE OR REPLACE FUNCTION match_knowledge_chunks(
  query_embedding vector(384),
  match_threshold FLOAT DEFAULT 0.5,
  match_count     INT   DEFAULT 5,
  filter          JSONB DEFAULT '{}'
)
RETURNS TABLE (
  id                    UUID,
  doc_id                UUID,
  chunk_text            TEXT,
  similarity            FLOAT,
  metadata              JSONB,
  regulation_code       TEXT,
  effective_date        DATE,
  is_current_regulation BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    kc.id,
    kc.doc_id,
    kc.chunk_text,
    (1 - (kc.embedding <=> query_embedding))::FLOAT AS similarity,
    kc.metadata,
    rd.short_code,
    rd.effective_date,
    NOT rd.is_superseded AS is_current_regulation
  FROM knowledge_chunks kc
  JOIN regulation_documents rd ON rd.id = kc.doc_id
  WHERE
    kc.embedding IS NOT NULL
    AND (1 - (kc.embedding <=> query_embedding)) > match_threshold
    AND (filter->>'doc_type' IS NULL OR rd.type = filter->>'doc_type')
    AND rd.is_superseded = false
  ORDER BY kc.embedding <=> query_embedding
  LIMIT match_count * 2;
END;
$$ LANGUAGE plpgsql;

-- ─── Seed: regulasi awal ─────────────────────────────────────────────────────
INSERT INTO regulation_documents (
  title, short_code, type, issuer, effective_date, version, summary
) VALUES (
  'Surat Keputusan Kepala BGN Nomor 244 Tahun 2025',
  'SK_244_2025',
  'sk',
  'BGN',
  '2025-01-01',
  '1.0',
  'Mekanisme matching SPPG dan UMKM/supplier lokal (hyperlocal sourcing).'
) ON CONFLICT (short_code) DO NOTHING;

-- ─── Seed: chunk contoh untuk RAG dev ────────────────────────────────────────
INSERT INTO knowledge_chunks (doc_id, chunk_index, chunk_text, metadata, token_count)
SELECT
  rd.id,
  0,
  'SPPG wajib memprioritaskan pengadaan bahan pangan dari UMKM lokal di wilayah kecamatan/kabupaten yang sama (hyperlocal sourcing) sesuai SK Kepala BGN No. 244 Tahun 2025.',
  '{"article": "Pasal 3"}'::jsonb,
  32
FROM regulation_documents rd
WHERE rd.short_code = 'SK_244_2025'
  AND NOT EXISTS (
    SELECT 1 FROM knowledge_chunks kc
    WHERE kc.doc_id = rd.id AND kc.chunk_index = 0
  );

-- ─── Seed: standar gizi SD ─────────────────────────────────────────────────────
INSERT INTO nutrition_standards (
  recipient_group, energi_min_kkal, energi_max_kkal,
  protein_min_g, lemak_min_g, karbohidrat_min_g,
  regulation_ref, effective_date, is_current
)
SELECT
  'sd', 450, 550, 15, 10, 60,
  'Standar Gizi Kemenkes', '2025-01-01'::date, true
WHERE NOT EXISTS (
  SELECT 1 FROM nutrition_standards
  WHERE recipient_group = 'sd' AND is_current = true
);

-- ─── Seed: subset TKPI ───────────────────────────────────────────────────────
INSERT INTO food_items (
  kode_pangan, nama_pangan, nama_alias, kategori,
  energi_kkal, protein_g, lemak_g, karbohidrat_g
) VALUES
  ('A001', 'Nasi putih', ARRAY['nasi', 'beras'], 'serealia', 175, 3.5, 0.5, 38.0),
  ('B001', 'Ayam daging', ARRAY['ayam', 'daging ayam'], 'daging', 146, 20.0, 7.0, 0.0),
  ('S001', 'Bayam', ARRAY['sayur bayam'], 'sayuran', 28, 3.0, 0.4, 4.0)
ON CONFLICT (kode_pangan) DO NOTHING;

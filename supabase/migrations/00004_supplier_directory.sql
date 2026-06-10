-- ─── Suppliers ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS suppliers (
  id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id                    UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  -- Produk & Kapasitas
  product_categories        TEXT[] NOT NULL DEFAULT '{}',
  product_details           JSONB DEFAULT '[]',   -- [{name, unit, price_per_unit}]
  daily_capacity_servings   INTEGER,
  min_order_servings        INTEGER,
  -- Lokasi (PostGIS)
  location                  geography(POINT, 4326),
  service_radius_km         INTEGER DEFAULT 20,
  -- Status
  is_verified               BOOLEAN NOT NULL DEFAULT false,
  verified_by               UUID REFERENCES profiles(id),
  verified_at               TIMESTAMPTZ,
  is_active                 BOOLEAN NOT NULL DEFAULT true,
  -- Profile completeness (0–100)
  profile_completeness_pct  SMALLINT NOT NULL DEFAULT 0,
  -- SK 244 compliance
  sk244_compliant           BOOLEAN,
  sk244_checked_at          TIMESTAMPTZ,
  -- Metrics
  total_orders_fulfilled    INTEGER DEFAULT 0,
  avg_rating                DECIMAL(3,2),
  created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── Supplier Documents ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS supplier_documents (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  supplier_id   UUID NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,
  doc_type      TEXT NOT NULL,    -- 'nib' | 'sertifikat_halal' | 'sertifikat_bpom' | 'foto_dapur' | dll
  doc_name      TEXT NOT NULL,
  file_url      TEXT NOT NULL,    -- Supabase Storage URL
  file_size     INTEGER,
  verified_at   TIMESTAMPTZ,
  expires_at    TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── SPPG-Supplier Matches ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sppg_supplier_matches (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sppg_org_id   UUID NOT NULL REFERENCES organizations(id),
  supplier_id   UUID NOT NULL REFERENCES suppliers(id),
  status        TEXT NOT NULL DEFAULT 'candidate',  -- 'candidate' | 'active' | 'inactive'
  match_score   DECIMAL(4,2),   -- similarity score dari matching algorithm
  notes         TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(sppg_org_id, supplier_id)
);

-- ─── Geospatial Indexes ───────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_suppliers_location ON suppliers USING gist(location);
CREATE INDEX IF NOT EXISTS idx_suppliers_categories ON suppliers USING gin(product_categories);
CREATE INDEX IF NOT EXISTS idx_suppliers_org_id ON suppliers(org_id);

-- ─── Function: Find Nearby Suppliers ─────────────────────────────────────────
CREATE OR REPLACE FUNCTION find_nearby_suppliers(
  sppg_lat    DOUBLE PRECISION,
  sppg_lon    DOUBLE PRECISION,
  radius_km   INTEGER DEFAULT 20,
  category    TEXT DEFAULT NULL,
  min_cap     INTEGER DEFAULT NULL
)
RETURNS TABLE (
  supplier_id UUID,
  org_name    TEXT,
  distance_km DECIMAL,
  categories  TEXT[],
  capacity    INTEGER,
  is_verified BOOLEAN,
  score       DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    s.id,
    o.name,
    ROUND((ST_Distance(s.location, ST_MakePoint(sppg_lon, sppg_lat)::geography) / 1000)::DECIMAL, 2),
    s.product_categories,
    s.daily_capacity_servings,
    s.is_verified,
    s.profile_completeness_pct::DECIMAL / 100
  FROM suppliers s
  JOIN organizations o ON o.id = s.org_id
  WHERE
    s.is_active = true
    AND ST_DWithin(s.location, ST_MakePoint(sppg_lon, sppg_lat)::geography, radius_km * 1000)
    AND (category IS NULL OR category = ANY(s.product_categories))
    AND (min_cap IS NULL OR s.daily_capacity_servings >= min_cap)
  ORDER BY ST_Distance(s.location, ST_MakePoint(sppg_lon, sppg_lat)::geography);
END;
$$ LANGUAGE plpgsql;

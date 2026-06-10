-- ─── Extensions ──────────────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "unaccent";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ─── Enums ───────────────────────────────────────────────────────────────────
DO $$ BEGIN
  CREATE TYPE user_role AS ENUM ('sppg_admin', 'umkm', 'dinas', 'public', 'api_user', 'superadmin');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE org_type AS ENUM ('sppg', 'umkm', 'dinas', 'other');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE compliance_status AS ENUM ('memenuhi', 'kurang', 'tidak_memenuhi');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ─── Organizations ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS organizations (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT NOT NULL,
  type          org_type NOT NULL,
  province      TEXT,
  city          TEXT,
  district      TEXT,
  village       TEXT,
  address       TEXT,
  phone         TEXT,
  npwp          TEXT UNIQUE,
  verified_at   TIMESTAMPTZ,
  verified_by   UUID,
  is_active     BOOLEAN NOT NULL DEFAULT true,
  metadata      JSONB DEFAULT '{}',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── Users ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name     TEXT,
  avatar_url    TEXT,
  role          user_role NOT NULL DEFAULT 'public',
  org_id        UUID REFERENCES organizations(id),
  onboarded_at  TIMESTAMPTZ,
  preferences   JSONB DEFAULT '{}',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── API Keys ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS api_keys (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id              UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name                 TEXT NOT NULL,
  key_hash             TEXT NOT NULL UNIQUE,
  key_prefix           TEXT NOT NULL,
  rate_limit_per_min   INTEGER NOT NULL DEFAULT 100,
  monthly_limit        INTEGER,
  total_calls          BIGINT NOT NULL DEFAULT 0,
  last_used_at         TIMESTAMPTZ,
  is_active            BOOLEAN NOT NULL DEFAULT true,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at           TIMESTAMPTZ
);

-- ─── Query Logs ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS query_logs (
  id                UUID NOT NULL DEFAULT gen_random_uuid(),
  user_id           UUID REFERENCES profiles(id),
  api_key_id        UUID REFERENCES api_keys(id),
  module            TEXT NOT NULL,
  query_text        TEXT,
  response_time_ms  INTEGER,
  tokens_used       INTEGER,
  cache_hit         BOOLEAN DEFAULT false,
  rating            SMALLINT CHECK (rating IN (1, -1)),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

CREATE TABLE IF NOT EXISTS query_logs_2026_05 PARTITION OF query_logs
  FOR VALUES FROM ('2026-05-01') TO ('2026-06-01');
CREATE TABLE IF NOT EXISTS query_logs_2026_06 PARTITION OF query_logs
  FOR VALUES FROM ('2026-06-01') TO ('2026-07-01');

-- ─── Menu Validations ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS menu_validations (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             UUID REFERENCES profiles(id),
  org_id              UUID REFERENCES organizations(id),
  menu_input          TEXT NOT NULL,
  recipient_group     TEXT NOT NULL,
  analysis_result     JSONB NOT NULL,
  compliance_status   compliance_status,
  score               SMALLINT,
  regulation_version  TEXT,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── Compliance Checks ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS compliance_checks (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             UUID REFERENCES profiles(id),
  org_id              UUID REFERENCES organizations(id),
  check_type          TEXT NOT NULL,
  inputs              JSONB NOT NULL,
  result              JSONB NOT NULL,
  overall_status      compliance_status,
  report_url          TEXT,
  regulation_version  TEXT,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Selaraskan profiles lama (jika sudah ada dari setup Supabase)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS full_name     TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS avatar_url    TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS role          user_role NOT NULL DEFAULT 'public';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS org_id        UUID REFERENCES organizations(id);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS onboarded_at  TIMESTAMPTZ;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS preferences   JSONB DEFAULT '{}';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ─── Indexes ──────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_profiles_org_id     ON profiles(org_id);
CREATE INDEX IF NOT EXISTS idx_api_keys_user_id    ON api_keys(user_id);
CREATE INDEX IF NOT EXISTS idx_api_keys_key_hash   ON api_keys(key_hash);
CREATE INDEX IF NOT EXISTS idx_query_logs_user_id  ON query_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_query_logs_created  ON query_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_menu_val_org_id     ON menu_validations(org_id);
CREATE INDEX IF NOT EXISTS idx_compliance_org_id   ON compliance_checks(org_id);

-- ─── Triggers ─────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_profiles_updated ON profiles;
CREATE TRIGGER trg_profiles_updated
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS trg_organizations_updated ON organizations;
CREATE TRIGGER trg_organizations_updated
  BEFORE UPDATE ON organizations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

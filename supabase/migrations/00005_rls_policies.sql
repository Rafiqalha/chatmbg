-- Enable RLS
ALTER TABLE profiles              ENABLE ROW LEVEL SECURITY;
ALTER TABLE organizations         ENABLE ROW LEVEL SECURITY;
ALTER TABLE api_keys              ENABLE ROW LEVEL SECURITY;
ALTER TABLE query_logs            ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_validations      ENABLE ROW LEVEL SECURITY;
ALTER TABLE compliance_checks     ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers             ENABLE ROW LEVEL SECURITY;
ALTER TABLE supplier_documents    ENABLE ROW LEVEL SECURITY;
ALTER TABLE knowledge_chunks      ENABLE ROW LEVEL SECURITY;
ALTER TABLE food_items            ENABLE ROW LEVEL SECURITY;
ALTER TABLE nutrition_standards   ENABLE ROW LEVEL SECURITY;
ALTER TABLE regulation_documents  ENABLE ROW LEVEL SECURITY;

-- Helper function
CREATE OR REPLACE FUNCTION auth_user_id() RETURNS UUID AS $$
  SELECT auth.uid();
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION auth_user_role() RETURNS user_role AS $$
  SELECT role FROM profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- ─── Profiles ────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Profiles: user can read own" ON profiles;
CREATE POLICY "Profiles: user can read own" ON profiles
  FOR SELECT USING (id = auth_user_id());

DROP POLICY IF EXISTS "Profiles: user can update own" ON profiles;
CREATE POLICY "Profiles: user can update own" ON profiles
  FOR UPDATE USING (id = auth_user_id());

DROP POLICY IF EXISTS "Profiles: insert on signup" ON profiles;
CREATE POLICY "Profiles: insert on signup" ON profiles
  FOR INSERT WITH CHECK (id = auth_user_id());

-- ─── API Keys ─────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "API Keys: user manages own" ON api_keys;
CREATE POLICY "API Keys: user manages own" ON api_keys
  FOR ALL USING (user_id = auth_user_id());

-- ─── Query Logs ───────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Query Logs: user reads own" ON query_logs;
CREATE POLICY "Query Logs: user reads own" ON query_logs
  FOR SELECT USING (user_id = auth_user_id());

-- ─── Menu Validations ─────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Menu Val: user reads own" ON menu_validations;
CREATE POLICY "Menu Val: user reads own" ON menu_validations
  FOR SELECT USING (user_id = auth_user_id());

DROP POLICY IF EXISTS "Menu Val: user inserts own" ON menu_validations;
CREATE POLICY "Menu Val: user inserts own" ON menu_validations
  FOR INSERT WITH CHECK (user_id = auth_user_id());

-- ─── Compliance Checks ────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Compliance: user reads own" ON compliance_checks;
CREATE POLICY "Compliance: user reads own" ON compliance_checks
  FOR SELECT USING (user_id = auth_user_id());

-- ─── Suppliers ────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "Suppliers: public read active" ON suppliers;
CREATE POLICY "Suppliers: public read active" ON suppliers
  FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Suppliers: owner manages" ON suppliers;
CREATE POLICY "Suppliers: owner manages" ON suppliers
  FOR ALL USING (
    org_id IN (SELECT org_id FROM profiles WHERE id = auth_user_id())
  );

-- ─── Knowledge Base: public read ──────────────────────────────────────────────
DROP POLICY IF EXISTS "Knowledge: public read" ON knowledge_chunks;
CREATE POLICY "Knowledge: public read" ON knowledge_chunks FOR SELECT USING (true);

DROP POLICY IF EXISTS "Food: public read" ON food_items;
CREATE POLICY "Food: public read" ON food_items FOR SELECT USING (true);

DROP POLICY IF EXISTS "Standards: public read" ON nutrition_standards;
CREATE POLICY "Standards: public read" ON nutrition_standards FOR SELECT USING (true);

DROP POLICY IF EXISTS "Regulations: public read" ON regulation_documents;
CREATE POLICY "Regulations: public read" ON regulation_documents FOR SELECT USING (true);

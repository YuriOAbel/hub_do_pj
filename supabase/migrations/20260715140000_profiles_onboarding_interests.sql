-- Onboarding profile fields + interests catalog

CREATE TABLE IF NOT EXISTS interests (
  id TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  active BOOLEAN NOT NULL DEFAULT TRUE
);

INSERT INTO interests (id, label, sort_order, active) VALUES
  ('consultarCnpj', 'Consultar CNPJ', 1, true),
  ('emitirCnds', 'Emitir CNDs', 2, true),
  ('consultarRestricao', 'Consultar restrição', 3, true),
  ('consultarProtesto', 'Consultar protesto', 4, true),
  ('monitorarEmpresas', 'Monitorar empresas', 5, true),
  ('outras', 'Outras', 6, true)
ON CONFLICT (id) DO NOTHING;

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS device_id TEXT,
  ADD COLUMN IF NOT EXISTS name TEXT,
  ADD COLUMN IF NOT EXISTS person_type TEXT,
  ADD COLUMN IF NOT EXISTS occupation TEXT,
  ADD COLUMN IF NOT EXISTS occupation_other TEXT,
  ADD COLUMN IF NOT EXISTS interest_ids TEXT[] NOT NULL DEFAULT '{}';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'profiles_person_type_check'
  ) THEN
    ALTER TABLE profiles
      ADD CONSTRAINT profiles_person_type_check
      CHECK (person_type IS NULL OR person_type IN ('pf', 'pj'));
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_profiles_device_id ON profiles (device_id);

ALTER TABLE interests ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'interests'
      AND policyname = 'Interests are publicly readable'
  ) THEN
    CREATE POLICY "Interests are publicly readable"
      ON interests FOR SELECT
      USING (active = true);
  END IF;
END $$;

GRANT SELECT ON interests TO anon, authenticated;
GRANT ALL ON interests TO postgres, service_role;

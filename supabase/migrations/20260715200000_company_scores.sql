-- Company health score (self-declared questionnaire, 1 per profile per calendar month)

CREATE TABLE IF NOT EXISTS company_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  cnpj TEXT NOT NULL,
  answers JSONB NOT NULL,
  score INTEGER NOT NULL CHECK (score >= 0 AND score <= 100),
  band TEXT NOT NULL CHECK (band IN ('excellent', 'good', 'attention', 'critical')),
  gaps TEXT[] NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  score_month DATE GENERATED ALWAYS AS (
    (date_trunc('month', created_at AT TIME ZONE 'America/Sao_Paulo'))::date
  ) STORED
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_company_scores_profile_month
  ON company_scores (profile_id, score_month);

CREATE INDEX IF NOT EXISTS idx_company_scores_profile_created
  ON company_scores (profile_id, created_at DESC);

ALTER TABLE company_scores ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'company_scores'
      AND policyname = 'Users can view own company scores'
  ) THEN
    CREATE POLICY "Users can view own company scores"
      ON company_scores FOR SELECT
      USING (auth.uid() = profile_id);
  END IF;
END $$;

REVOKE ALL ON company_scores FROM anon;
REVOKE INSERT, UPDATE, DELETE ON company_scores FROM authenticated;
GRANT SELECT ON company_scores TO authenticated;
GRANT ALL ON company_scores TO postgres, service_role;

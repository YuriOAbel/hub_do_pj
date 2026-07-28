-- Plan limits keyed by RevenueCat / profile plan_product_id.

CREATE TABLE IF NOT EXISTS public.plan_limits (
  plan_product_id TEXT PRIMARY KEY,
  daily_cnpj_search_limit INT NULL,
  monthly_restricao_cnpj_limit INT NOT NULL DEFAULT 0,
  monthly_protesto_cnpj_limit INT NOT NULL DEFAULT 0,
  monthly_cnd_package_cnpj_limit INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS plan_limits_updated_at ON public.plan_limits;
CREATE TRIGGER plan_limits_updated_at
  BEFORE UPDATE ON public.plan_limits
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

ALTER TABLE public.plan_limits ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated users can read plan limits" ON public.plan_limits;
CREATE POLICY "Authenticated users can read plan limits"
  ON public.plan_limits
  FOR SELECT
  TO authenticated
  USING (true);

GRANT SELECT ON public.plan_limits TO authenticated;
GRANT ALL ON public.plan_limits TO service_role;

-- Seed: test SKUs + free + marketing aliases
INSERT INTO public.plan_limits (
  plan_product_id,
  daily_cnpj_search_limit,
  monthly_restricao_cnpj_limit,
  monthly_protesto_cnpj_limit,
  monthly_cnd_package_cnpj_limit
) VALUES
  ('free', 10, 0, 0, 0),
  ('hub_pj_test_mensal_app', NULL, 0, 0, 0),
  ('hub_pj_test_mensal_cp_lg', NULL, 2, 2, 2),
  ('hub_pj_test_mensal_cp_pl', NULL, 10, 10, 10),
  ('app_access', NULL, 0, 0, 0),
  ('compliance_light', NULL, 2, 2, 2),
  ('compliance_plus', NULL, 10, 10, 10)
ON CONFLICT (plan_product_id) DO UPDATE SET
  daily_cnpj_search_limit = EXCLUDED.daily_cnpj_search_limit,
  monthly_restricao_cnpj_limit = EXCLUDED.monthly_restricao_cnpj_limit,
  monthly_protesto_cnpj_limit = EXCLUDED.monthly_protesto_cnpj_limit,
  monthly_cnd_package_cnpj_limit = EXCLUDED.monthly_cnd_package_cnpj_limit,
  updated_at = NOW();

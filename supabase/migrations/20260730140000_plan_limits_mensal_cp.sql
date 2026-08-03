-- Monthly compliance experiment (Android consumable offering).
-- 2 CNPJs per product, rolling 1-month window.

INSERT INTO public.plan_limits (
  plan_product_id,
  daily_cnpj_search_limit,
  monthly_restricao_cnpj_limit,
  monthly_protesto_cnpj_limit,
  monthly_cnd_package_cnpj_limit,
  quota_period_months
) VALUES
  ('hub_pj_mensal_cp', NULL, 2, 2, 2, 1),
  ('hub_pj_mensal_cp:hub-pj-mensal-cp', NULL, 2, 2, 2, 1)
ON CONFLICT (plan_product_id) DO UPDATE SET
  daily_cnpj_search_limit = EXCLUDED.daily_cnpj_search_limit,
  monthly_restricao_cnpj_limit = EXCLUDED.monthly_restricao_cnpj_limit,
  monthly_protesto_cnpj_limit = EXCLUDED.monthly_protesto_cnpj_limit,
  monthly_cnd_package_cnpj_limit = EXCLUDED.monthly_cnd_package_cnpj_limit,
  quota_period_months = EXCLUDED.quota_period_months,
  updated_at = NOW();

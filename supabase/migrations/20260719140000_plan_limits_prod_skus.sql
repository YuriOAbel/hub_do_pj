-- Production App Store / Play product IDs (same quotas as test SKUs).

INSERT INTO public.plan_limits (
  plan_product_id,
  daily_cnpj_search_limit,
  monthly_restricao_cnpj_limit,
  monthly_protesto_cnpj_limit,
  monthly_cnd_package_cnpj_limit,
  quota_period_months
) VALUES
  ('hub_pj_mensal_app', NULL, 0, 0, 0, 1),
  ('hub_pj_mensal_cp_lg', NULL, 2, 2, 2, 3),
  ('hub_pj_mensal_cp_pl', NULL, 10, 10, 10, 1)
ON CONFLICT (plan_product_id) DO UPDATE SET
  daily_cnpj_search_limit = EXCLUDED.daily_cnpj_search_limit,
  monthly_restricao_cnpj_limit = EXCLUDED.monthly_restricao_cnpj_limit,
  monthly_protesto_cnpj_limit = EXCLUDED.monthly_protesto_cnpj_limit,
  monthly_cnd_package_cnpj_limit = EXCLUDED.monthly_cnd_package_cnpj_limit,
  quota_period_months = EXCLUDED.quota_period_months,
  updated_at = NOW();

-- Quota window in months (Light = 3, Plus = 1).

ALTER TABLE public.plan_limits
  ADD COLUMN IF NOT EXISTS quota_period_months INT NOT NULL DEFAULT 1;

UPDATE public.plan_limits
SET quota_period_months = 3,
    updated_at = NOW()
WHERE plan_product_id IN (
  'hub_pj_test_mensal_cp_lg',
  'compliance_light'
);

UPDATE public.plan_limits
SET quota_period_months = 1,
    updated_at = NOW()
WHERE plan_product_id IN (
  'free',
  'hub_pj_test_mensal_app',
  'hub_pj_test_mensal_cp_pl',
  'app_access',
  'compliance_plus'
);

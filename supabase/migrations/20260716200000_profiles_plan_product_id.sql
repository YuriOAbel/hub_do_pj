-- Link active subscription product to profiles.
-- 'free' = no active paid plan; otherwise RevenueCat StoreProduct.identifier.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS plan_product_id TEXT NOT NULL DEFAULT 'free';

CREATE INDEX IF NOT EXISTS idx_profiles_plan_product_id
  ON public.profiles(plan_product_id);

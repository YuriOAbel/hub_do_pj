-- Restructure payments: profile-linked subscription/payment row.
-- 1 payment → N orders via orders.payment_id (replaces payments.order_id).

-- Enums
DO $$ BEGIN
  CREATE TYPE payment_provider AS ENUM ('pagarme_pix', 'revenuecat');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE payment_platform AS ENUM ('ios', 'android', 'web');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE payment_recurrence AS ENUM ('one_time', 'monthly', 'annual');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Orders ← payment (new side of the relationship)
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS payment_id UUID;

-- Payments: new columns (nullable first for backfill)
ALTER TABLE public.payments
  ADD COLUMN IF NOT EXISTS profile_id UUID,
  ADD COLUMN IF NOT EXISTS provider payment_provider,
  ADD COLUMN IF NOT EXISTS platform payment_platform,
  ADD COLUMN IF NOT EXISTS recurrence payment_recurrence,
  ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS rc_id TEXT,
  ADD COLUMN IF NOT EXISTS rc_entitlement_id TEXT,
  ADD COLUMN IF NOT EXISTS rc_product_id TEXT,
  ADD COLUMN IF NOT EXISTS rc_transaction_id TEXT,
  ADD COLUMN IF NOT EXISTS plan_id TEXT,
  ADD COLUMN IF NOT EXISTS currency TEXT NOT NULL DEFAULT 'BRL',
  ADD COLUMN IF NOT EXISTS starts_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS current_period_end TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- PIX legacy columns: allow null for RevenueCat rows
ALTER TABLE public.payments
  ALTER COLUMN amount_cents DROP NOT NULL,
  ALTER COLUMN expires_at DROP NOT NULL;

-- Backfill profile_id from orders.user_id
UPDATE public.payments p
SET profile_id = o.user_id
FROM public.orders o
WHERE p.order_id = o.id
  AND o.user_id IS NOT NULL
  AND p.profile_id IS NULL;

-- Legacy PIX rows defaults
UPDATE public.payments
SET
  provider = COALESCE(provider, 'pagarme_pix'::payment_provider),
  recurrence = COALESCE(recurrence, 'one_time'::payment_recurrence),
  is_active = CASE WHEN status = 'paid' THEN true ELSE is_active END
WHERE provider IS NULL OR recurrence IS NULL;

-- Link orders → payments (1 payment can later cover many orders)
UPDATE public.orders o
SET payment_id = p.id
FROM public.payments p
WHERE p.order_id = o.id
  AND o.payment_id IS NULL;

-- FK: orders.payment_id → payments
DO $$ BEGIN
  ALTER TABLE public.orders
    ADD CONSTRAINT orders_payment_id_fkey
    FOREIGN KEY (payment_id) REFERENCES public.payments(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- FK: payments.profile_id → profiles (nullable: legacy PIX rows may lack user_id)
DO $$ BEGIN
  ALTER TABLE public.payments
    ADD CONSTRAINT payments_profile_id_fkey
    FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Require provider / recurrence on all rows after backfill
ALTER TABLE public.payments
  ALTER COLUMN provider SET NOT NULL,
  ALTER COLUMN recurrence SET NOT NULL,
  ALTER COLUMN provider SET DEFAULT 'pagarme_pix'::payment_provider,
  ALTER COLUMN recurrence SET DEFAULT 'one_time'::payment_recurrence;

-- Drop RLS that still references payments.order_id before dropping the column
DROP POLICY IF EXISTS "Users can view own payments" ON public.payments;
DROP POLICY IF EXISTS "Users can insert own payments" ON public.payments;
DROP POLICY IF EXISTS "Users can update own payments" ON public.payments;

-- Drop old payments → orders FK and column
ALTER TABLE public.payments DROP CONSTRAINT IF EXISTS payments_order_id_fkey;
DROP INDEX IF EXISTS idx_payments_order_id;
ALTER TABLE public.payments DROP COLUMN IF EXISTS order_id;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_orders_payment_id ON public.orders(payment_id);
CREATE INDEX IF NOT EXISTS idx_payments_profile_id ON public.payments(profile_id);
CREATE INDEX IF NOT EXISTS idx_payments_rc_id ON public.payments(rc_id)
  WHERE rc_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_payments_profile_active ON public.payments(profile_id, is_active)
  WHERE is_active = true;

-- updated_at trigger (reuse shared function if present)
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS payments_updated_at ON public.payments;
CREATE TRIGGER payments_updated_at
  BEFORE UPDATE ON public.payments
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- RLS: own profile payments
CREATE POLICY "Users can view own payments"
  ON public.payments
  FOR SELECT
  USING (profile_id = auth.uid());

CREATE POLICY "Users can insert own payments"
  ON public.payments
  FOR INSERT
  WITH CHECK (profile_id = auth.uid());

CREATE POLICY "Users can update own payments"
  ON public.payments
  FOR UPDATE
  USING (profile_id = auth.uid())
  WITH CHECK (profile_id = auth.uid());

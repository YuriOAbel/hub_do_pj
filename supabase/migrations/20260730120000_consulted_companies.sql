-- Consulted companies (CNPJ lookup history per profile) + orders FK.

CREATE TABLE IF NOT EXISTS public.consulted_companies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  cnpj_digits TEXT NOT NULL,
  company_name TEXT NOT NULL,
  situacao TEXT,
  fantasia TEXT,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  last_consulted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT consulted_companies_cnpj_digits_len
    CHECK (char_length(cnpj_digits) = 14),
  CONSTRAINT consulted_companies_profile_cnpj_unique
    UNIQUE (profile_id, cnpj_digits)
);

CREATE INDEX IF NOT EXISTS idx_consulted_companies_profile_last_consulted
  ON public.consulted_companies (profile_id, last_consulted_at DESC);

DROP TRIGGER IF EXISTS consulted_companies_updated_at ON public.consulted_companies;
CREATE TRIGGER consulted_companies_updated_at
  BEFORE UPDATE ON public.consulted_companies
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at();

ALTER TABLE public.consulted_companies ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'consulted_companies'
      AND policyname = 'Users can view own consulted companies'
  ) THEN
    CREATE POLICY "Users can view own consulted companies"
      ON public.consulted_companies
      FOR SELECT
      USING (auth.uid() = profile_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'consulted_companies'
      AND policyname = 'Users can insert own consulted companies'
  ) THEN
    CREATE POLICY "Users can insert own consulted companies"
      ON public.consulted_companies
      FOR INSERT
      WITH CHECK (auth.uid() = profile_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'consulted_companies'
      AND policyname = 'Users can update own consulted companies'
  ) THEN
    CREATE POLICY "Users can update own consulted companies"
      ON public.consulted_companies
      FOR UPDATE
      USING (auth.uid() = profile_id)
      WITH CHECK (auth.uid() = profile_id);
  END IF;
END $$;

REVOKE ALL ON public.consulted_companies FROM anon;
GRANT SELECT, INSERT, UPDATE ON public.consulted_companies TO authenticated;
GRANT ALL ON public.consulted_companies TO postgres, service_role;

-- Orders link to consulted company (nullable for legacy orphan rows).
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS consulted_company_id UUID;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'orders_consulted_company_id_fkey'
  ) THEN
    ALTER TABLE public.orders
      ADD CONSTRAINT orders_consulted_company_id_fkey
      FOREIGN KEY (consulted_company_id)
      REFERENCES public.consulted_companies (id)
      ON DELETE SET NULL;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_orders_consulted_company_id
  ON public.orders (consulted_company_id);

-- Backfill: one consulted_companies row per (user_id, cnpj digits) from orders.
WITH ranked AS (
  SELECT
    o.user_id AS profile_id,
    regexp_replace(o.cnpj, '[^0-9]', '', 'g') AS cnpj_digits,
    o.company_name,
    o.created_at,
    ROW_NUMBER() OVER (
      PARTITION BY o.user_id, regexp_replace(o.cnpj, '[^0-9]', '', 'g')
      ORDER BY o.created_at DESC
    ) AS rn,
    MAX(o.created_at) OVER (
      PARTITION BY o.user_id, regexp_replace(o.cnpj, '[^0-9]', '', 'g')
    ) AS last_consulted_at
  FROM public.orders o
  INNER JOIN public.profiles p ON p.id = o.user_id
  WHERE o.user_id IS NOT NULL
    AND char_length(regexp_replace(o.cnpj, '[^0-9]', '', 'g')) = 14
)
INSERT INTO public.consulted_companies (
  profile_id,
  cnpj_digits,
  company_name,
  situacao,
  fantasia,
  metadata,
  last_consulted_at,
  created_at,
  updated_at
)
SELECT
  profile_id,
  cnpj_digits,
  COALESCE(NULLIF(btrim(company_name), ''), 'Empresa'),
  NULL,
  NULL,
  '{}'::jsonb,
  last_consulted_at,
  NOW(),
  NOW()
FROM ranked
WHERE rn = 1
ON CONFLICT (profile_id, cnpj_digits) DO NOTHING;

UPDATE public.orders o
SET consulted_company_id = cc.id
FROM public.consulted_companies cc
WHERE o.user_id = cc.profile_id
  AND regexp_replace(o.cnpj, '[^0-9]', '', 'g') = cc.cnpj_digits
  AND o.consulted_company_id IS NULL
  AND o.user_id IS NOT NULL;

-- New inserts must carry consulted_company_id (mirrors device_id guard).
CREATE OR REPLACE FUNCTION public.enforce_order_has_consulted_company()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.consulted_company_id IS NULL THEN
    RAISE EXCEPTION 'orders.consulted_company_id is required';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.consulted_companies cc
    WHERE cc.id = NEW.consulted_company_id
      AND (NEW.user_id IS NULL OR cc.profile_id = NEW.user_id)
  ) THEN
    RAISE EXCEPTION 'orders.consulted_company_id must belong to order user';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS orders_require_consulted_company ON public.orders;
CREATE TRIGGER orders_require_consulted_company
  BEFORE INSERT ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_order_has_consulted_company();

-- One active profile per device_id.
-- Dedupe: keep oldest non-deleted row per device_id; clear device_id on others.
-- Then enforce with a partial unique index.

DO $$
BEGIN
  -- Clear device_id on duplicate rows (keep earliest created_at, then id).
  WITH ranked AS (
    SELECT
      id,
      ROW_NUMBER() OVER (
        PARTITION BY device_id
        ORDER BY created_at ASC NULLS LAST, id ASC
      ) AS rn
    FROM public.profiles
    WHERE device_id IS NOT NULL
      AND btrim(device_id) <> ''
      AND deleted_at IS NULL
  )
  UPDATE public.profiles p
  SET device_id = NULL
  FROM ranked r
  WHERE p.id = r.id
    AND r.rn > 1;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS profiles_device_id_unique
  ON public.profiles (device_id)
  WHERE device_id IS NOT NULL
    AND btrim(device_id) <> ''
    AND deleted_at IS NULL;

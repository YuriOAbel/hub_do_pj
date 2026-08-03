-- Track completed onboarding; soft-delete empty / orphan profiles without
-- device_id so active rows stay recoverable by device.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS onboarded_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_profiles_onboarded_at
  ON public.profiles (onboarded_at)
  WHERE onboarded_at IS NOT NULL AND deleted_at IS NULL;

-- Park never-used trigger shells (no name, no device).
UPDATE public.profiles
SET deleted_at = NOW()
WHERE deleted_at IS NULL
  AND (device_id IS NULL OR btrim(device_id) = '')
  AND (name IS NULL OR btrim(name) = '');

-- Park reclaim orphans that lost device_id but still appear active.
UPDATE public.profiles
SET deleted_at = NOW()
WHERE deleted_at IS NULL
  AND (device_id IS NULL OR btrim(device_id) = '');

-- Backfill onboarded_at for already-complete active profiles.
UPDATE public.profiles
SET onboarded_at = COALESCE(onboarded_at, created_at)
WHERE deleted_at IS NULL
  AND device_id IS NOT NULL AND btrim(device_id) <> ''
  AND name IS NOT NULL AND btrim(name) <> ''
  AND person_type IS NOT NULL AND btrim(person_type) <> ''
  AND occupation IS NOT NULL AND btrim(occupation) <> ''
  AND interest_ids IS NOT NULL AND cardinality(interest_ids) > 0
  AND onboarded_at IS NULL;

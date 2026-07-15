ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS monthly_certificate_interest BOOLEAN NOT NULL DEFAULT false;

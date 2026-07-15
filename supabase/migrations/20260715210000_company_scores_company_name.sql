-- Add company name to company scores for result/home display

ALTER TABLE company_scores
  ADD COLUMN IF NOT EXISTS company_name TEXT;

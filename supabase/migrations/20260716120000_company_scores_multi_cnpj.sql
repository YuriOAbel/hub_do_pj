-- Allow multiple company scores per profile per month (one per CNPJ).

DROP INDEX IF EXISTS uq_company_scores_profile_month;

CREATE UNIQUE INDEX IF NOT EXISTS uq_company_scores_profile_cnpj_month
  ON company_scores (profile_id, cnpj, score_month);

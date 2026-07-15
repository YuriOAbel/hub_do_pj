CREATE INDEX IF NOT EXISTS idx_payments_pagarme_charge_id
  ON payments(pagarme_charge_id)
  WHERE pagarme_charge_id IS NOT NULL;

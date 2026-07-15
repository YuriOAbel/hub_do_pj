-- Ao confirmar pagamento, pedido sai de em_analise (pré-pagamento) para processando.

CREATE OR REPLACE FUNCTION sync_order_status_on_payment()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.payment_status = 'paid' AND NEW.status = 'em_analise' THEN
    NEW.status = 'processando';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS orders_sync_status_on_payment ON orders;

CREATE TRIGGER orders_sync_status_on_payment
  BEFORE UPDATE OF payment_status ON orders
  FOR EACH ROW
  EXECUTE FUNCTION sync_order_status_on_payment();

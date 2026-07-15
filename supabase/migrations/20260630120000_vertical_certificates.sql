-- Vertical certificate catalog + multi-select orders

INSERT INTO products (id, slug, name, type, price_cents, active) VALUES
  ('c08', 'regularidade-fiscal', 'Certidão de Regularidade Fiscal', 'single', 999, true),
  ('c09', 'inscricao-cadastral-receita', 'Comprovante de Inscrição e de Situação Cadastral (Receita Federal)', 'single', 999, true),
  ('c10', 'certificado-mei', 'Certificado da Condição de Microempreendedor Individual (MEI)', 'single', 999, true),
  ('c11', 'inscricao-cadastral-junta', 'Comprovante de Inscrição e de Situação Cadastral (Junta Comercial)', 'single', 999, true),
  ('c12', 'opcao-simples-nacional', 'Comprovante de Opção pelo Simples Nacional', 'single', 999, true),
  ('c13', 'negativa-correcional-epad', 'Certidão Negativa Correcional — Entes Privados (ePAD)', 'single', 999, true),
  ('c14', 'infracoes-trabalhistas', 'Certidão de Infrações Trabalhistas', 'single', 999, true),
  ('c15', 'negativa-contas-julgadas', 'Certidão Negativa de Contas Julgadas Irregulares', 'single', 999, true)
ON CONFLICT (id) DO NOTHING;

UPDATE products SET price_cents = 4999 WHERE id = 'p01';

ALTER TABLE orders ADD COLUMN IF NOT EXISTS selected_product_ids TEXT[] DEFAULT NULL;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS total_cents INTEGER DEFAULT NULL;

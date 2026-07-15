-- SKUs for consulta de protesto and consulta de restrição (R$ 69,99).
INSERT INTO products (id, slug, name, type, price_cents, active) VALUES
  ('prot01', 'consulta-protesto', 'Consulta de Protesto', 'single', 6999, true),
  ('rest01', 'consulta-restricao', 'Consulta de Restrição', 'single', 6999, true)
ON CONFLICT (id) DO UPDATE
SET slug = EXCLUDED.slug,
    name = EXCLUDED.name,
    type = EXCLUDED.type,
    price_cents = EXCLUDED.price_cents,
    active = EXCLUDED.active;

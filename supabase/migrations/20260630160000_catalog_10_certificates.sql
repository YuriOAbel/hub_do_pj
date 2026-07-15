-- Catálogo oficial: 10 certidões ativas + pacote; desativa legado c01–c03, c06, c07

UPDATE products
SET active = false
WHERE id IN ('c01', 'c02', 'c03', 'c06', 'c07');

UPDATE products
SET price_cents = 999, active = true
WHERE id IN (
  'c04', 'c05', 'c08', 'c09', 'c10', 'c11', 'c12', 'c13', 'c14', 'c15'
);

UPDATE products
SET price_cents = 4999, active = true
WHERE id = 'p01';

-- Remoção física (somente se não houver pedidos referenciando):
-- SELECT product_id, COUNT(*) FROM orders
-- WHERE product_id IN ('c01','c02','c03','c06','c07') GROUP BY product_id;
-- DELETE FROM products WHERE id IN ('c01','c02','c03','c06','c07');

-- Avulsas c01–c07: R$9,99 (p01 e c08–c15 já ajustados na migration anterior)

UPDATE products SET price_cents = 999
WHERE id IN ('c01', 'c02', 'c03', 'c04', 'c05', 'c06', 'c07');

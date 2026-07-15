-- Certidões PJ — Schema inicial

-- Enums
CREATE TYPE product_type AS ENUM ('single', 'package');
CREATE TYPE order_status AS ENUM ('em_analise', 'processando', 'concluido', 'cancelado');
CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'expired', 'failed');

-- Profiles
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  phone TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- Products
CREATE TABLE products (
  id TEXT PRIMARY KEY,
  slug TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  type product_type NOT NULL,
  price_cents INTEGER NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Orders
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  guest_email TEXT NOT NULL,
  product_id TEXT NOT NULL REFERENCES products(id),
  cnpj TEXT NOT NULL,
  company_name TEXT NOT NULL,
  address JSONB NOT NULL,
  status order_status NOT NULL DEFAULT 'em_analise',
  payment_status payment_status NOT NULL DEFAULT 'pending',
  pagarme_order_id TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Order documents
CREATE TABLE order_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  certificate_type TEXT NOT NULL,
  file_url TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Payments
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  pagarme_charge_id TEXT,
  pix_qr_code TEXT,
  pix_copy_paste TEXT,
  amount_cents INTEGER NOT NULL,
  status payment_status NOT NULL DEFAULT 'pending',
  expires_at TIMESTAMPTZ NOT NULL,
  paid_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_guest_email ON orders(guest_email);
CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_order_documents_order_id ON order_documents(order_id);

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER orders_updated_at
  BEFORE UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Seed products
INSERT INTO products (id, slug, name, type, price_cents, active) VALUES
  ('c01', 'negativa-debitos-federais', 'Certidão Negativa de Débitos Federais', 'single', 4990, true),
  ('c02', 'negativa-debitos-estaduais', 'Certidão Negativa de Débitos Estaduais', 'single', 4990, true),
  ('c03', 'negativa-debitos-municipais', 'Certidão Negativa de Débitos Municipais', 'single', 4990, true),
  ('c04', 'regularidade-fgts', 'Certificado de Regularidade do FGTS (CRF)', 'single', 4990, true),
  ('c05', 'negativa-debitos-trabalhistas', 'Certidão Negativa de Débitos Trabalhistas (CNDT)', 'single', 4990, true),
  ('c06', 'falencia-concordata', 'Certidão de Falência e Concordata', 'single', 4990, true),
  ('c07', 'debitos-trabalhistas-tst', 'Certidão de Débitos Trabalhistas (TST)', 'single', 4990, true),
  ('p01', 'pacote-completo', 'Pacote Completo', 'package', 24990, true);

-- RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can delete own profile" ON profiles FOR DELETE USING (auth.uid() = id);

-- Products: public read
CREATE POLICY "Products are publicly readable" ON products FOR SELECT USING (active = true);

-- Orders policies
CREATE POLICY "Users can view own orders" ON orders FOR SELECT
  USING (auth.uid() = user_id OR guest_email = auth.jwt()->>'email');

CREATE POLICY "Anyone can create orders" ON orders FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update own orders" ON orders FOR UPDATE
  USING (auth.uid() = user_id);

-- Order documents policies
CREATE POLICY "Users can view own order documents" ON order_documents FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM orders
      WHERE orders.id = order_documents.order_id
      AND (orders.user_id = auth.uid() OR orders.guest_email = auth.jwt()->>'email')
    )
  );

-- Payments policies
CREATE POLICY "Users can view own payments" ON payments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM orders
      WHERE orders.id = payments.order_id
      AND (orders.user_id = auth.uid() OR orders.guest_email = auth.jwt()->>'email')
    )
  );

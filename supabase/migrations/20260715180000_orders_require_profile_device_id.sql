-- Orders must belong to an authenticated user whose profile has device_id.
-- Tightens RLS (no guest-email SELECT / open INSERT) and adds a BEFORE INSERT guard
-- that also runs for service_role paths (Edge Functions).

CREATE OR REPLACE FUNCTION public.enforce_order_has_profile_device_id()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.user_id IS NULL THEN
    RAISE EXCEPTION 'orders.user_id is required';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.profiles p
    WHERE p.id = NEW.user_id
      AND p.device_id IS NOT NULL
      AND btrim(p.device_id) <> ''
  ) THEN
    RAISE EXCEPTION 'orders require a profile with device_id';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS orders_require_profile_device_id ON public.orders;

CREATE TRIGGER orders_require_profile_device_id
  BEFORE INSERT ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_order_has_profile_device_id();

DROP POLICY IF EXISTS "Users can view own orders" ON public.orders;
CREATE POLICY "Users can view own orders"
  ON public.orders
  FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Anyone can create orders" ON public.orders;
DROP POLICY IF EXISTS "Authenticated users can create own orders" ON public.orders;
CREATE POLICY "Authenticated users can create own orders"
  ON public.orders
  FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1
      FROM public.profiles p
      WHERE p.id = auth.uid()
        AND p.device_id IS NOT NULL
        AND btrim(p.device_id) <> ''
    )
  );

DROP POLICY IF EXISTS "Users can view own order documents" ON public.order_documents;
CREATE POLICY "Users can view own order documents"
  ON public.order_documents
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM public.orders
      WHERE orders.id = order_documents.order_id
        AND orders.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can view own payments" ON public.payments;
CREATE POLICY "Users can view own payments"
  ON public.payments
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM public.orders
      WHERE orders.id = payments.order_id
        AND orders.user_id = auth.uid()
    )
  );

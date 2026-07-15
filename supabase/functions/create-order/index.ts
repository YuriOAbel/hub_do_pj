import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

interface OrderAddress {
  cep: string;
  logradouro: string;
  numero: string;
  complemento?: string | null;
  bairro: string;
  cidade: string;
  uf: string;
  telefone?: string | null;
}

interface CreateOrderRequest {
  productId?: string;
  cnpj?: string;
  companyName?: string;
  guestEmail?: string;
  guestPhone?: string | null;
  address?: OrderAddress;
}

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function onlyDigits(value: string): string {
  return value.replace(/\D/g, '');
}

function formatCnpj(raw: string): string {
  const digits = onlyDigits(raw);
  if (digits.length !== 14) return raw.trim();
  return `${digits.slice(0, 2)}.${digits.slice(2, 5)}.${digits.slice(5, 8)}/${digits.slice(8, 12)}-${digits.slice(12)}`;
}

function formatCep(raw: string): string {
  const digits = onlyDigits(raw);
  if (digits.length !== 8) return raw.trim();
  return `${digits.slice(0, 5)}-${digits.slice(5)}`;
}

function isoTimestamp(value: unknown): string {
  if (typeof value === 'string') return value;
  if (value instanceof Date) return value.toISOString();
  return new Date().toISOString();
}

function toApiOrder(row: Record<string, unknown>) {
  return {
    id: row.id,
    userId: row.user_id,
    guestEmail: row.guest_email,
    guestPhone: row.guest_phone ?? null,
    productId: row.product_id,
    selectedProductIds: row.selected_product_ids ?? null,
    totalCents: row.total_cents ?? null,
    cnpj: row.cnpj,
    companyName: row.company_name,
    address: row.address ?? null,
    status: row.status,
    paymentStatus: row.payment_status,
    createdAt: isoTimestamp(row.created_at),
    updatedAt: row.updated_at ? isoTimestamp(row.updated_at) : null,
  };
}

function validateAddress(address: OrderAddress | undefined): string | null {
  if (!address) return 'Endereço é obrigatório';
  if (!address.cep?.trim()) return 'CEP é obrigatório';
  if (!address.logradouro?.trim()) return 'Logradouro é obrigatório';
  if (!address.numero?.trim()) return 'Número é obrigatório';
  if (!address.bairro?.trim()) return 'Bairro é obrigatório';
  if (!address.cidade?.trim()) return 'Cidade é obrigatória';
  if (!address.uf?.trim()) return 'UF é obrigatória';
  return null;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405);
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error('Supabase credentials não configuradas');
    }

    const authHeader = req.headers.get('Authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      return jsonResponse({ error: 'Autenticação obrigatória' }, 401);
    }

    const jwt = authHeader.slice(7).trim();
    if (!jwt) {
      return jsonResponse({ error: 'Autenticação obrigatória' }, 401);
    }

    // Service role + explicit JWT — Edge has no local auth session.
    const admin = createClient(supabaseUrl, supabaseServiceKey);
    const {
      data: { user },
      error: userError,
    } = await admin.auth.getUser(jwt);

    if (userError || !user) {
      console.error('create-order getUser:', userError);
      return jsonResponse({ error: 'Sessão inválida' }, 401);
    }

    const body: CreateOrderRequest = await req.json();
    const productId = body.productId?.trim();
    const guestEmail = body.guestEmail?.trim().toLowerCase();
    const companyName = body.companyName?.trim();
    const cnpjRaw = body.cnpj?.trim() ?? '';
    const cnpjDigits = onlyDigits(cnpjRaw);
    const guestPhoneDigits = body.guestPhone
      ? onlyDigits(body.guestPhone)
      : '';

    if (!productId) {
      return jsonResponse({ error: 'productId é obrigatório' }, 400);
    }
    if (!guestEmail) {
      return jsonResponse({ error: 'guestEmail é obrigatório' }, 400);
    }
    if (!companyName) {
      return jsonResponse({ error: 'companyName é obrigatório' }, 400);
    }
    if (cnpjDigits.length !== 14) {
      return jsonResponse({ error: 'CNPJ inválido' }, 400);
    }

    const addressError = validateAddress(body.address);
    if (addressError) {
      return jsonResponse({ error: addressError }, 400);
    }

    const address: OrderAddress = {
      cep: formatCep(body.address!.cep),
      logradouro: body.address!.logradouro.trim(),
      numero: body.address!.numero.trim(),
      complemento: body.address!.complemento?.trim() || null,
      bairro: body.address!.bairro.trim(),
      cidade: body.address!.cidade.trim(),
      uf: body.address!.uf.trim().toUpperCase(),
      telefone: guestPhoneDigits || body.address!.telefone || null,
    };

    const { data: profile, error: profileError } = await admin
      .from('profiles')
      .select('id, device_id')
      .eq('id', user.id)
      .maybeSingle();

    if (profileError) {
      console.error('create-order profile lookup:', profileError);
      return jsonResponse({ error: 'Erro ao validar perfil' }, 500);
    }

    if (!profile) {
      return jsonResponse({ error: 'Perfil não encontrado' }, 403);
    }

    const deviceId =
      typeof profile.device_id === 'string' ? profile.device_id.trim() : '';
    if (!deviceId) {
      return jsonResponse(
        { error: 'Perfil sem device_id. Reabra o app e tente novamente.' },
        403,
      );
    }

    const { data: product, error: productError } = await admin
      .from('products')
      .select('id, price_cents, active')
      .eq('id', productId)
      .maybeSingle();

    if (productError) {
      console.error('create-order product lookup:', productError);
      return jsonResponse({ error: 'Erro ao validar produto' }, 500);
    }

    if (!product || product.active !== true) {
      return jsonResponse({ error: 'Produto inválido ou inativo' }, 400);
    }

    const insertPayload = {
      user_id: user.id,
      guest_email: guestEmail,
      guest_phone: guestPhoneDigits || null,
      product_id: product.id,
      selected_product_ids: [product.id],
      total_cents: product.price_cents,
      cnpj: formatCnpj(cnpjDigits),
      company_name: companyName,
      address,
    };

    const { data: order, error: insertError } = await admin
      .from('orders')
      .insert(insertPayload)
      .select('*')
      .single();

    if (insertError || !order) {
      console.error('create-order insert:', insertError);
      const message = insertError?.message?.includes('device_id')
        ? 'Perfil sem device_id. Reabra o app e tente novamente.'
        : 'Erro ao criar pedido';
      return jsonResponse({ error: message }, 400);
    }

    return jsonResponse(toApiOrder(order as Record<string, unknown>), 201);
  } catch (error) {
    console.error('create-order error:', error);
    return jsonResponse({ error: 'Erro interno ao criar pedido' }, 500);
  }
});

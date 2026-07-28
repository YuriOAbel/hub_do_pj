import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const PAGARME_API = 'https://api.pagar.me/core/v5';
const PIX_EXPIRATION = 300;
const DEV_PIX_AMOUNT_CENTS = 1;

function isDevMode(): boolean {
  return ['true', '1'].includes((Deno.env.get('APP_DEV_MODE') ?? '').toLowerCase());
}

interface OrderAddress {
  cep: string;
  logradouro: string;
  numero: string;
  complemento?: string;
  bairro: string;
  cidade: string;
  uf: string;
}

interface CreatePixRequest {
  orderId: string;
  guestEmail?: string;
}

interface PixResponse {
  pixQrCode: string;
  pixCopyPaste: string;
  expiresAt: string;
  amountCents: number;
  orderId: string;
}

function createMockPix(orderId: string, amountCents: number): PixResponse {
  const copyPaste = `00020126580014BR.GOV.BCB.PIX0136${orderId}520400005303986540${(amountCents / 100).toFixed(2)}5802BR5925CERTIDOES PJ6009SAO PAULO62070503***6304ABCD`;
  return {
    pixQrCode: copyPaste,
    pixCopyPaste: copyPaste,
    expiresAt: new Date(Date.now() + 2 * 60 * 1000).toISOString(),
    amountCents,
    orderId,
  };
}

const FALLBACK_PHONE_DIGITS = '48996498239';

function onlyDigits(value: string): string {
  return value.replace(/\D/g, '');
}

function parseBrazilianPhone(raw: string | null | undefined): {
  country_code: string;
  area_code: string;
  number: string;
} | null {
  if (!raw) return null;

  const digits = onlyDigits(raw);
  if (digits.length === 10 || digits.length === 11) {
    return {
      country_code: '55',
      area_code: digits.slice(0, 2),
      number: digits.slice(2),
    };
  }

  if ((digits.length === 12 || digits.length === 13) && digits.startsWith('55')) {
    return {
      country_code: '55',
      area_code: digits.slice(2, 4),
      number: digits.slice(4),
    };
  }

  return null;
}

function resolveCustomerPhone(order: {
  guest_phone?: string | null;
  address: OrderAddress;
}): { country_code: string; area_code: string; number: string } {
  const addressPhone =
    typeof order.address === 'object' && order.address !== null
      ? (order.address as OrderAddress & { telefone?: string }).telefone
      : undefined;

  const parsed =
    parseBrazilianPhone(order.guest_phone) ??
    parseBrazilianPhone(addressPhone) ??
    parseBrazilianPhone(Deno.env.get('PAGARME_FALLBACK_PHONE')) ??
    parseBrazilianPhone(FALLBACK_PHONE_DIGITS);

  if (!parsed) {
    throw new Error('Telefone do cliente inválido para pagamento PIX');
  }

  return parsed;
}

function buildCustomer(order: {
  company_name: string;
  guest_email: string;
  guest_phone?: string | null;
  cnpj: string;
  address: OrderAddress;
}) {
  const address = order.address;
  const mobilePhone = resolveCustomerPhone(order);

  return {
    name: order.company_name,
    email: order.guest_email,
    document: order.cnpj.replace(/\D/g, ''),
    type: 'company',
    document_type: 'CNPJ',
    phones: {
      mobile_phone: mobilePhone,
    },
    address: {
      line_1: `${address.logradouro}, ${address.numero}`,
      line_2: address.complemento || '',
      zip_code: address.cep.replace(/\D/g, ''),
      city: address.cidade,
      state: address.uf,
      country: 'BR',
    },
  };
}

async function canAccessOrder(
  supabase: ReturnType<typeof createClient>,
  order: { user_id: string | null; guest_email: string },
  authToken: string | null,
  serviceRoleKey: string,
  guestEmail?: string,
): Promise<boolean> {
  if (authToken === serviceRoleKey) return true;

  if (guestEmail && order.guest_email === guestEmail) return true;

  if (authToken) {
    const { data: { user } } = await supabase.auth.getUser(authToken);
    if (user) {
      if (order.user_id === user.id) return true;
      if (!order.user_id && guestEmail && order.guest_email === guestEmail) return true;
    }
  }

  return false;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      status: 405,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error('Supabase credentials não configuradas');
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { orderId, guestEmail }: CreatePixRequest = await req.json();

    if (!orderId) {
      return new Response(JSON.stringify({ error: 'orderId é obrigatório' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const authHeader = req.headers.get('Authorization');
    const authToken = authHeader?.startsWith('Bearer ') ? authHeader.slice(7) : null;

    const { data: order, error: orderError } = await supabase
      .from('orders')
      .select('*, products(name, price_cents)')
      .eq('id', orderId)
      .single();

    if (orderError || !order) {
      return new Response(JSON.stringify({ error: 'Pedido não encontrado' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const allowed = await canAccessOrder(
      supabase,
      order,
      authToken,
      supabaseServiceKey,
      guestEmail,
    );

    if (!allowed) {
      return new Response(JSON.stringify({ error: 'Acesso negado' }), {
        status: 403,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    if (order.payment_status === 'paid') {
      return new Response(JSON.stringify({ error: 'Pedido já pago' }), {
        status: 409,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const product = order.products as { name: string; price_cents: number } | null;
    const selectedIds = order.selected_product_ids as string[] | null | undefined;
    let amountCents = order.total_cents as number | null | undefined;
    if (amountCents == null && selectedIds?.length) {
      amountCents = selectedIds.length * 999;
    }
    if (amountCents == null && order.product_id === 'p01') {
      amountCents = 4999;
    }
    if (amountCents == null) {
      amountCents = product?.price_cents ?? 4990;
    }

    if (isDevMode()) {
      amountCents = DEV_PIX_AMOUNT_CENTS;
    }

    let existingPayment: Record<string, unknown> | null = null;
    if (order.payment_id) {
      const { data } = await supabase
        .from('payments')
        .select('*')
        .eq('id', order.payment_id)
        .maybeSingle();
      existingPayment = data;
    }

    if (
      existingPayment?.status === 'pending' &&
      existingPayment.expires_at &&
      new Date(existingPayment.expires_at as string) > new Date() &&
      existingPayment.amount_cents === amountCents
    ) {
      const response: PixResponse = {
        pixQrCode: (existingPayment.pix_qr_code as string) ?? '',
        pixCopyPaste: (existingPayment.pix_copy_paste as string) ?? '',
        expiresAt: existingPayment.expires_at as string,
        amountCents: existingPayment.amount_cents as number,
        orderId,
      };

      return new Response(JSON.stringify(response), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    if (existingPayment?.status === 'pending') {
      await supabase
        .from('payments')
        .update({ status: 'expired', is_active: false })
        .eq('id', existingPayment.id);
      await supabase.from('orders').update({ payment_status: 'expired' }).eq('id', orderId);
    }

    if (!order.user_id) {
      return new Response(JSON.stringify({ error: 'Pedido sem usuário vinculado' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const productName = order.selected_product_ids?.length
      ? `${order.selected_product_ids.length} certidões avulsas`
      : product?.name ?? 'Certidões PJ';

    const pagarmeSecretKey = Deno.env.get('PAGARME_SECRET_KEY');

    if (!pagarmeSecretKey || pagarmeSecretKey.includes('...')) {
      const mock = createMockPix(orderId, amountCents);

      const { data: mockPayment, error: paymentError } = await supabase
        .from('payments')
        .insert({
          profile_id: order.user_id,
          provider: 'pagarme_pix',
          platform: 'web',
          recurrence: 'one_time',
          is_active: false,
          pagarme_charge_id: `mock_${orderId}`,
          pix_qr_code: mock.pixQrCode,
          pix_copy_paste: mock.pixCopyPaste,
          amount_cents: amountCents,
          status: 'pending',
          expires_at: mock.expiresAt,
        })
        .select('id')
        .single();

      if (paymentError) throw paymentError;

      await supabase
        .from('orders')
        .update({
          pagarme_order_id: `mock_order_${orderId}`,
          payment_id: mockPayment.id,
        })
        .eq('id', orderId);

      return new Response(JSON.stringify(mock), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const authTokenPagarme = btoa(`${pagarmeSecretKey}:`);
    const address = order.address as OrderAddress;

    const orderPayload = {
      closed: true,
      code: orderId.slice(0, 8),
      customer: buildCustomer({
        company_name: order.company_name,
        guest_email: order.guest_email,
        guest_phone: order.guest_phone as string | null | undefined,
        cnpj: order.cnpj,
        address,
      }),
      items: [
        {
          amount: amountCents,
          description: productName.substring(0, 100),
          quantity: 1,
          code: orderId.slice(0, 8),
        },
      ],
      payments: [{ payment_method: 'pix', pix: { expires_in: PIX_EXPIRATION } }],
      metadata: {
        orderId,
        productId: order.product_id,
        source: 'certidoes-pj',
        email: order.guest_email,
      },
    };

    const pagarmeResponse = await fetch(`${PAGARME_API}/orders`, {
      method: 'POST',
      headers: {
        Authorization: `Basic ${authTokenPagarme}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(orderPayload),
    });

    if (!pagarmeResponse.ok) {
      const errorData = await pagarmeResponse.json().catch(() => ({}));
      console.error('Erro Pagar.me:', errorData);
      throw new Error(
        `Erro ao criar pedido PIX: ${(errorData as { message?: string }).message || pagarmeResponse.statusText}`,
      );
    }

    const orderData = await pagarmeResponse.json();

    if (!orderData.charges?.length) {
      throw new Error('Resposta inválida da Pagar.me - sem charges');
    }

    const charge = orderData.charges[0];
    const transaction = charge.last_transaction;

    if (transaction.transaction_type !== 'pix') {
      throw new Error('Tipo de transação inválido - apenas PIX é permitido');
    }

    if (transaction.status === 'failed' && transaction.gateway_response) {
      const gatewayError =
        transaction.gateway_response.errors?.[0]?.message || 'Erro desconhecido';

      if (gatewayError.includes('action_forbidden')) {
        throw new Error(
          'PIX não está habilitado na sua conta Pagar.me. Entre em contato com o suporte Pagar.me.',
        );
      }

      throw new Error(`Erro ao processar PIX: ${gatewayError}`);
    }

    if (!transaction.qr_code) {
      throw new Error('QR Code PIX não foi gerado pela Pagar.me');
    }

    const expiresAt =
      transaction.expires_at || new Date(Date.now() + PIX_EXPIRATION * 1000).toISOString();

    const { data: payment, error: paymentError } = await supabase
      .from('payments')
      .insert({
        profile_id: order.user_id,
        provider: 'pagarme_pix',
        platform: 'web',
        recurrence: 'one_time',
        is_active: false,
        pagarme_charge_id: charge.id,
        pix_qr_code: transaction.qr_code,
        pix_copy_paste: transaction.qr_code,
        amount_cents: amountCents,
        status: 'pending',
        expires_at: expiresAt,
      })
      .select('id')
      .single();

    if (paymentError) throw paymentError;

    await supabase
      .from('orders')
      .update({
        pagarme_order_id: orderData.id,
        payment_id: payment.id,
      })
      .eq('id', orderId);

    const response: PixResponse = {
      pixQrCode: transaction.qr_code,
      pixCopyPaste: transaction.qr_code,
      expiresAt,
      amountCents,
      orderId,
    };

    return new Response(JSON.stringify(response), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    console.error('Erro ao criar pedido PIX:', error);
    const message = error instanceof Error ? error.message : 'Erro ao criar pedido PIX';

    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});

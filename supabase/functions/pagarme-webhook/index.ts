import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3';

/**
 * verify_jwt = false — Pagar.me envia webhooks sem JWT.
 * Segurança via x-hub-signature (HMAC SHA1 + PAGARME_WEBHOOK_SECRET).
 */

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type, x-hub-signature',
};

interface PagarmeWebhookEvent {
  id: string;
  type: string;
  created_at: string;
  data: {
    id: string;
    code?: string;
    amount: number;
    status: string;
    customer?: {
      email: string;
      name?: string;
    };
    charges?: Array<{
      id: string;
      status: string;
      amount: number;
      paid_at?: string;
      last_transaction: {
        transaction_type: string;
        success: boolean;
      };
    }>;
    metadata?: {
      orderId?: string;
      source?: string;
    };
  };
}

function getSupabaseClient() {
  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

  if (!supabaseUrl || !supabaseKey) {
    throw new Error('Supabase credentials não configuradas');
  }

  return createClient(supabaseUrl, supabaseKey);
}

async function validateSignature(
  payload: string,
  signature: string,
  secret: string,
): Promise<boolean> {
  try {
    const [algorithm, hash] = signature.split('=');

    if (algorithm !== 'sha1') {
      console.warn('Algoritmo de assinatura não suportado:', algorithm);
      return false;
    }

    const encoder = new TextEncoder();
    const key = await crypto.subtle.importKey(
      'raw',
      encoder.encode(secret),
      { name: 'HMAC', hash: 'SHA-1' },
      false,
      ['sign'],
    );

    const signatureData = await crypto.subtle.sign('HMAC', key, encoder.encode(payload));
    const expectedHash = Array.from(new Uint8Array(signatureData))
      .map((b) => b.toString(16).padStart(2, '0'))
      .join('');

    const isValid = expectedHash === hash;

    if (!isValid) {
      console.error('Hash não corresponde:', { expected: expectedHash, received: hash });
    }

    return isValid;
  } catch (error) {
    console.error('Erro ao validar assinatura:', error);
    return false;
  }
}

async function findPayment(
  supabase: ReturnType<typeof createClient>,
  event: PagarmeWebhookEvent,
) {
  const chargeId = event.type.startsWith('charge.') ? event.data.id : null;
  const pagarmeOrderId =
    event.type.startsWith('order.') ? event.data.id : event.data.metadata?.orderId ?? null;

  if (chargeId) {
    const { data } = await supabase
      .from('payments')
      .select('id')
      .eq('pagarme_charge_id', chargeId)
      .maybeSingle();

    if (data) return data;
  }

  if (pagarmeOrderId) {
    const { data: order } = await supabase
      .from('orders')
      .select('id, payment_id')
      .eq('pagarme_order_id', pagarmeOrderId)
      .maybeSingle();

    if (order?.payment_id) {
      const { data } = await supabase
        .from('payments')
        .select('id')
        .eq('id', order.payment_id)
        .maybeSingle();

      if (data) return data;
    }

    // Fallback: metadata.orderId may be our orders.id
    if (event.data.metadata?.orderId) {
      const { data: orderById } = await supabase
        .from('orders')
        .select('id, payment_id')
        .eq('id', event.data.metadata.orderId)
        .maybeSingle();

      if (orderById?.payment_id) {
        return { id: orderById.payment_id };
      }
    }
  }

  return null;
}

async function markPaymentPaid(
  supabase: ReturnType<typeof createClient>,
  paymentId: string,
) {
  const paidAt = new Date().toISOString();

  const { error: paymentError } = await supabase
    .from('payments')
    .update({ status: 'paid', paid_at: paidAt, is_active: true })
    .eq('id', paymentId);

  if (paymentError) throw paymentError;

  const { error: orderError } = await supabase
    .from('orders')
    .update({ payment_status: 'paid', status: 'processando' })
    .eq('payment_id', paymentId);

  if (orderError) throw orderError;
}

async function markPaymentFailed(
  supabase: ReturnType<typeof createClient>,
  paymentId: string,
) {
  const { error: paymentError } = await supabase
    .from('payments')
    .update({ status: 'failed', is_active: false })
    .eq('id', paymentId);

  if (paymentError) throw paymentError;

  const { error: orderError } = await supabase
    .from('orders')
    .update({ payment_status: 'failed' })
    .eq('payment_id', paymentId);

  if (orderError) throw orderError;
}

async function handlePaidEvent(event: PagarmeWebhookEvent) {
  const supabase = getSupabaseClient();

  const charges = event.data.charges ?? [];
  const hasPixCharge =
    event.type === 'charge.paid' ||
    charges.some((charge) => charge.last_transaction?.transaction_type === 'pix');

  if (!hasPixCharge) {
    console.warn('Evento pago ignorado — não é PIX');
    return;
  }

  const payment = await findPayment(supabase, event);
  if (!payment) {
    console.error('Pagamento não encontrado para evento:', event.type, event.data.id);
    return;
  }

  console.log('Pagamento confirmado:', {
    eventType: event.type,
    paymentId: payment.id,
    email: event.data.customer?.email,
  });

  await markPaymentPaid(supabase, payment.id);
}

async function handleFailedEvent(event: PagarmeWebhookEvent) {
  const supabase = getSupabaseClient();
  const payment = await findPayment(supabase, event);

  if (!payment) {
    console.error('Pagamento não encontrado para falha:', event.type, event.data.id);
    return;
  }

  console.log('Pagamento falhou:', {
    eventType: event.type,
    paymentId: payment.id,
  });

  await markPaymentFailed(supabase, payment.id);
}

async function handleRefundedEvent(event: PagarmeWebhookEvent) {
  const supabase = getSupabaseClient();
  const payment = await findPayment(supabase, event);

  if (!payment) {
    console.error('Pagamento não encontrado para reembolso:', event.type, event.data.id);
    return;
  }

  console.log('Reembolso processado — marcando como failed:', {
    eventType: event.type,
    paymentId: payment.id,
  });

  await markPaymentFailed(supabase, payment.id);
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
    console.log('Webhook Pagar.me recebido');

    const body = await req.text();
    const signature = req.headers.get('x-hub-signature') || '';
    const webhookSecret = Deno.env.get('PAGARME_WEBHOOK_SECRET');

    if (webhookSecret && signature) {
      const isValid = await validateSignature(body, signature, webhookSecret);
      if (!isValid) {
        console.error('Assinatura inválida');
        return new Response(JSON.stringify({ error: 'Invalid signature' }), {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }
    }

    const event: PagarmeWebhookEvent = JSON.parse(body);

    console.log('Evento recebido:', {
      type: event.type,
      id: event.id,
      dataId: event.data.id,
      status: event.data.status,
    });

    if (event.type === 'charge.paid' || event.type === 'order.paid') {
      await handlePaidEvent(event);
    } else if (event.type === 'charge.payment_failed') {
      await handleFailedEvent(event);
    } else if (event.type === 'charge.refunded') {
      await handleRefundedEvent(event);
    } else {
      console.log(`Evento ignorado: ${event.type}`);
    }

    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    console.error('Erro no webhook:', error);
    const errorMessage = error instanceof Error ? error.message : 'Erro desconhecido';

    return new Response(JSON.stringify({ error: errorMessage }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});

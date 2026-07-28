import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const PAGARME_API = 'https://api.pagar.me/core/v5';

interface SyncRequest {
  orderId: string;
}

async function fetchChargeStatus(chargeId: string, secretKey: string): Promise<string | null> {
  const auth = btoa(`${secretKey}:`);
  const response = await fetch(`${PAGARME_API}/charges/${chargeId}`, {
    headers: { Authorization: `Basic ${auth}` },
  });

  if (!response.ok) return null;

  const data = await response.json();
  return typeof data.status === 'string' ? data.status : null;
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
    const pagarmeSecretKey = Deno.env.get('PAGARME_SECRET_KEY');

    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error('Supabase credentials não configuradas');
    }

    const authHeader = req.headers.get('Authorization');
    const token = authHeader?.startsWith('Bearer ') ? authHeader.slice(7) : null;

    if (token !== supabaseServiceKey) {
      return new Response(JSON.stringify({ error: 'Não autorizado' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const { orderId }: SyncRequest = await req.json();
    if (!orderId) {
      return new Response(JSON.stringify({ error: 'orderId é obrigatório' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { data: order } = await supabase
      .from('orders')
      .select('status, payment_status, payment_id')
      .eq('id', orderId)
      .single();

    if (!order) {
      return new Response(JSON.stringify({ error: 'Pedido não encontrado' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    if (order.payment_status === 'paid') {
      let orderStatus = order.status;

      if (order.status === 'em_analise') {
        await supabase.from('orders').update({ status: 'processando' }).eq('id', orderId);
        orderStatus = 'processando';
      }

      return new Response(
        JSON.stringify({ paymentStatus: 'paid', orderStatus, synced: orderStatus !== order.status }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    let payment: Record<string, unknown> | null = null;
    if (order.payment_id) {
      const { data } = await supabase
        .from('payments')
        .select('*')
        .eq('id', order.payment_id)
        .maybeSingle();
      payment = data;
    }

    if (!payment || payment.status !== 'pending' || !payment.pagarme_charge_id) {
      return new Response(
        JSON.stringify({
          paymentStatus: order.payment_status,
          orderStatus: order.status,
          synced: false,
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const chargeId = payment.pagarme_charge_id as string;

    if (chargeId.startsWith('mock_')) {
      return new Response(
        JSON.stringify({
          paymentStatus: payment.status,
          orderStatus: order.status,
          synced: false,
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    if (!pagarmeSecretKey || pagarmeSecretKey.includes('...')) {
      return new Response(
        JSON.stringify({
          paymentStatus: payment.status,
          orderStatus: order.status,
          synced: false,
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const chargeStatus = await fetchChargeStatus(chargeId, pagarmeSecretKey);
    let paymentStatus = payment.status as string;

    if (chargeStatus === 'paid') {
      const paidAt = new Date().toISOString();
      await supabase
        .from('payments')
        .update({ status: 'paid', paid_at: paidAt, is_active: true })
        .eq('id', payment.id);
      await supabase
        .from('orders')
        .update({ payment_status: 'paid', status: 'processando' })
        .eq('payment_id', payment.id);
      paymentStatus = 'paid';
    } else if (chargeStatus === 'failed' || chargeStatus === 'canceled') {
      await supabase
        .from('payments')
        .update({ status: 'failed', is_active: false })
        .eq('id', payment.id);
      await supabase
        .from('orders')
        .update({ payment_status: 'failed' })
        .eq('payment_id', payment.id);
      paymentStatus = 'failed';
    }

    const { data: updatedOrder } = await supabase
      .from('orders')
      .select('status, payment_status')
      .eq('id', orderId)
      .single();

    return new Response(
      JSON.stringify({
        paymentStatus: updatedOrder?.payment_status ?? paymentStatus,
        orderStatus: updatedOrder?.status ?? order.status,
        synced: chargeStatus === 'paid' || chargeStatus === 'failed' || chargeStatus === 'canceled',
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (error) {
    console.error('sync-payment-status error:', error);
    const message = error instanceof Error ? error.message : 'Erro interno';

    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});

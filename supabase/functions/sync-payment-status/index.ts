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
      .select('status, payment_status')
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

    const { data: payment } = await supabase
      .from('payments')
      .select('*')
      .eq('order_id', orderId)
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle();

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

    if (payment.pagarme_charge_id.startsWith('mock_')) {
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

    const chargeStatus = await fetchChargeStatus(payment.pagarme_charge_id, pagarmeSecretKey);
    let paymentStatus = payment.status;

    if (chargeStatus === 'paid') {
      const paidAt = new Date().toISOString();
      await supabase.from('payments').update({ status: 'paid', paid_at: paidAt }).eq('id', payment.id);
      await supabase
        .from('orders')
        .update({ payment_status: 'paid', status: 'processando' })
        .eq('id', orderId);
      paymentStatus = 'paid';
    } else if (chargeStatus === 'failed' || chargeStatus === 'canceled') {
      await supabase.from('payments').update({ status: 'failed' }).eq('id', payment.id);
      await supabase.from('orders').update({ payment_status: 'failed' }).eq('id', orderId);
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

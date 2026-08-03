import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3';
import {
  PRODUCT_LIMIT_COLUMN,
  PRODUCT_SUGGESTED_TIER,
  countDistinctActiveCnpjsInPeriod,
  findActiveOrderForCnpj,
  isConsumableRcProduct,
  onlyDigits,
} from '../_shared/plan_limits.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

interface MarkOrderPaidRequest {
  orderId?: string;
  paymentId?: string;
}

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
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
    paymentId: row.payment_id ?? null,
    createdAt: isoTimestamp(row.created_at),
    updatedAt: row.updated_at ? isoTimestamp(row.updated_at) : null,
  };
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

    const admin = createClient(supabaseUrl, supabaseServiceKey);
    const {
      data: { user },
      error: userError,
    } = await admin.auth.getUser(jwt);

    if (userError || !user) {
      console.error('mark-order-paid getUser:', userError);
      return jsonResponse({ error: 'Sessão inválida' }, 401);
    }

    const body: MarkOrderPaidRequest = await req.json();
    const orderId = body.orderId?.trim();
    const paymentId = body.paymentId?.trim();

    if (!orderId) {
      return jsonResponse({ error: 'orderId é obrigatório' }, 400);
    }
    if (!paymentId) {
      return jsonResponse({ error: 'paymentId é obrigatório' }, 400);
    }

    const { data: order, error: orderError } = await admin
      .from('orders')
      .select('*')
      .eq('id', orderId)
      .eq('user_id', user.id)
      .maybeSingle();

    if (orderError) {
      console.error('mark-order-paid order:', orderError);
      return jsonResponse({ error: 'Erro ao carregar pedido' }, 500);
    }
    if (!order) {
      return jsonResponse({ error: 'Pedido não encontrado' }, 404);
    }

    if (order.payment_status === 'paid') {
      return jsonResponse(toApiOrder(order as Record<string, unknown>));
    }

    const { data: payment, error: paymentError } = await admin
      .from('payments')
      .select('id, profile_id, is_active, status, rc_product_id, plan_id, recurrence')
      .eq('id', paymentId)
      .maybeSingle();

    if (paymentError) {
      console.error('mark-order-paid payment:', paymentError);
      return jsonResponse({ error: 'Erro ao validar pagamento' }, 500);
    }
    if (!payment || payment.profile_id !== user.id) {
      return jsonResponse({ error: 'Pagamento inválido' }, 403);
    }

    const consumablePurchase = isConsumableRcProduct(
      typeof payment.rc_product_id === 'string' ? payment.rc_product_id : null,
      typeof payment.plan_id === 'string' ? payment.plan_id : null,
    ) || payment.recurrence === 'one_time';

    const { data: profile, error: profileError } = await admin
      .from('profiles')
      .select('id, plan_product_id')
      .eq('id', user.id)
      .maybeSingle();

    if (profileError || !profile) {
      console.error('mark-order-paid profile:', profileError);
      return jsonResponse({ error: 'Perfil não encontrado' }, 403);
    }

    const productId = String(order.product_id ?? '');
    const limitColumn = PRODUCT_LIMIT_COLUMN[productId];
    if (!limitColumn) {
      return jsonResponse({ error: 'Produto sem cota de plano' }, 400);
    }

    const orderCnpj = onlyDigits(String(order.cnpj ?? ''));
    const otherActive = await findActiveOrderForCnpj(
      admin,
      user.id,
      productId,
      orderCnpj,
      orderId,
    );
    if (otherActive) {
      return jsonResponse(
        {
          error: 'Já existe um pedido vigente para este CNPJ',
          code: 'ACTIVE_ORDER_EXISTS',
          order: toApiOrder(otherActive),
        },
        409,
      );
    }

    if (!consumablePurchase) {
      const planProductId =
        typeof profile.plan_product_id === 'string' &&
          profile.plan_product_id.trim()
          ? profile.plan_product_id.trim()
          : 'free';

      const { data: limits, error: limitsError } = await admin
        .from('plan_limits')
        .select('*')
        .eq('plan_product_id', planProductId)
        .maybeSingle();

      if (limitsError) {
        console.error('mark-order-paid limits:', limitsError);
        return jsonResponse({ error: 'Erro ao carregar limites do plano' }, 500);
      }

      if (!limits) {
        console.error(
          'mark-order-paid missing plan_limits for',
          planProductId,
        );
        return jsonResponse(
          {
            error: 'Limites do plano não configurados',
            code: 'PLAN_LIMITS_MISSING',
            planProductId,
          },
          500,
        );
      }

      const limit = Number(
        (limits as Record<string, unknown>)[limitColumn] ?? 0,
      );
      const periodMonths = Number(limits?.quota_period_months ?? 1);
      const { used, cnpjs } = await countDistinctActiveCnpjsInPeriod(
        admin,
        user.id,
        productId,
        periodMonths,
        orderId,
      );

      const wouldConsume = !cnpjs.has(orderCnpj);
      if (limit <= 0 || (wouldConsume && used >= limit)) {
        return jsonResponse(
          {
            error: 'Limite do plano atingido para este produto',
            code: 'PLAN_LIMIT_REACHED',
            planProductId,
            productId,
            limit,
            used,
            suggestedTier: PRODUCT_SUGGESTED_TIER[productId] ?? 2,
          },
          403,
        );
      }
    }

    const { data: updated, error: updateError } = await admin
      .from('orders')
      .update({
        payment_status: 'paid',
        payment_id: paymentId,
      })
      .eq('id', orderId)
      .eq('user_id', user.id)
      .select('*')
      .single();

    if (updateError || !updated) {
      console.error('mark-order-paid update:', updateError);
      return jsonResponse({ error: 'Erro ao confirmar pagamento' }, 500);
    }

    if (consumablePurchase) {
      const { error: deactivateError } = await admin
        .from('payments')
        .update({ is_active: false })
        .eq('id', paymentId)
        .eq('recurrence', 'one_time');
      if (deactivateError) {
        console.error('mark-order-paid deactivate consumable:', deactivateError);
      }
    }

    return jsonResponse(toApiOrder(updated as Record<string, unknown>));
  } catch (error) {
    console.error('mark-order-paid error:', error);
    return jsonResponse({ error: 'Erro interno ao confirmar pagamento' }, 500);
  }
});

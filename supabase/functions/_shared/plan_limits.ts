import { SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3';

export const ACTIVE_ORDER_STATUSES = [
  'em_analise',
  'processando',
  'concluido',
] as const;

/** Order product_id → plan_limits column. */
export const PRODUCT_LIMIT_COLUMN: Record<string, string> = {
  rest01: 'monthly_restricao_cnpj_limit',
  prot01: 'monthly_protesto_cnpj_limit',
  p01: 'monthly_cnd_package_cnpj_limit',
};

export const PRODUCT_SUGGESTED_TIER: Record<string, number> = {
  rest01: 2,
  prot01: 2,
  p01: 2,
};

/** RevenueCat one-shot packages that pay a single order without a plan upgrade. */
export const CONSUMABLE_RC_PRODUCT_IDS = new Set([
  'hub_pj_certidoes_app',
  'hub_pj_restricoes_app',
  'hub_pj_protestos_app',
  'hub_pj_app_certidoes',
]);

export function isConsumableRcProduct(
  rcProductId: string | null | undefined,
  planId: string | null | undefined,
): boolean {
  const candidates = [rcProductId, planId]
    .filter((v): v is string => typeof v === 'string' && v.trim().length > 0)
    .map((v) => v.trim());
  for (const id of candidates) {
    if (CONSUMABLE_RC_PRODUCT_IDS.has(id)) return true;
    const colon = id.indexOf(':');
    if (colon > 0 && CONSUMABLE_RC_PRODUCT_IDS.has(id.substring(0, colon))) {
      return true;
    }
  }
  return false;
}

export function onlyDigits(value: string): string {
  return value.replace(/\D/g, '');
}

export function periodStartIso(quotaPeriodMonths: number): string {
  const months = Math.max(1, Math.floor(quotaPeriodMonths) || 1);
  const d = new Date();
  d.setUTCMonth(d.getUTCMonth() - months);
  return d.toISOString();
}

export async function findActiveOrderForCnpj(
  admin: SupabaseClient,
  userId: string,
  productId: string,
  cnpjDigits: string,
  excludeOrderId?: string,
): Promise<Record<string, unknown> | null> {
  let query = admin
    .from('orders')
    .select('*')
    .eq('user_id', userId)
    .eq('product_id', productId)
    .in('status', [...ACTIVE_ORDER_STATUSES])
    .order('created_at', { ascending: false });

  if (excludeOrderId) {
    query = query.neq('id', excludeOrderId);
  }

  const { data, error } = await query;
  if (error) {
    console.error('findActiveOrderForCnpj:', error);
    throw new Error('Erro ao buscar pedido vigente');
  }

  for (const row of data ?? []) {
    if (onlyDigits(String(row.cnpj ?? '')) === cnpjDigits) {
      return row as Record<string, unknown>;
    }
  }
  return null;
}

function isConsumablePayment(payment: {
  recurrence?: unknown;
  rc_product_id?: unknown;
  plan_id?: unknown;
} | null | undefined): boolean {
  if (!payment) return false;
  if (payment.recurrence === 'one_time') return true;
  return isConsumableRcProduct(
    typeof payment.rc_product_id === 'string' ? payment.rc_product_id : null,
    typeof payment.plan_id === 'string' ? payment.plan_id : null,
  );
}

/**
 * Distinct active CNPJs that consume subscription quota.
 * Consumable-funded orders (one_time / RC consumable SKUs) do NOT count.
 * Unpaid pending orders still count (occupy a slot until cancelled/paid).
 */
export async function countDistinctActiveCnpjsInPeriod(
  admin: SupabaseClient,
  userId: string,
  productId: string,
  quotaPeriodMonths: number,
  excludeOrderId?: string,
): Promise<{ used: number; cnpjs: Set<string> }> {
  const periodStart = periodStartIso(quotaPeriodMonths);
  let query = admin
    .from('orders')
    .select(
      'id, cnpj, payment_id, payment_status, payments(recurrence, rc_product_id, plan_id)',
    )
    .eq('user_id', userId)
    .eq('product_id', productId)
    .in('status', [...ACTIVE_ORDER_STATUSES])
    .gte('created_at', periodStart);

  if (excludeOrderId) {
    query = query.neq('id', excludeOrderId);
  }

  const { data, error } = await query;
  if (error) {
    console.error('countDistinctActiveCnpjsInPeriod:', error);
    throw new Error('Erro ao contar uso do plano');
  }

  const cnpjs = new Set<string>();
  for (const row of data ?? []) {
    const paymentRaw = (row as Record<string, unknown>).payments;
    const payment = (Array.isArray(paymentRaw) ? paymentRaw[0] : paymentRaw) as
      | {
        recurrence?: unknown;
        rc_product_id?: unknown;
        plan_id?: unknown;
      }
      | null
      | undefined;
    if (isConsumablePayment(payment)) continue;

    const digits = onlyDigits(String(row.cnpj ?? ''));
    if (digits.length === 14) cnpjs.add(digits);
  }
  return { used: cnpjs.size, cnpjs };
}

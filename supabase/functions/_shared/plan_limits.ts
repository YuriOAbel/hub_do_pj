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
    .select('id, cnpj')
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
    const digits = onlyDigits(String(row.cnpj ?? ''));
    if (digits.length === 14) cnpjs.add(digits);
  }
  return { used: cnpjs.size, cnpjs };
}

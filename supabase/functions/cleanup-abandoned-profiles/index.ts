/**
 * Remove abandoned profiles (never finished onboarding).
 *
 * Manual weekly ops: POST with Bearer = SUPABASE_SERVICE_ROLE_KEY.
 *
 * Abandoned = active or already soft-deleted, AND:
 * - no name (null/blank)
 * - no onboarded_at
 * - plan_product_id = 'free'
 * - no payments row
 * - no orders row
 * - created_at older than min_age_hours (default 0 = all ages)
 *
 * Action: delete auth.users → profiles CASCADE (row some da tabela).
 *
 * Body (optional JSON):
 * { "dry_run": true, "min_age_hours": 0 }
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function asPositiveInt(value: unknown, fallback: number): number {
  if (typeof value === 'number' && Number.isFinite(value) && value >= 0) {
    return Math.floor(value);
  }
  if (typeof value === 'string' && value.trim() !== '') {
    const n = Number(value);
    if (Number.isFinite(n) && n >= 0) return Math.floor(n);
  }
  return fallback;
}

/** Accepts legacy service_role JWT or exact SERVICE_ROLE_KEY match. */
function isServiceRoleToken(token: string, serviceKey: string): boolean {
  if (token === serviceKey) return true;
  try {
    const parts = token.split('.');
    if (parts.length < 2) return false;
    const b64 = parts[1].replace(/-/g, '+').replace(/_/g, '/');
    const padded = b64 + '='.repeat((4 - (b64.length % 4)) % 4);
    const payload = JSON.parse(atob(padded));
    return payload?.role === 'service_role';
  } catch {
    return false;
  }
}

function isBlank(value: unknown): boolean {
  return typeof value !== 'string' || value.trim() === '';
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405);
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error('Supabase credentials not configured');
    }

    const authHeader = req.headers.get('Authorization');
    const token = authHeader?.startsWith('Bearer ')
      ? authHeader.slice(7).trim()
      : null;

    if (!token || !isServiceRoleToken(token, supabaseServiceKey)) {
      return jsonResponse({ error: 'Não autorizado' }, 401);
    }

    let dryRun = false;
    let minAgeHours = 0;
    try {
      const body = await req.json();
      if (body && typeof body === 'object') {
        dryRun = body.dry_run === true;
        minAgeHours = asPositiveInt(body.min_age_hours, 0);
      }
    } catch {
      // empty body OK
    }

    const cutoffIso = new Date(
      Date.now() - minAgeHours * 60 * 60 * 1000,
    ).toISOString();

    const admin = createClient(supabaseUrl, supabaseServiceKey);

    // All profiles that never onboarded (active + soft-deleted shells).
    const { data: rows, error: selectError } = await admin
      .from('profiles')
      .select('id, created_at, deleted_at, name, device_id, onboarded_at, plan_product_id')
      .is('onboarded_at', null)
      .eq('plan_product_id', 'free')
      .lt('created_at', cutoffIso);

    if (selectError) {
      console.error('cleanup-abandoned-profiles select:', selectError);
      return jsonResponse({ error: 'Erro ao listar profiles' }, 500);
    }

    const noName = (rows ?? []).filter((row) => isBlank(row.name));
    if (noName.length === 0) {
      return jsonResponse({
        ok: true,
        dry_run: dryRun,
        min_age_hours: minAgeHours,
        cutoff: cutoffIso,
        candidate_count: 0,
        deleted_count: 0,
        message: 'Nenhum abandono de onboarding encontrado',
      });
    }

    const ids = noName.map((row) => row.id as string);

    const [{ data: withPayments }, { data: withOrders }] = await Promise.all([
      admin.from('payments').select('profile_id').in('profile_id', ids),
      admin.from('orders').select('user_id').in('user_id', ids),
    ]);

    const keep = new Set<string>();
    for (const row of withPayments ?? []) {
      if (row.profile_id) keep.add(row.profile_id as string);
    }
    for (const row of withOrders ?? []) {
      if (row.user_id) keep.add(row.user_id as string);
    }

    const candidates = noName.filter((row) => !keep.has(row.id as string));
    const candidateIds = candidates.map((row) => row.id as string);
    const skippedProtected = ids.length - candidateIds.length;

    if (dryRun || candidateIds.length === 0) {
      return jsonResponse({
        ok: true,
        dry_run: dryRun,
        min_age_hours: minAgeHours,
        cutoff: cutoffIso,
        candidate_count: candidateIds.length,
        candidate_ids: candidateIds,
        skipped_protected: skippedProtected,
        deleted_count: 0,
        message: dryRun
          ? 'Dry run — nenhum profile removido'
          : 'Nenhum abandono elegível para remoção',
      });
    }

    const deletedIds: string[] = [];
    const errors: Array<{ id: string; error: string }> = [];

    // Sequential to avoid Auth admin rate limits.
    for (const id of candidateIds) {
      const { error: deleteError } = await admin.auth.admin.deleteUser(id);
      if (deleteError) {
        console.error('cleanup-abandoned-profiles deleteUser:', id, deleteError);
        errors.push({ id, error: deleteError.message });
        continue;
      }
      deletedIds.push(id);
    }

    return jsonResponse({
      ok: errors.length === 0,
      dry_run: false,
      min_age_hours: minAgeHours,
      cutoff: cutoffIso,
      candidate_count: candidateIds.length,
      deleted_count: deletedIds.length,
      deleted_ids: deletedIds,
      skipped_protected: skippedProtected,
      errors: errors.length > 0 ? errors : undefined,
    });
  } catch (e) {
    console.error('cleanup-abandoned-profiles:', e);
    return jsonResponse({ error: 'Internal error' }, 500);
  }
});

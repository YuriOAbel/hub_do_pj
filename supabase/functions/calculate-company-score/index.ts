import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

type Answers = Record<string, string>;

const ALLOWED: Record<string, readonly string[]> = {
  companyAge: ['lessThan1y', 'y1to3', 'y3to7', 'moreThan7y'],
  companySize: ['mei', 'micro', 'small', 'mediumLarge', 'unknown'],
  cnpjMonitorFrequency: ['weekly', 'monthly', 'whenNeeded', 'almostNever'],
  taxStatus: ['ok', 'okButLateLastYear', 'pendingOrInstallment', 'unknown'],
  cndLast6m: ['several', 'oneOrTwo', 'neededButNot', 'notNeededOrUnknown'],
  accounting: ['activeAccountant', 'accountantDelayed', 'selfMei', 'noControl'],
  protestStatus: ['none', 'hadCleared', 'active', 'neverChecked'],
  restrictionStatus: ['clean', 'hadCleared', 'active', 'neverChecked'],
  overdueDebt: ['none', 'installmentsOk', 'overdue', 'unknown'],
  scoreMotive: [
    'generalHealth',
    'biddingContract',
    'creditAccount',
    'leasePartner',
    'curiosity',
  ],
};

const POINTS: Record<string, Record<string, number>> = {
  companyAge: { lessThan1y: 2, y1to3: 4, y3to7: 6, moreThan7y: 8 },
  companySize: { mei: 3, micro: 4, small: 5, mediumLarge: 5, unknown: 1 },
  cnpjMonitorFrequency: {
    weekly: 5,
    monthly: 4,
    whenNeeded: 2,
    almostNever: 0,
  },
  taxStatus: {
    ok: 20,
    okButLateLastYear: 12,
    pendingOrInstallment: 5,
    unknown: 2,
  },
  cndLast6m: {
    several: 10,
    oneOrTwo: 7,
    neededButNot: 2,
    notNeededOrUnknown: 3,
  },
  accounting: {
    activeAccountant: 10,
    accountantDelayed: 5,
    selfMei: 4,
    noControl: 1,
  },
  protestStatus: { none: 15, hadCleared: 8, active: 0, neverChecked: 3 },
  restrictionStatus: { clean: 15, hadCleared: 8, active: 0, neverChecked: 3 },
  overdueDebt: { none: 12, installmentsOk: 7, overdue: 0, unknown: 3 },
};

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function onlyDigits(value: string): string {
  return value.replace(/\D/g, '');
}

function isoTimestamp(value: unknown): string {
  if (typeof value === 'string') return value;
  if (value instanceof Date) return value.toISOString();
  return new Date().toISOString();
}

function validateAnswers(raw: unknown): Answers | string {
  if (!raw || typeof raw !== 'object' || Array.isArray(raw)) {
    return 'answers é obrigatório';
  }
  const answers: Answers = {};
  for (const key of Object.keys(ALLOWED)) {
    const value = (raw as Record<string, unknown>)[key];
    if (typeof value !== 'string' || !ALLOWED[key].includes(value)) {
      return `Resposta inválida: ${key}`;
    }
    answers[key] = value;
  }
  return answers;
}

function computeScore(answers: Answers): {
  score: number;
  band: string;
  gaps: string[];
} {
  let total = 0;
  for (const [key, map] of Object.entries(POINTS)) {
    total += map[answers[key]] ?? 0;
  }
  const score = Math.max(0, Math.min(100, total));

  const gaps: string[] = [];
  if (
    answers.taxStatus === 'pendingOrInstallment' ||
    answers.taxStatus === 'unknown'
  ) {
    gaps.push('fiscal');
  }
  if (answers.cndLast6m === 'neededButNot') {
    gaps.push('cnd');
  }
  if (
    answers.protestStatus === 'active' ||
    answers.protestStatus === 'neverChecked'
  ) {
    gaps.push('protesto');
  }
  if (
    answers.restrictionStatus === 'active' ||
    answers.restrictionStatus === 'neverChecked'
  ) {
    gaps.push('restricao');
  }
  if (answers.overdueDebt === 'overdue' || answers.overdueDebt === 'unknown') {
    gaps.push('debt');
  }

  let band = 'critical';
  if (score >= 80) band = 'excellent';
  else if (score >= 60) band = 'good';
  else if (score >= 40) band = 'attention';

  return { score, band, gaps };
}

function toApiScore(row: Record<string, unknown>) {
  return {
    id: row.id,
    profileId: row.profile_id,
    cnpj: row.cnpj,
    companyName: row.company_name ?? null,
    answers: row.answers,
    score: row.score,
    band: row.band,
    gaps: row.gaps ?? [],
    createdAt: isoTimestamp(row.created_at),
  };
}

function monthStartSaoPauloIso(): string {
  const fmt = new Intl.DateTimeFormat('en-CA', {
    timeZone: 'America/Sao_Paulo',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
  const parts = fmt.formatToParts(new Date());
  const y = parts.find((p) => p.type === 'year')?.value ?? '1970';
  const m = parts.find((p) => p.type === 'month')?.value ?? '01';
  return `${y}-${m}-01`;
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
      console.error('calculate-company-score getUser:', userError);
      return jsonResponse({ error: 'Sessão inválida' }, 401);
    }

    const body = await req.json();
    const cnpjDigits = onlyDigits(
      typeof body.cnpj === 'string' ? body.cnpj : '',
    );
    if (cnpjDigits.length !== 14) {
      return jsonResponse({ error: 'CNPJ inválido' }, 400);
    }

    const validated = validateAnswers(body.answers);
    if (typeof validated === 'string') {
      return jsonResponse({ error: validated }, 400);
    }

    const companyName =
      typeof body.companyName === 'string' && body.companyName.trim()
        ? body.companyName.trim()
        : null;

    const { data: profile, error: profileError } = await admin
      .from('profiles')
      .select('id, device_id, plan_product_id')
      .eq('id', user.id)
      .maybeSingle();

    if (profileError) {
      console.error('calculate-company-score profile:', profileError);
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

    const scoreMonth = monthStartSaoPauloIso();
    const { data: existing, error: existingError } = await admin
      .from('company_scores')
      .select('*')
      .eq('profile_id', user.id)
      .eq('cnpj', cnpjDigits)
      .eq('score_month', scoreMonth)
      .maybeSingle();

    if (existingError) {
      console.error('calculate-company-score existing:', existingError);
      return jsonResponse({ error: 'Erro ao consultar score' }, 500);
    }

    if (existing) {
      return jsonResponse(toApiScore(existing as Record<string, unknown>));
    }

    // New CNPJ this month — enforce plan limit (same column as restrição).
    const planProductId =
      typeof profile.plan_product_id === 'string' &&
        profile.plan_product_id.trim()
        ? profile.plan_product_id.trim()
        : 'free';

    const { data: limits, error: limitsError } = await admin
      .from('plan_limits')
      .select('monthly_restricao_cnpj_limit, quota_period_months')
      .eq('plan_product_id', planProductId)
      .maybeSingle();

    if (limitsError) {
      console.error('calculate-company-score limits:', limitsError);
      return jsonResponse({ error: 'Erro ao carregar limites do plano' }, 500);
    }

    const limit = Number(limits?.monthly_restricao_cnpj_limit ?? 0);
    const periodMonths = Math.max(1, Number(limits?.quota_period_months ?? 1));
    const periodStart = new Date();
    periodStart.setUTCMonth(periodStart.getUTCMonth() - periodMonths);
    const periodStartIso = periodStart.toISOString();

    const { data: periodScores, error: monthError } = await admin
      .from('company_scores')
      .select('cnpj')
      .eq('profile_id', user.id)
      .gte('created_at', periodStartIso);

    if (monthError) {
      console.error('calculate-company-score period scores:', monthError);
      return jsonResponse({ error: 'Erro ao contar scores do período' }, 500);
    }

    const usedCnpjs = new Set(
      (periodScores ?? [])
        .map((row) => onlyDigits(String(row.cnpj ?? '')))
        .filter((d) => d.length === 14),
    );
    const alreadyScored = usedCnpjs.has(cnpjDigits);
    const used = usedCnpjs.size;

    if (!alreadyScored && (limit <= 0 || used >= limit)) {
      return jsonResponse(
        {
          error: 'Limite do plano atingido para score de empresas',
          code: 'PLAN_LIMIT_REACHED',
          planProductId,
          limit,
          used,
          suggestedTier: limit <= 0 ? 2 : 3,
        },
        403,
      );
    }

    const { score, band, gaps } = computeScore(validated);

    const { data: inserted, error: insertError } = await admin
      .from('company_scores')
      .insert({
        profile_id: user.id,
        cnpj: cnpjDigits,
        company_name: companyName,
        answers: validated,
        score,
        band,
        gaps,
      })
      .select('*')
      .single();

    if (insertError) {
      // Race: another insert won unique index — return that row.
      if (insertError.code === '23505') {
        const { data: raced } = await admin
          .from('company_scores')
          .select('*')
          .eq('profile_id', user.id)
          .eq('cnpj', cnpjDigits)
          .eq('score_month', scoreMonth)
          .maybeSingle();
        if (raced) {
          return jsonResponse(toApiScore(raced as Record<string, unknown>));
        }
      }
      console.error('calculate-company-score insert:', insertError);
      return jsonResponse({ error: 'Erro ao salvar score' }, 500);
    }

    return jsonResponse(toApiScore(inserted as Record<string, unknown>));
  } catch (err) {
    console.error('calculate-company-score:', err);
    return jsonResponse({ error: 'Erro interno' }, 500);
  }
});

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3';
import { isConsumableRcProduct } from '../_shared/plan_limits.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

const PROFILE_SELECT =
  'id, device_id, name, person_type, occupation, occupation_other, interest_ids, plan_product_id, phone, monthly_certificate_interest, onboarded_at, created_at, deleted_at';

type SyncPurpose = 'bootstrap' | 'onboarding' | 'update';

interface SyncProfileBody {
  purpose?: unknown;
  device_id?: unknown;
  name?: unknown;
  person_type?: unknown;
  occupation?: unknown;
  occupation_other?: unknown;
  interest_ids?: unknown;
  plan_product_id?: unknown;
  phone?: unknown;
  monthly_certificate_interest?: unknown;
}

type ProfileRow = {
  id: string;
  device_id: string | null;
  name: string | null;
  person_type: string | null;
  occupation: string | null;
  occupation_other: string | null;
  interest_ids: string[] | null;
  plan_product_id: string | null;
  phone: string | null;
  monthly_certificate_interest: boolean | null;
  onboarded_at: string | null;
  created_at: string | null;
  deleted_at: string | null;
};

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function asNonEmptyString(value: unknown): string | null {
  if (typeof value !== 'string') return null;
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

function asStringArray(value: unknown): string[] | null {
  if (!Array.isArray(value)) return null;
  const out: string[] = [];
  for (const item of value) {
    if (typeof item === 'string' && item.trim().length > 0) {
      out.push(item.trim());
    }
  }
  return out;
}

function parsePurpose(value: unknown): SyncPurpose {
  if (value === 'onboarding' || value === 'update' || value === 'bootstrap') {
    return value;
  }
  return 'bootstrap';
}

function unionInterestIds(
  current: string[] | null | undefined,
  incoming: string[],
): string[] {
  const set = new Set<string>();
  for (const id of current ?? []) {
    if (typeof id === 'string' && id.trim()) set.add(id.trim());
  }
  for (const id of incoming) {
    if (id.trim()) set.add(id.trim());
  }
  return [...set];
}

function deviceEmailForUser(userId: string): string {
  return `device_${userId.replace(/-/g, '')}@hubdopj.device`;
}

function isProfileOnboarded(row: ProfileRow): boolean {
  const name = asNonEmptyString(row.name);
  const personType = asNonEmptyString(row.person_type);
  const occupation = asNonEmptyString(row.occupation);
  const deviceId = asNonEmptyString(row.device_id);
  const interests = row.interest_ids ?? [];
  return !!(
    name &&
    personType &&
    occupation &&
    deviceId &&
    interests.length > 0
  );
}

function toApiProfile(row: ProfileRow) {
  return {
    id: row.id,
    deviceId: row.device_id,
    name: row.name,
    personType: row.person_type,
    occupation: row.occupation,
    occupationOther: row.occupation_other,
    interestIds: row.interest_ids ?? [],
    planProductId: row.plan_product_id,
    phone: row.phone,
    monthlyCertificateInterest: row.monthly_certificate_interest ?? false,
    onboardedAt: row.onboarded_at,
    onboarded: isProfileOnboarded(row),
    createdAt: row.created_at,
    deletedAt: row.deleted_at,
  };
}

async function ensureProfileRow(
  admin: SupabaseClient,
  userId: string,
): Promise<ProfileRow> {
  const { data: existing, error: selectError } = await admin
    .from('profiles')
    .select(PROFILE_SELECT)
    .eq('id', userId)
    .maybeSingle();

  if (selectError) {
    console.error('sync-profile ensure select:', selectError);
    throw new Error('Erro ao carregar profile');
  }

  if (existing) return existing as ProfileRow;

  const { error: insertError } = await admin.from('profiles').insert({
    id: userId,
  });

  if (insertError && insertError.code !== '23505') {
    console.error('sync-profile ensure insert:', insertError);
    throw new Error('Erro ao criar profile');
  }

  const { data: created, error: reloadError } = await admin
    .from('profiles')
    .select(PROFILE_SELECT)
    .eq('id', userId)
    .maybeSingle();

  if (reloadError || !created) {
    console.error('sync-profile ensure reload:', reloadError);
    throw new Error('Erro ao carregar profile');
  }

  return created as ProfileRow;
}

/** Build patch: never write null / empty over existing values. */
function buildCoalescePatch(
  target: ProfileRow,
  opts: {
    deviceId: string;
    purpose: SyncPurpose;
    incomingName: string | null;
    incomingPersonType: string | null;
    incomingOccupation: string | null;
    incomingOccupationOther: string | null;
    incomingPhone: string | null;
    incomingInterests: string[] | null;
    planToApply: string | null;
    incomingMonthly: boolean | undefined;
  },
): Record<string, unknown> {
  const patch: Record<string, unknown> = {
    device_id: opts.deviceId,
    deleted_at: null,
  };

  if (opts.incomingName) patch.name = opts.incomingName;
  if (opts.incomingPersonType) patch.person_type = opts.incomingPersonType;
  if (opts.incomingOccupation) patch.occupation = opts.incomingOccupation;
  if (opts.incomingOccupationOther) {
    patch.occupation_other = opts.incomingOccupationOther;
  }
  if (opts.incomingPhone) patch.phone = opts.incomingPhone;
  if (opts.planToApply) patch.plan_product_id = opts.planToApply;

  if (opts.incomingInterests && opts.incomingInterests.length > 0) {
    // Onboarding: persist exact selection. Update/bootstrap: union.
    patch.interest_ids = opts.purpose === 'onboarding'
      ? opts.incomingInterests
      : unionInterestIds(target.interest_ids, opts.incomingInterests);
  }

  if (opts.incomingMonthly !== undefined) {
    patch.monthly_certificate_interest = opts.incomingMonthly;
  }

  if (opts.purpose === 'onboarding') {
    patch.onboarded_at = target.onboarded_at ?? new Date().toISOString();
  }

  return patch;
}

async function mintSessionForUser(
  admin: SupabaseClient,
  userId: string,
): Promise<{ email: string; password: string } | null> {
  const email = deviceEmailForUser(userId);
  const password = `${crypto.randomUUID()}${crypto.randomUUID()}`;

  const { error: updateError } = await admin.auth.admin.updateUserById(userId, {
    email,
    password,
    email_confirm: true,
  });

  if (updateError) {
    console.error('sync-profile mintSession updateUser:', updateError);
    return null;
  }

  return { email, password };
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
    if (!authHeader?.startsWith('Bearer ')) {
      return jsonResponse({ error: 'Authentication required' }, 401);
    }

    const jwt = authHeader.slice(7).trim();
    if (!jwt) {
      return jsonResponse({ error: 'Authentication required' }, 401);
    }

    const admin = createClient(supabaseUrl, supabaseServiceKey);
    const {
      data: { user },
      error: userError,
    } = await admin.auth.getUser(jwt);

    if (userError || !user) {
      console.error('sync-profile getUser:', userError);
      return jsonResponse({ error: 'Invalid session' }, 401);
    }

    const jwtUserId = user.id;
    let body: SyncProfileBody = {};
    try {
      body = (await req.json()) as SyncProfileBody;
    } catch {
      return jsonResponse({ error: 'Invalid JSON body' }, 400);
    }

    const purpose = parsePurpose(body.purpose);
    const deviceId = asNonEmptyString(body.device_id);
    if (!deviceId) {
      return jsonResponse({ error: 'device_id is required' }, 400);
    }

    const incomingName = asNonEmptyString(body.name);
    const incomingPersonType = asNonEmptyString(body.person_type);
    const incomingOccupation = asNonEmptyString(body.occupation);
    const incomingOccupationOther = asNonEmptyString(body.occupation_other);
    const incomingPhone = asNonEmptyString(body.phone);
    const incomingInterests = asStringArray(body.interest_ids);
    const incomingPlan = asNonEmptyString(body.plan_product_id);

    let incomingMonthly: boolean | undefined;
    if (typeof body.monthly_certificate_interest === 'boolean') {
      incomingMonthly = body.monthly_certificate_interest;
    }

    if (purpose === 'onboarding') {
      if (!incomingName) {
        return jsonResponse({ error: 'name is required for onboarding' }, 400);
      }
      if (!incomingPersonType) {
        return jsonResponse(
          { error: 'person_type is required for onboarding' },
          400,
        );
      }
      if (!incomingOccupation) {
        return jsonResponse(
          { error: 'occupation is required for onboarding' },
          400,
        );
      }
      if (!incomingInterests || incomingInterests.length === 0) {
        return jsonResponse(
          { error: 'interest_ids is required for onboarding' },
          400,
        );
      }
      if (incomingOccupation === 'outra' && !incomingOccupationOther) {
        return jsonResponse(
          { error: 'occupation_other is required when occupation is outra' },
          400,
        );
      }
    }

    // Never accept blank strings as intentional clears for identity fields.
    if (body.name !== undefined && body.name !== null && !incomingName) {
      return jsonResponse({ error: 'name cannot be empty' }, 400);
    }
    if (
      body.person_type !== undefined &&
      body.person_type !== null &&
      !incomingPersonType
    ) {
      return jsonResponse({ error: 'person_type cannot be empty' }, 400);
    }
    if (
      body.occupation !== undefined &&
      body.occupation !== null &&
      !incomingOccupation
    ) {
      return jsonResponse({ error: 'occupation cannot be empty' }, 400);
    }

    if (incomingPlan && isConsumableRcProduct(incomingPlan, incomingPlan)) {
      console.warn(
        'sync-profile: refused consumable plan_product_id',
        incomingPlan,
      );
    }

    const planToApply =
      incomingPlan && !isConsumableRcProduct(incomingPlan, incomingPlan)
        ? incomingPlan
        : null;

    if (
      incomingPersonType &&
      incomingPersonType !== 'pf' &&
      incomingPersonType !== 'pj'
    ) {
      return jsonResponse({ error: 'person_type must be pf or pj' }, 400);
    }

    await ensureProfileRow(admin, jwtUserId);

    const { data: owners, error: ownersError } = await admin
      .from('profiles')
      .select(PROFILE_SELECT)
      .eq('device_id', deviceId)
      .is('deleted_at', null)
      .order('created_at', { ascending: true });

    if (ownersError) {
      console.error('sync-profile owners:', ownersError);
      return jsonResponse({ error: 'Erro ao buscar device_id' }, 500);
    }

    const ownerRows = (owners ?? []) as ProfileRow[];
    const otherOwners = ownerRows.filter((p) => p.id !== jwtUserId);
    const canonical = otherOwners[0] ?? null;

    const patchOpts = {
      deviceId,
      purpose,
      incomingName,
      incomingPersonType,
      incomingOccupation,
      incomingOccupationOther,
      incomingPhone,
      incomingInterests,
      planToApply,
      incomingMonthly,
    };

    if (canonical) {
      const patch = buildCoalescePatch(canonical, patchOpts);

      const clearIds = [
        jwtUserId,
        ...otherOwners.filter((p) => p.id !== canonical.id).map((p) => p.id),
      ];
      if (clearIds.length > 0) {
        const { error: clearError } = await admin
          .from('profiles')
          .update({ device_id: null, deleted_at: new Date().toISOString() })
          .in('id', clearIds);
        if (clearError) {
          console.error('sync-profile clear before reclaim:', clearError);
          return jsonResponse({ error: 'Erro ao reconciliar device_id' }, 500);
        }
      }

      const { data: updated, error: updateError } = await admin
        .from('profiles')
        .update(patch)
        .eq('id', canonical.id)
        .select(PROFILE_SELECT)
        .maybeSingle();

      if (updateError || !updated) {
        console.error('sync-profile reclaim update:', updateError);
        return jsonResponse({ error: 'Erro ao atualizar profile' }, 500);
      }

      const updatedRow = updated as ProfileRow;
      if (purpose === 'onboarding' && !isProfileOnboarded(updatedRow)) {
        return jsonResponse(
          { error: 'Onboarding sync incomplete — required fields missing' },
          500,
        );
      }

      const session = await mintSessionForUser(admin, canonical.id);
      if (!session) {
        return jsonResponse(
          { error: 'Erro ao reabrir sessão do profile existente' },
          500,
        );
      }

      return jsonResponse({
        profile: toApiProfile(updatedRow),
        onboarded: isProfileOnboarded(updatedRow),
        reclaimed: true,
        session: {
          email: session.email,
          password: session.password,
          type: 'password',
        },
      });
    }

    const jwtProfile = await ensureProfileRow(admin, jwtUserId);
    const patch = buildCoalescePatch(jwtProfile, patchOpts);

    const { data: updated, error: updateError } = await admin
      .from('profiles')
      .update(patch)
      .eq('id', jwtUserId)
      .select(PROFILE_SELECT)
      .maybeSingle();

    if (updateError || !updated) {
      console.error('sync-profile update:', updateError);
      return jsonResponse({ error: 'Erro ao atualizar profile' }, 500);
    }

    const updatedRow = updated as ProfileRow;
    if (purpose === 'onboarding' && !isProfileOnboarded(updatedRow)) {
      return jsonResponse(
        { error: 'Onboarding sync incomplete — required fields missing' },
        500,
      );
    }

    return jsonResponse({
      profile: toApiProfile(updatedRow),
      onboarded: isProfileOnboarded(updatedRow),
      reclaimed: false,
    });
  } catch (e) {
    console.error('sync-profile:', e);
    return jsonResponse(
      { error: e instanceof Error ? e.message : 'Internal error' },
      500,
    );
  }
});

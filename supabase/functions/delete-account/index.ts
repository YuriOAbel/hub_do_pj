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

const ANON_EMAIL = 'deleted@deleted.local';
const ANON_COMPANY = '[deleted]';
const ANON_CNPJ = '00000000000000';
const ANON_ADDRESS = {
  cep: '00000-000',
  logradouro: '[deleted]',
  numero: '0',
  complemento: null,
  bairro: '[deleted]',
  cidade: '[deleted]',
  uf: 'XX',
  telefone: null,
};

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
      console.error('delete-account getUser:', userError);
      return jsonResponse({ error: 'Invalid session' }, 401);
    }

    const userId = user.id;

    const { error: ordersError } = await admin
      .from('orders')
      .update({
        guest_email: ANON_EMAIL,
        guest_phone: null,
        company_name: ANON_COMPANY,
        cnpj: ANON_CNPJ,
        address: ANON_ADDRESS,
      })
      .eq('user_id', userId);

    if (ordersError) {
      console.error('delete-account anonymize orders:', ordersError);
      return jsonResponse({ error: 'Failed to anonymize orders' }, 500);
    }

    const { error: deleteError } = await admin.auth.admin.deleteUser(userId);
    if (deleteError) {
      console.error('delete-account deleteUser:', deleteError);
      return jsonResponse({ error: 'Failed to delete account' }, 500);
    }

    return jsonResponse({ ok: true });
  } catch (e) {
    console.error('delete-account:', e);
    return jsonResponse({ error: 'Internal error' }, 500);
  }
});

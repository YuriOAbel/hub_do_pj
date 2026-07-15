/**
 * Supabase Edge Function — Envio em massa via template Resend
 *
 * Deploy:
 *   supabase functions deploy send-marketing-emails
 *
 * Secrets (supabase secrets set):
 *   RESEND_API_KEY
 *   RESEND_FROM_EMAIL   — ex: "Certidões PJ <contato@certidoespj.com.br>"
 *
 * Secrets opcionais:
 *   CONTACTS_JSON_PATH  — default: "contacts.json"
 *
 * Storage (fixo no código):
 *   bucket: "marketing"
 *   arquivo: contacts.json (ou path da secret acima)
 *
 * Estrutura esperada do JSON:
 *   {
 *     "template": "sell_certidoes_pj",
 *     "contacts": [
 *       { "n": 1, "nome": "...", "email": "...", "whats": "..." }
 *     ]
 *   }
 *
 * Variável Resend enviada: NOME_EMPRESA
 */

import { serve } from "https://deno.land/std/http/server.ts";
import { Resend } from "npm:resend@3.2.0";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.42.0";

// =========================================================================
// ENV VARS
// =========================================================================
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const RESEND_FROM_EMAIL =
  Deno.env.get("RESEND_FROM_EMAIL") ?? "Certidões PJ <contato@certidoespj.com.br>";

/** Bucket fixo no código (não usa secret). */
const CONTACTS_BUCKET = "marketing";

/** Path no Storage — default genérico: contacts.json */
const CONTACTS_JSON_PATH = Deno.env.get("CONTACTS_JSON_PATH") ?? "contacts.json";

// Instances
const resend = new Resend(RESEND_API_KEY);
const supabase = createClient(SUPABASE_URL!, SERVICE_KEY!);

// =========================================================================
// Types
// =========================================================================
interface Contato {
  n: number;
  nome: string;
  email: string;
  whats: string;
}

interface ContactsPayload {
  template: string;
  contacts: Contato[];
}

interface SendResult {
  n: number;
  nome: string;
  email: string;
  status: "sent" | "skipped" | "error";
  resendId?: string | null;
  error?: string;
}

interface RequestBody {
  /** Envia apenas para estes números (campo `n` do JSON). Omitir = todos. */
  only?: number[];
  /** Limite máximo de envios nesta execução (útil para testes). */
  limit?: number;
  /** Se true, simula sem chamar a API do Resend. */
  dry_run?: boolean;
  /** Intervalo em ms entre cada envio (default: 600). */
  delay_ms?: number;
}

// =========================================================================
// Helpers
// =========================================================================
function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

/**
 * Valida a estrutura do JSON antes de qualquer envio.
 * Esperado: { template: string, contacts: [{ n, nome, email, whats }, ...] }
 */
function validateContactsPayload(parsed: unknown): ContactsPayload {
  if (parsed === null || typeof parsed !== "object" || Array.isArray(parsed)) {
    const msg =
      'JSON inválido: esperado um objeto { "template": string, "contacts": [...] }.';
    console.error("❌ VALIDAÇÃO JSON:", msg);
    throw new Error(msg);
  }

  const root = parsed as Record<string, unknown>;
  const errors: string[] = [];

  if (typeof root.template !== "string" || !root.template.trim()) {
    errors.push('campo raiz "template" ausente ou vazio (string obrigatória)');
  }

  if (!Array.isArray(root.contacts)) {
    errors.push('campo raiz "contacts" ausente ou não é um array');
  } else if (root.contacts.length === 0) {
    errors.push('campo "contacts" está vazio — nenhum contato para enviar');
  } else {
    for (let i = 0; i < root.contacts.length; i++) {
      const item = root.contacts[i];
      const idx = i + 1;

      if (item === null || typeof item !== "object" || Array.isArray(item)) {
        errors.push(`contacts[${idx}] não é um objeto`);
        continue;
      }

      const row = item as Record<string, unknown>;

      if (typeof row.n !== "number" || !Number.isFinite(row.n)) {
        errors.push(`contacts[${idx}] campo "n" ausente ou não é number`);
      }
      if (typeof row.nome !== "string" || !row.nome.trim()) {
        errors.push(`contacts[${idx}] campo "nome" ausente ou vazio`);
      }
      if (typeof row.email !== "string" || !row.email.trim()) {
        errors.push(`contacts[${idx}] campo "email" ausente ou vazio`);
      }
      if (typeof row.whats !== "string") {
        errors.push(`contacts[${idx}] campo "whats" ausente ou não é string`);
      }
    }
  }

  if (errors.length > 0) {
    const preview = errors.slice(0, 20).join("; ");
    const extra = errors.length > 20 ? ` (+${errors.length - 20} outros)` : "";
    const msg =
      `JSON com estrutura inválida (${errors.length} erro(s)). ` +
      `Formato: { "template": "alias_resend", "contacts": [{ "n", "nome", "email", "whats" }] }. ` +
      `Detalhes: ${preview}${extra}`;
    console.error("❌ VALIDAÇÃO JSON:", msg);
    for (const e of errors.slice(0, 50)) {
      console.error("   •", e);
    }
    throw new Error(msg);
  }

  const template = (root.template as string).trim();
  const contacts = root.contacts as Contato[];

  console.log(
    `✅ VALIDAÇÃO JSON OK: template="${template}", ${contacts.length} contatos com { n, nome, email, whats }`,
  );

  return { template, contacts };
}

async function fetchContactsPayload(): Promise<ContactsPayload> {
  console.log(
    `📂 Carregando contatos: bucket="${CONTACTS_BUCKET}" path="${CONTACTS_JSON_PATH}"`,
  );

  const { data, error } = await supabase.storage
    .from(CONTACTS_BUCKET)
    .download(CONTACTS_JSON_PATH);

  if (error || !data) {
    const msg =
      `Falha ao baixar JSON (${CONTACTS_BUCKET}/${CONTACTS_JSON_PATH}): ${error?.message ?? "arquivo não encontrado"}`;
    console.error("❌", msg);
    throw new Error(msg);
  }

  let parsed: unknown;
  try {
    const text = await data.text();
    parsed = JSON.parse(text);
  } catch (err: any) {
    const msg = `JSON malformado (não é JSON válido): ${err?.message || err}`;
    console.error("❌ VALIDAÇÃO JSON:", msg);
    throw new Error(msg);
  }

  return validateContactsPayload(parsed);
}

// =========================================================================
// Envio via Resend (template do JSON)
// =========================================================================
async function sendViaResend(
  email: string,
  nomeEmpresa: string,
  templateId: string,
) {
  const resendResult = await resend.emails.send({
    from: RESEND_FROM_EMAIL,
    to: email,
    template: {
      id: templateId,
      variables: {
        NOME_EMPRESA: nomeEmpresa,
      },
    },
  });

  if (resendResult.error) {
    throw new Error(resendResult.error.message);
  }

  return { id: resendResult.data?.id ?? null };
}

// =========================================================================
// EDGE FUNCTION
// =========================================================================
serve(async (req) => {
  try {
    if (req.method === "OPTIONS") {
      return new Response("ok", {
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Headers":
            "authorization, x-client-info, apikey, content-type",
        },
      });
    }

    if (req.method !== "POST") {
      return new Response(JSON.stringify({ error: "Método não permitido" }), {
        status: 405,
      });
    }

    if (!RESEND_API_KEY) {
      return new Response(
        JSON.stringify({ error: "Secret RESEND_API_KEY não configurada." }),
        { status: 500 },
      );
    }

    const body: RequestBody | null = await req.json().catch(() => null);

    if (body === null) {
      return new Response(JSON.stringify({ error: "JSON inválido" }), {
        status: 400,
      });
    }

    const dryRun = body.dry_run ?? false;
    const delayMs = body.delay_ms ?? 600;
    const limit = body.limit;
    const onlySet = body.only ? new Set(body.only) : null;

    console.log("📨 Iniciando envio em massa:", {
      dry_run: dryRun,
      limit,
      only: body.only ?? "all",
      bucket: CONTACTS_BUCKET,
      path: CONTACTS_JSON_PATH,
    });

    // Carrega + valida estrutura (template + contacts) — aborta se inválido
    const payload = await fetchContactsPayload();
    const templateId = payload.template;
    const allContacts = payload.contacts;

    console.log(
      `📋 Template Resend: "${templateId}" | Contatos válidos: ${allContacts.length}`,
    );

    let contacts = allContacts.filter((c) => {
      if (!c.email || !isValidEmail(c.email)) return false;
      if (onlySet && !onlySet.has(c.n)) return false;
      return true;
    });

    if (limit && limit > 0) {
      contacts = contacts.slice(0, limit);
    }

    const results: SendResult[] = [];
    let sent = 0;
    let skipped = 0;
    let errors = 0;

    for (const contato of contacts) {
      if (!contato.nome?.trim()) {
        results.push({
          n: contato.n,
          nome: contato.nome,
          email: contato.email,
          status: "skipped",
          error: "Nome da empresa vazio",
        });
        skipped++;
        continue;
      }

      if (dryRun) {
        console.log(
          `[dry_run] template=${templateId} | ${contato.n} → ${contato.email} (${contato.nome})`,
        );
        results.push({
          n: contato.n,
          nome: contato.nome,
          email: contato.email,
          status: "sent",
          resendId: "dry_run",
        });
        sent++;
        continue;
      }

      try {
        const { id } = await sendViaResend(
          contato.email,
          contato.nome,
          templateId,
        );
        console.log(
          `✅ Enviado [${templateId}] ${contato.n} → ${contato.email}`,
          id,
        );
        results.push({
          n: contato.n,
          nome: contato.nome,
          email: contato.email,
          status: "sent",
          resendId: id,
        });
        sent++;

        if (delayMs > 0) await sleep(delayMs);
      } catch (err: any) {
        const message = err?.message || "Erro desconhecido";
        console.error(`❌ Erro ${contato.n} → ${contato.email}:`, message);
        results.push({
          n: contato.n,
          nome: contato.nome,
          email: contato.email,
          status: "error",
          error: message,
        });
        errors++;
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        dry_run: dryRun,
        template: templateId,
        bucket: CONTACTS_BUCKET,
        path: CONTACTS_JSON_PATH,
        total_in_json: allContacts.length,
        processed: contacts.length,
        sent,
        skipped,
        errors,
        results,
      }),
      { status: 200 },
    );
  } catch (err: any) {
    console.error("❌ ERRO GERAL NA FUNCTION send-marketing-emails:", err);
    return new Response(
      JSON.stringify({
        error: err?.message || "Erro desconhecido",
      }),
      { status: 500 },
    );
  }
});

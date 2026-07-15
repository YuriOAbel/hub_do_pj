# Skill: Supabase (Certidões PJ)

Patterns for Edge Functions, Storage, and the Certidões PJ database. This repo is the **deploy anchor** for project `certidoes` (`kpkctuuzhbnqudemeudh`). See `docs/SUPABASE.md`.

---

## Key Files

| File | Role |
|---|---|
| `supabase/config.toml` | CLI config; `project_id`; `pagarme-webhook` has `verify_jwt = false` |
| `supabase/functions/create-order/index.ts` | Create order for authenticated user (requires `profiles.device_id`) |
| `supabase/functions/create-pix-order/index.ts` | Create/reuse Pagar.me PIX charge for an order |
| `supabase/functions/pagarme-webhook/index.ts` | Pagar.me webhook → update `payments` + `orders` |
| `supabase/functions/sync-payment-status/index.ts` | Poll charge status (webhook lag fallback) |
| `supabase/functions/send-marketing-emails/index.ts` | Bulk Resend sends from Storage `marketing` |
| `supabase/migrations/*.sql` | Schema history (already applied remotely) |

---

## Payment flow

```
Flutter app (anonymous Supabase Auth + profiles.device_id)
  ↓ POST create-order { productId, cnpj, companyName, guestEmail, address, guestPhone? }
     Authorization: Bearer <user JWT>
[create-order]
  1. Resolve user from JWT
  2. Require profiles.device_id for that user
  3. Insert orders.user_id = user.id (service role); return camelCase order
  ↓ (optional payment)
  POST create-pix-order { orderId, guestEmail? }
[create-pix-order]
  1. Load order via service role
  2. Reuse open PIX charge if still valid, else create Pagar.me order/charge
  3. Persist payment row; return QR / copy-paste / expiresAt
  ↓
Pagar.me → POST pagarme-webhook (no JWT; HMAC x-hub-signature)
  → payments status + orders status (paid → processando via trigger)
  ↓
Optional: sync-payment-status (service-role Bearer) if webhook delayed

Order list: Flutter → PostgREST orders where user_id = auth.uid() (all product kinds)
```

`APP_DEV_MODE=true` secret → PIX amount R$0,01 in `create-pix-order`. Missing `PAGARME_SECRET_KEY` → mock PIX response (local/dev).

---

## Naming (English — non-negotiable)

All schema and Edge identifiers must be **English** `snake_case`:

- Tables, columns, indexes, enums, functions, triggers, RLS policy names
- Edge Function directory/export names (e.g. `create-pix-order`, `pagarme-webhook`)

UI copy and seed **labels** may be Portuguese. Catalog/seed **ids** may mirror app enum names (e.g. `consultarCnpj`).

Do not introduce Portuguese identifiers for new tables, columns, or functions.

---

## Auth patterns

### Non-negotiable

- Never update/delete other users' data from untrusted body fields alone.
- Prefer service-role inside Edge Functions for privileged writes; resolve order/payment from DB, not client-forged status.

### App / proxy-facing (JWT or caller auth)

- `create-order`, `create-pix-order`, `sync-payment-status`: deploy with default JWT verification unless product requires otherwise.
- `create-order`: never trust `user_id` from the body — always set from JWT; reject when profile has no `device_id`.
- `sync-payment-status`: expect service-role Bearer for privileged poll.

### Webhook (no Supabase JWT)

- `pagarme-webhook`: `verify_jwt = false` in `config.toml`.
- Authenticate with `PAGARME_WEBHOOK_SECRET` + `x-hub-signature` (HMAC SHA1).
- Resolve `orderId` from metadata / charge linkage in DB — never trust unpaid status updates blindly.

Deploy:

```bash
supabase functions deploy pagarme-webhook
```

(`verify_jwt` comes from config; do not assume `--no-verify-jwt` is required if config is set.)

---

## Domain tables (public)

Core entities from initial + follow-up migrations:

- `profiles` — user profile (`device_id`, `name`, `person_type`, `occupation`, `interest_ids`, phone, monthly certificate interest)
- `interests` — onboarding interest catalog (seeded ids match app enums)
- `products` — certificate catalog SKUs / prices
- `orders` — certificate requests (`guest_phone`, `selected_product_ids`, `total_cents`, status)
- `order_documents` — issued docs linkage
- `payments` — Pagar.me charge ids / status (`pagarme_charge_id` indexed)
- Storage bucket `certificates` (private) + policy for download
- Storage bucket `marketing` — contacts JSON for `send-marketing-emails`

Trigger: payment paid → order `status = processando`.

---

## Marketing emails

- Bucket: `marketing`
- File: `contacts.json` (or `CONTACTS_JSON_PATH`)
- Secrets: `RESEND_API_KEY`, optional `RESEND_FROM_EMAIL`
- Template variable: `NOME_EMPRESA`

---

## Environment variables

| Var | Used by |
|---|---|
| `SUPABASE_URL` | all functions (runtime) |
| `SUPABASE_SERVICE_ROLE_KEY` | all functions (runtime) |
| `PAGARME_SECRET_KEY` | create-pix-order, sync-payment-status |
| `PAGARME_WEBHOOK_SECRET` | pagarme-webhook |
| `PAGARME_FALLBACK_PHONE` | create-pix-order (optional) |
| `APP_DEV_MODE` | create-pix-order (optional; R$0,01 PIX) |
| `RESEND_API_KEY` | send-marketing-emails |
| `RESEND_FROM_EMAIL` | send-marketing-emails (optional) |
| `CONTACTS_JSON_PATH` | send-marketing-emails (optional) |

---

## Deploy commands

```bash
supabase link --project-ref kpkctuuzhbnqudemeudh

supabase functions deploy create-order
supabase functions deploy create-pix-order
supabase functions deploy pagarme-webhook
supabase functions deploy sync-payment-status
supabase functions deploy send-marketing-emails

supabase secrets set KEY=value
```

Migrations: additive DDL only; follow `.cursor/skills/supabase-migrations/SKILL.md`. Do not rewrite already-applied production migrations. Do not blind `db push`.

---

## Flutter note

Hub do PJ Flutter uses anonymous Supabase Auth (no Turnstile for now) on splash, syncs `profiles.device_id` under RLS, creates orders via `create-order` Edge Function (JWT), and lists orders via PostgREST under RLS (`user_id = auth.uid()`).

Dart-defines: `SUPABASE_URL`, `SUPABASE_ANON_KEY`. Dashboard: enable Anonymous sign-ins; captcha off for anon until Turnstile lands.

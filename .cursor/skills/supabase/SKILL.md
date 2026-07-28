# Skill: Supabase (Certidões PJ)

Patterns for Edge Functions, Storage, and the Certidões PJ database. This repo is the **deploy anchor** for project `certidoes` (`kpkctuuzhbnqudemeudh`). See `docs/SUPABASE.md`.

**Plan quotas / emission limits:** always read [`docs/PLAN_LIMITS.md`](../../../docs/PLAN_LIMITS.md) before changing `plan_limits`, order counting, or score quotas.

---

## Key Files

| File | Role |
|---|---|
| `docs/PLAN_LIMITS.md` | Business rules for plan quotas (status vigentes, rolling window) |
| `supabase/functions/_shared/plan_limits.ts` | Shared Edge helpers (active status + period count) |
| `supabase/config.toml` | CLI config; `project_id`; `pagarme-webhook` has `verify_jwt = false` |
| `supabase/functions/create-order/index.ts` | Create order (+ duplicate / quota checks) |
| `supabase/functions/create-pix-order/index.ts` | Create/reuse Pagar.me PIX; insert `payments` + set `orders.payment_id` |
| `supabase/functions/pagarme-webhook/index.ts` | Pagar.me webhook → update `payments` + linked `orders` |
| `supabase/functions/mark-order-paid/index.ts` | Confirm premium order paid + enforce `plan_limits` quotas |
| `supabase/functions/sync-payment-status/index.ts` | Poll charge status via `orders.payment_id` |
| `lib/services/payments_service.dart` | Flutter upsert of RevenueCat rows into `payments` |
| `supabase/functions/send-marketing-emails/index.ts` | Bulk Resend sends from Storage `marketing` |
| `supabase/migrations/*.sql` | Schema history (already applied remotely) |

---

## Payment flow

Two payment tracks share the same `payments` table (1 payment → N orders via `orders.payment_id`):

### A) RevenueCat (Flutter app — primary)

```
Flutter purchase/restore (RevenueCat)
  → PaymentsService.upsertRevenueCatPayment
     inserts/updates payments (provider=revenuecat, rc_id, recurrence, is_active, platform)
  → markOrderPaid sets orders.payment_status=paid + orders.payment_id
```

### B) PIX / Pagar.me (legacy / web)

```
Flutter/web → POST create-order { ... }
  → POST create-pix-order { orderId }
[create-pix-order]
  1. Load order; require order.user_id
  2. Reuse open PIX via orders.payment_id if still valid
  3. Else insert payments (provider=pagarme_pix, profile_id, one_time) + set orders.payment_id
  ↓
Pagar.me → POST pagarme-webhook
  → payments status + all orders with that payment_id
  ↓
Optional: sync-payment-status (service-role Bearer)
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

- `profiles` — user profile (`device_id`, `name`, `person_type`, `occupation`, `interest_ids`, `plan_product_id` default `free`, phone, monthly certificate interest)
- `interests` — onboarding interest catalog (seeded ids match app enums)
- `products` — certificate catalog SKUs / prices
- `orders` — certificate requests (`guest_phone`, `selected_product_ids`, `total_cents`, `payment_id` → payments, status)
- `order_documents` — issued docs linkage
- `payments` — profile-linked payment/subscription mirror:
  - `profile_id` → profiles (nullable for legacy PIX orphans)
  - `provider` (`pagarme_pix` | `revenuecat`), `platform` (`ios` | `android` | `web`)
  - `recurrence` (`one_time` | `monthly` | `annual`), `is_active`
  - RC: `rc_id`, `rc_entitlement_id`, `rc_product_id`, `rc_transaction_id`, `plan_id`, `current_period_end`
  - PIX legacy: `pagarme_charge_id`, `pix_qr_code`, `pix_copy_paste`, `expires_at`
  - Relationship: **1 payment → N orders** via `orders.payment_id` (no `payments.order_id`)
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

### Edge Functions — deploy after every change (non-negotiable)

Whenever you **create** or **modify** any file under `supabase/functions/**`, you **must deploy** that function to the remote project before considering the task done. Do not leave function changes local-only.

```bash
supabase link --project-ref kpkctuuzhbnqudemeudh
supabase functions deploy <function-name>
```

Examples:

```bash
supabase functions deploy create-order
supabase functions deploy create-pix-order
supabase functions deploy pagarme-webhook
supabase functions deploy sync-payment-status
supabase functions deploy send-marketing-emails
supabase functions deploy calculate-company-score
```

If several functions changed in the same task, deploy each one. Prefer CLI deploy with `--project-ref kpkctuuzhbnqudemeudh` when link state is uncertain. Confirm success in the command output before finishing.

```bash
supabase secrets set KEY=value
```

Migrations: additive DDL only; follow `.cursor/skills/supabase-migrations/SKILL.md`. Do not rewrite already-applied production migrations. Do not blind `db push`. When migration history local/remote diverge, apply the specific SQL via MCP `apply_migration` (or equivalent) and verify indexes/tables — do not skip shipping the schema change.

---

## Flutter note

Hub do PJ Flutter uses anonymous Supabase Auth (no Turnstile for now) on splash, syncs `profiles.device_id` under RLS, creates orders via `create-order` Edge Function (JWT), and lists orders via PostgREST under RLS (`user_id = auth.uid()`).

After RevenueCat purchase/restore, `PaymentsService.syncUserPlan` upserts `payments`, sets `profiles.plan_product_id` to the store product id (or `free`), and `PremiumStatus` provider exposes `UserPlanState` (tier / product / isPremium).

Dart-defines: `SUPABASE_URL`, `SUPABASE_ANON_KEY`. Dashboard: enable Anonymous sign-ins; captcha off for anon until Turnstile lands.

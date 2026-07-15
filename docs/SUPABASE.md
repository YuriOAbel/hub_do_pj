# Supabase — Certidões PJ (âncora)

Este repositório é a **fonte da verdade** para o backend Supabase do Certidões PJ. Edits, deploys de Edge Functions e novas migrations devem sair daqui — não do projeto web `certidoesPJ`.

| Campo | Valor |
|---|---|
| Nome | `certidoes` |
| Project ref | `kpkctuuzhbnqudemeudh` |
| URL | `https://kpkctuuzhbnqudemeudh.supabase.co` |

## Link local

```bash
supabase link --project-ref kpkctuuzhbnqudemeudh
```

`supabase/config.toml` já define `project_id = "kpkctuuzhbnqudemeudh"`.

## Flutter — Auth anônima + CND

O app autentica no splash via `SupabaseAuthService` (`signInAnonymously`, sem Turnstile por enquanto). Session em SharedPreferences + Keychain. Após sessão, grava `profiles.device_id`. Onboarding sincroniza `name`, `person_type`, `occupation`, `occupation_other`, `interest_ids`.

Pedidos CND/protesto/restrição são criados neste projeto via Edge Function `create-order` (JWT obrigatório). O pedido só é aceito se `profiles.device_id` estiver preenchido para o user autenticado. Listagem no app: PostgREST `orders` filtrado por `user_id = auth.uid()` (qualquer `product_id`).

### Dart-defines

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://kpkctuuzhbnqudemeudh.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key \
  --dart-define=RC_API_KEY=your_key
```

`SUPABASE_URL` tem default no código; `SUPABASE_ANON_KEY` é obrigatório (sem ela, auth é skip).

### Dashboard (pré-requisito)

1. Authentication → Providers → **Anonymous** enabled  
2. Captcha **off** para anon até Turnstile (fase futura)  
3. Aplicar migration `20260715140000_profiles_onboarding_interests.sql` com review  
4. Aplicar migration `20260715200000_company_scores.sql` com review (score empresarial)

Naming: tabelas/colunas/functions sempre inglês (`snake_case`) — ver skill Supabase.

## Edge Functions

| Function | Uso | JWT |
|---|---|---|
| `create-order` | Cria `orders` vinculados ao user autenticado (exige `profiles.device_id`) | on (default) |
| `create-pix-order` | Cria/reusa cobrança PIX (Pagar.me) para um pedido | on (default) |
| `pagarme-webhook` | Eventos Pagar.me (`charge.paid` / fail / refund) → `payments` + `orders` | **off** (`verify_jwt = false` no config; HMAC via `x-hub-signature`) |
| `sync-payment-status` | Poll status da charge (fallback se webhook atrasar); Bearer service-role | on |
| `send-marketing-emails` | Envio em massa Resend a partir do Storage bucket `marketing` | on |
| `calculate-company-score` | Calcula e persiste score empresarial (1×/mês por profile) | on |

```bash
supabase functions deploy create-order
supabase functions deploy create-pix-order
supabase functions deploy pagarme-webhook
supabase functions deploy sync-payment-status
supabase functions deploy send-marketing-emails
supabase functions deploy calculate-company-score
```

Webhook URL (Pagar.me):

```
https://kpkctuuzhbnqudemeudh.supabase.co/functions/v1/pagarme-webhook
```

## Secrets

```bash
supabase secrets set PAGARME_SECRET_KEY=sk_...
supabase secrets set PAGARME_WEBHOOK_SECRET=sk_...   # mesma chave API; valida x-hub-signature
supabase secrets set RESEND_API_KEY=re_...
supabase secrets set RESEND_FROM_EMAIL="Certidões PJ <contato@certidoespj.com.br>"

# Opcional — PIX R$0,01 em teste (create-pix-order). Produção: ausente ou false.
supabase secrets set APP_DEV_MODE=true
```

Também usadas pelas functions (injetadas pelo runtime): `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`.

Opcionais: `PAGARME_FALLBACK_PHONE`, `CONTACTS_JSON_PATH` (default `contacts.json`).

## Migrations

Histórico em `supabase/migrations/` (já aplicado no remoto). **Não** rode `supabase db push` às cegas — risk de reaplicar ou divergir.

- Novas migrations: criar só neste repo, depois aplicar via CLI/Dashboard com review.
- Não reescrever migrations legadas já executadas em produção.

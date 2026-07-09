# Skill: Supabase

Patterns for working with Supabase Edge Functions, Storage, and the database.

---

## Key Files

| File | Role |
|---|---|
| `supabase/functions/_shared/market-contracts.ts` | Shared TypeScript interfaces |
| `supabase/functions/_shared/price-analysis.ts` | Shared pricing utilities |
| `supabase/functions/_shared/ebay-query-builder.ts` | Shared eBay query string builder + price range helper |
| `supabase/functions/scan-card/index.ts` | Main orchestrator (production entry point) |
| `supabase/functions/scan-card-dev/index.ts` | Dev copy — test changes here first |
| `supabase/functions/analyze-card/index.ts` | GPT-4.1 vision analysis |
| `supabase/functions/upload-images-temp/index.ts` | Storage ops (upload, signed URL, cleanup) |
| `supabase/functions/ebay-api/index.ts` | eBay Browse API fetch |
| `supabase/functions/ebay-api-inference/index.ts` | eBay filtering + pricing |
| `supabase/functions/ebay-oauth-token/index.ts` | eBay OAuth 2.0 + DB token cache |

---

## Shared Contract

All inference functions MUST return `MarketDataResponse`. Never break this contract.

```typescript
// supabase/functions/_shared/market-contracts.ts

interface RecentSale {
  id: string;
  thumbnail: string;
  title: string;
  condition: string;
  price: number;
  saleDate: string;
  url: string;
  source: string;  // default: 'eBay'
}

interface MarketDataResponse {
  recentSales: RecentSale[];
  referencePriceMin: number;   // P20
  referencePriceMax: number;   // P90
  priceTrend: 'up' | 'down' | 'stable';
}
```

---

## scan-card Orchestration Flow

```
Mobile App (multipart/form-data, x-device-id header required)
  ↓
[scan-card]
  1. Validate x-device-id header
  2. Rate limit: 30 scans/device/day (device_rate_limits table)
  3. Parse images (image_front required, image_back optional; max 5 MB each)
  4. POST → upload-images-temp  → signed URLs (120s TTL)
  5. POST → analyze-card        → card JSON + queryEbay
  6. eBay pipeline (USE_SCRAPPER_PIPELINE flag in scan-card/index.ts)
  7. Build FinalResponse (fallback to OpenAI estimate if no eBay data)
  8. DELETE → upload-images-temp (async fire-and-forget, never fails hard)
  9. Return unified JSON to app
```

Feature flag to toggle pipeline:
```typescript
const USE_SCRAPPER_PIPELINE = false; // false = API pipeline (default)
```

---

## Storage Rules (upload-images-temp)

- Bucket: `card-scans-temp`
- Signed URL TTL: **120 seconds** — must be consumed quickly by analyze-card
- **NEVER** import Supabase Storage directly in `scan-card` — always delegate to `upload-images-temp`
- DELETE is best-effort and fire-and-forget; never let cleanup block the response

```typescript
// POST — upload images, get signed URLs
const uploadRes = await fetch(`${SUPABASE_URL}/functions/v1/upload-images-temp`, {
  method: 'POST',
  body: formData,
  headers: { Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}` },
});
// returns: [{ field: 'image_front', url: string, path: string }]

// DELETE — cleanup (after response sent)
fetch(`${SUPABASE_URL}/functions/v1/upload-images-temp`, {
  method: 'DELETE',
  body: JSON.stringify({ paths }),
  headers: { ... },
}); // fire-and-forget, no await
```

---

## Database Tables

```sql
-- Daily scan quota per device
device_rate_limits (
  device_id TEXT,
  date DATE,
  count INTEGER
)

-- eBay OAuth token cache (single row, renewed 60s before expiry)
ebay_application_tokens (
  access_token TEXT,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ
)
```

**Note:** The mobile app uses SQLite (`local_database_service.dart`), not Supabase, for local data.

---

## eBay API Pipeline

**ebay-api** — fetch raw listings:
- Endpoint: eBay Browse API, limit 200
- Season-removal fallback if ≤ 2 results
- Delegates OAuth to `ebay-oauth-token`
- Returns: `EbayItemSummary[]`

**ebay-api-inference** — filter + price:
1. Structural comparability filter (player name, slabbed/raw, auto, parallel, team, parallelColor)
2. Noise title filter (lot, case, reprint)
3. Date filter: 365-day window (only if > 30 items)
4. Seller quality filter
5. Outlier removal: Tukey IQR far fence `Q3 + 2.0 × IQR`, then density tail (Q3 × 1.6 if ≥ 25% of data)
6. Reference prices: **P20** (min) and **P90** (max), 2 decimal places
7. Price trend: compare avg first vs second half, 5% threshold
8. Returns top 20 sales

---

## analyze-card

- Model: `gpt-4.1` via OpenAI Responses API (`/v1/responses`)
- Input: `{ frontImageUrl, backImageUrl? }` — signed URLs only
- Output: full card JSON + `queryEbay` field
- Season normalization: `"22-23"` → `"2022-23"`, `"2022-2023"` → `"2022-23"`
- Strips `"Parallel"` from `queryEbay` before returning

---

## Auth Patterns for Edge Functions

There are two distinct auth patterns. Pick the right one based on who calls the function.

### Non-negotiable security rule (all Edge Functions)

- **Never update or delete other users' data** based on request body fields.
- Always resolve the acting user via `auth.getUser()` from the JWT, and only
  update rows scoped to that `user.id`.
- If you need cross-user backfills, do it as an **admin-only manual runbook**
  or a separate server-side job, never as an app-facing Edge Function.

### App-facing functions (called by the mobile app with a user JWT)

Reference implementation: `ensure-profile/index.ts` and `monitoring-terms/index.ts`.

```typescript
// 1. Require the Authorization header
const authHeader = req.headers.get("Authorization");
if (!authHeader) return unauthorizedResponse();

// 2. Build a user-scoped client with the JWT
const userClient = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_ANON_KEY")!,   // ← anon key, NOT service role
  { global: { headers: { Authorization: authHeader } } },
);

// 3. Resolve user_id from the JWT — never trust client-supplied user_id
const { data: { user }, error } = await userClient.auth.getUser();
if (error || !user) return unauthorizedResponse();
const userId = user.id;

// 4. Use adminClient (service role) only for privileged DB writes
const adminClient = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);
```

Deploy **without** `--no-verify-jwt` (JWT verification enabled by default).

> **Do not use `scan-card` as the auth reference** — it doesn't validate the user
> with `getUser()`. Always follow the `ensure-profile` pattern for user-facing functions.

### Webhook functions (called by external services, no user JWT)

Reference implementation: `monitoring-webhook/index.ts`.

```typescript
// Authenticate via shared secret header
const secret = Deno.env.get("MONITORING_WEBHOOK_SECRET");
const provided = req.headers.get("X-Webhook-Secret");
if (!provided || provided !== secret) return unauthorizedResponse();

// Resolve user_id only from the database — never from the request body
const { data: monitoring } = await adminClient
  .from("monitoring_cards")
  .select("user_id, card_id")
  .eq("term_id", resolvedTermId)
  .eq("is_active", true)
  .maybeSingle();
```

Deploy **with** `--no-verify-jwt` (no Supabase JWT expected).

---

## Monitoring Architecture

| File | Role |
|---|---|
| `supabase/functions/monitoring-terms/index.ts` | Register / unregister a card for monitoring (app-facing, JWT auth) |
| `supabase/functions/monitoring-webhook/index.ts` | Receives price-change callbacks from external API (secret auth) |
| `supabase/functions/_shared/ebay-query-builder.ts` | Shared eBay query string builder + price range helper |

**DB tables** (see migration `20260414000001_monitoring_schema.sql`):
- `terms` — external API term ids + query string
- `price_history` — price snapshots per user + card
- `monitoring_cards` — active/inactive monitoring subscriptions per user + card

**Required secrets** for monitoring:
- `MONITORING_API_BASE_URL` — base URL of the external monitoring API
- `MONITORING_WEBHOOK_SECRET` — shared secret validated on each webhook call
- `SCRAPPER_API_KEY` — API key for the external scrapper/monitoring service

**Deploy commands**:
```bash
# App-facing (JWT enabled)
supabase functions deploy monitoring-terms

# Webhook (no JWT)
supabase functions deploy monitoring-webhook --no-verify-jwt

# Secrets
supabase secrets set MONITORING_API_BASE_URL=https://...
supabase secrets set MONITORING_WEBHOOK_SECRET=<strong-secret>
```

---

## Deploy Commands

```bash
supabase functions deploy <function-name>
supabase secrets set KEY=value
```

Test changes in `scan-card-dev` before deploying to `scan-card`.

---

## Environment Variables

| Var | Used by |
|---|---|
| `SUPABASE_URL` | scan-card, ebay-api, upload-images-temp, ebay-oauth-token |
| `SUPABASE_SERVICE_ROLE_KEY` | scan-card (rate limit), upload-images-temp, ebay-oauth-token |
| `SUPABASE_ANON_KEY` | ebay-api (calls ebay-oauth-token) |
| `OPENAI_API_KEY` | analyze-card |
| `EBAY_CLIENT_ID` / `EBAY_CLIENT_SECRET` | ebay-oauth-token |
| `SCRAPPER_API_KEY` | ebay-scrapper, monitoring-terms |
| `MONITORING_API_BASE_URL` | monitoring-terms |
| `MONITORING_WEBHOOK_SECRET` | monitoring-webhook |

# Plan limits — regras de negócio

Fonte de verdade para cotas de plano (consulta CNPJ, score, restrição, protesto, pacote CND).  
Sempre consultar este documento ao alterar limites, Edge Functions ou `PlanLimitsService`.

## Tabelas

### `plan_limits`

| Coluna | Tipo | Significado |
|---|---|---|
| `plan_product_id` | TEXT PK | Mesmo valor de `profiles.plan_product_id` / RC product id |
| `daily_cnpj_search_limit` | INT NULL | Consultas CNPJ/dia; `NULL` = ilimitado |
| `monthly_restricao_cnpj_limit` | INT | CNPJs distintos p/ restrição (`rest01`) **e** score |
| `monthly_protesto_cnpj_limit` | INT | CNPJs distintos p/ protesto (`prot01`) |
| `monthly_cnd_package_cnpj_limit` | INT | CNPJs distintos p/ pacote CND (`p01`) |
| `quota_period_months` | INT | Janela rolante em meses (Light=3, Plus=1) |

Seeds atuais:

| `plan_product_id` | restrição/score | protesto | pacote | consulta/dia | janela |
|---|---|---|---|---|---|
| `free` | 0 | 0 | 0 | 10 | 1 |
| `hub_pj_test_mensal_app` / `hub_pj_mensal_app` / `app_access` | 0 | 0 | 0 | ∞ | 1 |
| `hub_pj_test_mensal_cp_lg` / `hub_pj_mensal_cp_lg` / `compliance_light` | 2 | 2 | 2 | ∞ | **3** |
| `hub_pj_test_mensal_cp_pl` / `hub_pj_mensal_cp_pl` / `compliance_plus` | 10 | 10 | 10 | ∞ | **1** |

`0` = feature bloqueada no plano. Upgrade via paywall.

### `orders` (uso de emissão)

Contagem de cota (por produto):

```text
COUNT(DISTINCT digits(cnpj))
WHERE user_id = :uid
  AND product_id = :p01|prot01|rest01
  AND status IN ('em_analise', 'processando', 'concluido')  -- cancelado NÃO conta
  AND created_at >= now() - interval ':quota_period_months months'
```

Pedido duplicado (mesmo CNPJ + mesmo `product_id` + status vigente): **bloqueado** antes de criar.

### `company_scores` (uso de score)

Mesma cota numérica de restrição + mesma janela `quota_period_months`:

```text
COUNT(DISTINCT digits(cnpj))
WHERE profile_id = :uid
  AND created_at >= now() - interval ':quota_period_months months'
```

Mesmo CNPJ no período: permite recalcular / retornar score existente (unique por mês em `score_month`).

## Fluxo de emissão (app)

1. Confirmar dados → `findActiveOrder` (client) / `ACTIVE_ORDER_EXISTS` (Edge).  
   - Se existir → bottomsheet “Já possui pedido” → detalhe.  
2. Se premium → `canEmitOrder` (distinct vigentes na janela &lt; limite).  
   - Se estourado → paywall (upgrade).  
3. `create-order` (free pula cota no create; planos pagos validam).  
4. Premium → `mark-order-paid` (revalida cota + duplicate).  

## Edge Functions

| Function | Papel |
|---|---|
| `create-order` | Duplicate + cota (planos ≠ free); insert order |
| `mark-order-paid` | Duplicate + cota; set `payment_status=paid` + `payment_id` |
| `calculate-company-score` | Cota score na janela do plano |

Helper compartilhado: `supabase/functions/_shared/plan_limits.ts`.

Códigos de erro:

- `ACTIVE_ORDER_EXISTS` (409) + `order`
- `PLAN_LIMIT_REACHED` (403) + `limit`, `used`, `suggestedTier`

## Client

- [`lib/services/free_user_limits_service.dart`](../lib/services/free_user_limits_service.dart) — lê `plan_limits` (+ fallback `assets/config/plan_limits.json`)
- [`docs/PLAN_LIMITS.md`](PLAN_LIMITS.md) — este arquivo

Consulta CNPJ diária (free): SharedPreferences; sem Edge de busca ReceitaWS.

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
| `hub_pj_mensal_cp` / `hub_pj_mensal_cp:hub-pj-mensal-cp` | 2 | 2 | 2 | ∞ | **1** |

`0` = feature bloqueada no plano. Upgrade via paywall.

**Android experiment (consumables):** offering `hub_pj_cp_prod_consumables` (prod) / `hub_pj_cp_test_consumables` (Test Store — mesma regra `useTestStore` da assinatura). Package IDs iguais nos dois.

- Assinatura `hub_pj_mensal_cp` → plano acima (2 CNPJs / 30 dias).
- Consumíveis (`hub_pj_certidoes_app`, `hub_pj_restricoes_app`, `hub_pj_protestos_app`): **não** alteram `plan_product_id`. `PaymentsService.updateProfilePlanProductId` recusa IDs consumíveis; `recordConsumablePurchase` só grava `payments` (`recurrence=one_time`). `mark-order-paid` libera o pedido pendente sem checar cota quando o `payment` é `recurrence=one_time` ou `rc_product_id`/`plan_id` na lista de consumíveis.

### `orders` (uso de emissão)

Contagem de cota (por produto):

```text
COUNT(DISTINCT digits(cnpj))
WHERE user_id = :uid
  AND product_id = :p01|prot01|rest01
  AND status IN ('em_analise', 'processando', 'concluido')  -- cancelado NÃO conta
  AND created_at >= now() - interval ':quota_period_months months'
  AND NOT consumable-funded  -- payments.recurrence = one_time OU rc_product_id/plan_id consumível
```

Pedidos pagos por **consumível** (`one_time` / SKUs `hub_pj_*_app` one-shot) **não** consomem cota da assinatura. Pedidos `pending` sem payment ainda contam (ocupam slot até cancelar ou pagar).

Pedido duplicado (mesmo CNPJ + mesmo `product_id` + status vigente): **bloqueado** antes de criar.

**Plano `hub_pj_mensal_cp` no limite (2 CNPJs):** app abre sheet de especialistas + WhatsApp (sem paywall/upgrade).

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
| `mark-order-paid` | Duplicate + cota (pula cota p/ pagamento consumível); set `payment_status=paid` + `payment_id` |
| `calculate-company-score` | Cota score na janela do plano |

Helper compartilhado: `supabase/functions/_shared/plan_limits.ts`.

Códigos de erro:

- `ACTIVE_ORDER_EXISTS` (409) + `order`
- `PLAN_LIMIT_REACHED` (403) + `limit`, `used`, `suggestedTier`

## Client

- [`lib/services/free_user_limits_service.dart`](../lib/services/free_user_limits_service.dart) — lê `plan_limits` (+ fallback `assets/config/plan_limits.json`)
- [`docs/PLAN_LIMITS.md`](PLAN_LIMITS.md) — este arquivo

Consulta CNPJ diária (free): SharedPreferences; sem Edge de busca ReceitaWS.

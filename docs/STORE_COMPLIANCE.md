# Store Compliance — Consulta CNPJ

Última revisão: 2026-07-17  
Versão app: 4.0.1+51  
Bundle/package: `com.hubdopj.consultaempresas`

Fontes: [Apple App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/#introduction) · [Google Play Policies](https://play.google/intl/pt-BR/developer-content-policy/)

Docs relacionados: [APPSTORE_CHECKLIST](APPSTORE_CHECKLIST.md) · [STORE_LISTING](STORE_LISTING.md) · [IOS_SETUP](IOS_SETUP.md) · [compliance/](compliance/) (HTML espelho local)

Skill: `.cursor/skills/store-compliance/SKILL.md`

## URLs legais (publicadas)

| Documento | URL |
|---|---|
| Termos de Uso | https://www.hubdopj.com/consulta-empresas/termos-de-uso.html |
| Política de Privacidade | https://www.hubdopj.com/consulta-empresas/politica-de-privacidade.html |

Config do app: `LEGAL_TERMS_URL` / `LEGAL_PRIVACY_URL` em `.env` / `.env.example` (flutter_dotenv via `LegalUrls`).

## Resumo executivo

O app tem posicionamento “não oficial”, billing via RevenueCat, políticas/termos publicados e **exclusão de conta in-app** (Menu → Excluir conta → Edge Function `delete-account` + wipe local). Financial cards **removidos** do binary. Display name alinhado iOS/Android: **Hub do PJ: Consulta empresas**. **0 bloqueadores**. **4 atenções** (Monitor/NotAvailable, disclaimer aba Sobre, App Store URL placeholder, colar URLs nos consoles). **9 itens OK**.

Contagem: **0 bloqueadores**, **4 atenções**, **9 OK**.

## Pontos de atenção

### Bloqueadores

_Nenhum neste ciclo._

### Atenção

1. **Completude / metadata (Apple 2.1, 2.3 / Play declarações)** — Tutorial e home promovem “Monitorar minha empresa”; tap abre `NotAvailable`.
2. **Disclaimer na aba Sobre** — Checklist interno marca disclaimer na aba Sobre; `result_about_tab.dart` ainda sem `AppDisclaimerBanner`.
3. **App Store URL placeholder** — `ShareAppService._appStoreUrl` ainda `id0000000000`.
4. **Consoles** — Colar URLs legais no App Store Connect e Play Console.

### OK / mitigado

1. **Privacy + Terms URLs publicadas** e lidas do `.env`.
2. **Exclusão de conta in-app** — Menu → confirmação → `delete-account` + wipe local + novo anon; “Gerir assinatura” abre App Store / Play.
3. **IAP / assinatura** — RevenueCat + restore + texto auto-renovável.
4. **Não oficial / gov** — Disclaimers onboarding, home, CND, listing, páginas legais.
5. **Sign in with Apple** — N/A (só anon).
6. **Permissões alinhadas** — Contatos + notificações.
7. **Público** — Não Made for Kids / Families.
8. **Sem serviços financeiros no app** — rota/tela/service/model de financial cards removidos; alinhado ao listing.
9. **Display name alinhado** — iOS + Android: `Hub do PJ: Consulta empresas`.

## Checklist de conformidade

### Apple App Review

- [x] 3.1.1 / 3.1.2 — IAP (RevenueCat); restore presente
- [x] 3.1.2(c) — Texto auto-renovável no paywall
- [x] 4.8 — Sign in with Apple não exigido
- [x] 1.6 / ATS — Exception HTTP limitada ao domínio ASW
- [x] Export compliance — `ITSAppUsesNonExemptEncryption` = false
- [x] Contacts purpose string presente
- [x] **5.1** — Privacy / Terms URLs publicadas e no app
- [x] **5.1.1(i)** — Exclusão de conta/dados in-app (Menu + Edge Function)
- [ ] **2.1 / 2.3** — Copy de Monitor alinhada ao que funciona
- [ ] **2.1** — URL App Store real no share
- [ ] Disclaimer na aba Sobre do resultado
- [ ] Review notes: tiers, backends ativos
- [ ] Colar Privacy URL no App Store Connect

### Google Play Policies

- [x] Pagamentos / Assinaturas — Play Billing via RevenueCat
- [x] Declarações falsas (mitigação) — Disclaimer não-oficial
- [x] Permissões justificadas
- [x] Famílias — Não direcionado a crianças
- [x] Privacy URL publicada
- [x] **Dados do usuário** — Exclusão de conta in-app disponível
- [x] **Serviços financeiros** — Sem ofertas de cartão/crédito no binary
- [ ] Declarações / metadata — Features vs build (Monitor, CNDs)
- [ ] `usesCleartextTraffic` (hoje global `true`)
- [ ] Colar Privacy / Terms URL no Play Console

### Console / listing (manual)

- [x] Publicar política e termos na web
- [x] Preencher `LEGAL_*` no `.env`
- [x] Exclusão de conta in-app + “Gerir assinatura”
- [ ] Privacy URL no App Store Connect + Play Console
- [ ] Produtos IAP + RevenueCat
- [ ] Screenshots / description (`STORE_LISTING.md`)
- [ ] Firebase iOS se claimar push/analytics nativos
- [ ] TestFlight / internal testing
- [ ] Support e-mail / WhatsApp (`SUPPORT_EMAIL`, `SUPPORT_WHATSAPP_PHONE`)
- [ ] `ShareAppService` com Apple ID real

## Evidências no código

| Achado | Path | Nota |
|---|---|---|
| Legal URLs | `.env.example`, `.env`, `legal_urls.dart` | OK |
| Menu + exclusão | `settings_screen/`, `settings_provider.dart`, `settings_service.dart` | OK |
| Delete Edge Function | `supabase/functions/delete-account/` | Deployed |
| Auth wipe + re-init | `supabase_auth_service.dart` `deleteAccount()` | OK |
| Gerir assinatura | `SettingsService.openManageSubscription` | OK |
| Support e-mail | `SUPPORT_EMAIL` / `SupportConfig` | OK |
| Financial cards removidos | rota/tela/service/model/provider | OK |
| Monitor → NotAvailable | `home_screen.dart` | Atenção |
| App Store URL placeholder | `share_app_service.dart` | Atenção |

## Próximas ações

1. Colar URLs legais no App Store Connect e Play Console.
2. Ajustar tutorial/home: Monitor como “em breve” / waitlist.
3. Disclaimer na aba Sobre do resultado.
4. Trocar `id0000000000` pela URL real da App Store.
5. Reexecutar skill `store-compliance` antes do próximo submit.

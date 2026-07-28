# App Store — checklist de publicação

Estado do projeto após prep de código (jul/2026). Textos de listing: `docs/STORE_LISTING.md`. Setup iOS detalhado: `docs/IOS_SETUP.md`.

**Bundle ID atual:** `com.hubdopj.consultaempresas`  
**Team:** `JAQM5S9JWA`  
**Versão:** `4.0.0+50` (`pubspec.yaml`)

---

## Já feito no código

- [x] Bundle ID fora de `com.example.*`
- [x] Display name `Hub do PJ: Consulta empresas` (iOS + Android)
- [x] Portrait only (iPhone + iPad)
- [x] ATS exception HTTP para `api.consultarempresas.com.br`
- [x] Usage descriptions (contatos)
- [x] `LSApplicationQueriesSchemes` (tel, mailto, maps, http/https)
- [x] `ITSAppUsesNonExemptEncryption` = false (export compliance)
- [x] Push entitlements (`Runner.entitlements` debug / `RunnerRelease.entitlements` production)
- [x] `UIBackgroundModes` → `remote-notification`
- [x] Disclaimer in-app (home + aba Sobre do resultado)
- [x] Texto de assinatura auto-renovável + Restaurar compras no paywall
- [x] Textos de ficha em `STORE_LISTING.md`

---

## Bloqueadores manuais (você)

### 1. Firebase iOS

- [ ] `GoogleService-Info.plist` em `ios/Runner/` (adicionar via Xcode; Bundle ID `com.hubdopj.consultaempresas`)
- [x] `lib/firebase_options.dart` + `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
- [ ] Upload chave APNs no Firebase → Cloud Messaging

Sem plist + APNs: push/Analytics nativo iOS incompletos.  
Bundle ID iOS em camelCase (Apple não aceita `_` como no package Android).

DebugView: `docs/FIREBASE_DEBUGVIEW.md`.

### 2. Apple Developer + App Store Connect

- [ ] App ID `com.hubdopj.consultaempresas` com Push + In-App Purchase
- [ ] Criar app no App Store Connect (mesmo Bundle ID)
- [ ] Xcode → Signing & Capabilities: Team, Push Notifications, In-App Purchase
- [ ] Confirmar Bundle ID se já existir outro ID registrado (avise para alinhar o projeto)

### 3. Assinatura (RevenueCat)

- [ ] Produto auto-renovável no ASC (ex. mensal ~R$ 4,99)
- [ ] Agreements, Tax, and Banking preenchidos
- [ ] RevenueCat: app iOS + entitlement `premium` + offering `hub_pj_cp_prod_mensal`
- [ ] Build com keys no `.env` (`RC_IOS_API_KEY`) — sem `--dart-define`

### 4. Privacidade

- [x] Publicar URL de política de privacidade — https://www.hubdopj.com/consulta-empresas/politica-de-privacidade.html
- [x] Termos de uso — https://www.hubdopj.com/consulta-empresas/termos-de-uso.html
- [x] Preencher `LEGAL_PRIVACY_URL` / `LEGAL_TERMS_URL` (`.env` → `LegalUrls`)
- [ ] Mesma URL no App Store Connect + Privacy Nutrition Labels (contatos, analytics)

### 5. Listing

- [ ] Copiar título / subtitle / description / keywords de `STORE_LISTING.md` (seção Apple)
- [ ] Screenshots (6.7", 6.5", 5.5" — e iPad se `TARGETED_DEVICE_FAMILY` incluir 2)
- [ ] Após criar o app: atualizar `ShareAppService._appStoreUrl` (`id0000000000` → Apple ID real)

### 6. Build e upload

```bash
cd ios && pod install && cd ..
flutter build ipa
# keys from root `.env` (flutter_dotenv)
# ou Archive pelo Xcode → Distribute App → App Store Connect
```

- [ ] TestFlight interno
- [ ] Device físico: IAP, push, maps, share, PDF, contatos
- [ ] Submit for Review

---

## Compliance review (Apple)

| Risco | Mitigação |
|---|---|
| App “governamental” / enganoso | Disclaimer no listing + in-app |
| Assinatura sem info legal | Texto auto-renew + restore no paywall |
| Privacy URL ausente | Obrigatório no ASC + no app |
| HTTP cleartext | ATS exception só no domínio ASW (já no Info.plist) |
| Export compliance | `ITSAppUsesNonExemptEncryption` = false |

---

## Ordem sugerida

1. Confirmar Bundle ID no Apple Developer  
2. Firebase iOS + APNs  
3. Produto IAP + RevenueCat  
4. Privacy URL no código + ASC  
5. `flutter build ipa` → TestFlight  
6. Listing + screenshots → Review  

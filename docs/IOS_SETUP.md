# Configuração iOS — CNPJ Consulta

Checklist do que falta configurar manualmente para rodar no iOS (o projeto legado só rodava no Android).

> Prep App Store (código + passos manuais): ver `docs/APPSTORE_CHECKLIST.md`.  
> Analytics DebugView: ver `docs/FIREBASE_DEBUGVIEW.md`.

## Firebase e build

- [ ] **`GoogleService-Info.plist`** — baixar do Firebase Console e adicionar via Xcode em `ios/Runner/` (Copy Bundle Resources)
- [x] **`lib/firebase_options.dart`** — Android + iOS
- [x] **`FirebaseService`** — usa `DefaultFirebaseOptions.currentPlatform`
- [ ] **APNs** — upload da chave Auth Key `.p8` no Firebase Console → Project settings → Cloud Messaging (push iOS não funciona sem isso)

> Android e iOS usam o mesmo ID: `com.hubdopj.consultaempresas`

```bash
# Opcional: atualizar só lib/firebase_options.dart a partir do Firebase CLI
firebase login
./scripts/configure_firebase.sh
```

## Identidade e assinatura

- [x] **Bundle ID** — `com.hubdopj.consultaempresas` (team `JAQM5S9JWA`)
- [ ] **Apple Developer** — App ID, provisioning profile, signing team no `Runner.xcodeproj`
- [ ] **App Store Connect** — criar app, screenshots, metadata

## Assinaturas (RevenueCat)

- [ ] **Produto auto-renovável** no App Store Connect (mensal, equivalente R$ 4,99)
- [ ] **RevenueCat** — conectar App Store, criar entitlement `premium`, offering `hub_pj_cp_prod_mensal`
- [ ] **StoreKit Configuration** (opcional) — arquivo `.storekit` para testes locais no simulador
- [ ] **RC keys** — `RC_IOS_API_KEY` / `RC_TEST_API_KEY` no `.env` (flutter_dotenv)

## Info.plist e permissões

Já no `ios/Runner/Info.plist`:

- [x] `NSContactsUsageDescription`
- [x] Orientação Portrait (iPhone + iPad)
- [x] ATS exception para `api.consultarempresas.com.br`
- [x] `LSApplicationQueriesSchemes`, `UIBackgroundModes`, `ITSAppUsesNonExemptEncryption`

## Capacidades nativas (Xcode → Signing & Capabilities)

- [x] **Push Notifications** entitlements no projeto (`Runner.entitlements` / `RunnerRelease.entitlements`)
- [ ] Confirmar capability **Push Notifications** + **In-App Purchase** no Xcode UI
- [ ] Testar `maps_launcher`, `url_launcher`, `share_plus`, `printing` em device físico

## Conteúdo e loja

- [ ] **URL App Store** — atualizar em `lib/services/share_app_service.dart` (placeholder `id0000000000`)
- [ ] **Privacy Nutrition Labels** — declarar contatos, analytics
- [ ] **Política de privacidade** — URL em `lib/core/config/legal_urls.dart` + ASC
- [x] **Disclaimer in-app** — `AppDisclaimerBanner` na home e no resultado

## Fase posterior (ads)

- [ ] Wortise ou AdMob iOS SDK + consentimento ATT — fora do MVP

## Verificação

```bash
cd ios && pod install && cd ..
flutter build ios --no-codesign
```

IAP e push não validam bem no simulador — testar em device físico.

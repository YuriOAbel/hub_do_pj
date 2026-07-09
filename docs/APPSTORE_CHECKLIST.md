# App Store — checklist de publicação

Estado do projeto após prep de código (jul/2026). Textos de listing: `docs/STORE_LISTING.md`. Setup iOS detalhado: `docs/IOS_SETUP.md`.

**Bundle ID atual:** `br.com.cgy.consultaCnpjEmpresas`  
**Team:** `JAQM5S9JWA`  
**Versão:** `4.0.0+50` (`pubspec.yaml`)

---

## Já feito no código

- [x] Bundle ID fora de `com.example.*`
- [x] Display name `Consulta CNPJ`
- [x] Portrait only (iPhone + iPad)
- [x] ATS exception HTTP para `api.consultarempresas.com.br`
- [x] Usage descriptions (contatos + localização)
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

- [ ] Baixar `GoogleService-Info.plist` do Firebase Console → `ios/Runner/`
- [ ] Rodar `flutterfire configure` (gerar `lib/firebase_options.dart` com iOS)
- [ ] Atualizar `FirebaseService` para `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` se FlutterFire gerar o arquivo
- [ ] Upload chave APNs no Firebase → Cloud Messaging

Sem isso: Analytics / Remote Config / FCM no iOS falham (app já degrada, mas store review pode notar features quebradas).

### 2. Apple Developer + App Store Connect

- [ ] App ID `br.com.cgy.consultaCnpjEmpresas` com Push + In-App Purchase
- [ ] Criar app no App Store Connect (mesmo Bundle ID)
- [ ] Xcode → Signing & Capabilities: Team, Push Notifications, In-App Purchase
- [ ] Confirmar Bundle ID se já existir outro ID registrado (avise para alinhar o projeto)

### 3. Assinatura (RevenueCat)

- [ ] Produto auto-renovável no ASC (ex. mensal ~R$ 4,99)
- [ ] Agreements, Tax, and Banking preenchidos
- [ ] RevenueCat: app iOS + entitlement `premium` + offering `default`
- [ ] Build com `--dart-define=RC_API_KEY=...` (chave **Apple** do RC)

### 4. Privacidade

- [ ] Publicar URL de política de privacidade
- [ ] Colar em `lib/core/config/legal_urls.dart` → `privacyPolicy`
- [ ] Mesma URL no App Store Connect + Privacy Nutrition Labels (contatos, localização, analytics)

### 5. Listing

- [ ] Copiar título / subtitle / description / keywords de `STORE_LISTING.md` (seção Apple)
- [ ] Screenshots (6.7", 6.5", 5.5" — e iPad se `TARGETED_DEVICE_FAMILY` incluir 2)
- [ ] Após criar o app: atualizar `ShareAppService._appStoreUrl` (`id0000000000` → Apple ID real)

### 6. Build e upload

```bash
cd ios && pod install && cd ..
flutter build ipa --dart-define=RC_API_KEY=sua_chave_apple
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

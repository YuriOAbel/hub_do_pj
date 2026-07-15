# Validar Analytics no Firebase DebugView

Registry e helper já alinhados (19 eventos). Este guia confirma eventos no Console.

## Pré-requisitos

- Android: `google-services.json` + `DefaultFirebaseOptions.android`
- iOS: adicionar `GoogleService-Info.plist` via Xcode + `DefaultFirebaseOptions.ios`

## Ativar debug mode

### Android

```bash
adb shell setprop debug.firebase.analytics.app br.com.cgy.consulta_cnpj_empresas
flutter run
```

Desligar: `adb shell setprop debug.firebase.analytics.app .none.`

### iOS

No Xcode → Runner → Scheme → Run → Arguments → Arguments Passed On Launch:

```
-FIRDebugEnabled
```

Ou build debug e abrir o app no device físico.

## Console

1. [Firebase Console](https://console.firebase.google.com/project/consulta-cnpj-1196c/analytics/debugview) → Analytics → DebugView
2. Disparar fluxos no app (busca CNPJ, favorito, paywall, etc.)
3. Confirmar os 19 event keys em `assets/config/analytics_events.json`

## Teste automatizado (drift registry ↔ helper)

```bash
flutter test test/analytics_events_registry_test.dart
```

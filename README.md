# CNPJ Consulta (consulta_cnpj_new)

App Flutter para consulta cadastral de empresas brasileiras por CNPJ ou nome.

## Arquitetura

- `presentation` → `domain` (Riverpod) → `services`
- Models Freezed em `lib/domain/models/`
- RevenueCat para assinatura premium (Test Store em debug; store keys em release)
- Keys em `.env` (flutter_dotenv) — sem `--dart-define`

## Setup

```bash
cp .env.example .env
# Preencha SUPABASE_*, RC_*, LEGAL_*, SUPPORT_*
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Build

```bash
flutter build ios --release --no-codesign
flutter build appbundle --release
```

Debug usa Test Store (`RC_TEST_API_KEY`). Release usa `RC_IOS_API_KEY` / `RC_ANDROID_API_KEY`.
Forçar Test Store: `RC_USE_TEST=true` no `.env`.
Forçar prod (mesmo em debug): `RC_USE_PROD=true` no `.env`.

## Testes

```bash
flutter test test/analytics_events_registry_test.dart
flutter test test/release_readiness_test.dart
flutter analyze
```

Antes de subir nas lojas: setar `RC_USE_PROD=true` no `.env`, depois `/dev-ops-release` (ou rodar o test de release acima). O agent checa keys, branding, compliance, sync de migrations/Edge Functions pendentes no Supabase e builds Android/iOS.

## iOS

Ver checklist completo em [docs/IOS_SETUP.md](docs/IOS_SETUP.md).

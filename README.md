# CNPJ Consulta (consulta_cnpj_new)

App Flutter para consulta cadastral de empresas brasileiras por CNPJ ou nome.

## Arquitetura

- `presentation` → `domain` (Riverpod) → `services`
- Models Freezed em `lib/domain/models/`
- RevenueCat para assinatura premium (mock quando `RC_API_KEY` vazio)

## Rodar

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Premium com RevenueCat:

```bash
flutter run --dart-define=RC_API_KEY=sua_chave
```

## Testes

```bash
flutter test test/analytics_events_registry_test.dart
flutter analyze
```

## iOS

Ver checklist completo em [docs/IOS_SETUP.md](docs/IOS_SETUP.md).

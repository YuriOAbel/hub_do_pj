---
name: env-config
description: >-
  App environment keys via flutter_dotenv and a root `.env` asset. Use when
  adding or changing `.env` / `.env.example` keys, API keys, Supabase, RevenueCat,
  legal URLs, support contacts, or any runtime config that must work with plain
  `flutter run` / `flutter build` without dart-define flags.
---

# Env config (flutter_dotenv)

## Hard rules

1. **Single source:** root `.env` (gitignored). Document every key in `.env.example` with placeholders — no real secrets in the example.
2. **Load once:** `main.dart` must call `await dotenv.load(fileName: '.env');` before any service/config that reads env.
3. **Asset:** list `.env` under `flutter: assets:` in `pubspec.yaml`.
4. **Read in Dart:** `dotenv.env['KEY']` (or a getter on a config class). **Forbidden** for app keys: `String.fromEnvironment`, `bool.fromEnvironment`, `--dart-define`, `--dart-define-from-file`.
5. **Build / run:** no env flags required. Valid: `flutter run`, `flutter build ios --release --no-codesign`, `flutter build appbundle --release`.
6. **New key checklist:** update `.env` + `.env.example` + Dart config via `dotenv`. Do **not** change `launch.json` for defines. Do **not** ask the user to pass keys on the CLI.
7. **Never** put server secrets (`service_role`, private API keys) in the app `.env`.

## Pattern

```dart
// main.dart
await dotenv.load(fileName: '.env');

// config
static String get apiKey => dotenv.env['RC_IOS_API_KEY']?.trim() ?? '';
```

## Bool flags in `.env`

Parse manually (`true` / `1` / `yes`). Do not use `bool.fromEnvironment`.

## Clone / first setup

Copy `.env.example` → `.env` and fill values. Without a local `.env`, the asset load fails at startup.

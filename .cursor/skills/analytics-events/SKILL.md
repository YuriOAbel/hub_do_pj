# Skill: Firebase Analytics events

## Why this exists

`FirebaseService.logEvent` validates each `eventKey` against `assets/config/analytics_events.json` when `FirebaseConfigService` is initialized. If the key is missing, the event is **not** sent to Firebase Analytics (only a debug print in debug mode). The JSON file is the allowlist for production logging.

## Authoritative files

| File | Role |
|------|------|
| `assets/config/analytics_events.json` | Registry: keys, `name` (Firebase event name), `description`, `parameters` |
| `lib/core/helpers/firebase_analytics_helper.dart` | Typed `log…` methods that only call `FirebaseService.logEvent`; every `eventKey` must match a registry key — **no domain logic here** |
| `lib/services/firebase_service.dart` | `logEvent` — validation and `FirebaseAnalytics.logEvent` |
| `test/analytics_events_registry_test.dart` | Automated drift checks |

## Adding a new event

1. Add an entry under `events` in `analytics_events.json`:
   - **Object key** = string used in code (snake_case), e.g. `result_foo_click`.
   - **`name`** = same string as the key (must match; used as Firebase event name).
   - **`description`** = short product/analytics description.
   - **`parameters`** = list of parameter **names** as strings, e.g. `["card_id"]` or `["error"]`, or `[]`.

2. Add a method in `FirebaseAnalyticsHelper` that **only** calls `_firebase.logEvent(eventKey: '...', parameters: ...)`. Do not import domain services into the helper or encode “when to log” rules there — that belongs at the call site.

3. From screens/services: compute any conditions, then call the helper — **never** call `FirebaseService.instance.logEvent` directly from features.

4. **Run the registry test** (required before considering the task done):

   ```bash
   flutter test test/analytics_events_registry_test.dart
   ```

5. Optionally run full analyzer: `flutter analyze`.

## What the tests enforce

- JSON loads and has an `events` map.
- Each event has `name` (equals the map key), non-empty `description`, and `parameters` as a list of strings.
- **Every** `eventKey: '...'` in `FirebaseAnalyticsHelper` has a matching key in `analytics_events.json`.
- No duplicate `name` values across entries.

## Parameters

Match documented parameter names in JSON with the `Map<String, Object>` keys passed to `logEvent`. Firebase has limits on parameter names and value sizes; error events truncate in the helper — follow existing `paywall_error_*` patterns.

## Meta / Facebook

`MetaEventsService` uses Facebook App Events separately. Do not mix those event names with `analytics_events.json` unless product explicitly aligns them.

## Checklist for agents

- [ ] New event added to `analytics_events.json` with correct shape.
- [ ] Thin helper method added in `FirebaseAnalyticsHelper` (forward-only; no extra rules).
- [ ] Call site(s) decide when to invoke the helper.
- [ ] `flutter test test/analytics_events_registry_test.dart` passes.

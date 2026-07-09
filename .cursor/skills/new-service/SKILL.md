# Skill: New Service

How to create a new service following the project's singleton pattern.

---

## What a Service Is

Services are the **only layer** that can access external data sources: SQLite, REST APIs, RevenueCat SDK, Firebase SDK, SharedPreferences, or any other platform dependency. They are stateless business-logic executors — they do not hold Riverpod state, do not know about widgets, and do not import Flutter's `BuildContext`.

---

## Existing Services (reference before creating a new one)

Check if any of these already covers your need:

| Service | File | Responsibility |
|---|---|---|
| `LocalDatabaseService` | `lib/services/local_database_service.dart` | SQLite — all local card/binder/wishlist/preferences CRUD |
| `StorageService` | `lib/services/storage_service.dart` | Local image file storage |
| `PaywallService` | `lib/services/paywall/paywall_service.dart` | RevenueCat offerings, purchase, restore |
| `RevenueCatService` | `lib/services/revenuecat_service.dart` | Raw RevenueCat SDK wrapper |
| `FirebaseConfigService` | `lib/services/firebase_config_service.dart` | Firebase Remote Config + analytics events JSON |
| `FirebaseService` | `lib/services/firebase_service.dart` | Raw Firebase Remote Config wrapper |
| `OpenAIService` | `lib/services/openai_service.dart` | OpenAI API calls |
| `OpenAICardAnalysisService` | `lib/services/openai_card_analysis_service.dart` | Card analysis via OpenAI |
| `CommunityScansService` | `lib/services/community_scans_service.dart` | Supabase REST — community card feed |
| `FreeUserLimitsService` | `lib/services/free_user_limits_service.dart` | Free-tier quota tracking (SharedPreferences) |
| `AppCopyService` | `lib/services/app_copy_service.dart` | JSON-driven copy/text system |
| `AppDesignService` | `lib/services/app_design_service.dart` | JSON-driven design tokens |
| `AppPromptService` | `lib/services/app_prompt_service.dart` | JSON-driven AI prompt management |
| `MetaEventsService` | `lib/services/meta_events_service.dart` | Meta (Facebook) analytics events |
| `AttService` | `lib/services/att_service.dart` | iOS App Tracking Transparency |
| `ImageCropService` | `lib/services/image_crop_service.dart` | Camera image cropping |

---

## Singleton Pattern (standard — use this by default)

```dart
import 'package:flutter/foundation.dart';

class MyFeatureService {
  static final MyFeatureService instance = MyFeatureService._init();

  MyFeatureService._init();

  // Public methods below
  Future<List<MyModel>> getItems() async {
    try {
      // implementation
      return [];
    } catch (e) {
      debugPrint('❌ MyFeatureService.getItems: $e');
      rethrow;
    }
  }
}
```

## Singleton Pattern with init() (use when startup loading is required)

Use when the service must load an asset or config before first use (like `AppCopyService`, `FirebaseConfigService`).

```dart
class MyFeatureService {
  static final MyFeatureService instance = MyFeatureService._init();

  MyFeatureService._init();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      // load asset, open DB, etc.
      _isInitialized = true;
    } catch (e) {
      debugPrint('❌ MyFeatureService.init: $e');
      // decide: rethrow or allow graceful degradation
    }
  }
}
```

Register the `init()` call in `main.dart` before `runApp()` if needed.

## Static-Only Service (use when no shared state is needed)

Use when all methods are stateless and don't need a shared instance (like `FreeUserLimitsService`).

```dart
class MyUtilityService {
  // No instance — all static methods
  static Future<bool> checkSomething() async { ... }
  static Future<void> doSomething() async { ... }
}
```

---

## Exposing a Service via Riverpod

When a notifier needs to depend on a service (for testability), register it in `lib/domain/providers/services_provider.dart`:

```dart
// services_provider.dart
final myFeatureServiceProvider = Provider<MyFeatureService>((ref) {
  return MyFeatureService.instance;
});
```

Then inject it in the notifier:

```dart
class MyFeatureNotifier extends StateNotifier<MyFeatureState> {
  final MyFeatureService _service;

  MyFeatureNotifier(this._service) : super(const MyFeatureState());
}

final myFeatureProvider =
    StateNotifierProvider<MyFeatureNotifier, MyFeatureState>((ref) {
      return MyFeatureNotifier(ref.read(myFeatureServiceProvider));
    });
```

For simple cases where testability is not a concern, calling `MyFeatureService.instance` directly from the notifier is acceptable (see `PaywallPlansNotifier` as reference).

---

## File Location

```
lib/services/
  my_feature_service.dart          ← simple service
  my_feature/                      ← grouped services (like paywall/)
    my_feature_service.dart
    my_feature_config.dart
```

---

## Rules

- **Never** import `BuildContext`, `Widget`, or any Riverpod type inside a service
- **Never** hold Riverpod `StateNotifier` or `Provider` references inside a service
- **Always** use `debugPrint` with a clear prefix (`✅`, `❌`, `⚠️`) for logging
- **Always** wrap external calls in try/catch — decide per method whether to rethrow or return a safe default
- **Never** create a new service if an existing one already covers the responsibility — extend it instead

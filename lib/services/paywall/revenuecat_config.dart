import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RevenueCatConfig {
  /// Apple App Store public SDK key (RevenueCat → Project → API keys).
  static String get iosApiKey =>
      dotenv.env['RC_IOS_API_KEY']?.trim() ?? '';

  /// Google Play public SDK key (RevenueCat → Project → API keys).
  /// Used only in release (not debug / Test Store).
  static String get androidApiKey =>
      dotenv.env['RC_ANDROID_API_KEY']?.trim() ?? '';

  /// RevenueCat Test Store key (debug / sandbox without real store).
  static String get testApiKey =>
      dotenv.env['RC_TEST_API_KEY']?.trim() ?? '';

  /// Test offering id (Test Store has multiple offerings).
  static String get testOfferingId {
    final value = dotenv.env['RC_TEST_OFFERING_ID']?.trim();
    if (value == null || value.isEmpty) return 'hub_pj_test';
    return value;
  }

  /// Prod offering id — attach the same `plan_1`/`plan_2`/`plan_3` metadata
  /// as the test offering (title, subtitle, badgeText, isSelected).
  static const String prodOfferingId = 'hub_pj_cp_prod_mensal';

  /// Legacy override: if set, wins over platform / test selection.
  static String get _apiKeyOverride =>
      dotenv.env['RC_API_KEY']?.trim() ?? '';

  static const String premiumEntitlementId = 'premium';

  static bool get isDebug => _envBool('RC_DEBUG');

  /// Force Test Store even in release (`RC_USE_TEST=true` in `.env`).
  static bool get forceTestStore => _envBool('RC_USE_TEST');

  /// Force production store/offering even in debug (`RC_USE_PROD=true` in `.env`).
  /// Wins over [forceTestStore] and debug auto-test.
  static bool get forceProdStore => _envBool('RC_USE_PROD');

  static const bool forceMockPlans = false;

  static bool get useTestStore =>
      !forceProdStore &&
      (forceTestStore || (kDebugMode && testApiKey.isNotEmpty));

  /// Test Store → [testOfferingId]; release → [prodOfferingId].
  static String get offeringId =>
      useTestStore ? testOfferingId : prodOfferingId;

  static String get apiKey {
    if (_apiKeyOverride.isNotEmpty) return _apiKeyOverride;
    if (useTestStore) return testApiKey;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return iosApiKey;
      case TargetPlatform.android:
        return androidApiKey;
      default:
        return iosApiKey;
    }
  }

  static bool get useMock => apiKey.isEmpty;

  static bool _envBool(String key) {
    final raw = dotenv.env[key]?.trim().toLowerCase();
    return raw == 'true' || raw == '1' || raw == 'yes';
  }
}

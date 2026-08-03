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

  /// Android experiment: monthly + one-shot consumables (prod).
  static const String prodConsumableOfferingId = 'hub_pj_cp_prod_consumables';

  /// Same packages as prod; used when [useTestStore] is true.
  static const String testConsumableOfferingId = 'hub_pj_cp_test_consumables';

  /// Test Store → [testConsumableOfferingId]; else [prodConsumableOfferingId].
  static String get consumableOfferingId =>
      useTestStore ? testConsumableOfferingId : prodConsumableOfferingId;

  static bool isConsumableOfferingId(String? id) =>
      id == prodConsumableOfferingId || id == testConsumableOfferingId;

  /// Package: monthly compliance (2 CNPJs / 30 days).
  static const String monthlyCpPackageId = 'hub_pj_mensal_cp';

  /// Google Play store product for [monthlyCpPackageId].
  static const String monthlyCpStoreProductId =
      'hub_pj_mensal_cp:hub-pj-mensal-cp';

  static const String certidoesConsumablePackageId = 'hub_pj_certidoes_app';
  static const String restricoesConsumablePackageId = 'hub_pj_restricoes_app';
  static const String protestosConsumablePackageId = 'hub_pj_protestos_app';

  static const Set<String> consumablePackageIds = {
    certidoesConsumablePackageId,
    restricoesConsumablePackageId,
    protestosConsumablePackageId,
  };

  /// Store / plan ids that unlock a single order without changing plan.
  static const Set<String> consumableProductIds = {
    certidoesConsumablePackageId,
    restricoesConsumablePackageId,
    protestosConsumablePackageId,
    'hub_pj_app_certidoes',
  };

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

  /// Single platform gate for consumable paywall experiment (flip for iOS later).
  static bool get useConsumablePaywallExperiment =>
      defaultTargetPlatform == TargetPlatform.android;

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

  /// Google Play subscriptions often use `productId:basePlanId`.
  static String normalizeStoreProductId(String? raw) {
    final id = (raw ?? '').trim();
    if (id.isEmpty) return id;
    final colon = id.indexOf(':');
    if (colon <= 0) return id;
    return id.substring(0, colon);
  }

  static bool isConsumablePackageId(String packageId) =>
      consumablePackageIds.contains(packageId);

  static bool isConsumableProductId(String? productId) {
    if (productId == null || productId.isEmpty) return false;
    final normalized = normalizeStoreProductId(productId);
    return consumableProductIds.contains(productId) ||
        consumableProductIds.contains(normalized) ||
        consumablePackageIds.contains(productId) ||
        consumablePackageIds.contains(normalized);
  }

  static bool isMonthlyCpProductId(String? productId) {
    if (productId == null || productId.isEmpty) return false;
    final normalized = normalizeStoreProductId(productId);
    return productId == monthlyCpPackageId ||
        productId == monthlyCpStoreProductId ||
        normalized == monthlyCpPackageId;
  }

  /// Tier used for premium gates (Light-equivalent = 2).
  static int? tierForPlanProductId(String? productId) {
    if (isMonthlyCpProductId(productId)) return 2;
    return null;
  }

  /// Package ids to show on consumable paywall for a given entry context.
  static List<String> packageIdsForConsumableContext({
    required PaywallConsumableContext context,
    String? productKind,
  }) {
    switch (context) {
      case PaywallConsumableContext.score:
        return const [monthlyCpPackageId];
      case PaywallConsumableContext.emit:
        final consumable = switch (productKind) {
          'restricao' => restricoesConsumablePackageId,
          'protesto' => protestosConsumablePackageId,
          _ => certidoesConsumablePackageId,
        };
        return [monthlyCpPackageId, consumable];
    }
  }

  static bool _envBool(String key) {
    final raw = dotenv.env[key]?.trim().toLowerCase();
    return raw == 'true' || raw == '1' || raw == 'yes';
  }
}

enum PaywallConsumableContext {
  emit,
  score,
}

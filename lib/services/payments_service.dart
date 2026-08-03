import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase/supabase.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/services/free_user_limits_service.dart';
import 'package:consulta_cnpj_new/services/paywall/paywall_service.dart';
import 'package:consulta_cnpj_new/services/paywall/premium_config.dart';
import 'package:consulta_cnpj_new/services/paywall/revenuecat_config.dart';
import 'package:consulta_cnpj_new/services/profile_sync_service.dart';
import 'package:consulta_cnpj_new/services/revenuecat_service.dart';
import 'package:consulta_cnpj_new/services/supabase_auth_service.dart';

/// Mirrors RevenueCat entitlement into Supabase `payments` + `profiles.plan_product_id`.
class PaymentsService {
  static final PaymentsService instance = PaymentsService._();
  PaymentsService._();

  static const freePlanProductId = UserPlanState.freePlanProductId;

  /// Full sync: payments row + profile plan + local cache. Returns resolved plan.
  Future<UserPlanState> syncUserPlan({
    CustomerInfo? customerInfo,
    String? planId,
    PackageType? packageType,
    String? planTitle,
    int? knownTier,
    String? knownProductId,
  }) async {
    if (PremiumConfig.temporarilyUnlocked) {
      return const UserPlanState(
        planProductId: 'unlocked',
        tier: 3,
        planTitle: 'Premium',
      );
    }

    final info =
        customerInfo ?? await RevenueCatService.instance.getCustomerInfo();
    final isActive =
        info != null && RevenueCatService.instance.isPremiumActive(info);

    if (!isActive) {
      // Purchase just completed but entitlement not visible yet — trust package.
      // Never promote one-shot consumables to a subscription plan.
      if (knownTier != null &&
          knownTier >= 1 &&
          knownProductId != null &&
          knownProductId.isNotEmpty &&
          !RevenueCatConfig.isConsumableProductId(knownProductId)) {
        return _applyPremiumPlan(
          productId: knownProductId,
          tier: knownTier,
          planTitle: planTitle,
          planId: planId ?? knownProductId,
          packageType: packageType,
          customerInfo: info,
          forcePaymentActive: true,
        );
      }

      // RC unavailable / not ready — keep cache or profile; never demote.
      if (info == null) {
        final restored = await _restorePlanFromLocalOrProfile();
        if (restored != null) return restored;
        return const UserPlanState();
      }

      final restored = await _restorePlanFromLocalOrProfile();
      final expired = _rcShowsExpiredPremium(info);
      // Entitlement lag / misnamed entitlement: keep local/profile premium.
      if (restored != null && !expired) {
        return restored;
      }

      // RC confirmed free/expired — clear paid state.
      await upsertRevenueCatPayment(
        customerInfo: info,
        planId: planId,
        packageType: packageType,
      );
      return _applyFreePlan();
    }

    final entitlement =
        info.entitlements.all[RevenueCatConfig.premiumEntitlementId] ??
            info.entitlements.active.values.firstOrNull;
    final rawProductId = knownProductId ??
        entitlement?.productIdentifier ??
        _firstNonConsumableSubscription(info) ??
        planId;
    if (rawProductId == null || rawProductId.isEmpty) {
      final restored = await _restorePlanFromLocalOrProfile();
      if (restored != null) return restored;
      return _applyFreePlan();
    }

    final resolvedProductId =
        RevenueCatConfig.normalizeStoreProductId(rawProductId);

    // Consumable attached to `premium` entitlement must not become plan.
    if (RevenueCatConfig.isConsumableProductId(resolvedProductId)) {
      final realSub = _firstNonConsumableSubscription(info);
      if (realSub != null) {
        final subId = RevenueCatConfig.normalizeStoreProductId(realSub);
        await upsertRevenueCatPayment(
          customerInfo: info,
          planId: planId ?? subId,
          packageType: packageType,
          knownProductId: subId,
        );
        await updateProfilePlanProductId(subId);
        final resolved = await resolvePlanState(
          productId: subId,
          planTitle: planTitle,
          knownTier: knownTier ??
              RevenueCatConfig.tierForPlanProductId(subId),
        );
        await PlanLimitsService.instance.cacheUserPlan(
          planProductId: resolved.planProductId,
          tier: resolved.tier,
          planTitle: resolved.planTitle,
        );
        return resolved;
      }
      // Keep a valid subscription plan if profile/cache already has one.
      // Only heal dirty consumable plan_product_id → free.
      return _healConsumablePlanArtifact();
    }

    await upsertRevenueCatPayment(
      customerInfo: info,
      planId: planId ?? resolvedProductId,
      packageType: packageType,
      knownProductId: resolvedProductId,
    );
    await updateProfilePlanProductId(resolvedProductId);

    final resolved = await resolvePlanState(
      productId: resolvedProductId,
      planTitle: planTitle,
      knownTier: knownTier ??
          RevenueCatConfig.tierForPlanProductId(resolvedProductId),
    );
    await PlanLimitsService.instance.cacheUserPlan(
      planProductId: resolved.planProductId,
      tier: resolved.tier,
      planTitle: resolved.planTitle,
    );
    return resolved;
  }

  Future<UserPlanState> _applyFreePlan() async {
    await updateProfilePlanProductId(freePlanProductId);
    const free = UserPlanState();
    await PlanLimitsService.instance.cacheUserPlan(
      planProductId: free.planProductId,
      tier: free.tier,
      planTitle: free.planTitle,
    );
    return free;
  }

  /// After a one-shot purchase RC may briefly report the consumable as the
  /// premium product. Preserve an existing subscription plan; otherwise clear
  /// a dirty consumable `plan_product_id` back to free.
  Future<UserPlanState> _healConsumablePlanArtifact() async {
    final kept = await _restorePlanFromLocalOrProfile();
    if (kept != null) return kept;

    final auth = SupabaseAuthService.instance;
    final client = auth.client;
    final profileId = auth.userId;
    if (client != null && profileId != null) {
      try {
        final row = await client
            .from('profiles')
            .select('plan_product_id')
            .eq('id', profileId)
            .maybeSingle();
        final productId = row?['plan_product_id'] as String?;
        if (productId != null &&
            RevenueCatConfig.isConsumableProductId(productId)) {
          await updateProfilePlanProductId(freePlanProductId);
        }
      } catch (e) {
        debugPrint('PaymentsService._healConsumablePlanArtifact: $e');
      }
    }

    const free = UserPlanState();
    await PlanLimitsService.instance.cacheUserPlan(
      planProductId: free.planProductId,
      tier: free.tier,
      planTitle: free.planTitle,
    );
    return free;
  }

  String? _firstNonConsumableSubscription(CustomerInfo info) {
    for (final id in info.activeSubscriptions) {
      if (!RevenueCatConfig.isConsumableProductId(id)) return id;
    }
    return null;
  }

  Future<UserPlanState> _applyPremiumPlan({
    required String productId,
    required int tier,
    String? planTitle,
    String? planId,
    PackageType? packageType,
    CustomerInfo? customerInfo,
    bool forcePaymentActive = false,
  }) async {
    final canonicalId = RevenueCatConfig.normalizeStoreProductId(productId);
    if (RevenueCatConfig.isConsumableProductId(canonicalId)) {
      return _applyFreePlan();
    }
    await updateProfilePlanProductId(canonicalId);
    final plan = UserPlanState(
      planProductId: canonicalId,
      tier: tier,
      planTitle: planTitle,
    );
    await PlanLimitsService.instance.cacheUserPlan(
      planProductId: plan.planProductId,
      tier: plan.tier,
      planTitle: plan.planTitle,
    );
    await upsertRevenueCatPayment(
      customerInfo: customerInfo,
      planId: planId ?? canonicalId,
      packageType: packageType,
      forceActive: forcePaymentActive,
      knownProductId: canonicalId,
    );
    return plan;
  }

  /// Local cache first, then `profiles.plan_product_id`.
  Future<UserPlanState?> _restorePlanFromLocalOrProfile() async {
    final cached = await PlanLimitsService.instance.readCachedUserPlan();
    if (cached != null &&
        cached.tier >= 1 &&
        cached.productId != freePlanProductId &&
        !RevenueCatConfig.isConsumableProductId(cached.productId)) {
      return UserPlanState(
        planProductId: cached.productId,
        tier: cached.tier,
        planTitle: cached.title,
      );
    }

    final auth = SupabaseAuthService.instance;
    final client = auth.client;
    final profileId = auth.userId;
    if (client == null || profileId == null) return null;

    try {
      final row = await client
          .from('profiles')
          .select('plan_product_id')
          .eq('id', profileId)
          .maybeSingle();
      final productId = row?['plan_product_id'] as String?;
      if (productId == null ||
          productId.isEmpty ||
          productId == freePlanProductId) {
        return null;
      }
      if (RevenueCatConfig.isConsumableProductId(productId)) {
        // Dirty row from a past one-shot purchase — clear back to free.
        await updateProfilePlanProductId(freePlanProductId);
        return null;
      }
      final resolved = await resolvePlanState(productId: productId);
      if (resolved.isPremium) {
        await PlanLimitsService.instance.cacheUserPlan(
          planProductId: resolved.planProductId,
          tier: resolved.tier,
          planTitle: resolved.planTitle,
        );
      }
      return resolved.isPremium ? resolved : null;
    } catch (e) {
      debugPrint('PaymentsService._restorePlanFromLocalOrProfile: $e');
      return null;
    }
  }

  Future<void> updateProfilePlanProductId(String planProductId) async {
    final auth = SupabaseAuthService.instance;
    if (auth.userId == null || !auth.isAuthenticated) return;

    final canonical = RevenueCatConfig.normalizeStoreProductId(planProductId);
    // Consumables must never become the user's plan.
    if (canonical.isEmpty ||
        RevenueCatConfig.isConsumableProductId(canonical) ||
        RevenueCatConfig.isConsumablePackageId(canonical)) {
      debugPrint(
        'PaymentsService.updateProfilePlanProductId: refused consumable '
        '`$planProductId`',
      );
      return;
    }

    try {
      final ok = await ProfileSyncService.instance.sync(
        purpose: 'update',
        planProductId: canonical,
      );
      if (!ok.ok) {
        debugPrint(
          'PaymentsService.updateProfilePlanProductId: sync-profile failed',
        );
      }
    } catch (e) {
      debugPrint('PaymentsService.updateProfilePlanProductId: $e');
    }
  }

  Future<UserPlanState> resolvePlanState({
    required String productId,
    String? planTitle,
    int? knownTier,
  }) async {
    final canonicalId = RevenueCatConfig.normalizeStoreProductId(productId);
    if (canonicalId == freePlanProductId ||
        canonicalId.isEmpty ||
        RevenueCatConfig.isConsumableProductId(canonicalId)) {
      return const UserPlanState();
    }

    final mappedTier =
        knownTier ?? RevenueCatConfig.tierForPlanProductId(canonicalId);
    if (mappedTier != null && mappedTier >= 1) {
      return UserPlanState(
        planProductId: canonicalId,
        tier: mappedTier,
        planTitle: planTitle,
      );
    }

    try {
      final plans = await PaywallService.instance.getAvailablePlans();
      for (final plan in plans) {
        final match = plan.productId == productId ||
            plan.productId == canonicalId ||
            plan.id == productId ||
            plan.id == canonicalId ||
            RevenueCatConfig.normalizeStoreProductId(plan.productId) ==
                canonicalId;
        if (match) {
          if (RevenueCatConfig.isConsumablePackageId(plan.id) ||
              RevenueCatConfig.isConsumableProductId(plan.productId)) {
            return const UserPlanState();
          }
          return UserPlanState(
            planProductId: canonicalId,
            tier: plan.tier,
            planTitle: planTitle ?? plan.title,
          );
        }
      }
      // Unknown product but entitlement active → at least tier 1 (unlimited search).
      return UserPlanState(
        planProductId: canonicalId,
        tier: 1,
        planTitle: planTitle,
      );
    } catch (e) {
      debugPrint('PaymentsService.resolvePlanState: $e');
      final cached = await PlanLimitsService.instance.readCachedUserPlan();
      if (cached != null &&
          (cached.productId == productId ||
              cached.productId == canonicalId) &&
          !RevenueCatConfig.isConsumableProductId(cached.productId)) {
        return UserPlanState(
          planProductId: cached.productId,
          tier: cached.tier,
          planTitle: planTitle ?? cached.title,
        );
      }
      return UserPlanState(
        planProductId: canonicalId,
        tier: 1,
        planTitle: planTitle,
      );
    }
  }

  /// One-shot consumable payment — does **not** change `plan_product_id`.
  Future<String?> recordConsumablePurchase({
    CustomerInfo? customerInfo,
    required String productId,
    String? planId,
    PackageType? packageType,
  }) async {
    final auth = SupabaseAuthService.instance;
    final client = auth.client;
    final profileId = auth.userId;
    if (client == null || profileId == null) {
      debugPrint('PaymentsService.recordConsumablePurchase: no auth session');
      return null;
    }

    try {
      final info =
          customerInfo ?? await RevenueCatService.instance.getCustomerInfo();
      final rcId = info?.originalAppUserId ?? profileId;
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final payload = <String, dynamic>{
        'profile_id': profileId,
        'provider': 'revenuecat',
        'platform': _platform(),
        'recurrence': 'one_time',
        'is_active': true,
        'rc_id': rcId,
        'rc_entitlement_id': RevenueCatConfig.premiumEntitlementId,
        'rc_product_id': productId,
        'plan_id': planId ?? productId,
        'status': 'paid',
        'paid_at': nowIso,
        'starts_at': nowIso,
        'current_period_end': null,
        'cancelled_at': null,
      };

      final inserted = await client
          .from('payments')
          .insert(payload)
          .select('id')
          .single();
      return inserted['id'] as String?;
    } catch (e) {
      debugPrint('PaymentsService.recordConsumablePurchase: $e');
      return null;
    }
  }

  /// Upserts RevenueCat payment for the current profile.
  /// Returns payment row id, or null when auth unavailable.
  ///
  /// [forceActive] — purchase just succeeded but RC entitlement may lag;
  /// write `is_active`/`paid` so `orders.payment_id` can link immediately.
  Future<String?> upsertRevenueCatPayment({
    CustomerInfo? customerInfo,
    String? planId,
    PackageType? packageType,
    bool forceActive = false,
    String? knownProductId,
  }) async {
    final auth = SupabaseAuthService.instance;
    final client = auth.client;
    final profileId = auth.userId;
    if (client == null || profileId == null) {
      debugPrint('PaymentsService.upsertRevenueCatPayment: no auth session');
      return null;
    }

    try {
      final info =
          customerInfo ?? await RevenueCatService.instance.getCustomerInfo();
      final entitlement = info == null
          ? null
          : (info.entitlements.all[RevenueCatConfig.premiumEntitlementId] ??
              (info.entitlements.active.isNotEmpty
                  ? info.entitlements.active.values.first
                  : null));
      final entitlementActive =
          info != null && RevenueCatService.instance.isPremiumActive(info);
      final isActive = forceActive || entitlementActive;
      final rcId = info?.originalAppUserId ?? profileId;
      final productId =
          knownProductId ?? entitlement?.productIdentifier ?? planId;
      final recurrence = _recurrenceFrom(
        packageType: packageType,
        productId: productId,
      );
      final platform = _platform();
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final periodEnd = entitlement?.expirationDate;
      final startsAt = entitlement?.latestPurchaseDate;

      final payload = <String, dynamic>{
        'profile_id': profileId,
        'provider': 'revenuecat',
        'platform': platform,
        'recurrence': recurrence,
        'is_active': isActive,
        'rc_id': rcId,
        'rc_entitlement_id': RevenueCatConfig.premiumEntitlementId,
        'rc_product_id': productId,
        'rc_transaction_id': entitlement?.originalPurchaseDate,
        'plan_id': planId ?? productId,
        'status': isActive ? 'paid' : 'expired',
        'paid_at': isActive ? (startsAt ?? nowIso) : null,
        'starts_at': startsAt ?? (isActive ? nowIso : null),
        'current_period_end': periodEnd,
        'cancelled_at': isActive
            ? null
            : (entitlement?.unsubscribeDetectedAt ?? nowIso),
      };

      final existing = await client
          .from('payments')
          .select('id, recurrence')
          .eq('profile_id', profileId)
          .eq('provider', 'revenuecat')
          .eq('rc_id', rcId)
          .neq('recurrence', 'one_time')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (existing != null && existing['id'] != null) {
        final id = existing['id'] as String;
        await client.from('payments').update(payload).eq('id', id);
        return id;
      }

      // Avoid overwriting a one-shot row with subscription upsert.
      if (recurrence == 'one_time') {
        final inserted = await client
            .from('payments')
            .insert(payload)
            .select('id')
            .single();
        return inserted['id'] as String?;
      }

      final inserted = await client
          .from('payments')
          .insert(payload)
          .select('id')
          .single();
      return inserted['id'] as String?;
    } catch (e) {
      debugPrint('PaymentsService.upsertRevenueCatPayment: $e');
      return null;
    }
  }

  /// Active RevenueCat payment id for current profile, if any.
  /// Prefers unused one-shot consumable rows over subscription.
  Future<String?> activeRevenueCatPaymentId() async {
    final auth = SupabaseAuthService.instance;
    final client = auth.client;
    final profileId = auth.userId;
    if (client == null || profileId == null) return null;

    try {
      final unusedConsumable = await _unusedActiveConsumablePaymentId(
        client: client,
        profileId: profileId,
      );
      if (unusedConsumable != null) return unusedConsumable;

      final row = await client
          .from('payments')
          .select('id')
          .eq('profile_id', profileId)
          .eq('provider', 'revenuecat')
          .eq('is_active', true)
          .neq('recurrence', 'one_time')
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return row?['id'] as String?;
    } catch (e) {
      debugPrint('PaymentsService.activeRevenueCatPaymentId: $e');
      return null;
    }
  }

  /// Latest active one-shot payment not yet linked to a paid order.
  Future<String?> _unusedActiveConsumablePaymentId({
    required SupabaseClient client,
    required String profileId,
  }) async {
    final consumables = await client
        .from('payments')
        .select('id')
        .eq('profile_id', profileId)
        .eq('provider', 'revenuecat')
        .eq('is_active', true)
        .eq('recurrence', 'one_time')
        .order('created_at', ascending: false)
        .limit(10);

    final rows = (consumables as List?) ?? const [];
    if (rows.isEmpty) return null;

    final used = await client
        .from('orders')
        .select('payment_id')
        .eq('user_id', profileId)
        .eq('payment_status', 'paid')
        .not('payment_id', 'is', null);

    final usedIds = <String>{};
    for (final row in (used as List?) ?? const []) {
      final id = (row as Map)['payment_id'] as String?;
      if (id != null && id.isNotEmpty) usedIds.add(id);
    }

    for (final row in rows) {
      final id = (row as Map)['id'] as String?;
      if (id != null && id.isNotEmpty && !usedIds.contains(id)) {
        return id;
      }
    }
    return null;
  }

  /// Marks a one-shot payment as consumed after linking to an order.
  Future<void> deactivateConsumablePayment(String paymentId) async {
    final auth = SupabaseAuthService.instance;
    final client = auth.client;
    if (client == null || paymentId.isEmpty) return;

    try {
      await client.from('payments').update({
        'is_active': false,
      }).eq('id', paymentId).eq('recurrence', 'one_time');
    } catch (e) {
      debugPrint('PaymentsService.deactivateConsumablePayment: $e');
    }
  }

  /// Ensures a linkable RevenueCat payment exists after purchase / premium gate.
  /// Never demotes plan — only upserts payment as active when needed.
  Future<String?> ensureRevenueCatPaymentId({
    String? planId,
    PackageType? packageType,
    String? knownProductId,
    String? preferredPaymentId,
  }) async {
    if (preferredPaymentId != null && preferredPaymentId.isNotEmpty) {
      return preferredPaymentId;
    }

    final existing = await activeRevenueCatPaymentId();
    if (existing != null) return existing;

    final cached = await PlanLimitsService.instance.readCachedUserPlan();
    final productId = knownProductId ??
        (cached != null &&
                cached.tier >= 1 &&
                !RevenueCatConfig.isConsumableProductId(cached.productId)
            ? cached.productId
            : null);

    if (productId != null &&
        RevenueCatConfig.isConsumableProductId(productId)) {
      return null;
    }

    final id = await upsertRevenueCatPayment(
      planId: planId ?? productId,
      packageType: packageType,
      knownProductId: productId,
      forceActive: true,
    );
    if (id != null &&
        productId != null &&
        productId.isNotEmpty &&
        productId != freePlanProductId) {
      await updateProfilePlanProductId(productId);
    }
    return id;
  }

  String _platform() {
    if (kIsWeb) return 'web';
    if (Platform.isIOS || Platform.isMacOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'web';
  }

  /// True when RC has a known premium entitlement that is expired/cancelled.
  bool _rcShowsExpiredPremium(CustomerInfo info) {
    final candidates = <EntitlementInfo>[
      ...info.entitlements.all.values,
    ];
    final now = DateTime.now();
    for (final e in candidates) {
      if (e.isActive) return false;
      if (e.unsubscribeDetectedAt != null) return true;
      final exp = e.expirationDate;
      if (exp == null) continue;
      final dt = DateTime.tryParse(exp);
      if (dt != null && dt.isBefore(now)) return true;
    }
    return false;
  }

  String _recurrenceFrom({
    PackageType? packageType,
    String? productId,
  }) {
    if (RevenueCatConfig.isConsumableProductId(productId)) {
      return 'one_time';
    }
    if (packageType == PackageType.annual) return 'annual';
    if (packageType == PackageType.monthly) return 'monthly';

    final id = (productId ?? '').toLowerCase();
    if (id.contains('annual') || id.contains('year') || id.contains('anual')) {
      return 'annual';
    }
    if (id.contains('month') || id.contains('mensal')) {
      return 'monthly';
    }
    return 'monthly';
  }
}

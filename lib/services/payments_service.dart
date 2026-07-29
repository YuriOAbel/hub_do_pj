import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/services/free_user_limits_service.dart';
import 'package:consulta_cnpj_new/services/paywall/paywall_service.dart';
import 'package:consulta_cnpj_new/services/paywall/premium_config.dart';
import 'package:consulta_cnpj_new/services/paywall/revenuecat_config.dart';
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
      if (knownTier != null &&
          knownTier >= 1 &&
          knownProductId != null &&
          knownProductId.isNotEmpty) {
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
      await updateProfilePlanProductId(freePlanProductId);
      const free = UserPlanState();
      await PlanLimitsService.instance.cacheUserPlan(
        planProductId: free.planProductId,
        tier: free.tier,
        planTitle: free.planTitle,
      );
      return free;
    }

    final entitlement =
        info.entitlements.all[RevenueCatConfig.premiumEntitlementId] ??
            info.entitlements.active.values.firstOrNull;
    final productId = knownProductId ??
        entitlement?.productIdentifier ??
        info.activeSubscriptions.firstOrNull ??
        planId;
    if (productId == null || productId.isEmpty) {
      final restored = await _restorePlanFromLocalOrProfile();
      if (restored != null) return restored;
    }

    final resolvedProductId = (productId != null && productId.isNotEmpty)
        ? productId
        : 'unknown';
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
      knownTier: knownTier,
    );
    await PlanLimitsService.instance.cacheUserPlan(
      planProductId: resolved.planProductId,
      tier: resolved.tier,
      planTitle: resolved.planTitle,
    );
    return resolved;
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
    await updateProfilePlanProductId(productId);
    final plan = UserPlanState(
      planProductId: productId,
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
      planId: planId ?? productId,
      packageType: packageType,
      forceActive: forcePaymentActive,
      knownProductId: productId,
    );
    return plan;
  }

  /// Local cache first, then `profiles.plan_product_id`.
  Future<UserPlanState?> _restorePlanFromLocalOrProfile() async {
    final cached = await PlanLimitsService.instance.readCachedUserPlan();
    if (cached != null &&
        cached.tier >= 1 &&
        cached.productId != freePlanProductId) {
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
    final client = auth.client;
    final profileId = auth.userId;
    if (client == null || profileId == null) return;

    try {
      await client.from('profiles').update({
        'plan_product_id': planProductId,
      }).eq('id', profileId);
    } catch (e) {
      debugPrint('PaymentsService.updateProfilePlanProductId: $e');
    }
  }

  Future<UserPlanState> resolvePlanState({
    required String productId,
    String? planTitle,
    int? knownTier,
  }) async {
    if (productId == freePlanProductId || productId.isEmpty) {
      return const UserPlanState();
    }

    if (knownTier != null && knownTier >= 1) {
      return UserPlanState(
        planProductId: productId,
        tier: knownTier,
        planTitle: planTitle,
      );
    }

    try {
      final plans = await PaywallService.instance.getAvailablePlans();
      for (final plan in plans) {
        final match = plan.productId == productId || plan.id == productId;
        if (match) {
          return UserPlanState(
            planProductId: plan.productId ?? productId,
            tier: plan.tier,
            planTitle: planTitle ?? plan.title,
          );
        }
      }
      // Unknown product but entitlement active → at least tier 1 (unlimited search).
      return UserPlanState(
        planProductId: productId,
        tier: 1,
        planTitle: planTitle,
      );
    } catch (e) {
      debugPrint('PaymentsService.resolvePlanState: $e');
      final cached = await PlanLimitsService.instance.readCachedUserPlan();
      if (cached != null && cached.productId == productId) {
        return UserPlanState(
          planProductId: cached.productId,
          tier: cached.tier,
          planTitle: planTitle ?? cached.title,
        );
      }
      return UserPlanState(
        planProductId: productId,
        tier: 1,
        planTitle: planTitle,
      );
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
          .select('id')
          .eq('profile_id', profileId)
          .eq('provider', 'revenuecat')
          .eq('rc_id', rcId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (existing != null && existing['id'] != null) {
        final id = existing['id'] as String;
        await client.from('payments').update(payload).eq('id', id);
        return id;
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
  Future<String?> activeRevenueCatPaymentId() async {
    final auth = SupabaseAuthService.instance;
    final client = auth.client;
    final profileId = auth.userId;
    if (client == null || profileId == null) return null;

    try {
      final row = await client
          .from('payments')
          .select('id')
          .eq('profile_id', profileId)
          .eq('provider', 'revenuecat')
          .eq('is_active', true)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return row?['id'] as String?;
    } catch (e) {
      debugPrint('PaymentsService.activeRevenueCatPaymentId: $e');
      return null;
    }
  }

  /// Ensures a linkable RevenueCat payment exists after purchase / premium gate.
  /// Never demotes plan — only upserts payment as active when needed.
  Future<String?> ensureRevenueCatPaymentId({
    String? planId,
    PackageType? packageType,
    String? knownProductId,
  }) async {
    final existing = await activeRevenueCatPaymentId();
    if (existing != null) return existing;

    final cached = await PlanLimitsService.instance.readCachedUserPlan();
    final productId = knownProductId ??
        (cached != null && cached.tier >= 1 ? cached.productId : null);

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

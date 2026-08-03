import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_order_model.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/services/paywall/revenuecat_config.dart';
import 'package:consulta_cnpj_new/services/supabase_auth_service.dart';

class PlanLimits {
  const PlanLimits({
    this.dailyCnpjSearchLimit,
    this.monthlyRestricaoCnpjLimit = 0,
    this.monthlyProtestoCnpjLimit = 0,
    this.monthlyCndPackageCnpjLimit = 0,
    this.quotaPeriodMonths = 1,
  });

  /// Null = unlimited.
  final int? dailyCnpjSearchLimit;

  /// 0 = blocked. Score uses the same cap as restrição.
  final int monthlyRestricaoCnpjLimit;
  final int monthlyProtestoCnpjLimit;
  final int monthlyCndPackageCnpjLimit;

  /// Rolling window in months for CNPJ quotas (Light=3, Plus=1).
  final int quotaPeriodMonths;

  /// Alias for score quota (same as restrição).
  int get monthlyScoreCnpjLimit => monthlyRestricaoCnpjLimit;

  int limitForOrderProductId(String productId) {
    switch (productId) {
      case 'rest01':
        return monthlyRestricaoCnpjLimit;
      case 'prot01':
        return monthlyProtestoCnpjLimit;
      case 'p01':
        return monthlyCndPackageCnpjLimit;
      default:
        return 0;
    }
  }

  int limitForProductKind(String productKind) {
    switch (productKind) {
      case 'restricao':
        return monthlyRestricaoCnpjLimit;
      case 'protesto':
        return monthlyProtestoCnpjLimit;
      case 'cnd':
        return monthlyCndPackageCnpjLimit;
      default:
        return 0;
    }
  }

  String? orderProductIdForKind(String productKind) {
    switch (productKind) {
      case 'restricao':
        return 'rest01';
      case 'protesto':
        return 'prot01';
      case 'cnd':
        return 'p01';
      default:
        return null;
    }
  }
}

/// Quotas by `plan_product_id` (Supabase `plan_limits` + JSON fallback).
class PlanLimitsService {
  PlanLimitsService._();
  static final PlanLimitsService instance = PlanLimitsService._();

  static const _limitsAsset = 'assets/config/plan_limits.json';
  static const _dayKey = 'cnpj_search_day';
  static const _countKey = 'cnpj_search_count';
  static const _cacheProductKey = 'user_plan_product_id';
  static const _cacheTierKey = 'user_plan_tier';
  static const _cacheTitleKey = 'user_plan_title';

  Map<String, PlanLimits>? _assetFallback;
  final Map<String, PlanLimits> _remoteByProduct = {};
  DateTime? _remoteFetchedAt;

  static const _remoteTtl = Duration(minutes: 10);

  Future<Map<String, PlanLimits>> _loadAssetFallback() async {
    if (_assetFallback != null) return _assetFallback!;
    try {
      final raw = await rootBundle.loadString(_limitsAsset);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _assetFallback = {
        for (final e in json.entries)
          e.key: _fromJsonMap(Map<String, dynamic>.from(e.value as Map)),
      };
    } catch (e) {
      debugPrint('PlanLimitsService._loadAssetFallback: $e');
      _assetFallback = {
        'free': const PlanLimits(dailyCnpjSearchLimit: 10),
        'app_access': const PlanLimits(),
        'compliance_light': const PlanLimits(
          monthlyRestricaoCnpjLimit: 2,
          monthlyProtestoCnpjLimit: 2,
          monthlyCndPackageCnpjLimit: 2,
          quotaPeriodMonths: 3,
        ),
        'compliance_plus': const PlanLimits(
          monthlyRestricaoCnpjLimit: 10,
          monthlyProtestoCnpjLimit: 10,
          monthlyCndPackageCnpjLimit: 10,
          quotaPeriodMonths: 1,
        ),
        'hub_pj_test_mensal_app': const PlanLimits(),
        'hub_pj_test_mensal_cp_lg': const PlanLimits(
          monthlyRestricaoCnpjLimit: 2,
          monthlyProtestoCnpjLimit: 2,
          monthlyCndPackageCnpjLimit: 2,
          quotaPeriodMonths: 3,
        ),
        'hub_pj_test_mensal_cp_pl': const PlanLimits(
          monthlyRestricaoCnpjLimit: 10,
          monthlyProtestoCnpjLimit: 10,
          monthlyCndPackageCnpjLimit: 10,
          quotaPeriodMonths: 1,
        ),
        'hub_pj_mensal_app': const PlanLimits(),
        'hub_pj_mensal_cp_lg': const PlanLimits(
          monthlyRestricaoCnpjLimit: 2,
          monthlyProtestoCnpjLimit: 2,
          monthlyCndPackageCnpjLimit: 2,
          quotaPeriodMonths: 3,
        ),
        'hub_pj_mensal_cp_pl': const PlanLimits(
          monthlyRestricaoCnpjLimit: 10,
          monthlyProtestoCnpjLimit: 10,
          monthlyCndPackageCnpjLimit: 10,
          quotaPeriodMonths: 1,
        ),
      };
    }
    return _assetFallback!;
  }

  PlanLimits _fromJsonMap(Map<String, dynamic> map) {
    return PlanLimits(
      dailyCnpjSearchLimit: _asNullableInt(
        map['dailyCnpjSearchLimit'] ?? map['daily_cnpj_search_limit'],
      ),
      monthlyRestricaoCnpjLimit: _asInt(
        map['monthlyRestricaoCnpjLimit'] ??
            map['monthly_restricao_cnpj_limit'] ??
            map['monthlyScoreCnpjLimit'],
        0,
      ),
      monthlyProtestoCnpjLimit: _asInt(
        map['monthlyProtestoCnpjLimit'] ??
            map['monthly_protesto_cnpj_limit'],
        0,
      ),
      monthlyCndPackageCnpjLimit: _asInt(
        map['monthlyCndPackageCnpjLimit'] ??
            map['monthly_cnd_package_cnpj_limit'],
        0,
      ),
      quotaPeriodMonths: _asInt(
        map['quotaPeriodMonths'] ?? map['quota_period_months'],
        1,
      ),
    );
  }

  Future<void> _refreshRemoteIfNeeded() async {
    final now = DateTime.now();
    if (_remoteFetchedAt != null &&
        now.difference(_remoteFetchedAt!) < _remoteTtl &&
        _remoteByProduct.isNotEmpty) {
      return;
    }

    final auth = SupabaseAuthService.instance;
    final client = auth.client;
    if (client == null || !auth.isAuthenticated) return;

    try {
      final rows = await client.from('plan_limits').select();
      for (final row in rows as List) {
        final map = Map<String, dynamic>.from(row as Map);
        final id = map['plan_product_id'] as String?;
        if (id == null || id.isEmpty) continue;
        _remoteByProduct[id] = _fromJsonMap(map);
      }
      _remoteFetchedAt = now;
    } catch (e) {
      debugPrint('PlanLimitsService._refreshRemoteIfNeeded: $e');
    }
  }

  Future<PlanLimits> limitsForProductId(String planProductId) async {
    await _refreshRemoteIfNeeded();
    final id = planProductId.trim().isEmpty
        ? UserPlanState.freePlanProductId
        : planProductId.trim();

    final remote = _remoteByProduct[id];
    if (remote != null) return remote;

    final asset = await _loadAssetFallback();
    return asset[id] ??
        asset[UserPlanState.freePlanProductId] ??
        const PlanLimits(dailyCnpjSearchLimit: 10);
  }

  /// Legacy tier mapping for callers that still pass numeric tier.
  Future<PlanLimits> limitsForTier(int tier) async {
    if (tier <= 0) return limitsForProductId(UserPlanState.freePlanProductId);
    if (tier == 1) return limitsForProductId('app_access');
    if (tier == 2) return limitsForProductId('compliance_light');
    return limitsForProductId('compliance_plus');
  }

  Future<String> resolvePlanProductId({String? knownProductId}) async {
    if (knownProductId != null && knownProductId.trim().isNotEmpty) {
      return knownProductId.trim();
    }
    final cached = await readCachedUserPlan();
    if (cached != null && cached.productId.isNotEmpty) {
      return cached.productId;
    }
    return UserPlanState.freePlanProductId;
  }

  Future<bool> canSearchCnpj({
    int? tier,
    String? planProductId,
  }) async {
    final PlanLimits limits;
    if (planProductId != null) {
      limits = await limitsForProductId(planProductId);
    } else if (tier != null) {
      limits = await limitsForTier(tier);
    } else {
      limits = await limitsForProductId(await resolvePlanProductId());
    }
    final cap = limits.dailyCnpjSearchLimit;
    if (cap == null) return true;
    final count = await _todayCount();
    return count < cap;
  }

  Future<void> recordCnpjSearch() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayStamp();
    final storedDay = prefs.getString(_dayKey);
    if (storedDay != today) {
      await prefs.setString(_dayKey, today);
      await prefs.setInt(_countKey, 1);
      return;
    }
    final current = prefs.getInt(_countKey) ?? 0;
    await prefs.setInt(_countKey, current + 1);
  }

  /// Whether [cnpj] can start/keep a score this month.
  /// Existing score for same CNPJ this month always allowed.
  Future<bool> canAddScoreCnpj({
    required String cnpj,
    required Iterable<String> existingCnpjsThisMonth,
    int? tier,
    String? planProductId,
  }) async {
    final normalized = cnpj.replaceAll(RegExp(r'\D'), '');
    final existing = existingCnpjsThisMonth
        .map((e) => e.replaceAll(RegExp(r'\D'), ''))
        .toSet();
    if (existing.contains(normalized)) return true;

    final PlanLimits limits;
    if (planProductId != null) {
      limits = await limitsForProductId(planProductId);
    } else if (tier != null) {
      limits = await limitsForTier(tier);
    } else {
      limits = await limitsForProductId(await resolvePlanProductId());
    }
    final cap = limits.monthlyScoreCnpjLimit;
    if (cap <= 0) return false;
    return existing.length < cap;
  }

  /// Whether a new CNPJ can be emitted under plan quota (rolling window).
  /// Does not allow re-emit for a CNPJ that already has an active order —
  /// use [findActiveOrder] for that case.
  Future<bool> canEmitOrder({
    required String productKind,
    required String cnpj,
    String? planProductId,
  }) async {
    final id = planProductId ?? await resolvePlanProductId();
    final limits = await limitsForProductId(id);
    final cap = limits.limitForProductKind(productKind);
    if (cap <= 0) return false;

    final orderProductId = limits.orderProductIdForKind(productKind);
    if (orderProductId == null) return false;

    final normalized = cnpj.replaceAll(RegExp(r'\D'), '');
    final used = await _distinctActiveCnpjsInPeriod(
      orderProductId,
      limits.quotaPeriodMonths,
    );
    if (used.contains(normalized)) {
      // Active order for this CNPJ — not a quota free slot; caller should
      // route to existing order UI.
      return false;
    }
    return used.length < cap;
  }

  /// Active (non-cancelled) order for product + CNPJ, if any.
  Future<CndOrderModel?> findActiveOrder({
    required String productKind,
    required String cnpj,
  }) async {
    final limits = await limitsForProductId(await resolvePlanProductId());
    final orderProductId = limits.orderProductIdForKind(productKind);
    if (orderProductId == null) return null;

    final auth = SupabaseAuthService.instance;
    final client = auth.client;
    final userId = auth.userId;
    if (client == null || userId == null) return null;

    final normalized = cnpj.replaceAll(RegExp(r'\D'), '');
    try {
      final rows = await client
          .from('orders')
          .select()
          .eq('user_id', userId)
          .eq('product_id', orderProductId)
          .inFilter('status', ['em_analise', 'processando', 'concluido'])
          .order('created_at', ascending: false);

      for (final row in rows as List) {
        final map = Map<String, dynamic>.from(row as Map);
        final digits = (map['cnpj'] as String? ?? '')
            .replaceAll(RegExp(r'\D'), '');
        if (digits == normalized) {
          return CndOrderModel.fromJson(_orderRowToApiJson(map));
        }
      }
      return null;
    } catch (e) {
      debugPrint('PlanLimitsService.findActiveOrder: $e');
      return null;
    }
  }

  Future<int> suggestedTierForEmit(String productKind) async {
    final id = await resolvePlanProductId();
    final limits = await limitsForProductId(id);
    final cap = limits.limitForProductKind(productKind);
    if (cap <= 0) return 2;
    return 3;
  }

  /// Distinct active CNPJs that consume subscription quota.
  /// Consumable-funded orders (`one_time` / RC consumable SKUs) are excluded.
  Future<Set<String>> _distinctActiveCnpjsInPeriod(
    String productId,
    int quotaPeriodMonths,
  ) async {
    final auth = SupabaseAuthService.instance;
    final client = auth.client;
    final userId = auth.userId;
    if (client == null || userId == null) return {};

    try {
      final months = quotaPeriodMonths < 1 ? 1 : quotaPeriodMonths;
      final periodStart = DateTime.now().toUtc().subtract(
            Duration(days: 30 * months),
          );
      final rows = await client
          .from('orders')
          .select(
            'cnpj, payment_id, payment_status, '
            'payments(recurrence, rc_product_id, plan_id)',
          )
          .eq('user_id', userId)
          .eq('product_id', productId)
          .inFilter('status', ['em_analise', 'processando', 'concluido'])
          .gte('created_at', periodStart.toIso8601String());

      final out = <String>{};
      for (final row in rows as List) {
        final map = Map<String, dynamic>.from(row as Map);
        if (_isConsumableFundedOrder(map)) continue;
        final digits = (map['cnpj'] as String? ?? '')
            .replaceAll(RegExp(r'\D'), '');
        if (digits.length == 14) out.add(digits);
      }
      return out;
    } catch (e) {
      debugPrint('PlanLimitsService._distinctActiveCnpjsInPeriod: $e');
      return {};
    }
  }

  bool _isConsumableFundedOrder(Map<String, dynamic> orderRow) {
    final paymentRaw = orderRow['payments'];
    Map<String, dynamic>? payment;
    if (paymentRaw is Map) {
      payment = Map<String, dynamic>.from(paymentRaw);
    } else if (paymentRaw is List && paymentRaw.isNotEmpty) {
      final first = paymentRaw.first;
      if (first is Map) {
        payment = Map<String, dynamic>.from(first);
      }
    }
    if (payment == null) return false;

    if (payment['recurrence'] == 'one_time') return true;
    final rcProductId = payment['rc_product_id'] as String?;
    final planId = payment['plan_id'] as String?;
    return RevenueCatConfig.isConsumableProductId(rcProductId) ||
        RevenueCatConfig.isConsumableProductId(planId) ||
        RevenueCatConfig.isConsumablePackageId(planId ?? '') ||
        RevenueCatConfig.isConsumablePackageId(rcProductId ?? '');
  }

  Map<String, dynamic> _orderRowToApiJson(Map<String, dynamic> map) {
    return {
      'id': map['id'],
      'userId': map['user_id'] ?? map['userId'],
      'guestEmail': map['guest_email'] ?? map['guestEmail'],
      'guestPhone': map['guest_phone'] ?? map['guestPhone'],
      'productId': map['product_id'] ?? map['productId'],
      'selectedProductIds':
          map['selected_product_ids'] ?? map['selectedProductIds'],
      'totalCents': map['total_cents'] ?? map['totalCents'],
      'cnpj': map['cnpj'],
      'companyName': map['company_name'] ?? map['companyName'],
      'address': map['address'],
      'status': map['status'],
      'paymentStatus': map['payment_status'] ?? map['paymentStatus'],
      'createdAt': map['created_at']?.toString() ??
          map['createdAt']?.toString() ??
          DateTime.now().toIso8601String(),
      'updatedAt': map['updated_at']?.toString() ?? map['updatedAt']?.toString(),
    };
  }

  Future<void> cacheUserPlan({
    required String planProductId,
    required int tier,
    String? planTitle,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheProductKey, planProductId);
    await prefs.setInt(_cacheTierKey, tier);
    if (planTitle != null) {
      await prefs.setString(_cacheTitleKey, planTitle);
    }
  }

  Future<({String productId, int tier, String? title})?> readCachedUserPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final productId = prefs.getString(_cacheProductKey);
    final tier = prefs.getInt(_cacheTierKey);
    if (productId == null || tier == null) return null;
    return (
      productId: productId,
      tier: tier,
      title: prefs.getString(_cacheTitleKey),
    );
  }

  Future<void> clearUsageAndCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_dayKey);
      await prefs.remove(_countKey);
      await prefs.remove(_cacheProductKey);
      await prefs.remove(_cacheTierKey);
      await prefs.remove(_cacheTitleKey);
      _remoteByProduct.clear();
      _remoteFetchedAt = null;
    } catch (e) {
      debugPrint('PlanLimitsService.clearUsageAndCache: $e');
    }
  }

  int? _asNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  int _asInt(dynamic value, int fallback) {
    if (value == null) return fallback;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  Future<int> _todayCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayStamp();
    final storedDay = prefs.getString(_dayKey);
    if (storedDay != today) return 0;
    return prefs.getInt(_countKey) ?? 0;
  }

  String _todayStamp() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

/// Backward-compatible alias used by existing free-limit provider.
class FreeUserLimitsService {
  FreeUserLimitsService._();
  static final FreeUserLimitsService instance = FreeUserLimitsService._();

  Future<int> get dailyCnpjSearchLimit async {
    final limits = await PlanLimitsService.instance.limitsForProductId(
      UserPlanState.freePlanProductId,
    );
    return limits.dailyCnpjSearchLimit ?? 10;
  }

  Future<bool> canSearchCnpj() =>
      PlanLimitsService.instance.canSearchCnpj(
        planProductId: UserPlanState.freePlanProductId,
      );

  Future<void> recordCnpjSearch() =>
      PlanLimitsService.instance.recordCnpjSearch();
}

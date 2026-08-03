import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/services/paywall/paywall_service.dart';
import 'package:consulta_cnpj_new/services/paywall/revenuecat_config.dart';

part 'paywall_provider.g.dart';

enum PaywallLoadMode {
  idle,
  subscription,
  consumable,
}

class PaywallPlansState {
  const PaywallPlansState({
    this.plans = const [],
    this.isLoading = false,
    this.error,
    this.isPurchasing = false,
    this.mode = PaywallLoadMode.idle,
  });

  final List<PlanModel> plans;
  final bool isLoading;
  final String? error;
  final bool isPurchasing;
  final PaywallLoadMode mode;

  PlanModel? get selectedPlan {
    for (final plan in plans) {
      if (plan.isSelected) return plan;
    }
    if (plans.isEmpty) return null;
    return plans.first;
  }

  PaywallPlansState copyWith({
    List<PlanModel>? plans,
    bool? isLoading,
    String? error,
    bool? isPurchasing,
    PaywallLoadMode? mode,
  }) =>
      PaywallPlansState(
        plans: plans ?? this.plans,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isPurchasing: isPurchasing ?? this.isPurchasing,
        mode: mode ?? this.mode,
      );
}

@riverpod
class PaywallPlans extends _$PaywallPlans {
  String? _offeringId;
  List<String>? _packageIds;
  int _loadGeneration = 0;

  @override
  PaywallPlansState build() {
    // Screens call [loadDefault] / [loadConsumable] — avoid racing default
    // subscription offering into the consumable paywall.
    return const PaywallPlansState(isLoading: true);
  }

  Future<void> _load(PaywallLoadMode mode) async {
    final generation = ++_loadGeneration;
    try {
      final plans = await PaywallService.instance.getAvailablePlans(
        offeringId: _offeringId,
        packageIds: _packageIds,
      );
      if (generation != _loadGeneration) return;
      state = PaywallPlansState(plans: plans, mode: mode);
    } catch (e) {
      if (generation != _loadGeneration) return;
      state = PaywallPlansState(error: e.toString(), mode: mode);
    }
  }

  /// Original subscription offering (3 tiers).
  Future<void> loadDefault() async {
    _offeringId = null;
    _packageIds = null;
    state = const PaywallPlansState(
      isLoading: true,
      mode: PaywallLoadMode.subscription,
    );
    await _load(PaywallLoadMode.subscription);
  }

  /// Consumable experiment offering filtered by package ids.
  Future<void> loadConsumable({required List<String> packageIds}) async {
    _offeringId = RevenueCatConfig.consumableOfferingId;
    _packageIds = packageIds;
    state = const PaywallPlansState(
      isLoading: true,
      mode: PaywallLoadMode.consumable,
    );
    await _load(PaywallLoadMode.consumable);
  }

  Future<void> retry() async {
    final mode = state.mode == PaywallLoadMode.idle
        ? (RevenueCatConfig.isConsumableOfferingId(_offeringId)
            ? PaywallLoadMode.consumable
            : PaywallLoadMode.subscription)
        : state.mode;
    state = PaywallPlansState(isLoading: true, mode: mode);
    await _load(mode);
  }

  void selectPlan(String planId) {
    final updated = [
      for (final plan in state.plans)
        plan.copyWith(isSelected: plan.id == planId),
    ];
    state = state.copyWith(plans: updated);
  }

  void selectPlanByTier(int tier) {
    if (state.plans.isEmpty) return;
    final hasTier = state.plans.any((p) => p.tier == tier);
    if (!hasTier) return;
    final updated = [
      for (final plan in state.plans)
        plan.copyWith(isSelected: plan.tier == tier),
    ];
    state = state.copyWith(plans: updated);
  }

  /// Prefer a specific package id (consumable paywall).
  void selectPlanById(String planId) {
    if (state.plans.isEmpty) return;
    final has = state.plans.any((p) => p.id == planId);
    if (!has) return;
    selectPlan(planId);
  }

  /// Returns false if a purchase/restore flow is already in progress.
  bool beginPurchasing() {
    if (state.isPurchasing) return false;
    state = state.copyWith(isPurchasing: true);
    return true;
  }

  void endPurchasing() {
    if (!state.isPurchasing) return;
    state = state.copyWith(isPurchasing: false);
  }

  Future<bool> purchase(String planId) async {
    if (!beginPurchasing()) return false;
    try {
      final result = await PaywallService.instance.purchasePlan(
        planId,
        offeringId: _offeringId,
      );
      return result != null && result.plan.isPremium;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    } finally {
      endPurchasing();
    }
  }

  /// Purchase and return synced result (null if cancelled).
  ///
  /// Caller must [beginPurchasing] before and [endPurchasing] after the full
  /// post-purchase flow (analytics, premium apply, navigation).
  Future<PurchaseSyncResult?> purchaseAndSync(String planId) async {
    try {
      return await PaywallService.instance.purchasePlan(
        planId,
        offeringId: _offeringId,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<bool> restore() async {
    if (!beginPurchasing()) return false;
    try {
      final plan = await PaywallService.instance.restorePurchases();
      return plan?.isPremium ?? false;
    } finally {
      endPurchasing();
    }
  }

  /// Restore and return synced plan. Caller must [beginPurchasing] /
  /// [endPurchasing] around the full post-restore flow.
  Future<UserPlanState?> restoreAndSync() async {
    return PaywallService.instance.restorePurchases();
  }
}

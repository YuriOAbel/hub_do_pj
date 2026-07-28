import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/services/paywall/paywall_service.dart';

part 'paywall_provider.g.dart';

class PaywallPlansState {
  const PaywallPlansState({
    this.plans = const [],
    this.isLoading = false,
    this.error,
    this.isPurchasing = false,
  });

  final List<PlanModel> plans;
  final bool isLoading;
  final String? error;
  final bool isPurchasing;

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
  }) =>
      PaywallPlansState(
        plans: plans ?? this.plans,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isPurchasing: isPurchasing ?? this.isPurchasing,
      );
}

@riverpod
class PaywallPlans extends _$PaywallPlans {
  @override
  PaywallPlansState build() {
    _load();
    return const PaywallPlansState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final plans = await PaywallService.instance.getAvailablePlans();
      state = PaywallPlansState(plans: plans);
    } catch (e) {
      state = PaywallPlansState(error: e.toString());
    }
  }

  Future<void> retry() async {
    state = const PaywallPlansState(isLoading: true);
    await _load();
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
      final result = await PaywallService.instance.purchasePlan(planId);
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
      return await PaywallService.instance.purchasePlan(planId);
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

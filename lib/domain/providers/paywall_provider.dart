import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/domain/models/financial_card_model.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/services/financial_cards_service.dart';
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

  Future<bool> purchase(String planId) async {
    state = state.copyWith(isPurchasing: true);
    try {
      final ok = await PaywallService.instance.purchasePlan(planId);
      state = state.copyWith(isPurchasing: false);
      return ok;
    } catch (e) {
      state = state.copyWith(isPurchasing: false, error: e.toString());
      rethrow;
    }
  }

  Future<bool> restore() async {
    state = state.copyWith(isLoading: true);
    final ok = await PaywallService.instance.restorePurchases();
    state = state.copyWith(isLoading: false);
    return ok;
  }
}

@riverpod
class FinancialCards extends _$FinancialCards {
  @override
  Future<List<FinancialCardModel>> build() =>
      FinancialCardsService.instance.fetchCards();
}

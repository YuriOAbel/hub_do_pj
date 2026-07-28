import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/services/free_user_limits_service.dart';
import 'package:consulta_cnpj_new/services/payments_service.dart';
import 'package:consulta_cnpj_new/services/paywall/paywall_service.dart';
import 'package:consulta_cnpj_new/services/paywall/premium_config.dart';
import 'package:consulta_cnpj_new/services/revenuecat_service.dart';

part 'premium_status_provider.g.dart';

@Riverpod(keepAlive: true)
class PremiumStatus extends _$PremiumStatus {
  @override
  Future<UserPlanState> build() async {
    if (PremiumConfig.temporarilyUnlocked) {
      return const UserPlanState(
        planProductId: 'unlocked',
        tier: 3,
        planTitle: 'Premium',
      );
    }

    RevenueCatService.instance.registerPremiumStatusUpdater((info) async {
      if (PremiumConfig.temporarilyUnlocked) {
        state = const AsyncData(
          UserPlanState(
            planProductId: 'unlocked',
            tier: 3,
            planTitle: 'Premium',
          ),
        );
        return;
      }
      state = AsyncData(
        await PaymentsService.instance.syncUserPlan(customerInfo: info),
      );
    });

    try {
      return await PaymentsService.instance.syncUserPlan();
    } catch (_) {
      final cached = await PlanLimitsService.instance.readCachedUserPlan();
      if (cached != null) {
        return UserPlanState(
          planProductId: cached.productId,
          tier: cached.tier,
          planTitle: cached.title,
        );
      }
      final active = await PaywallService.instance.checkPremiumActive();
      return active
          ? const UserPlanState(planProductId: 'unknown', tier: 1)
          : const UserPlanState();
    }
  }

  Future<void> refresh() async {
    if (PremiumConfig.temporarilyUnlocked) {
      state = const AsyncData(
        UserPlanState(
          planProductId: 'unlocked',
          tier: 3,
          planTitle: 'Premium',
        ),
      );
      return;
    }
    // Keep previous value while syncing — gates must not fall back to free.
    final plan = await PaymentsService.instance.syncUserPlan();
    state = AsyncData(plan);
  }

  /// Apply plan immediately after purchase/restore (avoids free-tier race).
  void applyPlan(UserPlanState plan) {
    state = AsyncData(plan);
  }

  void activateMockPremium() {
    state = const AsyncData(
      UserPlanState(
        planProductId: 'unlocked',
        tier: 3,
        planTitle: 'Premium',
      ),
    );
  }
}

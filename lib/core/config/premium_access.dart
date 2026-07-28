import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/domain/providers/premium_status_provider.dart';
import 'package:consulta_cnpj_new/services/paywall/premium_config.dart';

bool isPremiumActive(WidgetRef ref) {
  if (PremiumConfig.temporarilyUnlocked) return true;
  return ref.read(premiumStatusProvider).value?.isPremium ?? false;
}

UserPlanState currentUserPlan(WidgetRef ref) {
  if (PremiumConfig.temporarilyUnlocked) {
    return const UserPlanState(
      planProductId: 'unlocked',
      tier: 3,
      planTitle: 'Premium',
    );
  }
  return ref.read(premiumStatusProvider).value ?? const UserPlanState();
}

/// Score / compliance features require Light (tier 2)+.
bool hasPlanTier(WidgetRef ref, int minTier) {
  if (PremiumConfig.temporarilyUnlocked) return true;
  return currentUserPlan(ref).tier >= minTier;
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/services/paywall/paywall_service.dart';
import 'package:consulta_cnpj_new/services/paywall/premium_config.dart';
import 'package:consulta_cnpj_new/services/revenuecat_service.dart';

part 'premium_status_provider.g.dart';

@Riverpod(keepAlive: true)
class PremiumStatus extends _$PremiumStatus {
  @override
  Future<bool> build() async {
    if (PremiumConfig.temporarilyUnlocked) return true;

    RevenueCatService.instance.registerPremiumStatusUpdater((info) async {
      if (PremiumConfig.temporarilyUnlocked) {
        state = const AsyncData(true);
        return;
      }
      state = AsyncData(
        RevenueCatService.instance.isPremiumActive(info),
      );
    });
    return PaywallService.instance.checkPremiumActive();
  }

  Future<void> refresh() async {
    if (PremiumConfig.temporarilyUnlocked) {
      state = const AsyncData(true);
      return;
    }
    state = const AsyncLoading();
    state = AsyncData(await PaywallService.instance.checkPremiumActive());
  }
}

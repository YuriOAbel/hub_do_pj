import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:consulta_cnpj_new/domain/providers/premium_status_provider.dart';
import 'package:consulta_cnpj_new/services/paywall/premium_config.dart';

bool isPremiumActive(WidgetRef ref) {
  if (PremiumConfig.temporarilyUnlocked) return true;
  return ref.read(premiumStatusProvider).value ?? false;
}

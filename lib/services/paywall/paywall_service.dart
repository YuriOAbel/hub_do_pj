import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/services/paywall/revenuecat_config.dart';
import 'package:consulta_cnpj_new/services/revenuecat_service.dart';

class PaywallService {
  PaywallService._();
  static final PaywallService instance = PaywallService._();

  static const _mockPlan = PlanModel(
    id: 'mock_plan',
    title: 'Premium',
    priceText: r'R$ 4,99',
    isSelected: true,
  );

  Future<List<PlanModel>> getAvailablePlans() async {
    if (RevenueCatConfig.useMock) return [_mockPlan];
    try {
      final offerings = await RevenueCatService.instance.getOfferings();
      final offering = offerings?.all[RevenueCatConfig.offeringId] ??
          offerings?.current;
      if (offering == null || offering.availablePackages.isEmpty) {
        return [_mockPlan];
      }
      return offering.availablePackages
          .map(
            (pkg) => PlanModel(
              id: pkg.identifier,
              title: pkg.storeProduct.title,
              priceText: pkg.storeProduct.priceString,
              isSelected: pkg == offering.availablePackages.first,
            ),
          )
          .toList();
    } on MissingPluginException {
      return [_mockPlan];
    } catch (e) {
      debugPrint('PaywallService.getAvailablePlans: $e');
      return [_mockPlan];
    }
  }

  Future<bool> purchasePlan(String planId) async {
    if (RevenueCatConfig.useMock) return true;
    try {
      final offerings = await RevenueCatService.instance.getOfferings();
      final offering = offerings?.all[RevenueCatConfig.offeringId] ??
          offerings?.current;
      if (offering == null) return false;
      final package = offering.availablePackages.firstWhere(
        (p) => p.identifier == planId,
        orElse: () => offering.availablePackages.first,
      );
      await RevenueCatService.instance.purchasePackage(package);
      return true;
    } on PurchaseCancelledException {
      return false;
    } on ProductAlreadyPurchasedException {
      return true;
    } catch (e) {
      debugPrint('PaywallService.purchasePlan: $e');
      rethrow;
    }
  }

  Future<bool> restorePurchases() async {
    if (RevenueCatConfig.useMock) return false;
    try {
      final info = await RevenueCatService.instance.restorePurchases();
      if (info == null) return false;
      return RevenueCatService.instance.isPremiumActive(info);
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkPremiumActive() async {
    if (RevenueCatConfig.useMock) return false;
    final info = await RevenueCatService.instance.getCustomerInfo();
    if (info == null) return false;
    return RevenueCatService.instance.isPremiumActive(info);
  }
}

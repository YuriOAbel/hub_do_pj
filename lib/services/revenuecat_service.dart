import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:consulta_cnpj_new/services/paywall/revenuecat_config.dart';

class PurchaseCancelledException implements Exception {}

class ProductAlreadyPurchasedException implements Exception {}

class RevenueCatService {
  RevenueCatService._();
  static final RevenueCatService instance = RevenueCatService._();

  final _customerInfoController = StreamController<CustomerInfo>.broadcast();
  Future<void> Function(CustomerInfo)? _premiumStatusUpdater;
  bool _isInitialized = false;

  Stream<CustomerInfo> get customerInfoStream =>
      _customerInfoController.stream;
  bool get isInitialized => _isInitialized;

  void registerPremiumStatusUpdater(Future<void> Function(CustomerInfo) fn) {
    _premiumStatusUpdater = fn;
  }

  Future<void> init() async {
    if (RevenueCatConfig.useMock || _isInitialized) return;
    try {
      await Purchases.configure(
        PurchasesConfiguration(RevenueCatConfig.apiKey),
      );
      if (RevenueCatConfig.isDebug) {
        await Purchases.setLogLevel(LogLevel.debug);
      }
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
      _isInitialized = true;
    } catch (e) {
      debugPrint('RevenueCatService.init: $e');
    }
  }

  void _onCustomerInfoUpdated(CustomerInfo info) {
    _customerInfoController.add(info);
  }

  Future<void> _notifyPremiumStatusUpdated(CustomerInfo info) async {
    try {
      await _premiumStatusUpdater?.call(info);
    } catch (_) {}
  }

  bool isPremiumActive(CustomerInfo info) {
    final entitlement =
        info.entitlements.all[RevenueCatConfig.premiumEntitlementId];
    return entitlement?.isActive ?? false;
  }

  Future<CustomerInfo?> getCustomerInfo() async {
    if (RevenueCatConfig.useMock) return null;
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('RevenueCatService.getCustomerInfo: $e');
      return null;
    }
  }

  Future<Offerings?> getOfferings() async {
    if (RevenueCatConfig.useMock) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('RevenueCatService.getOfferings: $e');
      return null;
    }
  }

  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      final info = await Purchases.purchasePackage(package);
      if (isPremiumActive(info)) {
        await _notifyPremiumStatusUpdated(info);
      }
      return info;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        throw PurchaseCancelledException();
      }
      if (code == PurchasesErrorCode.productAlreadyPurchasedError) {
        throw ProductAlreadyPurchasedException();
      }
      rethrow;
    }
  }

  Future<CustomerInfo?> restorePurchases() async {
    if (RevenueCatConfig.useMock) return null;
    try {
      final info = await Purchases.restorePurchases();
      if (isPremiumActive(info)) await _notifyPremiumStatusUpdated(info);
      return info;
    } catch (e) {
      debugPrint('RevenueCatService.restorePurchases: $e');
      return null;
    }
  }
}

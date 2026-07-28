import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/services/payments_service.dart';
import 'package:consulta_cnpj_new/services/paywall/revenuecat_config.dart';
import 'package:consulta_cnpj_new/services/revenuecat_service.dart';

class PaywallService {
  PaywallService._();
  static final PaywallService instance = PaywallService._();

  static const _plansAsset = 'assets/config/paywall_plans.json';

  List<PlanModel>? _cachedMockPlans;

  Future<List<PlanModel>> getAvailablePlans() async {
    if (RevenueCatConfig.forceMockPlans) return _loadMockPlans();
    if (RevenueCatConfig.useMock) return _loadMockPlans();
    try {
      final offering = await _fetchOffering();
      if (offering == null || offering.availablePackages.isEmpty) {
        // Never mix mock plan ids with live RC purchase path.
        throw StateError(
          'Offering "${RevenueCatConfig.offeringId}" unavailable or empty',
        );
      }
      debugPrint(
        'PaywallService: offering=${RevenueCatConfig.offeringId} '
        'packages=${offering.availablePackages.map((p) => p.identifier).join(",")} '
        'metadataKeys=${offering.metadata.keys.join(",")}',
      );
      final packages = offering.availablePackages;
      final plans = [
        for (var i = 0; i < packages.length; i++)
          _mapPackageToPlan(
            packages[i],
            tier: i + 1,
            offeringMetadata: offering.metadata,
          ),
      ];
      return _ensureSingleSelection(plans);
    } on MissingPluginException {
      return _loadMockPlans();
    } catch (e) {
      debugPrint('PaywallService.getAvailablePlans: $e');
      rethrow;
    }
  }

  Future<Offering?> _fetchOffering() async {
    final offerings = await RevenueCatService.instance.getOfferings();
    if (offerings == null) return null;

    final offeringId = RevenueCatConfig.offeringId;
    if (offeringId.isEmpty) {
      if (RevenueCatConfig.useTestStore) {
        debugPrint(
          'PaywallService: RC_TEST_OFFERING_ID empty — set in .env',
        );
        return null;
      }
      return offerings.current;
    }

    final offering = offerings.all[offeringId];
    if (offering != null) return offering;

    // Test mode: never fall back to another offering.
    if (RevenueCatConfig.useTestStore) {
      debugPrint(
        'PaywallService: offering "$offeringId" missing. '
        'available=${offerings.all.keys.join(",")}',
      );
      return null;
    }

    return offerings.current;
  }

  /// Maps RC package + offering metadata key `plan_{tier}`.
  ///
  /// Expected offering metadata (test + prod):
  /// ```json
  /// {
  ///   "plan_1": { "title": "...", "subtitle": "", "badgeText": null, "isSelected": false },
  ///   "plan_2": { ... },
  ///   "plan_3": { ... }
  /// }
  /// ```
  PlanModel _mapPackageToPlan(
    Package pkg, {
    required int tier,
    required Map<String, Object> offeringMetadata,
  }) {
    final meta = _planMetadata(offeringMetadata, tier);
    final title = _metaString(meta, 'title');
    final subtitle = _metaString(meta, 'subtitle');
    final badgeText = _metaString(meta, 'badgeText');
    final isSelected = _metaBool(meta, 'isSelected') ?? false;

    return PlanModel(
      id: pkg.identifier,
      title: (title != null && title.isNotEmpty)
          ? title
          : pkg.storeProduct.title,
      priceText: pkg.storeProduct.priceString,
      tier: tier,
      badgeText: (badgeText != null && badgeText.isNotEmpty) ? badgeText : null,
      subtitle: (subtitle != null && subtitle.isNotEmpty) ? subtitle : null,
      isSelected: isSelected,
      periodLabel: _periodLabel(
        packageType: pkg.packageType,
        subscriptionPeriod: pkg.storeProduct.subscriptionPeriod,
      ),
      productId: pkg.storeProduct.identifier,
      price: pkg.storeProduct.price,
      currencyCode: _currencyFromStoreProduct(pkg.storeProduct),
    );
  }

  /// ISO 4217 from RevenueCat `StoreProduct.currencyCode` (uppercase).
  String _currencyFromStoreProduct(StoreProduct product) {
    final code = product.currencyCode.trim().toUpperCase();
    return code.isNotEmpty ? code : 'BRL';
  }

  String _normalizeCurrencyCode(String? code) {
    final normalized = (code ?? '').trim().toUpperCase();
    return normalized.isNotEmpty ? normalized : 'BRL';
  }

  /// Parses display strings like `R$ 14,99` / `R$ 149,99` into a double.
  double _parseBrlPriceText(String priceText) {
    final match = RegExp(r'(\d+),(\d{2})').firstMatch(priceText);
    if (match != null) {
      return double.parse('${match.group(1)}.${match.group(2)}');
    }
    return double.tryParse(
          priceText.replaceAll(RegExp(r'[^\d.]'), ''),
        ) ??
        0;
  }

  String? _periodLabel({
    required PackageType packageType,
    String? subscriptionPeriod,
  }) {
    if (packageType == PackageType.annual) return '/ano';
    if (packageType == PackageType.monthly) return '/mês';

    final period = (subscriptionPeriod ?? '').toUpperCase();
    if (period.contains('Y') || period == 'P1Y') return '/ano';
    if (period.contains('M') || period == 'P1M') return '/mês';
    return '/mês';
  }

  Map<String, dynamic>? _planMetadata(
    Map<String, Object> offeringMetadata,
    int tier,
  ) {
    final raw = offeringMetadata['plan_$tier'];
    if (raw == null) return null;

    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }

    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (e) {
        debugPrint('PaywallService: invalid plan_$tier metadata JSON: $e');
      }
    }

    return null;
  }

  String? _metaString(Map<String, dynamic>? meta, String key) {
    if (meta == null) return null;
    final value = meta[key];
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  bool? _metaBool(Map<String, dynamic>? meta, String key) {
    if (meta == null) return null;
    final value = meta[key];
    if (value is bool) return value;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
    return null;
  }

  /// Exactly one plan selected; if none/metadata missing, pick middle tier.
  List<PlanModel> _ensureSingleSelection(List<PlanModel> plans) {
    if (plans.isEmpty) return plans;

    final selectedCount = plans.where((p) => p.isSelected).length;
    if (selectedCount == 1) return plans;

    final fallbackIndex = plans.length ~/ 2;
    return [
      for (var i = 0; i < plans.length; i++)
        plans[i].copyWith(isSelected: i == fallbackIndex),
    ];
  }

  Future<List<PlanModel>> _loadMockPlans() async {
    if (_cachedMockPlans != null) return _cachedMockPlans!;
    try {
      final raw = await rootBundle.loadString(_plansAsset);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final metadataRaw = json['offeringMetadata'];
      final metadata = <String, Object>{};
      if (metadataRaw is Map) {
        for (final entry in metadataRaw.entries) {
          final value = entry.value;
          if (value != null) {
            metadata[entry.key.toString()] = value as Object;
          }
        }
      }

      final list = (json['plans'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map((map) {
            final tier = (map['tier'] as num?)?.toInt() ?? 1;
            final meta = _planMetadata(metadata, tier);
            final title = _metaString(meta, 'title') ?? map['title'] as String;
            final subtitle =
                _metaString(meta, 'subtitle') ?? map['subtitle'] as String?;
            final badgeText =
                _metaString(meta, 'badgeText') ?? map['badgeText'] as String?;
            final isSelected = _metaBool(meta, 'isSelected') ??
                map['isSelected'] as bool? ??
                false;

            final priceText = map['priceText'] as String;
            return PlanModel(
              id: map['id'] as String,
              title: title,
              priceText: priceText,
              tier: tier,
              badgeText:
                  (badgeText != null && badgeText.isNotEmpty) ? badgeText : null,
              subtitle:
                  (subtitle != null && subtitle.isNotEmpty) ? subtitle : null,
              isSelected: isSelected,
              periodLabel: map['periodLabel'] as String? ?? '/mês',
              productId: map['productId'] as String? ?? map['id'] as String,
              price: (map['price'] as num?)?.toDouble() ??
                  _parseBrlPriceText(priceText),
              currencyCode: _normalizeCurrencyCode(
                map['currencyCode'] as String?,
              ),
            );
          })
          .toList();
      _cachedMockPlans = _ensureSingleSelection(list);
      return _cachedMockPlans!;
    } catch (e) {
      debugPrint('PaywallService._loadMockPlans: $e');
      return const [
        PlanModel(
          id: 'app_access',
          productId: 'app_access',
          title: 'Liberar acesso do app',
          priceText: r'R$ 14,99',
          periodLabel: '/mês',
          tier: 1,
          isSelected: false,
          price: 14.99,
          currencyCode: 'BRL',
        ),
        PlanModel(
          id: 'compliance_light',
          productId: 'compliance_light',
          title: 'Compliance light',
          subtitle: 'Liberado até 2 CNPJs',
          priceText: r'R$ 49,99',
          periodLabel: '/mês',
          tier: 2,
          badgeText: 'Melhor valor',
          isSelected: true,
          price: 49.99,
          currencyCode: 'BRL',
        ),
        PlanModel(
          id: 'compliance_plus',
          productId: 'compliance_plus',
          title: 'Compliance plus',
          subtitle: 'Liberado até 10 CNPJs',
          priceText: r'R$ 149,99',
          periodLabel: '/mês',
          tier: 3,
          isSelected: false,
          price: 149.99,
          currencyCode: 'BRL',
        ),
      ];
    }
  }

  Future<PurchaseSyncResult?> purchasePlan(String planId) async {
    if (RevenueCatConfig.forceMockPlans || RevenueCatConfig.useMock) {
      final mockPlans = await _loadMockPlans();
      PlanModel? mockPlan;
      for (final p in mockPlans) {
        if (p.id == planId || p.productId == planId) {
          mockPlan = p;
          break;
        }
      }
      mockPlan ??= mockPlans.isNotEmpty ? mockPlans.first : null;
      final productId =
          mockPlan?.productId ?? mockPlan?.id ?? planId;
      final tier = mockPlan?.tier ?? 3;
      final plan = await PaymentsService.instance.syncUserPlan(
        planId: productId,
        knownTier: tier,
        knownProductId: productId,
        planTitle: mockPlan?.title ?? 'Premium',
      );
      return PurchaseSyncResult(
        plan: plan.isPremium
            ? plan
            : UserPlanState(
                planProductId: productId,
                tier: tier,
                planTitle: mockPlan?.title ?? 'Premium',
              ),
        transactionId:
            'mock_${planId}_${DateTime.now().millisecondsSinceEpoch}',
        price: mockPlan?.price ?? 0,
        currencyCode: _normalizeCurrencyCode(mockPlan?.currencyCode),
      );
    }
    try {
      final offering = await _fetchOffering();
      if (offering == null) {
        throw Exception(
          'Offering not found: ${RevenueCatConfig.offeringId}',
        );
      }
      final package = offering.availablePackages.firstWhere(
        (p) => p.identifier == planId,
        orElse: () => throw Exception('Package not found: $planId'),
      );
      final storePrice = package.storeProduct.price;
      final storeCurrency = _currencyFromStoreProduct(package.storeProduct);
      try {
        final purchaseResult =
            await RevenueCatService.instance.purchasePackage(package);
        if (purchaseResult == null) return null;
        final info = purchaseResult.customerInfo;
        // Prefer package product id + package index as tier source of truth.
        final productId = package.storeProduct.identifier;
        final tier = offering.availablePackages.indexOf(package) + 1;
        final plan = await PaymentsService.instance.syncUserPlan(
          customerInfo: info,
          planId: productId,
          packageType: package.packageType,
          planTitle: null,
          knownTier: tier > 0 ? tier : null,
          knownProductId: productId,
        );
        final txId = purchaseResult.storeTransaction.transactionIdentifier;
        return PurchaseSyncResult(
          plan: plan,
          transactionId: txId.isNotEmpty
              ? txId
              : '${productId}_${DateTime.now().millisecondsSinceEpoch}',
          price: storePrice,
          currencyCode: storeCurrency,
        );
      } on PurchaseCancelledException {
        return null;
      } on ProductAlreadyPurchasedException {
        final plan =
            await PaymentsService.instance.syncUserPlan(planId: planId);
        return PurchaseSyncResult(
          plan: plan,
          price: storePrice,
          currencyCode: storeCurrency,
        );
      }
    } catch (e) {
      debugPrint('PaywallService.purchasePlan: $e');
      rethrow;
    }
  }

  Future<UserPlanState?> restorePurchases() async {
    if (RevenueCatConfig.forceMockPlans || RevenueCatConfig.useMock) {
      return null;
    }
    try {
      final info = await RevenueCatService.instance.restorePurchases();
      if (info == null) return null;
      final active = RevenueCatService.instance.isPremiumActive(info);
      if (!active) {
        return PaymentsService.instance.syncUserPlan(customerInfo: info);
      }
      return PaymentsService.instance.syncUserPlan(customerInfo: info);
    } catch (_) {
      return null;
    }
  }

  Future<bool> checkPremiumActive() async {
    if (RevenueCatConfig.forceMockPlans || RevenueCatConfig.useMock) {
      return false;
    }
    final info = await RevenueCatService.instance.getCustomerInfo();
    if (info == null) return false;
    return RevenueCatService.instance.isPremiumActive(info);
  }

  Future<UserPlanState> resolveCurrentUserPlan() =>
      PaymentsService.instance.syncUserPlan();
}

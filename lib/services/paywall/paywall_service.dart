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

  Future<List<PlanModel>> getAvailablePlans({
    String? offeringId,
    List<String>? packageIds,
  }) async {
    if (RevenueCatConfig.forceMockPlans) {
      return _filterPlans(
        await _loadMockPlans(forConsumable: offeringId != null),
        packageIds,
      );
    }
    if (RevenueCatConfig.useMock) {
      return _filterPlans(
        await _loadMockPlans(forConsumable: offeringId != null),
        packageIds,
      );
    }
    try {
      final resolvedOfferingId = offeringId ?? RevenueCatConfig.offeringId;
      final offering = await _fetchOffering(offeringId: resolvedOfferingId);
      if (offering == null || offering.availablePackages.isEmpty) {
        throw StateError(
          'Offering "$resolvedOfferingId" unavailable or empty',
        );
      }
      debugPrint(
        'PaywallService: offering=$resolvedOfferingId '
        'packages=${offering.availablePackages.map((p) => p.identifier).join(",")} '
        'metadataKeys=${offering.metadata.keys.join(",")}',
      );
      var packages = offering.availablePackages;
      if (packageIds != null && packageIds.isNotEmpty) {
        final wanted = packageIds.toSet();
        packages = [
          for (final p in packages)
            if (wanted.contains(p.identifier)) p,
        ];
        // Preserve caller order when possible.
        packages.sort((a, b) {
          final ai = packageIds.indexOf(a.identifier);
          final bi = packageIds.indexOf(b.identifier);
          return ai.compareTo(bi);
        });
      }
      if (packages.isEmpty) {
        throw StateError(
          'Offering "$resolvedOfferingId" has no matching packages '
          '(filter=${packageIds?.join(",")})',
        );
      }
      final usePackageMeta =
          RevenueCatConfig.isConsumableOfferingId(resolvedOfferingId);
      final plans = [
        for (var i = 0; i < packages.length; i++)
          _mapPackageToPlan(
            packages[i],
            tier: _tierForPackage(packages[i], index: i),
            offeringMetadata: offering.metadata,
            metadataByPackageId: usePackageMeta,
          ),
      ];
      return _ensureSingleSelection(plans);
    } on MissingPluginException {
      return _filterPlans(
        await _loadMockPlans(forConsumable: offeringId != null),
        packageIds,
      );
    } catch (e) {
      debugPrint('PaywallService.getAvailablePlans: $e');
      rethrow;
    }
  }

  List<PlanModel> _filterPlans(
    List<PlanModel> plans,
    List<String>? packageIds,
  ) {
    if (packageIds == null || packageIds.isEmpty) return plans;
    final wanted = packageIds.toSet();
    final filtered = [
      for (final id in packageIds)
        for (final plan in plans)
          if (plan.id == id || plan.productId == id) plan,
    ];
    if (filtered.isNotEmpty) return _ensureSingleSelection(filtered);
    final fallback = [
      for (final plan in plans)
        if (wanted.contains(plan.id) ||
            (plan.productId != null && wanted.contains(plan.productId)))
          plan,
    ];
    return _ensureSingleSelection(fallback);
  }

  int _tierForPackage(Package pkg, {required int index}) {
    if (RevenueCatConfig.isMonthlyCpProductId(pkg.identifier) ||
        RevenueCatConfig.isMonthlyCpProductId(pkg.storeProduct.identifier)) {
      return 2;
    }
    if (RevenueCatConfig.isConsumablePackageId(pkg.identifier)) {
      return 2;
    }
    return index + 1;
  }

  Future<Offering?> _fetchOffering({String? offeringId}) async {
    final offerings = await RevenueCatService.instance.getOfferings();
    if (offerings == null) return null;

    final id = offeringId ?? RevenueCatConfig.offeringId;
    if (id.isEmpty) {
      if (RevenueCatConfig.useTestStore) {
        debugPrint(
          'PaywallService: RC_TEST_OFFERING_ID empty — set in .env',
        );
        return null;
      }
      return offerings.current;
    }

    final offering = offerings.all[id];
    if (offering != null) return offering;

    // Test mode: never fall back to another offering.
    if (RevenueCatConfig.useTestStore) {
      debugPrint(
        'PaywallService: offering "$id" missing. '
        'available=${offerings.all.keys.join(",")}',
      );
      return null;
    }

    // Consumable offering must not fall back to subscription offering.
    if (RevenueCatConfig.isConsumableOfferingId(id)) {
      debugPrint(
        'PaywallService: consumable offering "$id" missing. '
        'available=${offerings.all.keys.join(",")}',
      );
      return null;
    }

    return offerings.current;
  }

  /// Maps RC package + offering metadata.
  ///
  /// Subscription offerings use `plan_{tier}`.
  /// Consumable offering uses package identifier keys:
  /// ```json
  /// {
  ///   "hub_pj_mensal_cp": { "title": "...", "subtitle": "...", "isSelected": true },
  ///   "hub_pj_certidoes_app": { "isSelected": false, ... }
  /// }
  /// ```
  /// `isSelected` drives the initial highlighted plan.
  PlanModel _mapPackageToPlan(
    Package pkg, {
    required int tier,
    required Map<String, Object> offeringMetadata,
    bool metadataByPackageId = false,
  }) {
    final meta = metadataByPackageId
        ? _packageMetadata(offeringMetadata, pkg.identifier)
        : _planMetadata(offeringMetadata, tier);
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
        packageId: pkg.identifier,
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
    String? packageId,
  }) {
    if (packageId != null &&
        RevenueCatConfig.isConsumablePackageId(packageId)) {
      return null;
    }
    if (packageType == PackageType.annual) return '/ano';
    if (packageType == PackageType.monthly) return '/mês';
    if (packageType == PackageType.custom ||
        packageType == PackageType.unknown) {
      final period = (subscriptionPeriod ?? '').toUpperCase();
      if (period.isEmpty) return null;
    }

    final period = (subscriptionPeriod ?? '').toUpperCase();
    if (period.contains('Y') || period == 'P1Y') return '/ano';
    if (period.contains('M') || period == 'P1M') return '/mês';
    return '/mês';
  }

  Map<String, dynamic>? _planMetadata(
    Map<String, Object> offeringMetadata,
    int tier,
  ) {
    return _decodeMetadata(offeringMetadata['plan_$tier'], label: 'plan_$tier');
  }

  Map<String, dynamic>? _packageMetadata(
    Map<String, Object> offeringMetadata,
    String packageId,
  ) {
    return _decodeMetadata(
      offeringMetadata[packageId],
      label: packageId,
    );
  }

  Map<String, dynamic>? _decodeMetadata(Object? raw, {required String label}) {
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
        debugPrint('PaywallService: invalid $label metadata JSON: $e');
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

  /// Exactly one plan selected from offering metadata `isSelected`.
  /// If several are flagged (e.g. monthly + consumable), keep the last.
  /// If none, pick middle index.
  List<PlanModel> _ensureSingleSelection(List<PlanModel> plans) {
    if (plans.isEmpty) return plans;

    final selectedCount = plans.where((p) => p.isSelected).length;
    if (selectedCount == 1) return plans;

    var keepIndex = plans.length ~/ 2;
    if (selectedCount > 1) {
      for (var i = 0; i < plans.length; i++) {
        if (plans[i].isSelected) keepIndex = i;
      }
    }

    return [
      for (var i = 0; i < plans.length; i++)
        plans[i].copyWith(isSelected: i == keepIndex),
    ];
  }

  Future<List<PlanModel>> _loadMockPlans({bool forConsumable = false}) async {
    if (!forConsumable && _cachedMockPlans != null) return _cachedMockPlans!;
    if (forConsumable) {
      return _ensureSingleSelection(const [
        PlanModel(
          id: RevenueCatConfig.monthlyCpPackageId,
          productId: RevenueCatConfig.monthlyCpPackageId,
          title: 'Plano mensal compliance',
          subtitle: 'Voce paga e recebe todo o mes',
          priceText: r'R$ 49,99',
          periodLabel: '/mês',
          tier: 2,
          isSelected: true,
          price: 49.99,
          currencyCode: 'BRL',
        ),
        PlanModel(
          id: RevenueCatConfig.certidoesConsumablePackageId,
          productId: RevenueCatConfig.certidoesConsumablePackageId,
          title: 'Pagamento único no valor',
          subtitle: 'Voce paga e recebe uma vez',
          priceText: r'R$ 29,99',
          tier: 2,
          isSelected: false,
          price: 29.99,
          currencyCode: 'BRL',
        ),
        PlanModel(
          id: RevenueCatConfig.restricoesConsumablePackageId,
          productId: RevenueCatConfig.restricoesConsumablePackageId,
          title: 'Pagamento único no valor',
          subtitle: 'Voce paga e recebe uma vez',
          priceText: r'R$ 19,99',
          tier: 2,
          isSelected: true,
          price: 19.99,
          currencyCode: 'BRL',
        ),
        PlanModel(
          id: RevenueCatConfig.protestosConsumablePackageId,
          productId: RevenueCatConfig.protestosConsumablePackageId,
          title: 'Pagamento único no valor',
          subtitle: 'Voce paga e recebe uma vez',
          priceText: r'R$ 19,99',
          tier: 2,
          isSelected: true,
          price: 19.99,
          currencyCode: 'BRL',
        ),
      ]);
    }
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

  Future<PurchaseSyncResult?> purchasePlan(
    String planId, {
    String? offeringId,
  }) async {
    if (RevenueCatConfig.forceMockPlans || RevenueCatConfig.useMock) {
      final mockPlans = await _loadMockPlans(
        forConsumable: RevenueCatConfig.isConsumableOfferingId(offeringId),
      );
      PlanModel? mockPlan;
      for (final p in mockPlans) {
        if (p.id == planId || p.productId == planId) {
          mockPlan = p;
          break;
        }
      }
      mockPlan ??= mockPlans.isNotEmpty ? mockPlans.first : null;
      final productId = mockPlan?.productId ?? mockPlan?.id ?? planId;

        if (RevenueCatConfig.isConsumablePackageId(planId) ||
          RevenueCatConfig.isConsumableProductId(productId)) {
        final paymentId =
            await PaymentsService.instance.recordConsumablePurchase(
          productId: productId,
          planId: planId,
        );
        return PurchaseSyncResult(
          plan: const UserPlanState(),
          transactionId:
              'mock_consumable_${planId}_${DateTime.now().millisecondsSinceEpoch}',
          price: mockPlan?.price ?? 0,
          currencyCode: _normalizeCurrencyCode(mockPlan?.currencyCode),
          paymentId: paymentId,
        );
      }

      final tier = RevenueCatConfig.tierForPlanProductId(productId) ??
          mockPlan?.tier ??
          3;
      final canonicalId =
          RevenueCatConfig.normalizeStoreProductId(productId);
      final plan = await PaymentsService.instance.syncUserPlan(
        planId: canonicalId,
        knownTier: tier,
        knownProductId: canonicalId,
        planTitle: mockPlan?.title ?? 'Premium',
      );
      return PurchaseSyncResult(
        plan: plan.isPremium
            ? plan
            : UserPlanState(
                planProductId: canonicalId,
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
      final resolvedOfferingId = offeringId ?? RevenueCatConfig.offeringId;
      final offering = await _fetchOffering(offeringId: resolvedOfferingId);
      if (offering == null) {
        throw Exception('Offering not found: $resolvedOfferingId');
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
        final storeProductId = package.storeProduct.identifier;
        final txId = purchaseResult.storeTransaction.transactionIdentifier;

        if (RevenueCatConfig.isConsumablePackageId(package.identifier) ||
            RevenueCatConfig.isConsumableProductId(storeProductId)) {
          final paymentId =
              await PaymentsService.instance.recordConsumablePurchase(
            customerInfo: info,
            productId: storeProductId,
            planId: package.identifier,
            packageType: package.packageType,
          );
          return PurchaseSyncResult(
            plan: const UserPlanState(),
            transactionId: txId.isNotEmpty
                ? txId
                : '${storeProductId}_${DateTime.now().millisecondsSinceEpoch}',
            price: storePrice,
            currencyCode: storeCurrency,
            paymentId: paymentId,
          );
        }

        final canonicalId =
            RevenueCatConfig.normalizeStoreProductId(storeProductId);
        final tier = RevenueCatConfig.tierForPlanProductId(canonicalId) ??
            _tierForPackage(
              package,
              index: offering.availablePackages.indexOf(package),
            );
        final plan = await PaymentsService.instance.syncUserPlan(
          customerInfo: info,
          planId: canonicalId,
          packageType: package.packageType,
          planTitle: null,
          knownTier: tier > 0 ? tier : null,
          knownProductId: canonicalId,
        );
        return PurchaseSyncResult(
          plan: plan,
          transactionId: txId.isNotEmpty
              ? txId
              : '${canonicalId}_${DateTime.now().millisecondsSinceEpoch}',
          price: storePrice,
          currencyCode: storeCurrency,
        );
      } on PurchaseCancelledException {
        return null;
      } on ProductAlreadyPurchasedException {
        if (RevenueCatConfig.isConsumablePackageId(planId) ||
            RevenueCatConfig.isConsumableProductId(planId) ||
            RevenueCatConfig.isConsumableProductId(
              package.storeProduct.identifier,
            )) {
          return null;
        }
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

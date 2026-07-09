# Skill: Payment Core

Architecture and implementation patterns for in-app subscriptions/purchases using RevenueCat (`purchases_flutter`) in Flutter apps with Riverpod.

## Key Files

- `lib/services/paywall/paywall_service.dart`
- `lib/services/revenuecat_service.dart`
- `lib/domain/providers/paywall_plans_provider.dart`
- `lib/presentation/paywall_screen/paywall_screen.dart`
- `lib/presentation/paywall_screen/widgets/paywall_plan_card.dart`
- `lib/presentation/paywall_screen/widgets/recovery_offer_bottom_sheet.dart`

---

## Mandatory layer rule

```
View → Provider/Notifier → Service
```

**View never calls Service directly.** No `PaywallService.instance` or `RevenueCatService.instance` inside widget code. All purchase actions go through the provider notifier. All state is read from `StateNotifier` state.

---

## Layer responsibilities

| Layer | File pattern | Responsibility |
|---|---|---|
| **RevenueCatService** | `lib/services/revenuecat_service.dart` | Thin SDK wrapper. Init, stream, `getOfferings`, `purchasePackage`, `restorePurchases`, `isPremiumActive`. Normalizes SDK errors into domain exceptions. |
| **PaywallService** | `lib/services/paywall/paywall_service.dart` | Orchestration. Fetches offerings, maps to `PlanModel`, purchases by plan ID, restores. Mock mode support. Single source of truth for purchase contract. |
| **Provider/Notifier** | `lib/domain/providers/paywall_plans_provider.dart` | Riverpod `StateNotifier`. Holds `PaywallPlansState` (plans, isLoading, error). Bridges view and service. |
| **View** | `lib/presentation/paywall_screen/` | Reads state, calls notifier methods, never imports services. |

---

## Flow Rules

- Paywall UI delegates orchestration to provider/notifier.
- Provider delegates business logic to `PaywallService`.
- `PaywallService` is single entry point for offerings, purchase, and restore.
- Purchase contract: `true` success, `false` user-cancelled, throw on real failure.

---

## File templates

### `revenuecat_config.dart`

```dart
class RevenueCatConfig {
  static const String apiKey = String.fromEnvironment('RC_API_KEY');
  static const String offeringId = 'default'; // or remote-config-driven
  static const bool isDebug = bool.fromEnvironment('RC_DEBUG', defaultValue: false);
  static bool get useMock => apiKey.isEmpty;
}
```

---

### `revenuecat_service.dart`

```dart
class RevenueCatService {
  RevenueCatService._();
  static final RevenueCatService instance = RevenueCatService._();

  final _customerInfoController = StreamController<CustomerInfo>.broadcast();
  Future<void> Function(CustomerInfo)? _premiumStatusUpdater;

  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  void registerPremiumStatusUpdater(Future<void> Function(CustomerInfo) fn) {
    _premiumStatusUpdater = fn;
  }

  Future<void> init() async {
    if (RevenueCatConfig.useMock || _isInitialized) return;
    await Purchases.configure(PurchasesConfiguration(RevenueCatConfig.apiKey));
    if (RevenueCatConfig.isDebug) await Purchases.setLogLevel(LogLevel.debug);
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
    if (Platform.isIOS) _setupPromotedPurchaseListener();
    _isInitialized = true;
  }

  void _onCustomerInfoUpdated(CustomerInfo info) =>
      _customerInfoController.add(info);

  Future<void> _notifyPremiumStatusUpdated(CustomerInfo info) async {
    try { await _premiumStatusUpdater?.call(info); } catch (_) {}
  }

  bool isPremiumActive(CustomerInfo info) =>
      info.entitlements.all.values.any((e) => e.isActive);

  Future<Offerings> getOfferings() => Purchases.getOfferings();
  Future<CustomerInfo> getCustomerInfo() => Purchases.getCustomerInfo();

  Future<CustomerInfo> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      if (isPremiumActive(result.customerInfo)) {
        await _notifyPremiumStatusUpdated(result.customerInfo);
      }
      return result.customerInfo;
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

  Future<CustomerInfo> restorePurchases() async {
    final info = await Purchases.restorePurchases();
    if (isPremiumActive(info)) await _notifyPremiumStatusUpdated(info);
    return info;
  }
}

class PurchaseCancelledException implements Exception {}
class ProductAlreadyPurchasedException implements Exception {}
```

Key points:
- Singleton via `instance`.
- `_premiumStatusUpdater` callback lets other providers react to entitlement changes without coupling.
- Platform errors → domain exceptions (`PurchaseCancelledException`, `ProductAlreadyPurchasedException`).
- iOS promoted purchases handled inside service, invisible to upper layers.

---

### `paywall_service.dart`

```dart
class PaywallService {
  PaywallService._();
  static final PaywallService instance = PaywallService._();

  // Mock plan used when no API key is set (UI dev / CI)
  static const _mockPlan = PlanModel(
    id: 'mock_plan',
    title: 'Premium',
    priceText: r'$9.99',
    isSelected: true,
  );

  Future<List<PlanModel>> getAvailablePlans() async {
    if (RevenueCatConfig.useMock) return [_mockPlan];
    try {
      final offerings = await RevenueCatService.instance.getOfferings();
      final offering =
          offerings.all[RevenueCatConfig.offeringId] ?? offerings.current;
      if (offering == null || offering.availablePackages.isEmpty) {
        return [_mockPlan];
      }
      return _mapOffering(offering);
    } on MissingPluginException {
      return [_mockPlan]; // desktop / test runner
    } catch (e) {
      rethrow;
    }
  }

  List<PlanModel> _mapOffering(Offering offering) {
    return offering.availablePackages.map((pkg) {
      return PlanModel(
        id: pkg.identifier,
        title: pkg.storeProduct.title,
        priceText: pkg.storeProduct.priceString,
        isSelected: pkg == offering.availablePackages.first,
      );
    }).toList();
  }

  /// Returns `true` on success, `false` on user cancel, throws on real error.
  Future<bool> purchasePlan(String planId) async {
    if (RevenueCatConfig.useMock) return true;
    try {
      final offerings = await RevenueCatService.instance.getOfferings();
      final offering =
          offerings.all[RevenueCatConfig.offeringId] ?? offerings.current;
      if (offering == null) throw Exception('No offering available');
      final package = offering.availablePackages.firstWhere(
        (p) => p.identifier == planId,
        orElse: () => throw Exception('Package not found: $planId'),
      );
      await RevenueCatService.instance.purchasePackage(package);
      return true;
    } on PurchaseCancelledException {
      return false;
    } on ProductAlreadyPurchasedException {
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> restorePurchases() async {
    if (RevenueCatConfig.useMock) return false;
    try {
      final info = await RevenueCatService.instance.restorePurchases();
      return RevenueCatService.instance.isPremiumActive(info);
    } catch (_) {
      return false;
    }
  }
}
```

Key points:
- `purchasePlan` purchase contract: `true` = success, `false` = cancelled, throws = real error.
- Falls back to mock plan on any missing-plugin / empty offering. Safe on desktop/CI.
- `restorePurchases` swallows errors and returns `false`; restore is non-critical.

---

### `plan_model.dart`

```dart
@freezed
class PlanModel with _$PlanModel {
  const factory PlanModel({
    required String id,
    required String title,
    required String priceText,
    @Default(false) bool isSelected,
    String? trialInfoText,
  }) = _PlanModel;
}
```

---

### `paywall_plans_provider.dart`

```dart
class PaywallPlansState {
  const PaywallPlansState({
    this.plans = const [],
    this.isLoading = false,
    this.error,
  });
  final List<PlanModel> plans;
  final bool isLoading;
  final String? error;

  PaywallPlansState copyWith({
    List<PlanModel>? plans,
    bool? isLoading,
    String? error,
  }) => PaywallPlansState(
    plans: plans ?? this.plans,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );

  PlanModel? get selectedPlan =>
      plans.firstWhereOrNull((p) => p.isSelected) ??
      (plans.isEmpty ? null : plans.first);
}

class PaywallPlansNotifier extends StateNotifier<PaywallPlansState> {
  PaywallPlansNotifier(this._service) : super(const PaywallPlansState());

  final PaywallService _service;

  Future<void> loadPlans() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final plans = await _service.getAvailablePlans();
      state = state.copyWith(plans: plans, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load plans: $e');
    }
  }

  Future<bool> purchaseSelectedPlan() async {
    final selected = state.selectedPlan;
    if (selected == null) return false;
    return _service.purchasePlan(selected.id);
  }
}

final paywallPlansProvider =
    StateNotifierProvider<PaywallPlansNotifier, PaywallPlansState>(
  (ref) => PaywallPlansNotifier(PaywallService.instance),
);

/// Call from view to complete purchase and sync premium status.
Future<bool> completePaywallPurchase(WidgetRef ref) async {
  final success = await ref.read(paywallPlansProvider.notifier).purchaseSelectedPlan();
  if (!success) return false;

  if (RevenueCatConfig.useMock) {
    await ref.read(premiumStatusProvider.notifier).activateMockPremium();
  } else {
    final info = await RevenueCatService.instance.getCustomerInfo();
    await ref.read(premiumStatusProvider.notifier).updateFromCustomerInfo(info);
  }
  return true;
}
```

Key points:
- `PaywallPlansNotifier` takes `PaywallService` as constructor arg (testable).
- `completePaywallPurchase` is the only place `RevenueCatService.instance` is called outside a service — it is a top-level provider function, not view code.
- View calls `completePaywallPurchase(ref)` and reacts to returned bool.

---

### View pattern

```dart
// ✅ Correct — view reads provider state, calls notifier
class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paywallPlansProvider.notifier).loadPlans();
    });
  }

  Future<void> _onPurchase() async {
    final success = await completePaywallPurchase(ref);
    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paywallPlansProvider);
    if (state.isLoading) return const CircularProgressIndicator();
    if (state.error != null) return ErrorWidget(state.error!);
    return PaywallPlanList(plans: state.plans, onPurchase: _onPurchase);
  }
}

// ❌ Forbidden — view importing/calling service directly
// import '../../services/paywall/paywall_service.dart';
// await PaywallService.instance.purchasePlan(id);  // NEVER
```

---

## Init in `main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RevenueCatService.instance.init();
  runApp(const ProviderScope(child: MyApp()));
}
```

---

## Recovery Offer Rules

- Preload recovery offer state during paywall initialization.
- On cancel action, open recovery sheet only when offer is available.
- Keep countdown continuity by passing start reference timestamp.

---

## Plan Card Rules

- `isTrial` changes text hierarchy only; layout metrics stay consistent.
- Keep equal border width in selected/unselected states.
- Avoid `FittedBox` for plan text; use regular `Text` with overflow handling.

---

## Error handling summary

| Exception | Raised by | Meaning | Handled at |
|---|---|---|---|
| `PurchaseCancelledException` | `RevenueCatService` | User tapped Cancel | `PaywallService` → returns `false` |
| `ProductAlreadyPurchasedException` | `RevenueCatService` | Already owned | `PaywallService` → returns `true` |
| Any other | `RevenueCatService` | Real error | Rethrown, surfaces in notifier `error` state |
| `MissingPluginException` | `Purchases.*` | Desktop / test | `PaywallService` → falls back to mock plan |

---

## Checklist for new projects

- [ ] `RevenueCatConfig` with `apiKey`, `offeringId`, `useMock`, `isDebug`
- [ ] `RevenueCatService` singleton, `init()` called in `main`
- [ ] `PlanModel` Freezed model
- [ ] `PaywallService` singleton with `getAvailablePlans`, `purchasePlan`, `restorePurchases`
- [ ] `PaywallPlansState` + `PaywallPlansNotifier` + `paywallPlansProvider`
- [ ] `premiumStatusProvider` to hold and sync premium entitlement state
- [ ] `completePaywallPurchase(ref)` helper in provider file
- [ ] View reads state only via `ref.watch`, calls only notifier methods or `completePaywallPurchase`
- [ ] No `Service.instance` calls inside widget/screen files

---

## Cross-Skill Ownership

- Remote Config parsing/default fallback: `.cursor/skills/remote-config/SKILL.md`
- Fonts/colors/sizing: `.cursor/skills/theming/SKILL.md`

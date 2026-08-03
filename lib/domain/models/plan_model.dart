import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_model.freezed.dart';

@freezed
class PlanModel with _$PlanModel {
  const factory PlanModel({
    required String id,
    required String title,
    required String priceText,
    @Default(false) bool isSelected,
    String? trialInfoText,
    @Default(1) int tier,
    String? badgeText,
    String? subtitle,
    /// Billing period suffix from RC (`/mês`, `/ano`).
    String? periodLabel,
    /// Store product identifier (RevenueCat `StoreProduct.identifier`).
    String? productId,
    /// Numeric price from store (`StoreProduct.price`) for analytics.
    @Default(0) double price,
    /// ISO currency code (`StoreProduct.currencyCode`), default BRL.
    @Default('BRL') String currencyCode,
  }) = _PlanModel;
}

enum PaywallOrigin {
  home,
  result,
  favorite,
  share,
  contact,
  onboarding,
  score,
  cnd,
  searchLimit,
  appOpen,
  scoreLimit,
}

/// Typed args for [AppRoutes.paywall] / [AppRoutes.paywallConsumables].
class PaywallRouteArgs {
  const PaywallRouteArgs({
    required this.origin,
    this.pendingOrderId,
    this.suggestedTier,
    this.limitMessage,
    this.suggestedPlanTitle,
    this.showLimitSheet = false,
    this.productKind,
  });

  final PaywallOrigin origin;
  final String? pendingOrderId;

  /// When set, paywall selects this tier after plans load (or after limit sheet).
  final int? suggestedTier;

  /// Optional copy from limit/upsell sheet.
  final String? limitMessage;
  final String? suggestedPlanTitle;

  /// When true, paywall opens the limit bottomsheet after plans load, then
  /// selects [suggestedTier] when the sheet closes.
  final bool showLimitSheet;

  /// Emit kind for consumable paywall filter (`cnd` / `restricao` / `protesto`).
  final String? productKind;
}

/// Runtime plan for the signed-in profile.
class UserPlanState {
  const UserPlanState({
    this.planProductId = freePlanProductId,
    this.tier = 0,
    this.planTitle,
  });

  static const freePlanProductId = 'free';

  final String planProductId;
  final int tier;
  final String? planTitle;

  bool get isPremium => tier >= 1;
  bool get isFree => tier <= 0;

  UserPlanState copyWith({
    String? planProductId,
    int? tier,
    String? planTitle,
  }) =>
      UserPlanState(
        planProductId: planProductId ?? this.planProductId,
        tier: tier ?? this.tier,
        planTitle: planTitle ?? this.planTitle,
      );
}

/// Result of a purchase + Supabase sync (for analytics `transaction_id`).
class PurchaseSyncResult {
  const PurchaseSyncResult({
    required this.plan,
    this.transactionId,
    this.price = 0,
    this.currencyCode = 'BRL',
    this.paymentId,
  });

  final UserPlanState plan;
  final String? transactionId;

  /// Store price from RevenueCat `StoreProduct.price` at purchase time.
  final double price;

  /// ISO 4217 from RevenueCat `StoreProduct.currencyCode` at purchase time.
  final String currencyCode;

  /// Supabase `payments.id` for one-shot consumable purchases.
  final String? paymentId;
}

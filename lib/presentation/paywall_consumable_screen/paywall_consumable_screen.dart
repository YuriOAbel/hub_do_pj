import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:consulta_cnpj_new/core/config/legal_urls.dart';
import 'package:consulta_cnpj_new/core/config/support_config.dart';
import 'package:consulta_cnpj_new/core/helpers/firebase_analytics_helper.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_request_args.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/domain/providers/cnd_orders_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/paywall_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/premium_status_provider.dart';
import 'package:consulta_cnpj_new/presentation/paywall_screen/widgets/paywall_benefit_data.dart';
import 'package:consulta_cnpj_new/presentation/paywall_screen/widgets/paywall_benefit_row.dart';
import 'package:consulta_cnpj_new/presentation/paywall_screen/widgets/paywall_benefit_sheet.dart';
import 'package:consulta_cnpj_new/presentation/paywall_screen/widgets/paywall_header.dart';
import 'package:consulta_cnpj_new/presentation/paywall_screen/widgets/paywall_plan_card.dart';
import 'package:consulta_cnpj_new/presentation/paywall_screen/widgets/paywall_premium_badge.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_async_error.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_async_loading.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_screen_fade.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/premium_upsell_sheet.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/services/cnd_orders_service.dart';
import 'package:consulta_cnpj_new/services/paywall/revenuecat_config.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

/// Android experiment paywall: monthly CP and/or one-shot consumable.
class PaywallConsumableScreen extends ConsumerStatefulWidget {
  const PaywallConsumableScreen({super.key, required this.args});

  final PaywallRouteArgs args;

  @override
  ConsumerState<PaywallConsumableScreen> createState() =>
      _PaywallConsumableScreenState();
}

class _PaywallConsumableScreenState
    extends ConsumerState<PaywallConsumableScreen> {
  bool _loggedViewItemList = false;
  bool _limitSheetShown = false;

  PaywallConsumableContext get _context {
    switch (widget.args.origin) {
      case PaywallOrigin.score:
      case PaywallOrigin.scoreLimit:
        return PaywallConsumableContext.score;
      default:
        return PaywallConsumableContext.emit;
    }
  }

  List<String> get _packageIds =>
      RevenueCatConfig.packageIdsForConsumableContext(
        context: _context,
        productKind: widget.args.productKind,
      );

  @override
  void initState() {
    super.initState();
    FirebaseAnalyticsHelper.instance.logViewCart(
      origin: widget.args.origin.name,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(paywallPlansProvider.notifier).loadConsumable(
            packageIds: _packageIds,
          );
    });
  }

  void _maybeLogViewItemList() {
    if (_loggedViewItemList) return;
    _loggedViewItemList = true;
    FirebaseAnalyticsHelper.instance.logViewItemList(
      itemListId: 'paywall_benefits',
      itemListName: 'Servicos Premium',
    );
  }

  void _onSeeMore(PaywallBenefitData benefit, String packageId) {
    FirebaseAnalyticsHelper.instance.logViewItem(
      itemId: benefit.id.name,
      itemName: benefit.title,
    );
    PaywallBenefitSheet.show(
      context,
      benefit: benefit,
      tier: 2,
      packageId: packageId,
    );
  }

  bool get _shouldShowLimitSheet => widget.args.showLimitSheet;

  String? _titleForTier(PaywallPlansState state, int? tier) {
    if (widget.args.suggestedPlanTitle != null) {
      return widget.args.suggestedPlanTitle;
    }
    if (tier == null) return null;
    for (final plan in state.plans) {
      if (plan.tier == tier) return plan.title;
    }
    return null;
  }

  void _maybeShowLimitSheet(PaywallPlansState state) {
    if (_limitSheetShown ||
        state.isLoading ||
        state.mode != PaywallLoadMode.consumable ||
        state.plans.isEmpty) {
      return;
    }
    if (!_shouldShowLimitSheet) {
      // Initial selection comes from offering metadata `isSelected`.
      return;
    }

    _limitSheetShown = true;
    final tier = widget.args.suggestedTier;
    final planTitle = _titleForTier(state, tier);
    final hasConsumableOption = state.plans.any(
      (p) =>
          RevenueCatConfig.isConsumablePackageId(p.id) ||
          RevenueCatConfig.isConsumableProductId(p.productId),
    );
    final message = PremiumUpsellSheet.limitBody(
      planTitle: planTitle,
      limitMessage: widget.args.limitMessage,
      allowConsumable: hasConsumableOption,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await PremiumUpsellSheet.present(
        context,
        origin: widget.args.origin,
        suggestedTier: tier,
        limitMessage: message,
        suggestedPlanTitle: hasConsumableOption ? null : planTitle,
        allowConsumable: hasConsumableOption,
      );
      if (!mounted) return;
      // After limit sheet: nudge toward monthly subscription when available.
      if (state.plans.any((p) => p.id == RevenueCatConfig.monthlyCpPackageId)) {
        ref
            .read(paywallPlansProvider.notifier)
            .selectPlanById(RevenueCatConfig.monthlyCpPackageId);
      } else if (tier != null) {
        ref.read(paywallPlansProvider.notifier).selectPlanByTier(tier);
      }
    });
  }

  Future<void> _onPurchase(PlanModel plan) async {
    final notifier = ref.read(paywallPlansProvider.notifier);
    if (!notifier.beginPurchasing()) return;

    try {
      final itemId = plan.productId ?? plan.id;
      final analytics = FirebaseAnalyticsHelper.instance;
      final currency = _isoCurrency(plan.currencyCode);
      final isConsumable = RevenueCatConfig.isConsumablePackageId(plan.id) ||
          RevenueCatConfig.isConsumableProductId(plan.productId);

      await analytics.logAddToCart(
        value: plan.price,
        currency: currency,
        itemId: itemId,
        itemName: plan.title,
      );

      await analytics.logBeginCheckout(
        value: plan.price,
        currency: currency,
        itemId: itemId,
        itemName: plan.title,
      );

      final result = await notifier.purchaseAndSync(plan.id);
      if (result == null || !mounted) return;

      final synced = result.plan;
      final transactionId = result.transactionId ??
          '${itemId}_${DateTime.now().millisecondsSinceEpoch}';

      await analytics.logPurchase(
        value: result.price > 0 ? result.price : plan.price,
        currency: _isoCurrency(result.currencyCode, fallback: currency),
        transactionId: transactionId,
        itemId: itemId,
        itemName: plan.title,
      );
      if (!mounted) return;

      if (isConsumable) {
        await _finishAfterConsumable(paymentId: result.paymentId);
        return;
      }

      ref.read(premiumStatusProvider.notifier).applyPlan(synced);
      if (!synced.isPremium) {
        await ref.read(premiumStatusProvider.notifier).refresh();
      }
      if (!mounted) return;
      await _finishAfterPremium();
    } finally {
      if (mounted) notifier.endPurchasing();
    }
  }

  String _isoCurrency(String code, {String fallback = 'BRL'}) {
    final normalized = code.trim().toUpperCase();
    return normalized.isNotEmpty ? normalized : fallback;
  }

  Future<void> _onRestore() async {
    final notifier = ref.read(paywallPlansProvider.notifier);
    if (!notifier.beginPurchasing()) return;

    try {
      final synced = await notifier.restoreAndSync();
      if (synced == null || !synced.isPremium || !mounted) return;
      ref.read(premiumStatusProvider.notifier).applyPlan(synced);
      if (!mounted) return;
      await _finishAfterPremium();
    } finally {
      if (mounted) notifier.endPurchasing();
    }
  }

  Future<void> _finishAfterConsumable({String? paymentId}) async {
    // Heal plan if RC entitlement briefly looked like a subscription.
    await ref.read(premiumStatusProvider.notifier).refresh();

    final orderId = widget.args.pendingOrderId;
    if (orderId == null || orderId.isEmpty) {
      if (mounted) Navigator.of(context).pop(true);
      return;
    }

    try {
      final order = await ref
          .read(cndOrdersProvider.notifier)
          .markOrderPaid(orderId, paymentId: paymentId);
      if (!mounted) return;
      await Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.cndOrderDetail,
        (route) => route.settings.name == AppRoutes.home || route.isFirst,
        arguments: CndOrderDetailArgs(order: order),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is CndOrdersException
          ? e.message
          : 'Ops, tivemos um problema... tente novamente';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      await Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.cndOrders,
        (route) => route.settings.name == AppRoutes.home || route.isFirst,
      );
    }
  }

  Future<void> _finishAfterPremium() async {
    final orderId = widget.args.pendingOrderId;
    if (orderId == null || orderId.isEmpty) {
      if (mounted) Navigator.of(context).pop(true);
      return;
    }

    try {
      final order = await ref
          .read(cndOrdersProvider.notifier)
          .markOrderPaid(orderId);
      if (!mounted) return;
      await Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.cndOrderDetail,
        (route) => route.settings.name == AppRoutes.home || route.isFirst,
        arguments: CndOrderDetailArgs(order: order),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is CndOrdersException
          ? e.message
          : 'Ops, tivemos um problema... tente novamente';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      await Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.cndOrders,
        (route) => route.settings.name == AppRoutes.home || route.isFirst,
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _footerHint(PlanModel? selected) {
    if (selected != null &&
        (RevenueCatConfig.isConsumablePackageId(selected.id) ||
            RevenueCatConfig.isConsumableProductId(selected.productId))) {
      return 'Compra única para este pedido.';
    }
    return 'Assinatura auto-renovável até o cancelamento.';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paywallPlansProvider);
    _maybeShowLimitSheet(state);
    final selected = state.selectedPlan;
    final selectedPackageId =
        selected?.id ?? RevenueCatConfig.monthlyCpPackageId;
    final waitingConsumable = state.mode != PaywallLoadMode.consumable ||
        state.isLoading;
    final showContent = !waitingConsumable &&
        !(state.error != null && state.plans.isEmpty);
    if (showContent) {
      _maybeLogViewItemList();
    }

    return DefaultTextStyle(
      style: const TextStyle(
        inherit: false,
        decoration: TextDecoration.none,
        letterSpacing: -0.41,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        body: AppScreenFade(
          child: AppAsyncFadeSwitcher(
            child: waitingConsumable
                ? const AppAsyncLoading(key: ValueKey('paywall-c-loading'))
                : state.error != null && state.plans.isEmpty
                ? AppAsyncError(
                    key: const ValueKey('paywall-c-error'),
                    onRetry: () =>
                        ref.read(paywallPlansProvider.notifier).retry(),
                  )
                : Stack(
                    key: const ValueKey('paywall-c-content'),
                    children: [
                      AbsorbPointer(
                        absorbing: state.isPurchasing,
                        child: Column(
                          children: [
                            PaywallHeader(
                              onClose: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Transform.translate(
                                offset: Offset(0, -1.h),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppTheme.surface,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(24),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.shadowLight
                                                .withValues(alpha: 0.6),
                                            blurRadius: 12,
                                            offset: const Offset(0, -2),
                                          ),
                                        ],
                                      ),
                                      child: SingleChildScrollView(
                                        padding: EdgeInsets.fromLTRB(
                                          5.w,
                                          3.h,
                                          5.w,
                                          3.h,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            SizedBox(height: 3.h),
                                            for (final benefit
                                                in PaywallBenefitData.all)
                                              PaywallBenefitRow(
                                                title: benefit.title,
                                                subtitle: benefit
                                                    .subtitleForTier(2),
                                                periodPrefix: benefit
                                                    .periodPrefixForPackage(
                                                      selectedPackageId,
                                                    ),
                                                periodHighlight: benefit
                                                    .periodHighlightForPackage(
                                                      selectedPackageId,
                                                    ),
                                                enabled: benefit
                                                    .isEnabledForPackage(
                                                      selectedPackageId,
                                                    ),
                                                onSeeMore: () => _onSeeMore(
                                                  benefit,
                                                  selectedPackageId,
                                                ),
                                              ),
                                            SizedBox(height: 3.h),
                                            for (final plan in state.plans)
                                              PaywallPlanCard(
                                                plan: plan,
                                                onTap: () => ref
                                                    .read(
                                                      paywallPlansProvider
                                                          .notifier,
                                                    )
                                                    .selectPlan(plan.id),
                                              ),
                                            SizedBox(height: 1.h),
                                            Text(
                                              _footerHint(selected),
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                fontSize:
                                                    (AppTypography.fontBody + 2)
                                                        .sp,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                            CnpjPrimaryButton(
                                              enabled:
                                                  !state.isPurchasing &&
                                                  selected != null,
                                              onPressed: selected == null
                                                  ? null
                                                  : () =>
                                                      _onPurchase(selected),
                                              child: Text(
                                                state.isPurchasing
                                                    ? 'Processando...'
                                                    : 'Continuar',
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 1.2.h),
                                            Center(
                                              child: GestureDetector(
                                                onTap: () {
                                                  final url = SupportConfig
                                                      .whatsappUrl;
                                                  if (url != null) {
                                                    _launchUrl(url);
                                                  }
                                                },
                                                child: Text(
                                                  'Precisa cobrir mais CNPJs, entre em contato!',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.inter(
                                                    fontSize: AppTypography
                                                        .fontBody.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppTheme.primary,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    decorationColor:
                                                        AppTheme.primary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: TextButton(
                                                    onPressed:
                                                        state.isPurchasing
                                                        ? null
                                                        : _onRestore,
                                                    child: Text(
                                                      'Restaurar compra',
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      style: GoogleFonts.inter(
                                                        fontSize: AppTypography
                                                            .fontSubtitle.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppTheme.primary,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        decorationColor:
                                                            AppTheme.primary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                TextButton(
                                                  onPressed: LegalUrls
                                                          .hasTermsOfService
                                                      ? () => _launchUrl(
                                                            LegalUrls
                                                                .termsOfService,
                                                          )
                                                      : null,
                                                  child: Text(
                                                    'Termos',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                      fontSize: AppTypography
                                                          .fontSubtitle.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppTheme.primary,
                                                      decoration: TextDecoration
                                                          .underline,
                                                      decorationColor: LegalUrls
                                                              .hasTermsOfService
                                                          ? AppTheme.primary
                                                          : AppTheme.textMuted,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: LegalUrls
                                                          .hasPrivacyPolicy
                                                      ? () => _launchUrl(
                                                            LegalUrls
                                                                .privacyPolicy,
                                                          )
                                                      : null,
                                                  child: Text(
                                                    'Políticas',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.inter(
                                                      fontSize: AppTypography
                                                          .fontSubtitle.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppTheme.primary,
                                                      decoration: TextDecoration
                                                          .underline,
                                                      decorationColor: LegalUrls
                                                              .hasPrivacyPolicy
                                                          ? AppTheme.primary
                                                          : AppTheme.textMuted,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: -1.8.h,
                                      left: 0,
                                      right: 0,
                                      child: const PaywallPremiumBadge(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (state.isPurchasing)
                        const Positioned.fill(
                          child: ColoredBox(
                            color: Color(0x66FFFFFF),
                            child: AppAsyncLoading(
                              key: ValueKey('paywall-c-purchasing'),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

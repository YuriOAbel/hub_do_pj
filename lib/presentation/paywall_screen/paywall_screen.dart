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
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key, required this.args});

  final PaywallRouteArgs args;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _appliedSuggestedTier = false;
  bool _loggedViewItemList = false;
  bool _limitSheetShown = false;

  @override
  void initState() {
    super.initState();
    FirebaseAnalyticsHelper.instance.logViewCart(
      origin: widget.args.origin.name,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(paywallPlansProvider.notifier).loadDefault();
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

  void _onSeeMore(PaywallBenefitData benefit, int tier) {
    FirebaseAnalyticsHelper.instance.logViewItem(
      itemId: benefit.id.name,
      itemName: benefit.title,
    );
    PaywallBenefitSheet.show(
      context,
      benefit: benefit,
      tier: tier < 2 ? 2 : tier,
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

  void _maybeApplySuggestedTier(PaywallPlansState state) {
    final tier = widget.args.suggestedTier;
    if (_appliedSuggestedTier || tier == null || state.isLoading) return;
    if (state.plans.isEmpty) return;
    _appliedSuggestedTier = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(paywallPlansProvider.notifier).selectPlanByTier(tier);
    });
  }

  void _maybeShowLimitSheet(PaywallPlansState state) {
    if (_limitSheetShown || state.isLoading || state.plans.isEmpty) return;
    if (!_shouldShowLimitSheet) {
      _maybeApplySuggestedTier(state);
      return;
    }

    _limitSheetShown = true;
    final tier = widget.args.suggestedTier;
    final planTitle = _titleForTier(state, tier);
    final message = PremiumUpsellSheet.limitBody(
      planTitle: planTitle,
      limitMessage: widget.args.limitMessage,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await PremiumUpsellSheet.present(
        context,
        origin: widget.args.origin,
        suggestedTier: tier,
        limitMessage: message,
        suggestedPlanTitle: planTitle,
      );
      if (!mounted) return;
      if (tier != null) {
        _appliedSuggestedTier = true;
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

  /// ISO 4217 for Firebase (`value` requires matching `currency`).
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paywallPlansProvider);
    final waitingSubscription = state.mode != PaywallLoadMode.subscription ||
        state.isLoading;
    _maybeShowLimitSheet(state);
    final selected = state.selectedPlan;
    final tier = selected?.tier ?? 1;
    final showContent = !waitingSubscription &&
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
            child: waitingSubscription
                ? const AppAsyncLoading(key: ValueKey('paywall-loading'))
                : state.error != null && state.plans.isEmpty
                ? AppAsyncError(
                    key: const ValueKey('paywall-error'),
                    onRetry: () =>
                        ref.read(paywallPlansProvider.notifier).retry(),
                  )
                : Stack(
                    key: const ValueKey('paywall-content'),
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
                                                    .subtitleForTier(tier),
                                                periodPrefix: benefit
                                                    .periodPrefixForTier(tier),
                                                periodHighlight: benefit
                                                    .periodHighlightForTier(
                                                      tier,
                                                    ),
                                                enabled: benefit
                                                    .isEnabledForTier(tier),
                                                onSeeMore: () =>
                                                    _onSeeMore(benefit, tier),
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
                                              'Assinatura auto-renovável até o cancelamento.',
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
                                                Spacer(),
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
                              key: ValueKey('paywall-purchasing'),
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

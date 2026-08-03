import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/open_paywall.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class PremiumUpsellSheet extends StatelessWidget {
  const PremiumUpsellSheet({
    super.key,
    required this.origin,
    this.suggestedTier,
    this.limitMessage,
    this.suggestedPlanTitle,
    this.allowConsumable = false,
  });

  final PaywallOrigin origin;
  final int? suggestedTier;
  final String? limitMessage;
  final String? suggestedPlanTitle;
  final bool allowConsumable;

  /// Limit hit: open paywall first; paywall presents this sheet, then selects
  /// [suggestedTier] when the sheet closes.
  ///
  /// Generic premium gate (no limit copy): sheet first, then paywall.
  static Future<void> show(
    BuildContext context,
    PaywallOrigin origin, {
    int? suggestedTier,
    String? limitMessage,
    String? suggestedPlanTitle,
    bool allowConsumable = false,
  }) {
    final isLimit =
        limitMessage != null || suggestedPlanTitle != null || suggestedTier != null;
    final args = PaywallRouteArgs(
      origin: origin,
      suggestedTier: suggestedTier,
      limitMessage: limitMessage,
      suggestedPlanTitle: suggestedPlanTitle,
      showLimitSheet: isLimit,
    );

    if (isLimit) {
      return openPaywall(context, args);
    }

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => PremiumUpsellSheet(
        origin: origin,
        allowConsumable: allowConsumable,
      ),
    ).whenComplete(() {
      if (!context.mounted) return;
      openPaywall(context, args);
    });
  }

  /// Sheet only (no navigation). Used by [PaywallScreen] after plans load.
  static Future<void> present(
    BuildContext context, {
    required PaywallOrigin origin,
    int? suggestedTier,
    String? limitMessage,
    String? suggestedPlanTitle,
    bool allowConsumable = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => PremiumUpsellSheet(
        origin: origin,
        suggestedTier: suggestedTier,
        limitMessage: limitMessage,
        suggestedPlanTitle: suggestedPlanTitle,
        allowConsumable: allowConsumable,
      ),
    );
  }

  static String limitBody({
    required String? planTitle,
    String? limitMessage,
    bool allowConsumable = false,
  }) {
    if (limitMessage != null && limitMessage.trim().isNotEmpty) {
      return limitMessage;
    }
    if (allowConsumable) {
      if (planTitle != null && planTitle.trim().isNotEmpty) {
        return 'Você atingiu o limite do plano para esta operação. '
            'Assine o plano $planTitle ou faça a compra única deste pedido.';
      }
      return 'Você atingiu o limite do plano para esta operação. '
          'Assine um plano superior ou faça a compra única deste pedido.';
    }
    if (planTitle != null && planTitle.trim().isNotEmpty) {
      return 'Você atingiu o limite desta operação. '
          'Para continuar, faça a assinatura do plano $planTitle.';
    }
    return 'Você atingiu o limite desta operação. '
        'Para continuar, faça a assinatura de um plano superior.';
  }

  @override
  Widget build(BuildContext context) {
    final isLimit = limitMessage != null ||
        suggestedPlanTitle != null ||
        allowConsumable;
    final title = allowConsumable
        ? 'Limite atingido'
        : suggestedPlanTitle != null
            ? 'Ative o plano $suggestedPlanTitle'
            : isLimit
                ? 'Limite atingido'
                : 'Recurso Premium';
    final body = isLimit
        ? limitBody(
            planTitle: suggestedPlanTitle,
            limitMessage: limitMessage,
            allowConsumable: allowConsumable,
          )
        : 'Assine o Premium para desbloquear este recurso sem limites.';
    final ctaLabel = allowConsumable
        ? 'Ver opções'
        : suggestedPlanTitle != null
            ? 'Ver plano'
            : 'Ver planos';

    return Padding(
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: AppTypography.fontTitle.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            body,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: AppTypography.fontSubtitle.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 3.h),
          CnpjPrimaryButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              ctaLabel,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}

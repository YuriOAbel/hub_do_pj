import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:consulta_cnpj_new/core/config/support_config.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

/// Shown when `hub_pj_mensal_cp` subscribers hit the 2-CNPJ plan cap.
class PlanCnpjLimitSpecialistSheet extends StatelessWidget {
  const PlanCnpjLimitSpecialistSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const PlanCnpjLimitSpecialistSheet(),
    );
  }

  Future<void> _openWhatsApp() async {
    final url = SupportConfig.whatsappUrlWithText(
      'Olá! Atingi o limite de CNPJs do meu plano e gostaria de falar '
      'com um especialista.',
    );
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Limite excedido',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: AppTypography.fontTitle.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Limite excedido para contratar mais CNPJs. '
            'Fale com um dos nossos especialistas.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: AppTypography.fontSubtitle.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 3.h),
          CnpjPrimaryButton(
            onPressed: () async {
              await _openWhatsApp();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(
              'Falar no WhatsApp',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fechar',
              style: GoogleFonts.inter(
                fontSize: AppTypography.fontBody.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          SizedBox(height: 1.h),
        ],
      ),
    );
  }
}

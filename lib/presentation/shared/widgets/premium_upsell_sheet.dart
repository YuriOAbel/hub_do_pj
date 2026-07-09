import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class PremiumUpsellSheet extends StatelessWidget {
  const PremiumUpsellSheet({super.key, required this.origin});

  final PaywallOrigin origin;

  static Future<void> show(BuildContext context, PaywallOrigin origin) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => PremiumUpsellSheet(origin: origin),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Recurso Premium',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Assine o Premium para desbloquear este recurso sem limites.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14.sp, color: AppTheme.textSecondary),
          ),
          SizedBox(height: 3.h),
          CnpjPrimaryButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.paywall, arguments: origin);
            },
            child: Text(
              'Ver planos',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}

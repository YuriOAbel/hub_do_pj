import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/presentation/onboarding_screen/widgets/onboarding_skip_link.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class OnboardingPaywallPlaceholder extends StatelessWidget {
  const OnboardingPaywallPlaceholder({super.key, required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        children: [
          const Spacer(),
          Text(
            'Paywall',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: (AppTypography.fontTitle + 8).sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Em breve: planos premium. Por enquanto você pode continuar.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: AppTypography.fontSubtitle.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          const Spacer(),
          CnpjPrimaryButton(
            onPressed: onSkip,
            child: Text(
              'Deixar para depois',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          OnboardingSkipLink(onTap: onSkip),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}

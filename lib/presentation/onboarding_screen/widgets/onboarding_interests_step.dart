import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/onboarding_model.dart';
import 'package:consulta_cnpj_new/presentation/onboarding_screen/widgets/onboarding_interest_chips.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class OnboardingInterestsStep extends StatelessWidget {
  const OnboardingInterestsStep({
    super.key,
    required this.name,
    required this.selected,
    required this.onToggle,
    required this.onContinue,
  });

  final String name;
  final Set<OnboardingInterest> selected;
  final ValueChanged<OnboardingInterest> onToggle;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 4.h),
          Text(
            'Olá, $name.',
            style: GoogleFonts.inter(
              fontSize: (AppTypography.fontTitle + 4).sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            'No que você tem interesse?',
            style: GoogleFonts.inter(
              fontSize: (AppTypography.fontTitle + 2).sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Selecione uma ou mais opções. Você pode mudar depois.',
            style: GoogleFonts.inter(
              fontSize: AppTypography.fontSubtitle.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 3.h),
          OnboardingInterestChips(selected: selected, onToggle: onToggle),
          const Spacer(),
          CnpjPrimaryButton(
            enabled: selected.isNotEmpty,
            onPressed: onContinue,
            child: Text(
              'Continuar',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }
}

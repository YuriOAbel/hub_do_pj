import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/onboarding_model.dart';
import 'package:consulta_cnpj_new/presentation/onboarding_screen/widgets/onboarding_company_info_chips.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class OnboardingCompanyInfosStep extends StatelessWidget {
  const OnboardingCompanyInfosStep({
    super.key,
    required this.selected,
    required this.onToggle,
    required this.onContinue,
  });

  final Set<OnboardingCompanyInfo> selected;
  final ValueChanged<OnboardingCompanyInfo> onToggle;
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
            'Quais infos da empresa você gostaria de analisar?',
            style: GoogleFonts.inter(
              fontSize: (AppTypography.fontTitle + 4).sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Selecione uma ou mais opções.',
            style: GoogleFonts.inter(
              fontSize: AppTypography.fontSubtitle.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 3.h),
          OnboardingCompanyInfoChips(selected: selected, onToggle: onToggle),
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

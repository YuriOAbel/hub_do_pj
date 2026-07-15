import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/presentation/onboarding_screen/widgets/onboarding_interest_chips.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CompanyScoreQuestionStep<T> extends StatelessWidget {
  const CompanyScoreQuestionStep({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelect,
    required this.onContinue,
    this.subtitle = 'Selecione uma opção.',
    this.buttonLabel = 'Continuar',
    this.onHelpTap,
  });

  final String title;
  final String subtitle;
  final List<T> options;
  final T? selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelect;
  final VoidCallback onContinue;
  final String buttonLabel;
  final VoidCallback? onHelpTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 4.h),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: (AppTypography.fontTitle + 4).sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: AppTypography.fontSubtitle.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          if (onHelpTap != null) ...[
            SizedBox(height: 1.h),
            GestureDetector(
              onTap: onHelpTap,
              child: Text(
                'Não sei informar, confira aqui!',
                style: GoogleFonts.inter(
                  fontSize: AppTypography.fontSubtitle.sp,
                  color: AppTheme.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppTheme.primary,
                ),
              ),
            ),
          ],
          SizedBox(height: 3.h),
          Expanded(
            child: SingleChildScrollView(
              child: OnboardingSingleSelectChips<T>(
                options: options,
                selected: selected,
                labelOf: labelOf,
                onSelect: onSelect,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          CnpjPrimaryButton(
            enabled: selected != null,
            onPressed: onContinue,
            child: Text(
              buttonLabel,
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/onboarding_model.dart';
import 'package:consulta_cnpj_new/presentation/onboarding_screen/widgets/onboarding_interest_chips.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class OnboardingNameStep extends StatelessWidget {
  const OnboardingNameStep({
    super.key,
    required this.personType,
    required this.controller,
    required this.onPersonTypeSelected,
    required this.onContinue,
  });

  final OnboardingPersonType? personType;
  final TextEditingController controller;
  final ValueChanged<OnboardingPersonType> onPersonTypeSelected;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final showName = personType != null;
        final canContinue =
            showName && controller.text.trim().isNotEmpty;
        final isPj = personType == OnboardingPersonType.pj;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 4.h),
              Text(
                'Você é…',
                style: GoogleFonts.inter(
                  fontSize: (AppTypography.fontTitle + 4).sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Selecione uma opção para continuar.',
                style: GoogleFonts.inter(
                  fontSize: AppTypography.fontSubtitle.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: 3.h),
              OnboardingSingleSelectChips<OnboardingPersonType>(
                options: OnboardingPersonType.values,
                selected: personType,
                labelOf: (e) => e.label,
                onSelect: onPersonTypeSelected,
              ),
              SizedBox(height: 4.h),
              AnimatedOpacity(
                opacity: showName ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: IgnorePointer(
                  ignoring: !showName,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Como podemos te chamar?',
                        style: GoogleFonts.inter(
                          fontSize: (AppTypography.fontTitle + 4).sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      if (isPj)
                        Text(
                          'Seu nome (do responsável) nos ajuda a personalizar a experiência.',
                          style: GoogleFonts.inter(
                            fontSize: AppTypography.fontSubtitle.sp,
                            color: AppTheme.textSecondary,
                          ),
                        )
                      else
                        Text(
                          'Seu nome nos ajuda a personalizar a experiência.',
                          style: GoogleFonts.inter(
                            fontSize: AppTypography.fontSubtitle.sp,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      SizedBox(height: 4.h),
                      TextField(
                        controller: controller,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          if (canContinue) onContinue();
                        },
                        style: GoogleFonts.inter(
                          fontSize: AppTypography.fontSubtitle.sp,
                          color: AppTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Seu nome',
                          hintStyle: GoogleFonts.inter(
                            fontSize: AppTypography.fontSubtitle.sp,
                            color: AppTheme.textSecondary,
                          ),
                          filled: true,
                          fillColor: AppTheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.8.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              CnpjPrimaryButton(
                enabled: canContinue,
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
      },
    );
  }
}

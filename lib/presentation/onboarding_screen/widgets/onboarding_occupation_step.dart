import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/onboarding_model.dart';
import 'package:consulta_cnpj_new/presentation/onboarding_screen/widgets/onboarding_interest_chips.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class OnboardingOccupationStep extends StatelessWidget {
  const OnboardingOccupationStep({
    super.key,
    required this.personType,
    required this.pfProfession,
    required this.pjOccupation,
    required this.otherController,
    required this.onPfProfessionSelected,
    required this.onPjOccupationSelected,
    required this.onContinue,
  });

  final OnboardingPersonType personType;
  final OnboardingPfProfession? pfProfession;
  final OnboardingPjOccupation? pjOccupation;
  final TextEditingController otherController;
  final ValueChanged<OnboardingPfProfession> onPfProfessionSelected;
  final ValueChanged<OnboardingPjOccupation> onPjOccupationSelected;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final isPf = personType == OnboardingPersonType.pf;
    final showOther = isPf
        ? pfProfession == OnboardingPfProfession.outra
        : pjOccupation == OnboardingPjOccupation.outra;

    return ListenableBuilder(
      listenable: otherController,
      builder: (context, _) {
        final hasSelection = isPf ? pfProfession != null : pjOccupation != null;
        final canContinue = hasSelection &&
            (!showOther || otherController.text.trim().isNotEmpty);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 4.h),
              if (isPf)
                Text(
                  'Qual sua profissão atual?',
                  style: GoogleFonts.inter(
                    fontSize: (AppTypography.fontTitle + 4).sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                )
              else
                Text(
                  'Qual a ocupação da empresa?',
                  style: GoogleFonts.inter(
                    fontSize: (AppTypography.fontTitle + 4).sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              SizedBox(height: 1.h),
              Text(
                'Selecione uma opção.',
                style: GoogleFonts.inter(
                  fontSize: AppTypography.fontSubtitle.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: 3.h),
              if (isPf)
                OnboardingSingleSelectChips<OnboardingPfProfession>(
                  options: OnboardingPfProfession.values,
                  selected: pfProfession,
                  labelOf: (e) => e.label,
                  onSelect: onPfProfessionSelected,
                )
              else
                OnboardingSingleSelectChips<OnboardingPjOccupation>(
                  options: OnboardingPjOccupation.values,
                  selected: pjOccupation,
                  labelOf: (e) => e.label,
                  onSelect: onPjOccupationSelected,
                ),
              SizedBox(height: 3.h),
              AnimatedOpacity(
                opacity: showOther ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: IgnorePointer(
                  ignoring: !showOther,
                  child: TextField(
                    controller: otherController,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (canContinue) onContinue();
                    },
                    style: GoogleFonts.inter(
                      fontSize: AppTypography.fontSubtitle.sp,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: isPf ? 'Qual outra profissão?' : 'Qual outra ocupação?',
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

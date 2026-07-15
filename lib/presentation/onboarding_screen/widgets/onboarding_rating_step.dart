import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/presentation/onboarding_screen/widgets/onboarding_skip_link.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class OnboardingRatingStep extends StatelessWidget {
  const OnboardingRatingStep({
    super.key,
    required this.rating,
    required this.feedbackController,
    required this.onRatingUpdate,
    required this.onContinue,
    required this.onSkip,
  });

  final double rating;
  final TextEditingController feedbackController;
  final ValueChanged<double> onRatingUpdate;
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  bool get _needsFeedback => rating > 0 && rating <= 3;
  bool get _canContinue {
    if (rating <= 0) return false;
    if (_needsFeedback) return feedbackController.text.trim().isNotEmpty;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: feedbackController,
      builder: (context, _) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Text(
                'Você gostou da consulta?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: (AppTypography.fontTitle + 4).sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Por favor avalie nosso app e nos ajude a crescer.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: AppTypography.fontSubtitle.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: 3.h),
              Center(
                child: RatingBar.builder(
                  initialRating: rating,
                  minRating: 1,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemSize: 10.w,
                  unratedColor: AppTheme.textMuted.withValues(alpha: 0.35),
                  itemBuilder: (_, index) =>
                      Icon(Icons.star, color: AppTheme.warning),
                  onRatingUpdate: onRatingUpdate,
                ),
              ),
              if (_needsFeedback) ...[
                SizedBox(height: 2.5.h),
                Text(
                  'Por favor nos ajude a melhorar. Passe o feedback do que podemos evoluir em nosso app.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: AppTypography.fontSubtitle.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 1.5.h),
                TextField(
                  controller: feedbackController,
                  maxLines: 4,
                  style: GoogleFonts.inter(
                    fontSize: AppTypography.fontSubtitle.sp,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Seu feedback',
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
                  ),
                ),
              ],
              const Spacer(flex: 1),
              SizedBox(height: 2.h),
              CnpjPrimaryButton(
                enabled: _canContinue,
                onPressed: onContinue,
                child: Text(
                  _needsFeedback ? 'Enviar feedback' : 'Continuar',
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
      },
    );
  }
}

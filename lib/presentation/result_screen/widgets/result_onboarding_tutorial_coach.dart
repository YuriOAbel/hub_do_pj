import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

/// Coach mark shown only when Result opens from first-session onboarding.
/// Does not touch [home_tutorial_seen].
class ResultOnboardingTutorialCoach {
  ResultOnboardingTutorialCoach._();

  static TutorialCoachMark show({
    required BuildContext context,
    required GlobalKey tabsKey,
    required GlobalKey headerKey,
    required VoidCallback onFinish,
  }) {
    final tutorial = TutorialCoachMark(
      targets: [
        _target(
          identify: 'header',
          key: headerKey,
          align: ContentAlign.bottom,
          title: 'Resumo da empresa',
          body:
              'Aqui ficam o nome, CNPJ e a situação cadastral — o essencial de um olhar.',
        ),
        _target(
          identify: 'tabs',
          key: tabsKey,
          align: ContentAlign.bottom,
          title: 'Informações divididas em abas',
          body:
              'Sobre, Atividades, Sócios e Contato separam todos os dados da empresa. Toque em cada aba para explorar.',
        ),
      ],
      colorShadow: AppTheme.textPrimary,
      opacityShadow: 0.85,
      paddingFocus: 8,
      textSkip: 'Pular',
      textStyleSkip: GoogleFonts.inter(
        color: Colors.white,
        fontSize: AppTypography.fontSubtitle.sp,
        fontWeight: FontWeight.w600,
      ),
      alignSkip: Alignment.topRight,
      onFinish: onFinish,
      onSkip: () {
        onFinish();
        return true;
      },
    )..show(context: context);

    return tutorial;
  }

  static TargetFocus _target({
    required String identify,
    required GlobalKey key,
    required ContentAlign align,
    required String title,
    required String body,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: key,
      shape: ShapeLightFocus.RRect,
      radius: 12,
      paddingFocus: identify == 'header' ? 4 : 8,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: align,
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: (AppTypography.fontTitle + 2).sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 0.6.h),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: AppTypography.fontSubtitle.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

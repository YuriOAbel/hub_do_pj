import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CompanyOfferTutorialTargets {
  const CompanyOfferTutorialTargets({
    required this.header,
    required this.fullInfo,
    required this.score,
    required this.products,
  });

  final GlobalKey header;
  final GlobalKey fullInfo;
  final GlobalKey score;
  final GlobalKey products;
}

/// First-session coach on the company offer screen (replaces home tutorial).
/// Marks [home_tutorial_seen] via caller [onFinish].
class CompanyOfferTutorialCoach {
  CompanyOfferTutorialCoach._();

  static TutorialCoachMark show({
    required BuildContext context,
    required CompanyOfferTutorialTargets targets,
    required VoidCallback onFinish,
  }) {
    final tutorial = TutorialCoachMark(
      targets: _buildTargets(targets),
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
      beforeFocus: (target) => _ensureVisible(target),
    )..show(context: context);

    return tutorial;
  }

  static Future<void> _ensureVisible(TargetFocus target) async {
    final key = target.keyTarget;
    if (key == null) return;
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      alignment: 0.35,
    );
  }

  static List<TargetFocus> _buildTargets(CompanyOfferTutorialTargets keys) {
    return [
      _target(
        identify: 'header',
        key: keys.header,
        align: ContentAlign.bottom,
        title: 'Empresa consultada',
        body:
            'Aqui ficam o nome, CNPJ e a situação cadastral da empresa que você buscou.',
      ),
      _target(
        identify: 'fullInfo',
        key: keys.fullInfo,
        align: ContentAlign.bottom,
        title: 'Informações completas',
        body:
            'Toque para ver todos os dados cadastrais — sobre, atividades, sócios e contato.',
      ),
      _target(
        identify: 'score',
        key: keys.score,
        align: ContentAlign.bottom,
        title: 'Score empresarial',
        body:
            'Estime o score desta empresa e acompanhe a visão de conformidade.',
      ),
      _target(
        identify: 'products',
        key: keys.products,
        align: ContentAlign.top,
        title: 'Serviços para este CNPJ',
        body:
            'Monitore a empresa, emita CNDs ou consulte restrições e protestos direto daqui.',
      ),
    ];
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
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: align,
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
          child: _TutorialStepCopy(title: title, body: body),
        ),
      ],
    );
  }
}

class _TutorialStepCopy extends StatelessWidget {
  const _TutorialStepCopy({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: (AppTypography.fontTitle + 2).sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 0.6.h),
        Text(
          body,
          style: GoogleFonts.inter(
            fontSize: (AppTypography.fontSubtitle).sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.92),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

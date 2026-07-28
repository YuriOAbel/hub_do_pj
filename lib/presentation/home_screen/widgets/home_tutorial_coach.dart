import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class HomeTutorialTargets {
  const HomeTutorialTargets({
    required this.chips,
    required this.search,
    required this.score,
    required this.monitor,
    required this.cnds,
    required this.restricao,
    required this.protesto,
  });

  final GlobalKey chips;
  final GlobalKey search;
  final GlobalKey score;
  final GlobalKey monitor;
  final GlobalKey cnds;
  final GlobalKey restricao;
  final GlobalKey protesto;
}

class HomeTutorialCoach {
  HomeTutorialCoach._();

  static TutorialCoachMark show({
    required BuildContext context,
    required HomeTutorialTargets targets,
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

  static List<TargetFocus> _buildTargets(HomeTutorialTargets keys) {
    return [
      _target(
        identify: 'chips',
        key: keys.chips,
        align: ContentAlign.bottom,
        title: 'Menu rápido',
        body: 'Toque nas tags para navegar entre as principais funções do app.',
      ),
      _target(
        identify: 'search',
        key: keys.search,
        align: ContentAlign.bottom,
        title: 'Consulta de CNPJ',
        body:
            'Digite o número e veja a situação cadastral e os dados completos.',
      ),
      _target(
        identify: 'score',
        key: keys.score,
        align: ContentAlign.bottom,
        title: 'Score empresarial',
        body: 'Estime o score da empresa e acompanhe a saúde do seu CNPJ.',
      ),
      _target(
        identify: 'monitor',
        key: keys.monitor,
        align: ContentAlign.top,
        title: 'Monitorar minha empresa',
        body:
            'Ative o monitoramento e avisaremos sobre qualquer irregularidade.',
      ),
      _target(
        identify: 'cnds',
        key: keys.cnds,
        align: ContentAlign.top,
        title: 'Gestão de CNDs',
        body:
            'Emita até 10 certidões negativas importantes para a sua empresa.',
      ),
      _target(
        identify: 'restricao',
        key: keys.restricao,
        align: ContentAlign.top,
        title: 'Consulta de restrição',
        body: 'Confira se o CNPJ tem restrições ou pendências em aberto.',
      ),
      _target(
        identify: 'protesto',
        key: keys.protesto,
        align: ContentAlign.top,
        title: 'Consulta de protesto',
        body: 'Veja se há protestos ativos e evite surpresas desagradáveis.',
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

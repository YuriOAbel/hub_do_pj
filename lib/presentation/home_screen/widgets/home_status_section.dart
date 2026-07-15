import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/providers/onboarding_provider.dart';
import 'package:consulta_cnpj_new/presentation/home_screen/widgets/home_feature_card.dart';
import 'package:consulta_cnpj_new/presentation/home_screen/widgets/home_score_card.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class HomeStatusSection extends ConsumerStatefulWidget {
  const HomeStatusSection({
    super.key,
    required this.onScoreStart,
    required this.onMonitorTap,
    required this.onCndTap,
    required this.onRestricaoTap,
    required this.onProtestoTap,
    this.scoreKey,
    this.monitorKey,
    this.cndsKey,
    this.restricaoKey,
    this.protestoKey,
  });

  final VoidCallback onScoreStart;
  final VoidCallback onMonitorTap;
  final VoidCallback onCndTap;
  final VoidCallback onRestricaoTap;
  final VoidCallback onProtestoTap;
  final GlobalKey? scoreKey;
  final GlobalKey? monitorKey;
  final GlobalKey? cndsKey;
  final GlobalKey? restricaoKey;
  final GlobalKey? protestoKey;

  @override
  ConsumerState<HomeStatusSection> createState() => _HomeStatusSectionState();
}

class _HomeStatusSectionState extends ConsumerState<HomeStatusSection> {
  String _greetingLine(String? savedName) {
    final parts = (savedName ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty);
    if (parts.isEmpty) {
      return 'Olá confira abaixo outras opções:';
    }
    return 'Olá ${parts.first} confira abaixo outras opções:';
  }

  @override
  Widget build(BuildContext context) {
    final savedName = ref.watch(onboardingNameProvider).valueOrNull;

    return ListView(
      padding: EdgeInsets.fromLTRB(5.w, 0.5.h, 5.w, 2.h),
      children: [
        AutoSizeText(
          _greetingLine(savedName),
          maxLines: 1,
          minFontSize: 12,
          stepGranularity: 0.5,
          style: GoogleFonts.inter(
            fontSize: (AppTypography.fontSubtitle + 3).sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 1.2.h),
        HomeScoreCard(
          key: widget.scoreKey,
          onStart: widget.onScoreStart,
        ),
        SizedBox(height: 1.2.h),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 2.w,
          crossAxisSpacing: 2.w,
          childAspectRatio: 0.88,
          children: [
            HomeFeatureCard(
              key: widget.monitorKey,
              icon: Icons.sensors,
              title: 'Monitorar Minha Empresa',
              subtitle: 'Radar 24/7',
              toggleValue: false,
              onToggleChanged: (v) {
                if (v) widget.onMonitorTap();
              },
              onTap: widget.onMonitorTap,
            ),
            HomeFeatureCard(
              key: widget.cndsKey,
              icon: Icons.description_outlined,
              title: 'Emitir CNDs',
              subtitle: 'Emita até 10 certidões para a sua empresa',
              actionLabel: 'Emitir',
              onTap: widget.onCndTap,
            ),
            HomeFeatureCard(
              key: widget.restricaoKey,
              icon: Icons.lock_outline,
              title: 'Consulta de Restrição',
              subtitle: 'Verifique se a empresa possui irregularidades',
              showCheck: true,
              actionLabel: 'Consultar',
              onTap: widget.onRestricaoTap,
            ),
            HomeFeatureCard(
              key: widget.protestoKey,
              icon: Icons.gavel,
              title: 'Consulta de Protesto',
              subtitle: 'Confira apontamentos por PJ',
              showCheck: true,
              actionLabel: 'Consultar',
              onTap: widget.onProtestoTap,
            ),
          ],
        ),
      ],
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/config/premium_access.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/company_score_model.dart';
import 'package:consulta_cnpj_new/domain/providers/company_score_provider.dart';
import 'package:consulta_cnpj_new/domain/providers/premium_status_provider.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/company_score_number.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class HomeScoreCard extends ConsumerWidget {
  const HomeScoreCard({
    super.key,
    required this.onStart,
  });

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreAsync = ref.watch(companyScoreLatestThisMonthProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: scoreAsync.when(
        loading: () => const _ScoreLoadingCard(key: ValueKey('score-loading')),
        error: (_, _) => _ScoreErrorCard(
          key: const ValueKey('score-error'),
          onRetry: () =>
              ref.invalidate(companyScoreLatestThisMonthProvider),
        ),
        data: (result) {
          if (result != null) {
            return _FilledScoreCard(
              key: ValueKey('score-filled-${result.id}'),
              result: result,
              onTap: onStart,
            );
          }
          return _EmptyScoreCard(
            key: const ValueKey('score-empty'),
            onStart: onStart,
          );
        },
      ),
    );
  }
}

BoxDecoration _scoreCardDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AppTheme.shadowLight.withValues(alpha: 0.4)),
    boxShadow: [
      BoxShadow(
        blurRadius: 8,
        offset: const Offset(0, 2),
        color: AppTheme.shadowLight.withValues(alpha: 0.25),
      ),
    ],
  );
}

class _ScoreLoadingCard extends StatelessWidget {
  const _ScoreLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.5.h),
      decoration: _scoreCardDecoration().copyWith(color: AppTheme.surface),
      child: Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: AppTheme.primary,
          size: 40,
        ),
      ),
    );
  }
}

class _ScoreErrorCard extends StatelessWidget {
  const _ScoreErrorCard({
    super.key,
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.2.h),
      decoration: _scoreCardDecoration().copyWith(color: AppTheme.surface),
      child: Column(
        children: [
          Text(
            'Ops, tivemos um problema...\ntente novamente',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: AppTypography.fontSubtitle.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
              height: 1.35,
            ),
          ),
          SizedBox(height: 1.5.h),
          IconButton(
            onPressed: onRetry,
            tooltip: 'Tentar novamente',
            icon: Icon(
              Icons.refresh,
              size: 7.w,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyScoreCard extends StatelessWidget {
  const _EmptyScoreCard({
    super.key,
    required this.onStart,
  });

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onStart,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: _scoreCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined, size: 5.w, color: AppTheme.primary),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Score empresarial',
                          style: GoogleFonts.inter(
                            fontSize: (AppTypography.fontSubtitle + 1).sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Visão de Conformidade',
                          style: GoogleFonts.inter(
                            fontSize: (AppTypography.fontBody + 2).sp,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.5.h),
              Text(
                'Inicie analise de score de empresas com a hub do pj.',
                style: GoogleFonts.inter(
                  fontSize: (AppTypography.fontSubtitle).sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primary,
                ),
              ),
              SizedBox(height: 1.5.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Iniciar >',
                  style: GoogleFonts.inter(
                    fontSize: (AppTypography.fontBody + 1).sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilledScoreCard extends ConsumerWidget {
  const _FilledScoreCard({
    super.key,
    required this.result,
    required this.onTap,
  });

  final CompanyScoreResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(premiumStatusProvider);
    final unlocked = isPremiumActive(ref);
    final message = companyScoreHomeMessage(result.bandEnum);

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: _scoreCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined, size: 5.w, color: AppTheme.primary),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Score empresarial',
                          style: GoogleFonts.inter(
                            fontSize: (AppTypography.fontSubtitle + 1).sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Visão de Conformidade',
                          style: GoogleFonts.inter(
                            fontSize: (AppTypography.fontBody + 2).sp,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.8.h),
              if (unlocked)
                CompanyScoreNumber(
                  score: result.score,
                  showScoreLabel: true,
                  largeFontSize: 28.sp,
                  smallFontSize: 14.sp,
                )
              else
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: CompanyScoreNumber(
                    score: result.score,
                    showScoreLabel: true,
                    largeFontSize: 28.sp,
                    smallFontSize: 14.sp,
                  ),
                ),
              SizedBox(height: 1.2.h),
              Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: AppTypography.fontSubtitle.sp,
                  color: AppTheme.textPrimary,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 1.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  unlocked ? 'Ver score >' : 'Desbloquear >',
                  style: GoogleFonts.inter(
                    fontSize: (AppTypography.fontBody + 1).sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/company_score_entry_args.dart';
import 'package:consulta_cnpj_new/domain/providers/company_score_provider.dart';
import 'package:consulta_cnpj_new/presentation/company_score_list_screen/widgets/company_score_list_card.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_async_error.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_async_loading.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_screen_fade.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class CompanyScoreListScreen extends ConsumerWidget {
  const CompanyScoreListScreen({super.key});

  void _openNewAnalysis(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.companyScore,
      arguments: const CompanyScoreEntryArgs(startNewQuiz: true),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoresAsync = ref.watch(companyScoresThisMonthProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Análises de score',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: AppScreenFade(
          child: Column(
            children: [
              SizedBox(height: 1.h),
              Expanded(
                child: AppAsyncFadeSwitcher(
                  child: scoresAsync.when(
                    loading: () => const AppAsyncLoading(
                      key: ValueKey('score-list-loading'),
                    ),
                    error: (_, _) => AppAsyncError(
                      key: const ValueKey('score-list-error'),
                      onRetry: () => ref
                          .read(companyScoresThisMonthProvider.notifier)
                          .refresh(),
                    ),
                    data: (scores) {
                      if (scores.isEmpty) {
                        return _EmptyScoreList(
                          key: const ValueKey('score-list-empty'),
                          onNewAnalysis: () => _openNewAnalysis(context),
                        );
                      }

                      return RefreshIndicator(
                        key: const ValueKey('score-list'),
                        color: AppTheme.primary,
                        onRefresh: () => ref
                            .read(companyScoresThisMonthProvider.notifier)
                            .refresh(),
                        child: ListView.separated(
                          padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 2.h),
                          itemCount: scores.length,
                          separatorBuilder: (_, _) => SizedBox(height: 1.5.h),
                          itemBuilder: (context, index) {
                            final result = scores[index];
                            return CompanyScoreListCard(
                              result: result,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.companyScore,
                                  arguments: CompanyScoreEntryArgs(
                                    initialResult: result,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 2.h),
                child: CnpjPrimaryButton(
                  onPressed: () => _openNewAnalysis(context),
                  child: Text(
                    'Nova análise',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
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

class _EmptyScoreList extends StatelessWidget {
  const _EmptyScoreList({
    super.key,
    required this.onNewAnalysis,
  });

  final VoidCallback onNewAnalysis;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 14.w,
              color: AppTheme.primary.withValues(alpha: 0.5),
            ),
            SizedBox(height: 2.h),
            Text(
              'Nenhuma análise este mês. Inicie o score de uma empresa para começar.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: AppTypography.fontSubtitle.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 2.h),
            CnpjPrimaryButton(
              onPressed: onNewAnalysis,
              child: Text(
                'Iniciar análise',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

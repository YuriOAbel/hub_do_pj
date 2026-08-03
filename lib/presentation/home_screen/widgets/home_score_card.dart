import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:consulta_cnpj_new/domain/models/company_score_model.dart';
import 'package:consulta_cnpj_new/domain/providers/company_score_provider.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/app_screen_fade.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_score_card.dart';

class HomeScoreCard extends ConsumerWidget {
  const HomeScoreCard({
    super.key,
    required this.onEmptyTap,
    required this.onSingleTap,
    required this.onMultiTap,
  });

  final VoidCallback onEmptyTap;
  final void Function(CompanyScoreResult result) onSingleTap;
  final VoidCallback onMultiTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoresAsync = ref.watch(companyScoresThisMonthProvider);

    return AppAsyncFadeSwitcher(
      child: scoresAsync.when(
        loading: () => const ScoreLoadingCard(key: ValueKey('score-loading')),
        error: (_, _) => ScoreErrorCard(
          key: const ValueKey('score-error'),
          onRetry: () => ref.invalidate(companyScoresThisMonthProvider),
        ),
        data: (scores) {
          if (scores.length >= 2) {
            return ScoreMultiCard(
              key: ValueKey('score-multi-${scores.length}'),
              count: scores.length,
              onTap: onMultiTap,
            );
          }
          if (scores.length == 1) {
            final result = scores.first;
            return ScoreFilledCard(
              key: ValueKey('score-filled-${result.id}'),
              result: result,
              onTap: () => onSingleTap(result),
            );
          }
          return ScoreEmptyCard(
            key: const ValueKey('score-empty'),
            onStart: onEmptyTap,
          );
        },
      ),
    );
  }
}

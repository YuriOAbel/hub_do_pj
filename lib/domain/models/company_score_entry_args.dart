import 'package:consulta_cnpj_new/domain/models/company_score_model.dart';

/// Typed args for [AppRoutes.companyScore].
class CompanyScoreEntryArgs {
  const CompanyScoreEntryArgs({
    this.initialResult,
    this.startNewQuiz = false,
  });

  final CompanyScoreResult? initialResult;
  final bool startNewQuiz;
}

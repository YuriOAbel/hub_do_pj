import 'package:consulta_cnpj_new/domain/models/company_score_model.dart';

/// Typed args for [AppRoutes.companyScore].
class CompanyScoreEntryArgs {
  const CompanyScoreEntryArgs({
    this.initialResult,
    this.startNewQuiz = false,
    this.prefillCnpj,
  });

  final CompanyScoreResult? initialResult;
  final bool startNewQuiz;

  /// Digits or formatted CNPJ to prefill the quiz CNPJ field.
  final String? prefillCnpj;
}

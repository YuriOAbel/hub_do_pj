import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/domain/models/company_score_model.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/services/cnpj_search_exception.dart';
import 'package:consulta_cnpj_new/services/cnpj_search_service.dart';
import 'package:consulta_cnpj_new/services/company_score_service.dart';

part 'company_score_provider.g.dart';

@riverpod
class CompanyScoreFlow extends _$CompanyScoreFlow {
  @override
  CompanyScoreState build() => const CompanyScoreState(
        phase: CompanyScorePhase.bootstrapping,
      );

  Future<void> bootstrap() async {
    state = state.copyWith(
      phase: CompanyScorePhase.bootstrapping,
      clearError: true,
    );
    try {
      final latest = await CompanyScoreService.instance.fetchLatestThisMonth();
      if (latest != null) {
        state = state.copyWith(
          phase: CompanyScorePhase.result,
          result: latest,
          clearError: true,
        );
        return;
      }
      state = state.copyWith(
        phase: CompanyScorePhase.quiz,
        draft: const CompanyScoreDraft(),
        clearResult: true,
        clearError: true,
      );
    } on CompanyScoreException catch (e) {
      state = state.copyWith(
        phase: CompanyScorePhase.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        phase: CompanyScorePhase.error,
        errorMessage: 'Erro ao carregar score',
      );
    }
  }

  void setCnpj(String value) {
    state = state.copyWith(
      draft: state.draft.copyWith(cnpj: value, clearCompany: true),
    );
  }

  Future<void> lookupCompany(String rawCnpj) async {
    final digits = CNPJValidator.strip(rawCnpj);
    if (!CNPJValidator.isValid(digits)) {
      state = state.copyWith(
        errorMessage: 'CNPJ inválido',
      );
      return;
    }

    state = state.copyWith(
      phase: CompanyScorePhase.fetchingCompany,
      draft: state.draft.copyWith(cnpj: digits, clearCompany: true),
      clearError: true,
    );

    try {
      final company = await CnpjSearchService.instance.getByCnpj(digits);
      state = state.copyWith(
        phase: CompanyScorePhase.quiz,
        draft: state.draft.copyWith(
          cnpj: digits,
          company: company,
          step: CompanyScoreStep.confirmCompany,
        ),
        clearError: true,
      );
    } on CnpjSearchException catch (e) {
      state = state.copyWith(
        phase: CompanyScorePhase.quiz,
        draft: state.draft.copyWith(
          cnpj: digits,
          step: CompanyScoreStep.cnpj,
          clearCompany: true,
        ),
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        phase: CompanyScorePhase.quiz,
        draft: state.draft.copyWith(
          cnpj: digits,
          step: CompanyScoreStep.cnpj,
          clearCompany: true,
        ),
        errorMessage: 'Falha ao consultar CNPJ',
      );
    }
  }

  void setCompany(CnpjModel company) {
    state = state.copyWith(draft: state.draft.copyWith(company: company));
  }

  void setCompanyAge(CompanyScoreAge value) {
    state = state.copyWith(draft: state.draft.copyWith(companyAge: value));
  }

  void setCompanySize(CompanyScoreSize value) {
    state = state.copyWith(draft: state.draft.copyWith(companySize: value));
  }

  void setCnpjMonitorFrequency(CompanyScoreMonitorFrequency value) {
    state = state.copyWith(
      draft: state.draft.copyWith(cnpjMonitorFrequency: value),
    );
  }

  void setTaxStatus(CompanyScoreTaxStatus value) {
    state = state.copyWith(draft: state.draft.copyWith(taxStatus: value));
  }

  void setCndLast6m(CompanyScoreCndLast6m value) {
    state = state.copyWith(draft: state.draft.copyWith(cndLast6m: value));
  }

  void setAccounting(CompanyScoreAccounting value) {
    state = state.copyWith(draft: state.draft.copyWith(accounting: value));
  }

  void setProtestStatus(CompanyScoreProtestStatus value) {
    state = state.copyWith(draft: state.draft.copyWith(protestStatus: value));
  }

  void setRestrictionStatus(CompanyScoreRestrictionStatus value) {
    state = state.copyWith(
      draft: state.draft.copyWith(restrictionStatus: value),
    );
  }

  void setOverdueDebt(CompanyScoreOverdueDebt value) {
    state = state.copyWith(draft: state.draft.copyWith(overdueDebt: value));
  }

  void setScoreMotive(CompanyScoreMotive value) {
    state = state.copyWith(draft: state.draft.copyWith(scoreMotive: value));
  }

  void goTo(CompanyScoreStep step) {
    state = state.copyWith(draft: state.draft.copyWith(step: step));
  }

  void advance() {
    final draft = state.draft;
    if (!draft.canContinueCurrentStep) return;
    final next = draft.step.next;
    if (next == null) {
      submit();
      return;
    }
    goTo(next);
  }

  void goBack() {
    final previous = state.draft.step.previous;
    if (previous == null) return;
    if (previous == CompanyScoreStep.cnpj) {
      state = state.copyWith(
        draft: state.draft.copyWith(
          step: previous,
          clearCompany: true,
        ),
      );
      return;
    }
    goTo(previous);
  }

  Future<void> submit() async {
    final draft = state.draft;
    if (!draft.canContinueCurrentStep) return;
    if (draft.scoreMotive == null) return;

    state = state.copyWith(
      phase: CompanyScorePhase.submitting,
      clearError: true,
    );

    try {
      final result = await CompanyScoreService.instance.calculate(
        cnpj: draft.cnpj,
        answers: draft.toAnswersPayload(),
        companyName: draft.company?.nome,
      );
      state = state.copyWith(
        phase: CompanyScorePhase.result,
        result: result,
        clearError: true,
      );
      ref.invalidate(companyScoreLatestThisMonthProvider);
    } on CompanyScoreException catch (e) {
      state = state.copyWith(
        phase: CompanyScorePhase.quiz,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        phase: CompanyScorePhase.quiz,
        errorMessage: 'Erro ao calcular score',
      );
    }
  }

  void retryBootstrap() => bootstrap();

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

@riverpod
class CompanyScoreLatestThisMonth extends _$CompanyScoreLatestThisMonth {
  @override
  Future<CompanyScoreResult?> build() {
    return CompanyScoreService.instance.fetchLatestThisMonth();
  }
}

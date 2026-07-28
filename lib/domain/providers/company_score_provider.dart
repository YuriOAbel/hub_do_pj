import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/domain/models/company_score_model.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/domain/providers/premium_status_provider.dart';
import 'package:consulta_cnpj_new/services/cnpj_search_exception.dart';
import 'package:consulta_cnpj_new/services/cnpj_search_service.dart';
import 'package:consulta_cnpj_new/services/company_score_service.dart';
import 'package:consulta_cnpj_new/services/free_user_limits_service.dart';
import 'package:consulta_cnpj_new/services/paywall/paywall_service.dart';
import 'package:consulta_cnpj_new/services/paywall/premium_config.dart';

part 'company_score_provider.g.dart';

@riverpod
class CompanyScoreFlow extends _$CompanyScoreFlow {
  @override
  CompanyScoreState build() => const CompanyScoreState(
        phase: CompanyScorePhase.bootstrapping,
      );

  Future<void> bootstrap({
    CompanyScoreResult? initialResult,
    bool startNewQuiz = false,
  }) async {
    state = state.copyWith(
      phase: CompanyScorePhase.bootstrapping,
      clearError: true,
    );
    try {
      if (initialResult != null) {
        state = state.copyWith(
          phase: CompanyScorePhase.result,
          result: initialResult,
          clearError: true,
        );
        return;
      }
      if (startNewQuiz) {
        state = state.copyWith(
          phase: CompanyScorePhase.quiz,
          draft: const CompanyScoreDraft(),
          clearResult: true,
          clearError: true,
        );
        return;
      }
      final list = await CompanyScoreService.instance.fetchThisMonth();
      if (list.length == 1) {
        state = state.copyWith(
          phase: CompanyScorePhase.result,
          result: list.first,
          clearError: true,
        );
        return;
      }
      if (list.length > 1) {
        state = state.copyWith(
          phase: CompanyScorePhase.result,
          result: list.first,
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
    if (state.phase == CompanyScorePhase.fetchingCompany ||
        state.phase == CompanyScorePhase.submitting) {
      return;
    }

    final digits = CNPJValidator.strip(rawCnpj);
    if (!CNPJValidator.isValid(digits)) {
      state = state.copyWith(
        errorMessage: 'CNPJ inválido',
      );
      return;
    }

    // Set loading immediately so UI blocks taps before plan/limit awaits.
    state = state.copyWith(
      phase: CompanyScorePhase.fetchingCompany,
      draft: state.draft.copyWith(cnpj: digits, clearCompany: true),
      clearError: true,
    );

    try {
      final planProductId = await _resolveScorePlanProductId();
      final tier = await _resolveScoreTier();

      try {
        final existing = await CompanyScoreService.instance.fetchThisMonth();
        final canAdd = await PlanLimitsService.instance.canAddScoreCnpj(
          planProductId: planProductId,
          cnpj: digits,
          existingCnpjsThisMonth: existing.map((e) => e.cnpj),
        );
        if (!canAdd) {
          final suggestedTier = tier < 2 ? 2 : 3;
          final title = await _planTitleForTier(suggestedTier);
          throw ScoreCnpjLimitException(
            suggestedTier: suggestedTier,
            suggestedPlanTitle: title,
          );
        }
      } on ScoreCnpjLimitException {
        rethrow;
      } catch (_) {
        // Offline / fetch fail — continue; edge enforces later if needed.
      }

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
    } on ScoreCnpjLimitException {
      state = state.copyWith(
        phase: CompanyScorePhase.quiz,
        draft: state.draft.copyWith(
          cnpj: digits,
          step: CompanyScoreStep.cnpj,
          clearCompany: true,
        ),
      );
      rethrow;
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
      ref.invalidate(companyScoresThisMonthProvider);
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

  void retryBootstrap({
    CompanyScoreResult? initialResult,
    bool startNewQuiz = false,
  }) =>
      bootstrap(
        initialResult: initialResult,
        startNewQuiz: startNewQuiz,
      );

  /// Reset to CNPJ quiz without bootstrapping overlay (e.g. from result CTA).
  void startNewQuiz() {
    state = state.copyWith(
      phase: CompanyScorePhase.quiz,
      draft: const CompanyScoreDraft(),
      clearResult: true,
      clearError: true,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<String> _resolveScorePlanProductId() async {
    if (PremiumConfig.temporarilyUnlocked) return 'compliance_plus';
    final fromProvider = ref.read(premiumStatusProvider).value;
    if (fromProvider != null &&
        fromProvider.planProductId.isNotEmpty) {
      return fromProvider.planProductId;
    }
    final cached = await PlanLimitsService.instance.readCachedUserPlan();
    if (cached != null && cached.productId.isNotEmpty) {
      return cached.productId;
    }
    return UserPlanState.freePlanProductId;
  }

  Future<int> _resolveScoreTier() async {
    if (PremiumConfig.temporarilyUnlocked) return 3;
    final fromProvider = ref.read(premiumStatusProvider).value;
    if (fromProvider != null && fromProvider.tier >= 1) {
      return fromProvider.tier;
    }
    final cached = await PlanLimitsService.instance.readCachedUserPlan();
    if (cached != null && cached.tier >= 1) return cached.tier;
    final active = await PaywallService.instance.checkPremiumActive();
    if (active) return fromProvider?.tier ?? cached?.tier ?? 1;
    return fromProvider?.tier ?? 0;
  }
}

@riverpod
class CompanyScoresThisMonth extends _$CompanyScoresThisMonth {
  @override
  Future<List<CompanyScoreResult>> build() {
    return CompanyScoreService.instance.fetchThisMonth();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => CompanyScoreService.instance.fetchThisMonth(),
    );
  }
}

Future<String?> _planTitleForTier(int tier) async {
  try {
    final plans = await PaywallService.instance.getAvailablePlans();
    for (final plan in plans) {
      if (plan.tier == tier) return plan.title;
    }
  } catch (_) {}
  return null;
}

import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/core/helpers/firebase_analytics_helper.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/domain/models/nome_model.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/domain/models/search_param.dart';
import 'package:consulta_cnpj_new/domain/providers/premium_status_provider.dart';
import 'package:consulta_cnpj_new/services/cnpj_search_exception.dart';
import 'package:consulta_cnpj_new/services/cnpj_search_service.dart';
import 'package:consulta_cnpj_new/services/company_name_search_service.dart';
import 'package:consulta_cnpj_new/services/free_user_limits_service.dart';
import 'package:consulta_cnpj_new/services/paywall/paywall_service.dart';
import 'package:consulta_cnpj_new/services/paywall/premium_config.dart';

part 'cnpj_search_provider.g.dart';

@riverpod
class CnpjSearch extends _$CnpjSearch {
  @override
  AsyncValue<CnpjModel?> build() => const AsyncData(null);

  Future<String> _resolvePlanProductId() async {
    if (PremiumConfig.temporarilyUnlocked) return 'compliance_plus';

    final fromProvider = ref.read(premiumStatusProvider).value;
    if (fromProvider != null &&
        fromProvider.planProductId.isNotEmpty &&
        fromProvider.planProductId != UserPlanState.freePlanProductId) {
      return fromProvider.planProductId;
    }

    final cached = await PlanLimitsService.instance.readCachedUserPlan();
    if (cached != null &&
        cached.productId.isNotEmpty &&
        cached.tier >= 1) {
      return cached.productId;
    }

    return fromProvider?.planProductId ?? UserPlanState.freePlanProductId;
  }

  Future<int> _resolveTier() async {
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

  Future<CnpjModel> searchByCnpj(String raw) async {
    state = const AsyncLoading();
    await FirebaseAnalyticsHelper.instance.logPesquisouCnpj();
    try {
      final planProductId = await _resolvePlanProductId();
      final tier = await _resolveTier();
      final canSearch = await PlanLimitsService.instance.canSearchCnpj(
        planProductId: planProductId,
      );
      if (!canSearch) {
        final title = await _suggestedPlanTitle(1);
        throw CnpjDailyLimitException(suggestedPlanTitle: title);
      }

      final digits = CNPJValidator.strip(raw);
      if (!CNPJValidator.isValid(digits)) {
        throw CnpjSearchException('CNPJ inválido');
      }
      final result = await CnpjSearchService.instance.getByCnpj(digits);
      await FirebaseAnalyticsHelper.instance.logSucessoPesquisouCnpj();

      if (tier <= 0) {
        await PlanLimitsService.instance.recordCnpjSearch();
      }

      state = AsyncData(result);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

Future<String?> _suggestedPlanTitle(int tier) async {
  try {
    final plans = await PaywallService.instance.getAvailablePlans();
    for (final plan in plans) {
      if (plan.tier == tier) return plan.title;
    }
  } catch (_) {}
  return null;
}

@riverpod
class CompanyNameSearch extends _$CompanyNameSearch {
  @override
  AsyncValue<List<NomeModel>> build() => const AsyncData([]);

  Future<List<NomeModel>> search(SearchParam param) async {
    state = const AsyncLoading();
    await FirebaseAnalyticsHelper.instance.logPesquisouRazao();
    try {
      final results =
          await CompanyNameSearchService.instance.searchByName(param.term);
      await FirebaseAnalyticsHelper.instance.logSucessoPesquisouRazao();
      state = AsyncData(results);
      return results;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

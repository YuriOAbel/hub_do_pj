import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/core/helpers/firebase_analytics_helper.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/domain/models/nome_model.dart';
import 'package:consulta_cnpj_new/domain/models/search_param.dart';
import 'package:consulta_cnpj_new/services/cnpj_search_exception.dart';
import 'package:consulta_cnpj_new/services/cnpj_search_service.dart';
import 'package:consulta_cnpj_new/services/company_name_search_service.dart';

part 'cnpj_search_provider.g.dart';

@riverpod
class CnpjSearch extends _$CnpjSearch {
  @override
  AsyncValue<CnpjModel?> build() => const AsyncData(null);

  Future<CnpjModel> searchByCnpj(String raw) async {
    state = const AsyncLoading();
    await FirebaseAnalyticsHelper.instance.logPesquisouCnpj();
    try {
      final digits = CNPJValidator.strip(raw);
      if (!CNPJValidator.isValid(digits)) {
        throw CnpjSearchException('CNPJ inválido');
      }
      final result = await CnpjSearchService.instance.getByCnpj(digits);
      await FirebaseAnalyticsHelper.instance.logSucessoPesquisouCnpj();
      state = AsyncData(result);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
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

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/domain/models/consulted_company_model.dart';
import 'package:consulta_cnpj_new/services/consulted_companies_service.dart';

part 'consulted_companies_provider.g.dart';

@riverpod
class ConsultedCompaniesList extends _$ConsultedCompaniesList {
  @override
  Future<List<ConsultedCompanyModel>> build() async {
    await ConsultedCompaniesService.instance.syncFromLocalHistoryIfNeeded();
    return ConsultedCompaniesService.instance.listWithOrders();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ConsultedCompaniesService.instance.listWithOrders(),
    );
  }

  /// Soft-fail upsert. Does not force a loading flash on listeners.
  Future<String?> upsert(CnpjModel company) async {
    final row =
        await ConsultedCompaniesService.instance.upsertFromCnpj(company);
    return row?.id;
  }
}

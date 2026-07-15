import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/core/utils/local_min_delay.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/services/local_cnpj_storage_service.dart';

part 'historic_provider.g.dart';

@riverpod
class HistoricList extends _$HistoricList {
  @override
  Future<List<CnpjModel>> build() {
    return withLocalMinDelay(LocalHistoryService.instance.getAll());
  }

  Future<void> save(CnpjModel item) async {
    await LocalHistoryService.instance.save(item);
    state = AsyncData(await LocalHistoryService.instance.getAll());
  }

  Future<void> refreshList() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => withLocalMinDelay(LocalHistoryService.instance.getAll()),
    );
  }
}

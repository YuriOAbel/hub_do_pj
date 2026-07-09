import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/services/local_cnpj_storage_service.dart';

part 'historic_provider.g.dart';

@riverpod
class HistoricList extends _$HistoricList {
  @override
  Future<List<CnpjModel>> build() => LocalHistoryService.instance.getAll();

  Future<void> save(CnpjModel item) async {
    await LocalHistoryService.instance.save(item);
    ref.invalidateSelf();
  }

  Future<void> refreshList() async {
    ref.invalidateSelf();
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/services/local_cnpj_storage_service.dart';

part 'favorite_provider.g.dart';

@riverpod
class FavoriteList extends _$FavoriteList {
  @override
  Future<List<CnpjModel>> build() => LocalFavoritesService.instance.getAll();

  Future<bool> isFavorite(CnpjModel item) =>
      LocalFavoritesService.instance.contains(item);

  Future<void> toggle(CnpjModel item) async {
    await LocalFavoritesService.instance.toggle(item);
    ref.invalidateSelf();
  }
}

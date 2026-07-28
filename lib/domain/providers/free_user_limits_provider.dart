import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/services/free_user_limits_service.dart';

part 'free_user_limits_provider.g.dart';

@riverpod
class FreeUserLimits extends _$FreeUserLimits {
  @override
  void build() {}

  Future<bool> canSearchCnpj() =>
      FreeUserLimitsService.instance.canSearchCnpj();

  Future<void> recordCnpjSearch() =>
      FreeUserLimitsService.instance.recordCnpjSearch();
}

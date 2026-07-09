import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/services/location_permission_service.dart';

part 'location_permission_provider.g.dart';

@riverpod
class LocationPermission extends _$LocationPermission {
  @override
  Future<bool> build() => LocationPermissionService.instance.isGranted();

  Future<bool> requestPermission() async {
    final granted = await LocationPermissionService.instance.request();
    state = AsyncData(granted);
    return granted;
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/services/location_permission_service.dart';
import 'package:consulta_cnpj_new/services/firebase_service.dart';
import 'package:consulta_cnpj_new/services/firebase_messaging_service.dart';
import 'package:consulta_cnpj_new/services/revenuecat_service.dart';
import 'package:consulta_cnpj_new/domain/providers/remote_config_provider.dart';

part 'app_init_provider.g.dart';

enum AppInitDestination { locationPermission, home }

@riverpod
class AppInit extends _$AppInit {
  @override
  Future<AppInitDestination> build() async {
    await FirebaseService.instance.init();
    await RevenueCatService.instance.init();
    await FirebaseMessagingService.instance.init();
    await ref.read(remoteConfigProvider.notifier).refresh();

    final granted = await LocationPermissionService.instance.isGranted();
    return granted
        ? AppInitDestination.home
        : AppInitDestination.locationPermission;
  }
}

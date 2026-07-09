import 'package:permission_handler/permission_handler.dart';

class LocationPermissionService {
  static final LocationPermissionService instance =
      LocationPermissionService._();
  LocationPermissionService._();

  Future<bool> isGranted() => Permission.location.isGranted;

  Future<bool> request() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }
}

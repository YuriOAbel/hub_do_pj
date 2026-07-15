import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// OS-backed device identifier for profile linking.
///
/// iOS: identifierForVendor. Android: androidInfo.id.
class DeviceIdentifier {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<String?> getDeviceId() async {
    try {
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor;
      }
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id;
      }
      return null;
    } catch (e) {
      debugPrint('DeviceIdentifier.getDeviceId: $e');
      return null;
    }
  }
}

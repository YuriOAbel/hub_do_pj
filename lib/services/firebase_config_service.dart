import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FirebaseConfigService {
  static final FirebaseConfigService instance = FirebaseConfigService._();
  FirebaseConfigService._();

  final Map<String, dynamic> _defaults = {};
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final raw =
          await rootBundle.loadString('assets/config/remote_config.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final configs = json['configs'] as Map<String, dynamic>;
      for (final entry in configs.entries) {
        final config = entry.value as Map<String, dynamic>;
        _defaults[entry.key] = config['default'];
      }
      _initialized = true;
    } catch (e) {
      debugPrint('FirebaseConfigService.init: $e');
    }
  }

  Map<String, dynamic>? getObj(String key) {
    final value = _defaults[key];
    if (value is Map<String, dynamic>) return value;
    if (value is String) {
      try {
        return jsonDecode(value) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  T getValue<T>(String key, T fallback) {
    final value = _defaults[key];
    if (value is T) return value;
    return fallback;
  }

  void updateFromRemote(Map<String, dynamic> remote) {
    _defaults.addAll(remote);
  }
}

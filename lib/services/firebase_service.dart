import 'dart:convert';

import 'package:consulta_cnpj_new/firebase_options.dart';
import 'package:consulta_cnpj_new/services/firebase_config_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._();
  FirebaseService._();

  FirebaseAnalytics? _analytics;
  FirebaseRemoteConfig? _remoteConfig;
  Set<String> _allowedEvents = {};
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      _analytics = FirebaseAnalytics.instance;
      _remoteConfig = FirebaseRemoteConfig.instance;
      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(minutes: 1),
        ),
      );
      await FirebaseConfigService.instance.init();
      await _loadEventRegistry();
      await _setRemoteConfigSdkDefaults();
      await _remoteConfig!.fetchAndActivate();
      _syncRemoteDefaults();
      _initialized = true;
    } catch (e) {
      debugPrint('FirebaseService.init: $e — running without Firebase');
      await FirebaseConfigService.instance.init();
      await _loadEventRegistry();
    }
  }

  Future<void> _setRemoteConfigSdkDefaults() async {
    if (_remoteConfig == null) return;
    try {
      final raw = await rootBundle.loadString(
        'assets/config/remote_config.json',
      );
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final configs = json['configs'] as Map<String, dynamic>;
      final defaults = <String, dynamic>{};
      for (final entry in configs.entries) {
        final config = entry.value as Map<String, dynamic>;
        final value = config['default'];
        if (value is bool || value is num || value is String) {
          defaults[entry.key] = value;
        } else {
          defaults[entry.key] = jsonEncode(value);
        }
      }
      await _remoteConfig!.setDefaults(defaults);
    } catch (e) {
      debugPrint('FirebaseService._setRemoteConfigSdkDefaults: $e');
    }
  }

  Future<void> _loadEventRegistry() async {
    try {
      final raw = await rootBundle.loadString(
        'assets/config/analytics_events.json',
      );
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final events = json['events'] as Map<String, dynamic>;
      _allowedEvents = events.keys.toSet();
    } catch (e) {
      debugPrint('FirebaseService._loadEventRegistry: $e');
    }
  }

  void _syncRemoteDefaults() {
    if (_remoteConfig == null) return;
    final keys = _remoteConfig!.getAll();
    final map = <String, dynamic>{};
    for (final entry in keys.entries) {
      map[entry.key] = entry.value.asString();
    }
    FirebaseConfigService.instance.updateFromRemote(map);
  }

  Future<void> logEvent({
    required String eventKey,
    Map<String, Object>? parameters,
    List<Map<String, Object>>? items,
  }) async {
    if (!_allowedEvents.contains(eventKey)) {
      if (kDebugMode) {
        debugPrint('FirebaseService.logEvent blocked: $eventKey');
      }
      return;
    }
    try {
      await _analytics?.logEvent(
        name: eventKey,
        parameters: parameters,
        items: items?.map(_analyticsEventItem).toList(),
      );
    } catch (e) {
      debugPrint('FirebaseService.logEvent: $e');
    }
  }

  AnalyticsEventItem _analyticsEventItem(Map<String, Object> map) {
    return AnalyticsEventItem(
      itemId: map['item_id'] as String?,
      itemName: map['item_name'] as String?,
      price: (map['price'] as num?)?.toDouble(),
      currency: map['currency'] as String?,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  String getString(String key, {String fallback = ''}) {
    try {
      return _remoteConfig?.getString(key) ?? fallback;
    } catch (_) {
      return FirebaseConfigService.instance.getValue(key, fallback);
    }
  }

  bool getBool(String key, {bool fallback = false}) {
    try {
      return _remoteConfig?.getBool(key) ?? fallback;
    } catch (_) {
      return FirebaseConfigService.instance.getValue(key, fallback);
    }
  }
}

import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/domain/models/banner_config_model.dart';
import 'package:consulta_cnpj_new/services/firebase_config_service.dart';
import 'package:consulta_cnpj_new/services/firebase_service.dart';

part 'remote_config_provider.g.dart';

@Riverpod(keepAlive: true)
class RemoteConfig extends _$RemoteConfig {
  @override
  AppRemoteConfigModel build() {
    return _load();
  }

  AppRemoteConfigModel _load() {
    final svc = FirebaseConfigService.instance;
    return AppRemoteConfigModel(
      activateSmartlook: _readBool(svc, 'activate_smartlook'),
      prospecting: _readBool(svc, 'prospecting'),
      restriction: _readBool(svc, 'restriction'),
      searchAdvanced: _readBool(svc, 'search_advanced'),
      enableBanner: _readBool(svc, 'enable_banner'),
      enableSearchNamed: _readBool(svc, 'enable_search_named', fallback: true),
      banners: svc.getValue<String>('banners', '{"imgs":[]}'),
      secondsAds: _readInt(svc, 'seconds_ads'),
    );
  }

  bool _readBool(FirebaseConfigService svc, String key, {bool fallback = false}) {
    final value = svc.getValue<dynamic>(key, fallback);
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return fallback;
  }

  int _readInt(FirebaseConfigService svc, String key, {int fallback = 60}) {
    final value = svc.getValue<dynamic>(key, fallback);
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  Future<void> refresh() async {
    await FirebaseService.instance.init();
    state = _load();
  }

  List<BannerConfigModel> get bannerItems {
    try {
      final decoded = jsonDecode(state.banners) as Map<String, dynamic>;
      final imgs = decoded['imgs'] as List<dynamic>? ?? [];
      return imgs
          .map((e) =>
              BannerConfigModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }
}

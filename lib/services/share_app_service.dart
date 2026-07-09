import 'dart:io';
import 'dart:ui';

import 'package:share_plus/share_plus.dart';

class ShareAppService {
  static final ShareAppService instance = ShareAppService._();
  ShareAppService._();

  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=br.com.cgy.consulta_cnpj_empresas';
  static const _appStoreUrl = 'https://apps.apple.com/app/id0000000000';

  /// Fallback origin required by iOS/iPadOS share sheet.
  static const _fallbackOrigin = Rect.fromLTWH(0, 0, 1, 1);

  String get storeUrl => Platform.isIOS ? _appStoreUrl : _playStoreUrl;

  Future<void> shareApp({Rect? sharePositionOrigin}) async {
    await Share.share(
      'Consulte CNPJs de empresas brasileiras! Baixe o app: $storeUrl',
      sharePositionOrigin: sharePositionOrigin ?? _fallbackOrigin,
    );
  }
}

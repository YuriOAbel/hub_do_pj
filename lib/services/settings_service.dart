import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:consulta_cnpj_new/core/config/legal_urls.dart';
import 'package:consulta_cnpj_new/core/config/support_config.dart';
import 'package:consulta_cnpj_new/services/onboarding_service.dart';
import 'package:consulta_cnpj_new/services/profile_sync_service.dart';
import 'package:consulta_cnpj_new/services/supabase_auth_service.dart';

/// External links + local profile helpers for the settings menu.
class SettingsService {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  static const _iosSubscriptions =
      'https://apps.apple.com/account/subscriptions';
  static const _androidSubscriptions =
      'https://play.google.com/store/account/subscriptions';

  Future<String> appVersionLabel() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version} (${info.buildNumber})';
  }

  Future<void> openTerms() => _openUrl(LegalUrls.termsOfService);

  Future<void> openPrivacy() => _openUrl(LegalUrls.privacyPolicy);

  Future<void> openSupportEmail() async {
    final url = SupportConfig.mailtoUrl;
    if (url == null || url.isEmpty) {
      throw StateError('E-mail de suporte não configurado');
    }
    await _openUrl(url);
  }

  Future<void> openWhatsApp() async {
    final url = SupportConfig.whatsappUrl;
    if (url == null || url.isEmpty) {
      throw StateError('WhatsApp de suporte não configurado');
    }
    await _openUrl(url);
  }

  Future<void> openManageSubscription() async {
    final url = Platform.isIOS ? _iosSubscriptions : _androidSubscriptions;
    await _openUrl(url);
  }

  Future<void> updateDisplayName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw StateError('Informe um nome');
    }
    await OnboardingService.instance.updateName(trimmed);
    await ProfileSyncService.instance.updateName(trimmed);
  }

  Future<void> deleteAccount() =>
      SupabaseAuthService.instance.deleteAccount();

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      debugPrint('SettingsService: cannot launch $url');
      throw StateError('Não foi possível abrir o link');
    }
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      throw StateError('Não foi possível abrir o link');
    }
  }
}

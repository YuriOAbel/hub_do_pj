import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase/supabase.dart';
import 'package:consulta_cnpj_new/core/utils/device_identifier.dart';
import 'package:consulta_cnpj_new/services/free_user_limits_service.dart';
import 'package:consulta_cnpj_new/services/home_tutorial_service.dart';
import 'package:consulta_cnpj_new/services/local_cnpj_storage_service.dart';
import 'package:consulta_cnpj_new/services/local_notification_inbox_service.dart';
import 'package:consulta_cnpj_new/services/onboarding_service.dart';
import 'package:consulta_cnpj_new/services/revenuecat_service.dart';

/// Anonymous Supabase auth with session restore (prefs + Keychain).
///
/// No Turnstile/captcha for now — dashboard must allow anon without captcha.
class SupabaseAuthService {
  static final SupabaseAuthService instance = SupabaseAuthService._();
  SupabaseAuthService._();

  static const _keySession = 'supabase_session_json';
  static const _keyUserId = 'supabase_user_id';
  static const _keychainSession = 'supabase_keychain_session_json';
  static const _keychainUserId = 'supabase_keychain_user_id';

  static const _defaultUrl = 'https://kpkctuuzhbnqudemeudh.supabase.co';

  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
      synchronizable: true,
    ),
  );

  String? _jwt;
  SupabaseClient? _client;
  String? _userId;
  Future<bool>? _refreshInFlight;

  String get _supabaseUrl {
    final fromEnv = dotenv.env['SUPABASE_URL']?.trim() ?? '';
    if (fromEnv.isNotEmpty) return fromEnv;
    return _defaultUrl;
  }

  String get _anonKey => dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';

  /// User JWT when authenticated; empty when not.
  String get currentJwt => _jwt ?? '';

  bool get isAuthenticated => _jwt != null && _jwt!.isNotEmpty;

  String? get userId => _userId;

  SupabaseClient? get client => _client;

  Future<void> initialize() async {
    if (isAuthenticated) return;

    final supabaseUrl = _supabaseUrl;
    final supabaseAnonKey = _anonKey;

    if (supabaseAnonKey.isEmpty) {
      debugPrint(
        'SupabaseAuthService: SUPABASE_ANON_KEY missing — skipping auth',
      );
      return;
    }

    final client = SupabaseClient(supabaseUrl, supabaseAnonKey);

    final restoredFromPrefs = await _tryRestoreSession(
      client,
      fromKeychain: false,
    );
    if (restoredFromPrefs) {
      _client = client;
      _afterSessionReady();
      return;
    }

    final restoredFromKeychain = await _tryRestoreSession(
      client,
      fromKeychain: true,
    );
    if (restoredFromKeychain) {
      _client = client;
      _afterSessionReady();
      return;
    }

    try {
      debugPrint('SupabaseAuthService: signing in anonymously...');
      final response = await client.auth.signInAnonymously();
      final session = response.session;
      if (session == null) {
        debugPrint('SupabaseAuthService: anon sign-in returned no session');
        return;
      }

      _jwt = session.accessToken;
      _userId = session.user.id;
      _client = client;

      await _persistSession(session);
      debugPrint('SupabaseAuthService: anon sign-in ok (user: $_userId)');
      _afterSessionReady();
    } catch (e) {
      debugPrint('SupabaseAuthService: anon sign-in failed: $e');
    }
  }

  Future<bool> refreshSession() {
    _refreshInFlight ??= _doRefreshSession().whenComplete(() {
      _refreshInFlight = null;
    });
    return _refreshInFlight!;
  }

  Future<bool> _doRefreshSession() async {
    if (_client == null) return false;
    try {
      final response = await _client!.auth.refreshSession();
      final session = response.session;
      if (session == null) return false;
      _jwt = session.accessToken;
      _userId = session.user.id;
      await _persistSession(session);
      return true;
    } catch (e) {
      debugPrint('SupabaseAuthService: refresh failed: $e');
      return false;
    }
  }

  void _afterSessionReady() {
    Future(() async {
      await syncDeviceId();
      final uid = _userId;
      if (uid != null && uid.isNotEmpty) {
        await RevenueCatService.instance.logIn(uid);
      }
    });
  }

  /// Ensures anon/session auth + `profiles.device_id` before order ops.
  Future<void> ensureReadyForOrders() async {
    await initialize();
    if (!isAuthenticated || _client == null || _userId == null) {
      throw StateError(
        'Sessão inválida. Reabra o app e tente novamente.',
      );
    }

    // Refresh access token when possible so Edge JWT checks stay valid.
    await refreshSession();
    if (!isAuthenticated || currentJwt.isEmpty) {
      throw StateError(
        'Sessão inválida. Reabra o app e tente novamente.',
      );
    }

    final synced = await syncDeviceId();
    if (!synced) {
      throw StateError(
        'Não foi possível vincular este dispositivo. Reabra o app e tente novamente.',
      );
    }
  }

  /// Writes OS device id to `profiles.device_id` under RLS.
  /// Returns true when profile has a non-empty device_id afterwards.
  Future<bool> syncDeviceId() async {
    if (_client == null || _userId == null || !isAuthenticated) return false;

    try {
      final deviceId = await DeviceIdentifier.getDeviceId();
      if (deviceId == null || deviceId.isEmpty) {
        debugPrint('SupabaseAuthService: device id unavailable');
        return false;
      }

      // Upsert covers race where auth trigger profile row is not ready yet.
      await _client!.from('profiles').upsert({
        'id': _userId!,
        'device_id': deviceId,
      });

      final row = await _client!
          .from('profiles')
          .select('device_id')
          .eq('id', _userId!)
          .maybeSingle();
      final stored = row?['device_id'] as String?;
      final ok = stored != null && stored.trim().isNotEmpty;
      if (ok) {
        debugPrint('SupabaseAuthService: device_id synced');
      } else {
        debugPrint('SupabaseAuthService: device_id missing after upsert');
      }
      return ok;
    } catch (e) {
      debugPrint('SupabaseAuthService: syncDeviceId failed: $e');
      return false;
    }
  }

  Future<bool> _tryRestoreSession(
    SupabaseClient client, {
    required bool fromKeychain,
  }) async {
    try {
      final String? sessionJson;
      final String? storedUserId;

      if (fromKeychain) {
        sessionJson = await _storage.read(key: _keychainSession);
        storedUserId = await _storage.read(key: _keychainUserId);
      } else {
        final prefs = await SharedPreferences.getInstance();
        sessionJson = prefs.getString(_keySession);
        storedUserId = prefs.getString(_keyUserId);
      }

      if (sessionJson == null || storedUserId == null) return false;

      final response = await client.auth.recoverSession(sessionJson);
      final session = response.session;
      if (session == null) {
        await _clearPrefsSession();
        return false;
      }

      _jwt = session.accessToken;
      _userId = session.user.id;
      await _persistSession(session);
      debugPrint('SupabaseAuthService: session restored ($_userId)');
      return true;
    } catch (e) {
      debugPrint('SupabaseAuthService: restore failed: $e');
      await _clearPrefsSession();
      return false;
    }
  }

  Future<void> _persistSession(Session session) async {
    final sessionJson = jsonEncode(session.toJson());
    final uid = session.user.id;

    try {
      await _storage.write(key: _keychainSession, value: sessionJson);
      await _storage.write(key: _keychainUserId, value: uid);
    } catch (e) {
      debugPrint('SupabaseAuthService: Keychain write failed: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySession, sessionJson);
      await prefs.setString(_keyUserId, uid);
    } catch (e) {
      debugPrint('SupabaseAuthService: prefs write failed: $e');
    }
  }

  Future<void> _clearPrefsSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keySession);
      await prefs.remove(_keyUserId);
    } catch (e) {
      debugPrint('SupabaseAuthService: clear prefs failed: $e');
    }
  }

  Future<void> clearIdentity() async {
    await _clearPrefsSession();
    try {
      await _storage.delete(key: _keychainSession);
      await _storage.delete(key: _keychainUserId);
    } catch (e) {
      debugPrint('SupabaseAuthService: clear Keychain failed: $e');
    }
    _jwt = null;
    _userId = null;
    _client = null;
  }

  /// Deletes remote account via Edge Function, wipes local user data, signs in
  /// anonymously again.
  Future<void> deleteAccount() async {
    await initialize();
    if (!isAuthenticated || _client == null || currentJwt.isEmpty) {
      throw StateError(
        'Sessão inválida. Reabra o app e tente novamente.',
      );
    }

    await refreshSession();
    if (!isAuthenticated || currentJwt.isEmpty || _client == null) {
      throw StateError(
        'Sessão inválida. Reabra o app e tente novamente.',
      );
    }

    try {
      final response = await _client!.functions.invoke(
        'delete-account',
        body: <String, dynamic>{},
        headers: {
          'Authorization': 'Bearer $currentJwt',
        },
      );

      final data = response.data;
      final ok = data is Map && data['ok'] == true;
      if (!ok) {
        final message = data is Map && data['error'] is String
            ? data['error'] as String
            : 'Não foi possível excluir a conta';
        throw StateError(message);
      }
    } catch (e) {
      debugPrint('SupabaseAuthService.deleteAccount: $e');
      if (e is StateError) rethrow;
      throw StateError('Não foi possível excluir a conta. Tente novamente.');
    }

    await _wipeLocalUserData();
    await clearIdentity();
    await initialize();
  }

  Future<void> _wipeLocalUserData() async {
    await OnboardingService.instance.clearAll();
    await LocalHistoryService.instance.clearAll();
    await LocalFavoritesService.instance.clearAll();
    await LocalNotificationInboxService.instance.clearAll();
    await HomeTutorialService.instance.clear();
    await PlanLimitsService.instance.clearUsageAndCache();
  }
}

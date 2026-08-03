import 'package:flutter/foundation.dart';
import 'package:consulta_cnpj_new/core/utils/device_identifier.dart';
import 'package:consulta_cnpj_new/services/onboarding_service.dart';
import 'package:consulta_cnpj_new/services/supabase_auth_service.dart';

/// Result of Edge Function `sync-profile`.
class ProfileSyncResult {
  const ProfileSyncResult({
    required this.ok,
    this.profileId,
    this.name,
    this.reclaimed = false,
    this.onboarded = false,
  });

  final bool ok;
  final String? profileId;
  final String? name;
  final bool reclaimed;
  final bool onboarded;

  static const failed = ProfileSyncResult(ok: false);
}

/// Gateway to Edge Function `sync-profile`.
///
/// Front only collects fields and invokes; reclaim / coalesce live on backend.
class ProfileSyncService {
  static final ProfileSyncService instance = ProfileSyncService._();
  ProfileSyncService._();

  Future<ProfileSyncResult> _queue = Future.value(ProfileSyncResult.failed);

  /// Syncs profile via `sync-profile`.
  ///
  /// [purpose]:
  /// - `bootstrap` — app open / device bind (device_id only OK)
  /// - `onboarding` — requires name, personType, occupation, interestIds
  /// - `update` — partial non-null fields (name, plan, …)
  Future<ProfileSyncResult> sync({
    String purpose = 'bootstrap',
    String? deviceId,
    String? name,
    String? personType,
    String? occupation,
    String? occupationOther,
    List<String>? interestIds,
    String? planProductId,
    String? phone,
    bool? monthlyCertificateInterest,
  }) {
    final next = _queue.then((_) {
      return _syncOnce(
        purpose: purpose,
        deviceId: deviceId,
        name: name,
        personType: personType,
        occupation: occupation,
        occupationOther: occupationOther,
        interestIds: interestIds,
        planProductId: planProductId,
        phone: phone,
        monthlyCertificateInterest: monthlyCertificateInterest,
      );
    });
    _queue = next.then(
      (_) => ProfileSyncResult.failed,
      onError: (_) => ProfileSyncResult.failed,
    );
    return next;
  }

  Future<ProfileSyncResult> _syncOnce({
    required String purpose,
    String? deviceId,
    String? name,
    String? personType,
    String? occupation,
    String? occupationOther,
    List<String>? interestIds,
    String? planProductId,
    String? phone,
    bool? monthlyCertificateInterest,
  }) async {
    final auth = SupabaseAuthService.instance;
    final client = auth.client;

    if (!auth.isAuthenticated || client == null || auth.currentJwt.isEmpty) {
      debugPrint('ProfileSyncService.sync: not authenticated — skip');
      return ProfileSyncResult.failed;
    }

    final resolvedDeviceId = (deviceId != null && deviceId.trim().isNotEmpty)
        ? deviceId.trim()
        : await DeviceIdentifier.getDeviceId();

    if (resolvedDeviceId == null || resolvedDeviceId.isEmpty) {
      debugPrint('ProfileSyncService.sync: device id unavailable');
      return ProfileSyncResult.failed;
    }

    final body = <String, dynamic>{
      'purpose': purpose,
      'device_id': resolvedDeviceId,
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      if (personType != null && personType.trim().isNotEmpty)
        'person_type': personType.trim(),
      if (occupation != null && occupation.trim().isNotEmpty)
        'occupation': occupation.trim(),
      if (occupationOther != null && occupationOther.trim().isNotEmpty)
        'occupation_other': occupationOther.trim(),
      if (interestIds != null && interestIds.isNotEmpty)
        'interest_ids': interestIds,
      if (planProductId != null && planProductId.trim().isNotEmpty)
        'plan_product_id': planProductId.trim(),
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      'monthly_certificate_interest': ?monthlyCertificateInterest,
    };

    try {
      final response = await client.functions.invoke(
        'sync-profile',
        body: body,
        headers: {
          'Authorization': 'Bearer ${auth.currentJwt}',
        },
      );

      final data = response.data;
      if (data is! Map) {
        debugPrint('ProfileSyncService.sync: unexpected response $data');
        return ProfileSyncResult.failed;
      }

      if (data['error'] is String) {
        debugPrint('ProfileSyncService.sync: ${data['error']}');
        return ProfileSyncResult.failed;
      }

      final profile = data['profile'];
      if (profile is! Map) {
        debugPrint('ProfileSyncService.sync: missing profile in response');
        return ProfileSyncResult.failed;
      }

      final stored = profile['deviceId'] as String? ??
          profile['device_id'] as String?;
      if (stored == null || stored.trim().isEmpty) {
        debugPrint('ProfileSyncService.sync: device_id missing after sync');
        return ProfileSyncResult.failed;
      }

      final sessionPayload = data['session'];
      if (sessionPayload is Map) {
        final email = sessionPayload['email'] as String?;
        final password = sessionPayload['password'] as String?;
        if (email != null &&
            email.isNotEmpty &&
            password != null &&
            password.isNotEmpty) {
          final adopted = await auth.adoptSessionFromPassword(
            email: email,
            password: password,
          );
          if (!adopted) {
            debugPrint(
              'ProfileSyncService.sync: failed to adopt reclaimed session',
            );
            return ProfileSyncResult.failed;
          }
        }
      }

      final profileName = profile['name'] as String?;
      final profileId = profile['id'] as String?;
      final reclaimed = data['reclaimed'] == true;
      final onboarded = data['onboarded'] == true ||
          profile['onboarded'] == true;

      // Only mark local onboarding done when remote profile is complete.
      if (onboarded) {
        if (profileName != null && profileName.trim().isNotEmpty) {
          await OnboardingService.instance.updateName(profileName.trim());
        }
        await OnboardingService.instance.markCompleted();
      }

      debugPrint(
        'ProfileSyncService.sync: ok'
        '${reclaimed ? ' (reclaimed)' : ''}'
        '${onboarded ? ' (onboarded)' : ''}',
      );
      return ProfileSyncResult(
        ok: true,
        profileId: profileId,
        name: profileName,
        reclaimed: reclaimed,
        onboarded: onboarded,
      );
    } catch (e) {
      debugPrint('ProfileSyncService.sync: $e');
      return ProfileSyncResult.failed;
    }
  }

  /// Full onboarding payload — refuses empty required fields; throws on failure.
  Future<void> syncOnboardingAnswers({
    required String name,
    required String personType,
    required String occupation,
    String? occupationOther,
    required List<String> interestIds,
  }) async {
    final trimmedName = name.trim();
    final trimmedPersonType = personType.trim();
    final trimmedOccupation = occupation.trim();
    final trimmedOther = occupationOther?.trim();
    final interests = interestIds
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (trimmedName.isEmpty) {
      throw StateError('Nome é obrigatório para salvar o perfil.');
    }
    if (trimmedPersonType.isEmpty) {
      throw StateError('Tipo de pessoa é obrigatório para salvar o perfil.');
    }
    if (trimmedOccupation.isEmpty) {
      throw StateError('Ocupação é obrigatória para salvar o perfil.');
    }
    if (interests.isEmpty) {
      throw StateError('Selecione ao menos um interesse.');
    }
    if (trimmedOccupation == 'outra' &&
        (trimmedOther == null || trimmedOther.isEmpty)) {
      throw StateError('Descreva a ocupação quando escolher Outra.');
    }

    final result = await sync(
      purpose: 'onboarding',
      name: trimmedName,
      personType: trimmedPersonType,
      occupation: trimmedOccupation,
      occupationOther: trimmedOther,
      interestIds: interests,
    );
    if (!result.ok || !result.onboarded) {
      throw StateError(
        'Não foi possível salvar seu perfil. Verifique a conexão e tente novamente.',
      );
    }
  }

  Future<void> updateName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw StateError('Nome não pode ser vazio.');
    }
    final result = await sync(purpose: 'update', name: trimmed);
    if (!result.ok) {
      throw StateError('Não foi possível atualizar o nome. Tente novamente.');
    }
  }

  /// Appends [interestIds] via sync (backend unions with existing).
  Future<void> appendInterestIds(List<String> interestIds) async {
    final cleaned = interestIds
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (cleaned.isEmpty) return;

    final result = await sync(purpose: 'update', interestIds: cleaned);
    if (!result.ok) {
      throw StateError(
        'Não foi possível salvar o interesse. Tente novamente.',
      );
    }
  }
}

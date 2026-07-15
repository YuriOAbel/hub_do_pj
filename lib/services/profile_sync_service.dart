import 'package:flutter/foundation.dart';
import 'package:consulta_cnpj_new/services/supabase_auth_service.dart';

/// Syncs onboarding answers to `profiles` under the authenticated user.
class ProfileSyncService {
  static final ProfileSyncService instance = ProfileSyncService._();
  ProfileSyncService._();

  Future<void> syncOnboardingAnswers({
    required String name,
    String? personType,
    String? occupation,
    String? occupationOther,
    required List<String> interestIds,
  }) async {
    final auth = SupabaseAuthService.instance;
    final client = auth.client;
    final userId = auth.userId;

    if (!auth.isAuthenticated || client == null || userId == null) {
      debugPrint('ProfileSyncService: not authenticated — skip sync');
      return;
    }

    try {
      final payload = <String, dynamic>{
        'name': name,
        'interest_ids': interestIds,
        'person_type': ?personType,
        'occupation': ?occupation,
        if (occupationOther != null && occupationOther.isNotEmpty)
          'occupation_other': occupationOther,
      };

      await client.from('profiles').update(payload).eq('id', userId);
      debugPrint('ProfileSyncService: onboarding synced');
    } catch (e) {
      debugPrint('ProfileSyncService.syncOnboardingAnswers: $e');
    }
  }

  /// Merges [interestIds] into `profiles.interest_ids` (no duplicates).
  Future<void> appendInterestIds(List<String> interestIds) async {
    if (interestIds.isEmpty) return;

    final auth = SupabaseAuthService.instance;
    final client = auth.client;
    final userId = auth.userId;

    if (!auth.isAuthenticated || client == null || userId == null) {
      debugPrint('ProfileSyncService: not authenticated — skip appendInterestIds');
      return;
    }

    try {
      final row = await client
          .from('profiles')
          .select('interest_ids')
          .eq('id', userId)
          .maybeSingle();

      final current = <String>[];
      final raw = row?['interest_ids'];
      if (raw is List) {
        for (final item in raw) {
          if (item is String && item.isNotEmpty) current.add(item);
        }
      }

      final merged = {...current, ...interestIds}.toList();
      if (merged.length == current.length) {
        debugPrint('ProfileSyncService: interests already present');
        return;
      }

      await client
          .from('profiles')
          .update({'interest_ids': merged})
          .eq('id', userId);
      debugPrint('ProfileSyncService: interests appended $interestIds');
    } catch (e) {
      debugPrint('ProfileSyncService.appendInterestIds: $e');
      rethrow;
    }
  }
}

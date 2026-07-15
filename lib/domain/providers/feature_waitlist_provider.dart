import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/domain/models/onboarding_model.dart';
import 'package:consulta_cnpj_new/services/firebase_messaging_service.dart';
import 'package:consulta_cnpj_new/services/profile_sync_service.dart';

part 'feature_waitlist_provider.g.dart';

@riverpod
class FeatureWaitlist extends _$FeatureWaitlist {
  @override
  FutureOr<void> build() {}

  String? interestIdForOrigin(String origin) {
    if (origin.contains('monitorar')) {
      return OnboardingInterest.monitorarEmpresas.id;
    }
    return null;
  }

  Future<void> subscribeRestrictionTopic() {
    return FirebaseMessagingService.instance.subscribeRestriction();
  }

  /// Marks profile interest (when mapped) and returns success message.
  Future<String> notifyWhenAvailable(String origin) async {
    state = const AsyncLoading();
    try {
      if (origin.contains('restricao')) {
        await subscribeRestrictionTopic();
      }

      final interestId = interestIdForOrigin(origin);
      if (interestId != null) {
        await ProfileSyncService.instance.appendInterestIds([interestId]);
      }

      state = const AsyncData(null);
      return 'Pronto! Avisaremos quando estiver disponível.';
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

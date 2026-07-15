import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/core/helpers/firebase_analytics_helper.dart';
import 'package:consulta_cnpj_new/domain/models/onboarding_model.dart';
import 'package:consulta_cnpj_new/services/in_app_review_service.dart';
import 'package:consulta_cnpj_new/services/onboarding_service.dart';
import 'package:consulta_cnpj_new/services/profile_sync_service.dart';

part 'onboarding_provider.g.dart';

@riverpod
class OnboardingCompleted extends _$OnboardingCompleted {
  @override
  Future<bool> build() => OnboardingService.instance.isCompleted();

  Future<void> markCompleted() async {
    await OnboardingService.instance.markCompleted();
    state = const AsyncData(true);
  }
}

@riverpod
class OnboardingName extends _$OnboardingName {
  @override
  Future<String?> build() => OnboardingService.instance.getName();
}

@riverpod
class OnboardingFlow extends _$OnboardingFlow {
  @override
  OnboardingDraft build() => const OnboardingDraft();

  void setPersonType(OnboardingPersonType type) {
    state = state.copyWith(
      personType: type,
      clearPfProfession: true,
      clearPjOccupation: true,
      occupationOther: '',
    );
  }

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setPfProfession(OnboardingPfProfession profession) {
    state = state.copyWith(
      pfProfession: profession,
      clearPjOccupation: true,
      occupationOther:
          profession == OnboardingPfProfession.outra ? state.occupationOther : '',
    );
  }

  void setPjOccupation(OnboardingPjOccupation occupation) {
    state = state.copyWith(
      pjOccupation: occupation,
      clearPfProfession: true,
      occupationOther:
          occupation == OnboardingPjOccupation.outra ? state.occupationOther : '',
    );
  }

  void setOccupationOther(String value) {
    state = state.copyWith(occupationOther: value);
  }

  void toggleInterest(OnboardingInterest interest) {
    final next = Set<OnboardingInterest>.from(state.interests);
    if (next.contains(interest)) {
      next.remove(interest);
    } else {
      next.add(interest);
    }
    state = state.copyWith(interests: next);
  }

  void toggleCompanyInfo(OnboardingCompanyInfo info) {
    final next = Set<OnboardingCompanyInfo>.from(state.companyInfos);
    if (next.contains(info)) {
      next.remove(info);
    } else {
      next.add(info);
    }
    state = state.copyWith(companyInfos: next);
  }

  void goTo(OnboardingStep step) {
    state = state.copyWith(step: step);
  }

  /// After interests: company infos if CNPJ selected, else CNPJ demo.
  void advanceFromInterests() {
    if (state.wantsCnpjConsulta) {
      goTo(OnboardingStep.companyInfos);
    } else {
      goTo(OnboardingStep.cnpj);
    }
  }

  Future<void> persistAnswers() async {
    final draft = state;
    final occupationId = draft.personType == OnboardingPersonType.pf
        ? draft.pfProfession?.id
        : draft.pjOccupation?.id;
    final name = draft.name.trim();
    final personType = draft.personType?.id;
    final occupationOther = draft.occupationOther.trim();
    final interests = draft.interests.map((e) => e.id).toList();

    await OnboardingService.instance.saveAnswers(
      name: name,
      personType: personType,
      occupationId: occupationId,
      occupationOther: occupationOther,
      interests: interests,
      companyInfos: draft.companyInfos.map((e) => e.id).toList(),
    );
    await ProfileSyncService.instance.syncOnboardingAnswers(
      name: name,
      personType: personType,
      occupation: occupationId,
      occupationOther: occupationOther,
      interestIds: interests,
    );
    ref.invalidate(onboardingNameProvider);
  }

  Future<void> logStarted() =>
      FirebaseAnalyticsHelper.instance.logOnboardingStarted();

  Future<void> logOccupation() {
    return FirebaseAnalyticsHelper.instance
        .logOnboardingOccupation(state.occupationAnalyticsValue);
  }

  Future<void> logInterests() {
    final csv = state.interests.map((e) => e.id).join(',');
    return FirebaseAnalyticsHelper.instance.logOnboardingInterests(csv);
  }

  Future<void> logCompanyInfos() {
    final csv = state.companyInfos.map((e) => e.id).join(',');
    return FirebaseAnalyticsHelper.instance.logOnboardingCompanyInfos(csv);
  }

  Future<void> logRating(int stars) =>
      FirebaseAnalyticsHelper.instance.logOnboardingRating(stars);

  Future<void> logRatingSkipped() =>
      FirebaseAnalyticsHelper.instance.logOnboardingRatingSkipped();

  Future<void> logFeedback() =>
      FirebaseAnalyticsHelper.instance.logOnboardingFeedback();

  Future<void> logPaywallSkipped() =>
      FirebaseAnalyticsHelper.instance.logOnboardingPaywallSkipped();

  Future<void> logCompleted() =>
      FirebaseAnalyticsHelper.instance.logOnboardingCompleted();

  Future<void> requestInAppReview() async {
    await FirebaseAnalyticsHelper.instance.logInAppReviewRequested();
    await InAppReviewService.instance.requestReview();
  }

  Future<void> finishOnboarding() async {
    await persistAnswers();
    await logPaywallSkipped();
    await logCompleted();
    await ref.read(onboardingCompletedProvider.notifier).markCompleted();
  }
}

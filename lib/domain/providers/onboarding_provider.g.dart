// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onboardingCompletedHash() =>
    r'e137f51f2805b77ba074b9576cafaef7e7afda93';

/// See also [OnboardingCompleted].
@ProviderFor(OnboardingCompleted)
final onboardingCompletedProvider =
    AutoDisposeAsyncNotifierProvider<OnboardingCompleted, bool>.internal(
      OnboardingCompleted.new,
      name: r'onboardingCompletedProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onboardingCompletedHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OnboardingCompleted = AutoDisposeAsyncNotifier<bool>;
String _$onboardingNameHash() => r'51fa88eaab3b9c7f5e979f5dea51ab59024fa240';

/// See also [OnboardingName].
@ProviderFor(OnboardingName)
final onboardingNameProvider =
    AutoDisposeAsyncNotifierProvider<OnboardingName, String?>.internal(
      OnboardingName.new,
      name: r'onboardingNameProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onboardingNameHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OnboardingName = AutoDisposeAsyncNotifier<String?>;
String _$onboardingFlowHash() => r'49ef18230d19fec6643c5bb8afe709032d092e57';

/// See also [OnboardingFlow].
@ProviderFor(OnboardingFlow)
final onboardingFlowProvider =
    AutoDisposeNotifierProvider<OnboardingFlow, OnboardingDraft>.internal(
      OnboardingFlow.new,
      name: r'onboardingFlowProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onboardingFlowHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OnboardingFlow = AutoDisposeNotifier<OnboardingDraft>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

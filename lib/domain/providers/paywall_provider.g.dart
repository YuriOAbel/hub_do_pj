// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paywall_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$paywallPlansHash() => r'cb04b42950aaf7eb91c93f6d2765db71b1124d15';

/// See also [PaywallPlans].
@ProviderFor(PaywallPlans)
final paywallPlansProvider =
    AutoDisposeNotifierProvider<PaywallPlans, PaywallPlansState>.internal(
      PaywallPlans.new,
      name: r'paywallPlansProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$paywallPlansHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PaywallPlans = AutoDisposeNotifier<PaywallPlansState>;
String _$financialCardsHash() => r'3f8097cff6b40fa40319948252db9ab20a270ffc';

/// See also [FinancialCards].
@ProviderFor(FinancialCards)
final financialCardsProvider =
    AutoDisposeAsyncNotifierProvider<
      FinancialCards,
      List<FinancialCardModel>
    >.internal(
      FinancialCards.new,
      name: r'financialCardsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$financialCardsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FinancialCards = AutoDisposeAsyncNotifier<List<FinancialCardModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

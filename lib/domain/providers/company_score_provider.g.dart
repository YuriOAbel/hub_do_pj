// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_score_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$companyScoreFlowHash() => r'ac4212b635b6ceed437270e9a2148c1e80fbaf0c';

/// See also [CompanyScoreFlow].
@ProviderFor(CompanyScoreFlow)
final companyScoreFlowProvider =
    AutoDisposeNotifierProvider<CompanyScoreFlow, CompanyScoreState>.internal(
      CompanyScoreFlow.new,
      name: r'companyScoreFlowProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$companyScoreFlowHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CompanyScoreFlow = AutoDisposeNotifier<CompanyScoreState>;
String _$companyScoreLatestThisMonthHash() =>
    r'68bc4a0b00622d9fcf3e865e403e2eb12e5facd0';

/// See also [CompanyScoreLatestThisMonth].
@ProviderFor(CompanyScoreLatestThisMonth)
final companyScoreLatestThisMonthProvider =
    AutoDisposeAsyncNotifierProvider<
      CompanyScoreLatestThisMonth,
      CompanyScoreResult?
    >.internal(
      CompanyScoreLatestThisMonth.new,
      name: r'companyScoreLatestThisMonthProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$companyScoreLatestThisMonthHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CompanyScoreLatestThisMonth =
    AutoDisposeAsyncNotifier<CompanyScoreResult?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

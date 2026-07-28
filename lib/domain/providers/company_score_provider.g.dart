// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_score_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$companyScoreFlowHash() => r'b095c6ba3f1d8000837c55e70a747d9470164392';

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
String _$companyScoresThisMonthHash() =>
    r'fb65aaf8c0e70f25f30a2d09a780d05b6481e9e9';

/// See also [CompanyScoresThisMonth].
@ProviderFor(CompanyScoresThisMonth)
final companyScoresThisMonthProvider =
    AutoDisposeAsyncNotifierProvider<
      CompanyScoresThisMonth,
      List<CompanyScoreResult>
    >.internal(
      CompanyScoresThisMonth.new,
      name: r'companyScoresThisMonthProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$companyScoresThisMonthHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CompanyScoresThisMonth =
    AutoDisposeAsyncNotifier<List<CompanyScoreResult>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

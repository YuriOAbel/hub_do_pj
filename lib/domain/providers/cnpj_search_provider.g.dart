// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cnpj_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cnpjSearchHash() => r'139a8776179feb08d433425023d2fcfdee43910a';

/// See also [CnpjSearch].
@ProviderFor(CnpjSearch)
final cnpjSearchProvider =
    AutoDisposeNotifierProvider<CnpjSearch, AsyncValue<CnpjModel?>>.internal(
      CnpjSearch.new,
      name: r'cnpjSearchProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cnpjSearchHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CnpjSearch = AutoDisposeNotifier<AsyncValue<CnpjModel?>>;
String _$companyNameSearchHash() => r'83073771c2902589fd1007566dc592cc80d096b2';

/// See also [CompanyNameSearch].
@ProviderFor(CompanyNameSearch)
final companyNameSearchProvider =
    AutoDisposeNotifierProvider<
      CompanyNameSearch,
      AsyncValue<List<NomeModel>>
    >.internal(
      CompanyNameSearch.new,
      name: r'companyNameSearchProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$companyNameSearchHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CompanyNameSearch = AutoDisposeNotifier<AsyncValue<List<NomeModel>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

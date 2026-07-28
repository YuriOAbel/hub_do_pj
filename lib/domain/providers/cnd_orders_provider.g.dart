// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cnd_orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cndCatalogHash() => r'6052505b272bb0adfe4a355668c4ca1747e96c73';

/// See also [CndCatalog].
@ProviderFor(CndCatalog)
final cndCatalogProvider =
    AutoDisposeAsyncNotifierProvider<CndCatalog, CndCatalogModel>.internal(
      CndCatalog.new,
      name: r'cndCatalogProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cndCatalogHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CndCatalog = AutoDisposeAsyncNotifier<CndCatalogModel>;
String _$cndOrdersHash() => r'e97f49abf89d82d73d498ec095947eb5ca5ba6df';

/// See also [CndOrders].
@ProviderFor(CndOrders)
final cndOrdersProvider =
    AutoDisposeAsyncNotifierProvider<CndOrders, List<CndOrderModel>>.internal(
      CndOrders.new,
      name: r'cndOrdersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cndOrdersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CndOrders = AutoDisposeAsyncNotifier<List<CndOrderModel>>;
String _$cndOrdersFilterHash() => r'bacad5c455bbc9595ba0975a3c670972b18d7f1e';

/// See also [CndOrdersFilter].
@ProviderFor(CndOrdersFilter)
final cndOrdersFilterProvider =
    AutoDisposeNotifierProvider<
      CndOrdersFilter,
      CndOrderDisplayStatus?
    >.internal(
      CndOrdersFilter.new,
      name: r'cndOrdersFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cndOrdersFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CndOrdersFilter = AutoDisposeNotifier<CndOrderDisplayStatus?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

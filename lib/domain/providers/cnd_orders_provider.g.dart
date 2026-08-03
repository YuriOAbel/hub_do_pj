// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cnd_orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeOrdersForCnpjHash() =>
    r'c56fe3f0352dc6b57a95ca142053d0147193bcba';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Latest active order per product kind for a CNPJ (digits).
///
/// Copied from [activeOrdersForCnpj].
@ProviderFor(activeOrdersForCnpj)
const activeOrdersForCnpjProvider = ActiveOrdersForCnpjFamily();

/// Latest active order per product kind for a CNPJ (digits).
///
/// Copied from [activeOrdersForCnpj].
class ActiveOrdersForCnpjFamily
    extends Family<AsyncValue<Map<String, CndOrderModel>>> {
  /// Latest active order per product kind for a CNPJ (digits).
  ///
  /// Copied from [activeOrdersForCnpj].
  const ActiveOrdersForCnpjFamily();

  /// Latest active order per product kind for a CNPJ (digits).
  ///
  /// Copied from [activeOrdersForCnpj].
  ActiveOrdersForCnpjProvider call(String cnpjDigits) {
    return ActiveOrdersForCnpjProvider(cnpjDigits);
  }

  @override
  ActiveOrdersForCnpjProvider getProviderOverride(
    covariant ActiveOrdersForCnpjProvider provider,
  ) {
    return call(provider.cnpjDigits);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'activeOrdersForCnpjProvider';
}

/// Latest active order per product kind for a CNPJ (digits).
///
/// Copied from [activeOrdersForCnpj].
class ActiveOrdersForCnpjProvider
    extends AutoDisposeFutureProvider<Map<String, CndOrderModel>> {
  /// Latest active order per product kind for a CNPJ (digits).
  ///
  /// Copied from [activeOrdersForCnpj].
  ActiveOrdersForCnpjProvider(String cnpjDigits)
    : this._internal(
        (ref) => activeOrdersForCnpj(ref as ActiveOrdersForCnpjRef, cnpjDigits),
        from: activeOrdersForCnpjProvider,
        name: r'activeOrdersForCnpjProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$activeOrdersForCnpjHash,
        dependencies: ActiveOrdersForCnpjFamily._dependencies,
        allTransitiveDependencies:
            ActiveOrdersForCnpjFamily._allTransitiveDependencies,
        cnpjDigits: cnpjDigits,
      );

  ActiveOrdersForCnpjProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.cnpjDigits,
  }) : super.internal();

  final String cnpjDigits;

  @override
  Override overrideWith(
    FutureOr<Map<String, CndOrderModel>> Function(
      ActiveOrdersForCnpjRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ActiveOrdersForCnpjProvider._internal(
        (ref) => create(ref as ActiveOrdersForCnpjRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        cnpjDigits: cnpjDigits,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, CndOrderModel>> createElement() {
    return _ActiveOrdersForCnpjProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveOrdersForCnpjProvider &&
        other.cnpjDigits == cnpjDigits;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, cnpjDigits.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ActiveOrdersForCnpjRef
    on AutoDisposeFutureProviderRef<Map<String, CndOrderModel>> {
  /// The parameter `cnpjDigits` of this provider.
  String get cnpjDigits;
}

class _ActiveOrdersForCnpjProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, CndOrderModel>>
    with ActiveOrdersForCnpjRef {
  _ActiveOrdersForCnpjProviderElement(super.provider);

  @override
  String get cnpjDigits => (origin as ActiveOrdersForCnpjProvider).cnpjDigits;
}

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

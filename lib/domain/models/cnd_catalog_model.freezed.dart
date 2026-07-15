// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cnd_catalog_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CndCertificateItem _$CndCertificateItemFromJson(Map<String, dynamic> json) {
  return _CndCertificateItem.fromJson(json);
}

/// @nodoc
mixin _$CndCertificateItem {
  String get id => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get subtitle => throw _privateConstructorUsedError;

  /// Serializes this CndCertificateItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CndCertificateItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CndCertificateItemCopyWith<CndCertificateItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CndCertificateItemCopyWith<$Res> {
  factory $CndCertificateItemCopyWith(
    CndCertificateItem value,
    $Res Function(CndCertificateItem) then,
  ) = _$CndCertificateItemCopyWithImpl<$Res, CndCertificateItem>;
  @useResult
  $Res call({String id, String slug, String name, String? subtitle});
}

/// @nodoc
class _$CndCertificateItemCopyWithImpl<$Res, $Val extends CndCertificateItem>
    implements $CndCertificateItemCopyWith<$Res> {
  _$CndCertificateItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CndCertificateItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? slug = null,
    Object? name = null,
    Object? subtitle = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            slug: null == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            subtitle: freezed == subtitle
                ? _value.subtitle
                : subtitle // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CndCertificateItemImplCopyWith<$Res>
    implements $CndCertificateItemCopyWith<$Res> {
  factory _$$CndCertificateItemImplCopyWith(
    _$CndCertificateItemImpl value,
    $Res Function(_$CndCertificateItemImpl) then,
  ) = __$$CndCertificateItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String slug, String name, String? subtitle});
}

/// @nodoc
class __$$CndCertificateItemImplCopyWithImpl<$Res>
    extends _$CndCertificateItemCopyWithImpl<$Res, _$CndCertificateItemImpl>
    implements _$$CndCertificateItemImplCopyWith<$Res> {
  __$$CndCertificateItemImplCopyWithImpl(
    _$CndCertificateItemImpl _value,
    $Res Function(_$CndCertificateItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CndCertificateItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? slug = null,
    Object? name = null,
    Object? subtitle = freezed,
  }) {
    return _then(
      _$CndCertificateItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        subtitle: freezed == subtitle
            ? _value.subtitle
            : subtitle // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CndCertificateItemImpl implements _CndCertificateItem {
  const _$CndCertificateItemImpl({
    required this.id,
    required this.slug,
    required this.name,
    this.subtitle,
  });

  factory _$CndCertificateItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$CndCertificateItemImplFromJson(json);

  @override
  final String id;
  @override
  final String slug;
  @override
  final String name;
  @override
  final String? subtitle;

  @override
  String toString() {
    return 'CndCertificateItem(id: $id, slug: $slug, name: $name, subtitle: $subtitle)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CndCertificateItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, slug, name, subtitle);

  /// Create a copy of CndCertificateItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CndCertificateItemImplCopyWith<_$CndCertificateItemImpl> get copyWith =>
      __$$CndCertificateItemImplCopyWithImpl<_$CndCertificateItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CndCertificateItemImplToJson(this);
  }
}

abstract class _CndCertificateItem implements CndCertificateItem {
  const factory _CndCertificateItem({
    required final String id,
    required final String slug,
    required final String name,
    final String? subtitle,
  }) = _$CndCertificateItemImpl;

  factory _CndCertificateItem.fromJson(Map<String, dynamic> json) =
      _$CndCertificateItemImpl.fromJson;

  @override
  String get id;
  @override
  String get slug;
  @override
  String get name;
  @override
  String? get subtitle;

  /// Create a copy of CndCertificateItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CndCertificateItemImplCopyWith<_$CndCertificateItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CndCatalogProduct _$CndCatalogProductFromJson(Map<String, dynamic> json) {
  return _CndCatalogProduct.fromJson(json);
}

/// @nodoc
mixin _$CndCatalogProduct {
  String get id => throw _privateConstructorUsedError;
  String get kind => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get shortLabel => throw _privateConstructorUsedError;
  int get priceCents => throw _privateConstructorUsedError;

  /// Serializes this CndCatalogProduct to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CndCatalogProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CndCatalogProductCopyWith<CndCatalogProduct> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CndCatalogProductCopyWith<$Res> {
  factory $CndCatalogProductCopyWith(
    CndCatalogProduct value,
    $Res Function(CndCatalogProduct) then,
  ) = _$CndCatalogProductCopyWithImpl<$Res, CndCatalogProduct>;
  @useResult
  $Res call({
    String id,
    String kind,
    String name,
    String shortLabel,
    int priceCents,
  });
}

/// @nodoc
class _$CndCatalogProductCopyWithImpl<$Res, $Val extends CndCatalogProduct>
    implements $CndCatalogProductCopyWith<$Res> {
  _$CndCatalogProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CndCatalogProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? kind = null,
    Object? name = null,
    Object? shortLabel = null,
    Object? priceCents = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            kind: null == kind
                ? _value.kind
                : kind // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            shortLabel: null == shortLabel
                ? _value.shortLabel
                : shortLabel // ignore: cast_nullable_to_non_nullable
                      as String,
            priceCents: null == priceCents
                ? _value.priceCents
                : priceCents // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CndCatalogProductImplCopyWith<$Res>
    implements $CndCatalogProductCopyWith<$Res> {
  factory _$$CndCatalogProductImplCopyWith(
    _$CndCatalogProductImpl value,
    $Res Function(_$CndCatalogProductImpl) then,
  ) = __$$CndCatalogProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String kind,
    String name,
    String shortLabel,
    int priceCents,
  });
}

/// @nodoc
class __$$CndCatalogProductImplCopyWithImpl<$Res>
    extends _$CndCatalogProductCopyWithImpl<$Res, _$CndCatalogProductImpl>
    implements _$$CndCatalogProductImplCopyWith<$Res> {
  __$$CndCatalogProductImplCopyWithImpl(
    _$CndCatalogProductImpl _value,
    $Res Function(_$CndCatalogProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CndCatalogProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? kind = null,
    Object? name = null,
    Object? shortLabel = null,
    Object? priceCents = null,
  }) {
    return _then(
      _$CndCatalogProductImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        kind: null == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        shortLabel: null == shortLabel
            ? _value.shortLabel
            : shortLabel // ignore: cast_nullable_to_non_nullable
                  as String,
        priceCents: null == priceCents
            ? _value.priceCents
            : priceCents // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CndCatalogProductImpl implements _CndCatalogProduct {
  const _$CndCatalogProductImpl({
    required this.id,
    required this.kind,
    required this.name,
    required this.shortLabel,
    required this.priceCents,
  });

  factory _$CndCatalogProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$CndCatalogProductImplFromJson(json);

  @override
  final String id;
  @override
  final String kind;
  @override
  final String name;
  @override
  final String shortLabel;
  @override
  final int priceCents;

  @override
  String toString() {
    return 'CndCatalogProduct(id: $id, kind: $kind, name: $name, shortLabel: $shortLabel, priceCents: $priceCents)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CndCatalogProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.shortLabel, shortLabel) ||
                other.shortLabel == shortLabel) &&
            (identical(other.priceCents, priceCents) ||
                other.priceCents == priceCents));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, kind, name, shortLabel, priceCents);

  /// Create a copy of CndCatalogProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CndCatalogProductImplCopyWith<_$CndCatalogProductImpl> get copyWith =>
      __$$CndCatalogProductImplCopyWithImpl<_$CndCatalogProductImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CndCatalogProductImplToJson(this);
  }
}

abstract class _CndCatalogProduct implements CndCatalogProduct {
  const factory _CndCatalogProduct({
    required final String id,
    required final String kind,
    required final String name,
    required final String shortLabel,
    required final int priceCents,
  }) = _$CndCatalogProductImpl;

  factory _CndCatalogProduct.fromJson(Map<String, dynamic> json) =
      _$CndCatalogProductImpl.fromJson;

  @override
  String get id;
  @override
  String get kind;
  @override
  String get name;
  @override
  String get shortLabel;
  @override
  int get priceCents;

  /// Create a copy of CndCatalogProduct
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CndCatalogProductImplCopyWith<_$CndCatalogProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CndCatalogModel _$CndCatalogModelFromJson(Map<String, dynamic> json) {
  return _CndCatalogModel.fromJson(json);
}

/// @nodoc
mixin _$CndCatalogModel {
  String get packageId => throw _privateConstructorUsedError;
  String get packageName => throw _privateConstructorUsedError;
  String get whatsappNumber => throw _privateConstructorUsedError;
  String get defaultKind => throw _privateConstructorUsedError;
  List<CndCatalogProduct> get products => throw _privateConstructorUsedError;
  List<CndCertificateItem> get certificates =>
      throw _privateConstructorUsedError;

  /// Serializes this CndCatalogModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CndCatalogModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CndCatalogModelCopyWith<CndCatalogModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CndCatalogModelCopyWith<$Res> {
  factory $CndCatalogModelCopyWith(
    CndCatalogModel value,
    $Res Function(CndCatalogModel) then,
  ) = _$CndCatalogModelCopyWithImpl<$Res, CndCatalogModel>;
  @useResult
  $Res call({
    String packageId,
    String packageName,
    String whatsappNumber,
    String defaultKind,
    List<CndCatalogProduct> products,
    List<CndCertificateItem> certificates,
  });
}

/// @nodoc
class _$CndCatalogModelCopyWithImpl<$Res, $Val extends CndCatalogModel>
    implements $CndCatalogModelCopyWith<$Res> {
  _$CndCatalogModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CndCatalogModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? packageId = null,
    Object? packageName = null,
    Object? whatsappNumber = null,
    Object? defaultKind = null,
    Object? products = null,
    Object? certificates = null,
  }) {
    return _then(
      _value.copyWith(
            packageId: null == packageId
                ? _value.packageId
                : packageId // ignore: cast_nullable_to_non_nullable
                      as String,
            packageName: null == packageName
                ? _value.packageName
                : packageName // ignore: cast_nullable_to_non_nullable
                      as String,
            whatsappNumber: null == whatsappNumber
                ? _value.whatsappNumber
                : whatsappNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultKind: null == defaultKind
                ? _value.defaultKind
                : defaultKind // ignore: cast_nullable_to_non_nullable
                      as String,
            products: null == products
                ? _value.products
                : products // ignore: cast_nullable_to_non_nullable
                      as List<CndCatalogProduct>,
            certificates: null == certificates
                ? _value.certificates
                : certificates // ignore: cast_nullable_to_non_nullable
                      as List<CndCertificateItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CndCatalogModelImplCopyWith<$Res>
    implements $CndCatalogModelCopyWith<$Res> {
  factory _$$CndCatalogModelImplCopyWith(
    _$CndCatalogModelImpl value,
    $Res Function(_$CndCatalogModelImpl) then,
  ) = __$$CndCatalogModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String packageId,
    String packageName,
    String whatsappNumber,
    String defaultKind,
    List<CndCatalogProduct> products,
    List<CndCertificateItem> certificates,
  });
}

/// @nodoc
class __$$CndCatalogModelImplCopyWithImpl<$Res>
    extends _$CndCatalogModelCopyWithImpl<$Res, _$CndCatalogModelImpl>
    implements _$$CndCatalogModelImplCopyWith<$Res> {
  __$$CndCatalogModelImplCopyWithImpl(
    _$CndCatalogModelImpl _value,
    $Res Function(_$CndCatalogModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CndCatalogModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? packageId = null,
    Object? packageName = null,
    Object? whatsappNumber = null,
    Object? defaultKind = null,
    Object? products = null,
    Object? certificates = null,
  }) {
    return _then(
      _$CndCatalogModelImpl(
        packageId: null == packageId
            ? _value.packageId
            : packageId // ignore: cast_nullable_to_non_nullable
                  as String,
        packageName: null == packageName
            ? _value.packageName
            : packageName // ignore: cast_nullable_to_non_nullable
                  as String,
        whatsappNumber: null == whatsappNumber
            ? _value.whatsappNumber
            : whatsappNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultKind: null == defaultKind
            ? _value.defaultKind
            : defaultKind // ignore: cast_nullable_to_non_nullable
                  as String,
        products: null == products
            ? _value._products
            : products // ignore: cast_nullable_to_non_nullable
                  as List<CndCatalogProduct>,
        certificates: null == certificates
            ? _value._certificates
            : certificates // ignore: cast_nullable_to_non_nullable
                  as List<CndCertificateItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CndCatalogModelImpl extends _CndCatalogModel {
  const _$CndCatalogModelImpl({
    required this.packageId,
    required this.packageName,
    required this.whatsappNumber,
    this.defaultKind = 'cnd',
    final List<CndCatalogProduct> products = const [],
    final List<CndCertificateItem> certificates = const [],
  }) : _products = products,
       _certificates = certificates,
       super._();

  factory _$CndCatalogModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CndCatalogModelImplFromJson(json);

  @override
  final String packageId;
  @override
  final String packageName;
  @override
  final String whatsappNumber;
  @override
  @JsonKey()
  final String defaultKind;
  final List<CndCatalogProduct> _products;
  @override
  @JsonKey()
  List<CndCatalogProduct> get products {
    if (_products is EqualUnmodifiableListView) return _products;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_products);
  }

  final List<CndCertificateItem> _certificates;
  @override
  @JsonKey()
  List<CndCertificateItem> get certificates {
    if (_certificates is EqualUnmodifiableListView) return _certificates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_certificates);
  }

  @override
  String toString() {
    return 'CndCatalogModel(packageId: $packageId, packageName: $packageName, whatsappNumber: $whatsappNumber, defaultKind: $defaultKind, products: $products, certificates: $certificates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CndCatalogModelImpl &&
            (identical(other.packageId, packageId) ||
                other.packageId == packageId) &&
            (identical(other.packageName, packageName) ||
                other.packageName == packageName) &&
            (identical(other.whatsappNumber, whatsappNumber) ||
                other.whatsappNumber == whatsappNumber) &&
            (identical(other.defaultKind, defaultKind) ||
                other.defaultKind == defaultKind) &&
            const DeepCollectionEquality().equals(other._products, _products) &&
            const DeepCollectionEquality().equals(
              other._certificates,
              _certificates,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    packageId,
    packageName,
    whatsappNumber,
    defaultKind,
    const DeepCollectionEquality().hash(_products),
    const DeepCollectionEquality().hash(_certificates),
  );

  /// Create a copy of CndCatalogModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CndCatalogModelImplCopyWith<_$CndCatalogModelImpl> get copyWith =>
      __$$CndCatalogModelImplCopyWithImpl<_$CndCatalogModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CndCatalogModelImplToJson(this);
  }
}

abstract class _CndCatalogModel extends CndCatalogModel {
  const factory _CndCatalogModel({
    required final String packageId,
    required final String packageName,
    required final String whatsappNumber,
    final String defaultKind,
    final List<CndCatalogProduct> products,
    final List<CndCertificateItem> certificates,
  }) = _$CndCatalogModelImpl;
  const _CndCatalogModel._() : super._();

  factory _CndCatalogModel.fromJson(Map<String, dynamic> json) =
      _$CndCatalogModelImpl.fromJson;

  @override
  String get packageId;
  @override
  String get packageName;
  @override
  String get whatsappNumber;
  @override
  String get defaultKind;
  @override
  List<CndCatalogProduct> get products;
  @override
  List<CndCertificateItem> get certificates;

  /// Create a copy of CndCatalogModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CndCatalogModelImplCopyWith<_$CndCatalogModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

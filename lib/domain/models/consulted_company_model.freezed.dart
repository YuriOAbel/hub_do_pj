// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consulted_company_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ConsultedCompanyModel _$ConsultedCompanyModelFromJson(
  Map<String, dynamic> json,
) {
  return _ConsultedCompanyModel.fromJson(json);
}

/// @nodoc
mixin _$ConsultedCompanyModel {
  String get id => throw _privateConstructorUsedError;
  String get profileId => throw _privateConstructorUsedError;
  String get cnpjDigits => throw _privateConstructorUsedError;
  String get companyName => throw _privateConstructorUsedError;
  String? get situacao => throw _privateConstructorUsedError;
  String? get fantasia => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;
  String get lastConsultedAt => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
  List<CndOrderModel> get orders => throw _privateConstructorUsedError;

  /// Serializes this ConsultedCompanyModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConsultedCompanyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConsultedCompanyModelCopyWith<ConsultedCompanyModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConsultedCompanyModelCopyWith<$Res> {
  factory $ConsultedCompanyModelCopyWith(
    ConsultedCompanyModel value,
    $Res Function(ConsultedCompanyModel) then,
  ) = _$ConsultedCompanyModelCopyWithImpl<$Res, ConsultedCompanyModel>;
  @useResult
  $Res call({
    String id,
    String profileId,
    String cnpjDigits,
    String companyName,
    String? situacao,
    String? fantasia,
    Map<String, dynamic> metadata,
    String lastConsultedAt,
    String createdAt,
    String? updatedAt,
    List<CndOrderModel> orders,
  });
}

/// @nodoc
class _$ConsultedCompanyModelCopyWithImpl<
  $Res,
  $Val extends ConsultedCompanyModel
>
    implements $ConsultedCompanyModelCopyWith<$Res> {
  _$ConsultedCompanyModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConsultedCompanyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? profileId = null,
    Object? cnpjDigits = null,
    Object? companyName = null,
    Object? situacao = freezed,
    Object? fantasia = freezed,
    Object? metadata = null,
    Object? lastConsultedAt = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? orders = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            profileId: null == profileId
                ? _value.profileId
                : profileId // ignore: cast_nullable_to_non_nullable
                      as String,
            cnpjDigits: null == cnpjDigits
                ? _value.cnpjDigits
                : cnpjDigits // ignore: cast_nullable_to_non_nullable
                      as String,
            companyName: null == companyName
                ? _value.companyName
                : companyName // ignore: cast_nullable_to_non_nullable
                      as String,
            situacao: freezed == situacao
                ? _value.situacao
                : situacao // ignore: cast_nullable_to_non_nullable
                      as String?,
            fantasia: freezed == fantasia
                ? _value.fantasia
                : fantasia // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: null == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            lastConsultedAt: null == lastConsultedAt
                ? _value.lastConsultedAt
                : lastConsultedAt // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            orders: null == orders
                ? _value.orders
                : orders // ignore: cast_nullable_to_non_nullable
                      as List<CndOrderModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConsultedCompanyModelImplCopyWith<$Res>
    implements $ConsultedCompanyModelCopyWith<$Res> {
  factory _$$ConsultedCompanyModelImplCopyWith(
    _$ConsultedCompanyModelImpl value,
    $Res Function(_$ConsultedCompanyModelImpl) then,
  ) = __$$ConsultedCompanyModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String profileId,
    String cnpjDigits,
    String companyName,
    String? situacao,
    String? fantasia,
    Map<String, dynamic> metadata,
    String lastConsultedAt,
    String createdAt,
    String? updatedAt,
    List<CndOrderModel> orders,
  });
}

/// @nodoc
class __$$ConsultedCompanyModelImplCopyWithImpl<$Res>
    extends
        _$ConsultedCompanyModelCopyWithImpl<$Res, _$ConsultedCompanyModelImpl>
    implements _$$ConsultedCompanyModelImplCopyWith<$Res> {
  __$$ConsultedCompanyModelImplCopyWithImpl(
    _$ConsultedCompanyModelImpl _value,
    $Res Function(_$ConsultedCompanyModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConsultedCompanyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? profileId = null,
    Object? cnpjDigits = null,
    Object? companyName = null,
    Object? situacao = freezed,
    Object? fantasia = freezed,
    Object? metadata = null,
    Object? lastConsultedAt = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? orders = null,
  }) {
    return _then(
      _$ConsultedCompanyModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        profileId: null == profileId
            ? _value.profileId
            : profileId // ignore: cast_nullable_to_non_nullable
                  as String,
        cnpjDigits: null == cnpjDigits
            ? _value.cnpjDigits
            : cnpjDigits // ignore: cast_nullable_to_non_nullable
                  as String,
        companyName: null == companyName
            ? _value.companyName
            : companyName // ignore: cast_nullable_to_non_nullable
                  as String,
        situacao: freezed == situacao
            ? _value.situacao
            : situacao // ignore: cast_nullable_to_non_nullable
                  as String?,
        fantasia: freezed == fantasia
            ? _value.fantasia
            : fantasia // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: null == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        lastConsultedAt: null == lastConsultedAt
            ? _value.lastConsultedAt
            : lastConsultedAt // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        orders: null == orders
            ? _value._orders
            : orders // ignore: cast_nullable_to_non_nullable
                  as List<CndOrderModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConsultedCompanyModelImpl extends _ConsultedCompanyModel {
  const _$ConsultedCompanyModelImpl({
    required this.id,
    required this.profileId,
    required this.cnpjDigits,
    required this.companyName,
    this.situacao,
    this.fantasia,
    final Map<String, dynamic> metadata = const {},
    required this.lastConsultedAt,
    required this.createdAt,
    this.updatedAt,
    final List<CndOrderModel> orders = const [],
  }) : _metadata = metadata,
       _orders = orders,
       super._();

  factory _$ConsultedCompanyModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConsultedCompanyModelImplFromJson(json);

  @override
  final String id;
  @override
  final String profileId;
  @override
  final String cnpjDigits;
  @override
  final String companyName;
  @override
  final String? situacao;
  @override
  final String? fantasia;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  final String lastConsultedAt;
  @override
  final String createdAt;
  @override
  final String? updatedAt;
  final List<CndOrderModel> _orders;
  @override
  @JsonKey()
  List<CndOrderModel> get orders {
    if (_orders is EqualUnmodifiableListView) return _orders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_orders);
  }

  @override
  String toString() {
    return 'ConsultedCompanyModel(id: $id, profileId: $profileId, cnpjDigits: $cnpjDigits, companyName: $companyName, situacao: $situacao, fantasia: $fantasia, metadata: $metadata, lastConsultedAt: $lastConsultedAt, createdAt: $createdAt, updatedAt: $updatedAt, orders: $orders)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConsultedCompanyModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.profileId, profileId) ||
                other.profileId == profileId) &&
            (identical(other.cnpjDigits, cnpjDigits) ||
                other.cnpjDigits == cnpjDigits) &&
            (identical(other.companyName, companyName) ||
                other.companyName == companyName) &&
            (identical(other.situacao, situacao) ||
                other.situacao == situacao) &&
            (identical(other.fantasia, fantasia) ||
                other.fantasia == fantasia) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.lastConsultedAt, lastConsultedAt) ||
                other.lastConsultedAt == lastConsultedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._orders, _orders));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    profileId,
    cnpjDigits,
    companyName,
    situacao,
    fantasia,
    const DeepCollectionEquality().hash(_metadata),
    lastConsultedAt,
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_orders),
  );

  /// Create a copy of ConsultedCompanyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConsultedCompanyModelImplCopyWith<_$ConsultedCompanyModelImpl>
  get copyWith =>
      __$$ConsultedCompanyModelImplCopyWithImpl<_$ConsultedCompanyModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConsultedCompanyModelImplToJson(this);
  }
}

abstract class _ConsultedCompanyModel extends ConsultedCompanyModel {
  const factory _ConsultedCompanyModel({
    required final String id,
    required final String profileId,
    required final String cnpjDigits,
    required final String companyName,
    final String? situacao,
    final String? fantasia,
    final Map<String, dynamic> metadata,
    required final String lastConsultedAt,
    required final String createdAt,
    final String? updatedAt,
    final List<CndOrderModel> orders,
  }) = _$ConsultedCompanyModelImpl;
  const _ConsultedCompanyModel._() : super._();

  factory _ConsultedCompanyModel.fromJson(Map<String, dynamic> json) =
      _$ConsultedCompanyModelImpl.fromJson;

  @override
  String get id;
  @override
  String get profileId;
  @override
  String get cnpjDigits;
  @override
  String get companyName;
  @override
  String? get situacao;
  @override
  String? get fantasia;
  @override
  Map<String, dynamic> get metadata;
  @override
  String get lastConsultedAt;
  @override
  String get createdAt;
  @override
  String? get updatedAt;
  @override
  List<CndOrderModel> get orders;

  /// Create a copy of ConsultedCompanyModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConsultedCompanyModelImplCopyWith<_$ConsultedCompanyModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cnd_order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CndOrderModel _$CndOrderModelFromJson(Map<String, dynamic> json) {
  return _CndOrderModel.fromJson(json);
}

/// @nodoc
mixin _$CndOrderModel {
  String get id => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String get guestEmail => throw _privateConstructorUsedError;
  String? get guestPhone => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  List<String>? get selectedProductIds => throw _privateConstructorUsedError;
  int? get totalCents => throw _privateConstructorUsedError;
  String get cnpj => throw _privateConstructorUsedError;
  String get companyName => throw _privateConstructorUsedError;
  CndAddressModel? get address => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get paymentStatus => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CndOrderModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CndOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CndOrderModelCopyWith<CndOrderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CndOrderModelCopyWith<$Res> {
  factory $CndOrderModelCopyWith(
    CndOrderModel value,
    $Res Function(CndOrderModel) then,
  ) = _$CndOrderModelCopyWithImpl<$Res, CndOrderModel>;
  @useResult
  $Res call({
    String id,
    String? userId,
    String guestEmail,
    String? guestPhone,
    String productId,
    List<String>? selectedProductIds,
    int? totalCents,
    String cnpj,
    String companyName,
    CndAddressModel? address,
    String status,
    String paymentStatus,
    String createdAt,
    String? updatedAt,
  });

  $CndAddressModelCopyWith<$Res>? get address;
}

/// @nodoc
class _$CndOrderModelCopyWithImpl<$Res, $Val extends CndOrderModel>
    implements $CndOrderModelCopyWith<$Res> {
  _$CndOrderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CndOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? guestEmail = null,
    Object? guestPhone = freezed,
    Object? productId = null,
    Object? selectedProductIds = freezed,
    Object? totalCents = freezed,
    Object? cnpj = null,
    Object? companyName = null,
    Object? address = freezed,
    Object? status = null,
    Object? paymentStatus = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            guestEmail: null == guestEmail
                ? _value.guestEmail
                : guestEmail // ignore: cast_nullable_to_non_nullable
                      as String,
            guestPhone: freezed == guestPhone
                ? _value.guestPhone
                : guestPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            selectedProductIds: freezed == selectedProductIds
                ? _value.selectedProductIds
                : selectedProductIds // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            totalCents: freezed == totalCents
                ? _value.totalCents
                : totalCents // ignore: cast_nullable_to_non_nullable
                      as int?,
            cnpj: null == cnpj
                ? _value.cnpj
                : cnpj // ignore: cast_nullable_to_non_nullable
                      as String,
            companyName: null == companyName
                ? _value.companyName
                : companyName // ignore: cast_nullable_to_non_nullable
                      as String,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as CndAddressModel?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            paymentStatus: null == paymentStatus
                ? _value.paymentStatus
                : paymentStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of CndOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CndAddressModelCopyWith<$Res>? get address {
    if (_value.address == null) {
      return null;
    }

    return $CndAddressModelCopyWith<$Res>(_value.address!, (value) {
      return _then(_value.copyWith(address: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CndOrderModelImplCopyWith<$Res>
    implements $CndOrderModelCopyWith<$Res> {
  factory _$$CndOrderModelImplCopyWith(
    _$CndOrderModelImpl value,
    $Res Function(_$CndOrderModelImpl) then,
  ) = __$$CndOrderModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? userId,
    String guestEmail,
    String? guestPhone,
    String productId,
    List<String>? selectedProductIds,
    int? totalCents,
    String cnpj,
    String companyName,
    CndAddressModel? address,
    String status,
    String paymentStatus,
    String createdAt,
    String? updatedAt,
  });

  @override
  $CndAddressModelCopyWith<$Res>? get address;
}

/// @nodoc
class __$$CndOrderModelImplCopyWithImpl<$Res>
    extends _$CndOrderModelCopyWithImpl<$Res, _$CndOrderModelImpl>
    implements _$$CndOrderModelImplCopyWith<$Res> {
  __$$CndOrderModelImplCopyWithImpl(
    _$CndOrderModelImpl _value,
    $Res Function(_$CndOrderModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CndOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? guestEmail = null,
    Object? guestPhone = freezed,
    Object? productId = null,
    Object? selectedProductIds = freezed,
    Object? totalCents = freezed,
    Object? cnpj = null,
    Object? companyName = null,
    Object? address = freezed,
    Object? status = null,
    Object? paymentStatus = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$CndOrderModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        guestEmail: null == guestEmail
            ? _value.guestEmail
            : guestEmail // ignore: cast_nullable_to_non_nullable
                  as String,
        guestPhone: freezed == guestPhone
            ? _value.guestPhone
            : guestPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        selectedProductIds: freezed == selectedProductIds
            ? _value._selectedProductIds
            : selectedProductIds // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        totalCents: freezed == totalCents
            ? _value.totalCents
            : totalCents // ignore: cast_nullable_to_non_nullable
                  as int?,
        cnpj: null == cnpj
            ? _value.cnpj
            : cnpj // ignore: cast_nullable_to_non_nullable
                  as String,
        companyName: null == companyName
            ? _value.companyName
            : companyName // ignore: cast_nullable_to_non_nullable
                  as String,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as CndAddressModel?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentStatus: null == paymentStatus
            ? _value.paymentStatus
            : paymentStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CndOrderModelImpl extends _CndOrderModel {
  const _$CndOrderModelImpl({
    required this.id,
    this.userId,
    required this.guestEmail,
    this.guestPhone,
    required this.productId,
    final List<String>? selectedProductIds,
    this.totalCents,
    required this.cnpj,
    required this.companyName,
    this.address,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    this.updatedAt,
  }) : _selectedProductIds = selectedProductIds,
       super._();

  factory _$CndOrderModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CndOrderModelImplFromJson(json);

  @override
  final String id;
  @override
  final String? userId;
  @override
  final String guestEmail;
  @override
  final String? guestPhone;
  @override
  final String productId;
  final List<String>? _selectedProductIds;
  @override
  List<String>? get selectedProductIds {
    final value = _selectedProductIds;
    if (value == null) return null;
    if (_selectedProductIds is EqualUnmodifiableListView)
      return _selectedProductIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? totalCents;
  @override
  final String cnpj;
  @override
  final String companyName;
  @override
  final CndAddressModel? address;
  @override
  final String status;
  @override
  final String paymentStatus;
  @override
  final String createdAt;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'CndOrderModel(id: $id, userId: $userId, guestEmail: $guestEmail, guestPhone: $guestPhone, productId: $productId, selectedProductIds: $selectedProductIds, totalCents: $totalCents, cnpj: $cnpj, companyName: $companyName, address: $address, status: $status, paymentStatus: $paymentStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CndOrderModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.guestEmail, guestEmail) ||
                other.guestEmail == guestEmail) &&
            (identical(other.guestPhone, guestPhone) ||
                other.guestPhone == guestPhone) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            const DeepCollectionEquality().equals(
              other._selectedProductIds,
              _selectedProductIds,
            ) &&
            (identical(other.totalCents, totalCents) ||
                other.totalCents == totalCents) &&
            (identical(other.cnpj, cnpj) || other.cnpj == cnpj) &&
            (identical(other.companyName, companyName) ||
                other.companyName == companyName) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    guestEmail,
    guestPhone,
    productId,
    const DeepCollectionEquality().hash(_selectedProductIds),
    totalCents,
    cnpj,
    companyName,
    address,
    status,
    paymentStatus,
    createdAt,
    updatedAt,
  );

  /// Create a copy of CndOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CndOrderModelImplCopyWith<_$CndOrderModelImpl> get copyWith =>
      __$$CndOrderModelImplCopyWithImpl<_$CndOrderModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CndOrderModelImplToJson(this);
  }
}

abstract class _CndOrderModel extends CndOrderModel {
  const factory _CndOrderModel({
    required final String id,
    final String? userId,
    required final String guestEmail,
    final String? guestPhone,
    required final String productId,
    final List<String>? selectedProductIds,
    final int? totalCents,
    required final String cnpj,
    required final String companyName,
    final CndAddressModel? address,
    required final String status,
    required final String paymentStatus,
    required final String createdAt,
    final String? updatedAt,
  }) = _$CndOrderModelImpl;
  const _CndOrderModel._() : super._();

  factory _CndOrderModel.fromJson(Map<String, dynamic> json) =
      _$CndOrderModelImpl.fromJson;

  @override
  String get id;
  @override
  String? get userId;
  @override
  String get guestEmail;
  @override
  String? get guestPhone;
  @override
  String get productId;
  @override
  List<String>? get selectedProductIds;
  @override
  int? get totalCents;
  @override
  String get cnpj;
  @override
  String get companyName;
  @override
  CndAddressModel? get address;
  @override
  String get status;
  @override
  String get paymentStatus;
  @override
  String get createdAt;
  @override
  String? get updatedAt;

  /// Create a copy of CndOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CndOrderModelImplCopyWith<_$CndOrderModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'atividade_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AtividadeModel _$AtividadeModelFromJson(Map<String, dynamic> json) {
  return _AtividadeModel.fromJson(json);
}

/// @nodoc
mixin _$AtividadeModel {
  String? get code => throw _privateConstructorUsedError;
  String? get text => throw _privateConstructorUsedError;

  /// Serializes this AtividadeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AtividadeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AtividadeModelCopyWith<AtividadeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AtividadeModelCopyWith<$Res> {
  factory $AtividadeModelCopyWith(
    AtividadeModel value,
    $Res Function(AtividadeModel) then,
  ) = _$AtividadeModelCopyWithImpl<$Res, AtividadeModel>;
  @useResult
  $Res call({String? code, String? text});
}

/// @nodoc
class _$AtividadeModelCopyWithImpl<$Res, $Val extends AtividadeModel>
    implements $AtividadeModelCopyWith<$Res> {
  _$AtividadeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AtividadeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? code = freezed, Object? text = freezed}) {
    return _then(
      _value.copyWith(
            code: freezed == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String?,
            text: freezed == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AtividadeModelImplCopyWith<$Res>
    implements $AtividadeModelCopyWith<$Res> {
  factory _$$AtividadeModelImplCopyWith(
    _$AtividadeModelImpl value,
    $Res Function(_$AtividadeModelImpl) then,
  ) = __$$AtividadeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? code, String? text});
}

/// @nodoc
class __$$AtividadeModelImplCopyWithImpl<$Res>
    extends _$AtividadeModelCopyWithImpl<$Res, _$AtividadeModelImpl>
    implements _$$AtividadeModelImplCopyWith<$Res> {
  __$$AtividadeModelImplCopyWithImpl(
    _$AtividadeModelImpl _value,
    $Res Function(_$AtividadeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AtividadeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? code = freezed, Object? text = freezed}) {
    return _then(
      _$AtividadeModelImpl(
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
        text: freezed == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AtividadeModelImpl implements _AtividadeModel {
  const _$AtividadeModelImpl({this.code, this.text});

  factory _$AtividadeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AtividadeModelImplFromJson(json);

  @override
  final String? code;
  @override
  final String? text;

  @override
  String toString() {
    return 'AtividadeModel(code: $code, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AtividadeModelImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code, text);

  /// Create a copy of AtividadeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AtividadeModelImplCopyWith<_$AtividadeModelImpl> get copyWith =>
      __$$AtividadeModelImplCopyWithImpl<_$AtividadeModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AtividadeModelImplToJson(this);
  }
}

abstract class _AtividadeModel implements AtividadeModel {
  const factory _AtividadeModel({final String? code, final String? text}) =
      _$AtividadeModelImpl;

  factory _AtividadeModel.fromJson(Map<String, dynamic> json) =
      _$AtividadeModelImpl.fromJson;

  @override
  String? get code;
  @override
  String? get text;

  /// Create a copy of AtividadeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AtividadeModelImplCopyWith<_$AtividadeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QsaModel _$QsaModelFromJson(Map<String, dynamic> json) {
  return _QsaModel.fromJson(json);
}

/// @nodoc
mixin _$QsaModel {
  String? get nome => throw _privateConstructorUsedError;
  String? get qual => throw _privateConstructorUsedError;

  /// Serializes this QsaModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QsaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QsaModelCopyWith<QsaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QsaModelCopyWith<$Res> {
  factory $QsaModelCopyWith(QsaModel value, $Res Function(QsaModel) then) =
      _$QsaModelCopyWithImpl<$Res, QsaModel>;
  @useResult
  $Res call({String? nome, String? qual});
}

/// @nodoc
class _$QsaModelCopyWithImpl<$Res, $Val extends QsaModel>
    implements $QsaModelCopyWith<$Res> {
  _$QsaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QsaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? nome = freezed, Object? qual = freezed}) {
    return _then(
      _value.copyWith(
            nome: freezed == nome
                ? _value.nome
                : nome // ignore: cast_nullable_to_non_nullable
                      as String?,
            qual: freezed == qual
                ? _value.qual
                : qual // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QsaModelImplCopyWith<$Res>
    implements $QsaModelCopyWith<$Res> {
  factory _$$QsaModelImplCopyWith(
    _$QsaModelImpl value,
    $Res Function(_$QsaModelImpl) then,
  ) = __$$QsaModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? nome, String? qual});
}

/// @nodoc
class __$$QsaModelImplCopyWithImpl<$Res>
    extends _$QsaModelCopyWithImpl<$Res, _$QsaModelImpl>
    implements _$$QsaModelImplCopyWith<$Res> {
  __$$QsaModelImplCopyWithImpl(
    _$QsaModelImpl _value,
    $Res Function(_$QsaModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QsaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? nome = freezed, Object? qual = freezed}) {
    return _then(
      _$QsaModelImpl(
        nome: freezed == nome
            ? _value.nome
            : nome // ignore: cast_nullable_to_non_nullable
                  as String?,
        qual: freezed == qual
            ? _value.qual
            : qual // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QsaModelImpl implements _QsaModel {
  const _$QsaModelImpl({this.nome, this.qual});

  factory _$QsaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$QsaModelImplFromJson(json);

  @override
  final String? nome;
  @override
  final String? qual;

  @override
  String toString() {
    return 'QsaModel(nome: $nome, qual: $qual)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QsaModelImpl &&
            (identical(other.nome, nome) || other.nome == nome) &&
            (identical(other.qual, qual) || other.qual == qual));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, nome, qual);

  /// Create a copy of QsaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QsaModelImplCopyWith<_$QsaModelImpl> get copyWith =>
      __$$QsaModelImplCopyWithImpl<_$QsaModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QsaModelImplToJson(this);
  }
}

abstract class _QsaModel implements QsaModel {
  const factory _QsaModel({final String? nome, final String? qual}) =
      _$QsaModelImpl;

  factory _QsaModel.fromJson(Map<String, dynamic> json) =
      _$QsaModelImpl.fromJson;

  @override
  String? get nome;
  @override
  String? get qual;

  /// Create a copy of QsaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QsaModelImplCopyWith<_$QsaModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BillingModel _$BillingModelFromJson(Map<String, dynamic> json) {
  return _BillingModel.fromJson(json);
}

/// @nodoc
mixin _$BillingModel {
  bool? get free => throw _privateConstructorUsedError;
  bool? get database => throw _privateConstructorUsedError;

  /// Serializes this BillingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BillingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BillingModelCopyWith<BillingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BillingModelCopyWith<$Res> {
  factory $BillingModelCopyWith(
    BillingModel value,
    $Res Function(BillingModel) then,
  ) = _$BillingModelCopyWithImpl<$Res, BillingModel>;
  @useResult
  $Res call({bool? free, bool? database});
}

/// @nodoc
class _$BillingModelCopyWithImpl<$Res, $Val extends BillingModel>
    implements $BillingModelCopyWith<$Res> {
  _$BillingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BillingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? free = freezed, Object? database = freezed}) {
    return _then(
      _value.copyWith(
            free: freezed == free
                ? _value.free
                : free // ignore: cast_nullable_to_non_nullable
                      as bool?,
            database: freezed == database
                ? _value.database
                : database // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BillingModelImplCopyWith<$Res>
    implements $BillingModelCopyWith<$Res> {
  factory _$$BillingModelImplCopyWith(
    _$BillingModelImpl value,
    $Res Function(_$BillingModelImpl) then,
  ) = __$$BillingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? free, bool? database});
}

/// @nodoc
class __$$BillingModelImplCopyWithImpl<$Res>
    extends _$BillingModelCopyWithImpl<$Res, _$BillingModelImpl>
    implements _$$BillingModelImplCopyWith<$Res> {
  __$$BillingModelImplCopyWithImpl(
    _$BillingModelImpl _value,
    $Res Function(_$BillingModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BillingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? free = freezed, Object? database = freezed}) {
    return _then(
      _$BillingModelImpl(
        free: freezed == free
            ? _value.free
            : free // ignore: cast_nullable_to_non_nullable
                  as bool?,
        database: freezed == database
            ? _value.database
            : database // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BillingModelImpl implements _BillingModel {
  const _$BillingModelImpl({this.free, this.database});

  factory _$BillingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BillingModelImplFromJson(json);

  @override
  final bool? free;
  @override
  final bool? database;

  @override
  String toString() {
    return 'BillingModel(free: $free, database: $database)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BillingModelImpl &&
            (identical(other.free, free) || other.free == free) &&
            (identical(other.database, database) ||
                other.database == database));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, free, database);

  /// Create a copy of BillingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BillingModelImplCopyWith<_$BillingModelImpl> get copyWith =>
      __$$BillingModelImplCopyWithImpl<_$BillingModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BillingModelImplToJson(this);
  }
}

abstract class _BillingModel implements BillingModel {
  const factory _BillingModel({final bool? free, final bool? database}) =
      _$BillingModelImpl;

  factory _BillingModel.fromJson(Map<String, dynamic> json) =
      _$BillingModelImpl.fromJson;

  @override
  bool? get free;
  @override
  bool? get database;

  /// Create a copy of BillingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BillingModelImplCopyWith<_$BillingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

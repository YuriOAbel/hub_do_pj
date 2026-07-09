// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nome_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NomeModel _$NomeModelFromJson(Map<String, dynamic> json) {
  return _NomeModel.fromJson(json);
}

/// @nodoc
mixin _$NomeModel {
  String? get cnpj => throw _privateConstructorUsedError;
  @JsonKey(name: 'fantasia')
  String? get nomeFantasia => throw _privateConstructorUsedError;
  @JsonKey(name: 'razao_social')
  String? get razaoSocial => throw _privateConstructorUsedError;

  /// Serializes this NomeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NomeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NomeModelCopyWith<NomeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NomeModelCopyWith<$Res> {
  factory $NomeModelCopyWith(NomeModel value, $Res Function(NomeModel) then) =
      _$NomeModelCopyWithImpl<$Res, NomeModel>;
  @useResult
  $Res call({
    String? cnpj,
    @JsonKey(name: 'fantasia') String? nomeFantasia,
    @JsonKey(name: 'razao_social') String? razaoSocial,
  });
}

/// @nodoc
class _$NomeModelCopyWithImpl<$Res, $Val extends NomeModel>
    implements $NomeModelCopyWith<$Res> {
  _$NomeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NomeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cnpj = freezed,
    Object? nomeFantasia = freezed,
    Object? razaoSocial = freezed,
  }) {
    return _then(
      _value.copyWith(
            cnpj: freezed == cnpj
                ? _value.cnpj
                : cnpj // ignore: cast_nullable_to_non_nullable
                      as String?,
            nomeFantasia: freezed == nomeFantasia
                ? _value.nomeFantasia
                : nomeFantasia // ignore: cast_nullable_to_non_nullable
                      as String?,
            razaoSocial: freezed == razaoSocial
                ? _value.razaoSocial
                : razaoSocial // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NomeModelImplCopyWith<$Res>
    implements $NomeModelCopyWith<$Res> {
  factory _$$NomeModelImplCopyWith(
    _$NomeModelImpl value,
    $Res Function(_$NomeModelImpl) then,
  ) = __$$NomeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? cnpj,
    @JsonKey(name: 'fantasia') String? nomeFantasia,
    @JsonKey(name: 'razao_social') String? razaoSocial,
  });
}

/// @nodoc
class __$$NomeModelImplCopyWithImpl<$Res>
    extends _$NomeModelCopyWithImpl<$Res, _$NomeModelImpl>
    implements _$$NomeModelImplCopyWith<$Res> {
  __$$NomeModelImplCopyWithImpl(
    _$NomeModelImpl _value,
    $Res Function(_$NomeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NomeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cnpj = freezed,
    Object? nomeFantasia = freezed,
    Object? razaoSocial = freezed,
  }) {
    return _then(
      _$NomeModelImpl(
        cnpj: freezed == cnpj
            ? _value.cnpj
            : cnpj // ignore: cast_nullable_to_non_nullable
                  as String?,
        nomeFantasia: freezed == nomeFantasia
            ? _value.nomeFantasia
            : nomeFantasia // ignore: cast_nullable_to_non_nullable
                  as String?,
        razaoSocial: freezed == razaoSocial
            ? _value.razaoSocial
            : razaoSocial // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NomeModelImpl implements _NomeModel {
  const _$NomeModelImpl({
    this.cnpj,
    @JsonKey(name: 'fantasia') this.nomeFantasia,
    @JsonKey(name: 'razao_social') this.razaoSocial,
  });

  factory _$NomeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NomeModelImplFromJson(json);

  @override
  final String? cnpj;
  @override
  @JsonKey(name: 'fantasia')
  final String? nomeFantasia;
  @override
  @JsonKey(name: 'razao_social')
  final String? razaoSocial;

  @override
  String toString() {
    return 'NomeModel(cnpj: $cnpj, nomeFantasia: $nomeFantasia, razaoSocial: $razaoSocial)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NomeModelImpl &&
            (identical(other.cnpj, cnpj) || other.cnpj == cnpj) &&
            (identical(other.nomeFantasia, nomeFantasia) ||
                other.nomeFantasia == nomeFantasia) &&
            (identical(other.razaoSocial, razaoSocial) ||
                other.razaoSocial == razaoSocial));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, cnpj, nomeFantasia, razaoSocial);

  /// Create a copy of NomeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NomeModelImplCopyWith<_$NomeModelImpl> get copyWith =>
      __$$NomeModelImplCopyWithImpl<_$NomeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NomeModelImplToJson(this);
  }
}

abstract class _NomeModel implements NomeModel {
  const factory _NomeModel({
    final String? cnpj,
    @JsonKey(name: 'fantasia') final String? nomeFantasia,
    @JsonKey(name: 'razao_social') final String? razaoSocial,
  }) = _$NomeModelImpl;

  factory _NomeModel.fromJson(Map<String, dynamic> json) =
      _$NomeModelImpl.fromJson;

  @override
  String? get cnpj;
  @override
  @JsonKey(name: 'fantasia')
  String? get nomeFantasia;
  @override
  @JsonKey(name: 'razao_social')
  String? get razaoSocial;

  /// Create a copy of NomeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NomeModelImplCopyWith<_$NomeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

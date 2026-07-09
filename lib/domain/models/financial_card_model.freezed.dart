// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'financial_card_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FinancialCardModel _$FinancialCardModelFromJson(Map<String, dynamic> json) {
  return _FinancialCardModel.fromJson(json);
}

/// @nodoc
mixin _$FinancialCardModel {
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get logo => throw _privateConstructorUsedError;
  bool? get active => throw _privateConstructorUsedError;
  bool? get destaque => throw _privateConstructorUsedError;
  @JsonKey(name: 'link_externo')
  String? get linkExterno => throw _privateConstructorUsedError;
  @JsonKey(name: 'renda_minima')
  String? get rendaMinima => throw _privateConstructorUsedError;
  String? get tipo => throw _privateConstructorUsedError;
  String? get bandeira => throw _privateConstructorUsedError;
  String? get anuidade => throw _privateConstructorUsedError;
  @JsonKey(name: 'demais_anuidade')
  String? get demaisAnuidade => throw _privateConstructorUsedError;
  String? get diferencial => throw _privateConstructorUsedError;
  String? get beneficios => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'external_id')
  String? get externalId => throw _privateConstructorUsedError;
  String? get categoria => throw _privateConstructorUsedError;
  @JsonKey(name: 'categoria_id')
  int? get categoriaId => throw _privateConstructorUsedError;
  @JsonKey(name: 'categoria_string')
  String? get categoriaString => throw _privateConstructorUsedError;

  /// Serializes this FinancialCardModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FinancialCardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FinancialCardModelCopyWith<FinancialCardModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FinancialCardModelCopyWith<$Res> {
  factory $FinancialCardModelCopyWith(
    FinancialCardModel value,
    $Res Function(FinancialCardModel) then,
  ) = _$FinancialCardModelCopyWithImpl<$Res, FinancialCardModel>;
  @useResult
  $Res call({
    int? id,
    String? name,
    String? logo,
    bool? active,
    bool? destaque,
    @JsonKey(name: 'link_externo') String? linkExterno,
    @JsonKey(name: 'renda_minima') String? rendaMinima,
    String? tipo,
    String? bandeira,
    String? anuidade,
    @JsonKey(name: 'demais_anuidade') String? demaisAnuidade,
    String? diferencial,
    String? beneficios,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'external_id') String? externalId,
    String? categoria,
    @JsonKey(name: 'categoria_id') int? categoriaId,
    @JsonKey(name: 'categoria_string') String? categoriaString,
  });
}

/// @nodoc
class _$FinancialCardModelCopyWithImpl<$Res, $Val extends FinancialCardModel>
    implements $FinancialCardModelCopyWith<$Res> {
  _$FinancialCardModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FinancialCardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? logo = freezed,
    Object? active = freezed,
    Object? destaque = freezed,
    Object? linkExterno = freezed,
    Object? rendaMinima = freezed,
    Object? tipo = freezed,
    Object? bandeira = freezed,
    Object? anuidade = freezed,
    Object? demaisAnuidade = freezed,
    Object? diferencial = freezed,
    Object? beneficios = freezed,
    Object? createdAt = freezed,
    Object? externalId = freezed,
    Object? categoria = freezed,
    Object? categoriaId = freezed,
    Object? categoriaString = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            logo: freezed == logo
                ? _value.logo
                : logo // ignore: cast_nullable_to_non_nullable
                      as String?,
            active: freezed == active
                ? _value.active
                : active // ignore: cast_nullable_to_non_nullable
                      as bool?,
            destaque: freezed == destaque
                ? _value.destaque
                : destaque // ignore: cast_nullable_to_non_nullable
                      as bool?,
            linkExterno: freezed == linkExterno
                ? _value.linkExterno
                : linkExterno // ignore: cast_nullable_to_non_nullable
                      as String?,
            rendaMinima: freezed == rendaMinima
                ? _value.rendaMinima
                : rendaMinima // ignore: cast_nullable_to_non_nullable
                      as String?,
            tipo: freezed == tipo
                ? _value.tipo
                : tipo // ignore: cast_nullable_to_non_nullable
                      as String?,
            bandeira: freezed == bandeira
                ? _value.bandeira
                : bandeira // ignore: cast_nullable_to_non_nullable
                      as String?,
            anuidade: freezed == anuidade
                ? _value.anuidade
                : anuidade // ignore: cast_nullable_to_non_nullable
                      as String?,
            demaisAnuidade: freezed == demaisAnuidade
                ? _value.demaisAnuidade
                : demaisAnuidade // ignore: cast_nullable_to_non_nullable
                      as String?,
            diferencial: freezed == diferencial
                ? _value.diferencial
                : diferencial // ignore: cast_nullable_to_non_nullable
                      as String?,
            beneficios: freezed == beneficios
                ? _value.beneficios
                : beneficios // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            externalId: freezed == externalId
                ? _value.externalId
                : externalId // ignore: cast_nullable_to_non_nullable
                      as String?,
            categoria: freezed == categoria
                ? _value.categoria
                : categoria // ignore: cast_nullable_to_non_nullable
                      as String?,
            categoriaId: freezed == categoriaId
                ? _value.categoriaId
                : categoriaId // ignore: cast_nullable_to_non_nullable
                      as int?,
            categoriaString: freezed == categoriaString
                ? _value.categoriaString
                : categoriaString // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FinancialCardModelImplCopyWith<$Res>
    implements $FinancialCardModelCopyWith<$Res> {
  factory _$$FinancialCardModelImplCopyWith(
    _$FinancialCardModelImpl value,
    $Res Function(_$FinancialCardModelImpl) then,
  ) = __$$FinancialCardModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String? name,
    String? logo,
    bool? active,
    bool? destaque,
    @JsonKey(name: 'link_externo') String? linkExterno,
    @JsonKey(name: 'renda_minima') String? rendaMinima,
    String? tipo,
    String? bandeira,
    String? anuidade,
    @JsonKey(name: 'demais_anuidade') String? demaisAnuidade,
    String? diferencial,
    String? beneficios,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'external_id') String? externalId,
    String? categoria,
    @JsonKey(name: 'categoria_id') int? categoriaId,
    @JsonKey(name: 'categoria_string') String? categoriaString,
  });
}

/// @nodoc
class __$$FinancialCardModelImplCopyWithImpl<$Res>
    extends _$FinancialCardModelCopyWithImpl<$Res, _$FinancialCardModelImpl>
    implements _$$FinancialCardModelImplCopyWith<$Res> {
  __$$FinancialCardModelImplCopyWithImpl(
    _$FinancialCardModelImpl _value,
    $Res Function(_$FinancialCardModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FinancialCardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? logo = freezed,
    Object? active = freezed,
    Object? destaque = freezed,
    Object? linkExterno = freezed,
    Object? rendaMinima = freezed,
    Object? tipo = freezed,
    Object? bandeira = freezed,
    Object? anuidade = freezed,
    Object? demaisAnuidade = freezed,
    Object? diferencial = freezed,
    Object? beneficios = freezed,
    Object? createdAt = freezed,
    Object? externalId = freezed,
    Object? categoria = freezed,
    Object? categoriaId = freezed,
    Object? categoriaString = freezed,
  }) {
    return _then(
      _$FinancialCardModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        logo: freezed == logo
            ? _value.logo
            : logo // ignore: cast_nullable_to_non_nullable
                  as String?,
        active: freezed == active
            ? _value.active
            : active // ignore: cast_nullable_to_non_nullable
                  as bool?,
        destaque: freezed == destaque
            ? _value.destaque
            : destaque // ignore: cast_nullable_to_non_nullable
                  as bool?,
        linkExterno: freezed == linkExterno
            ? _value.linkExterno
            : linkExterno // ignore: cast_nullable_to_non_nullable
                  as String?,
        rendaMinima: freezed == rendaMinima
            ? _value.rendaMinima
            : rendaMinima // ignore: cast_nullable_to_non_nullable
                  as String?,
        tipo: freezed == tipo
            ? _value.tipo
            : tipo // ignore: cast_nullable_to_non_nullable
                  as String?,
        bandeira: freezed == bandeira
            ? _value.bandeira
            : bandeira // ignore: cast_nullable_to_non_nullable
                  as String?,
        anuidade: freezed == anuidade
            ? _value.anuidade
            : anuidade // ignore: cast_nullable_to_non_nullable
                  as String?,
        demaisAnuidade: freezed == demaisAnuidade
            ? _value.demaisAnuidade
            : demaisAnuidade // ignore: cast_nullable_to_non_nullable
                  as String?,
        diferencial: freezed == diferencial
            ? _value.diferencial
            : diferencial // ignore: cast_nullable_to_non_nullable
                  as String?,
        beneficios: freezed == beneficios
            ? _value.beneficios
            : beneficios // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        externalId: freezed == externalId
            ? _value.externalId
            : externalId // ignore: cast_nullable_to_non_nullable
                  as String?,
        categoria: freezed == categoria
            ? _value.categoria
            : categoria // ignore: cast_nullable_to_non_nullable
                  as String?,
        categoriaId: freezed == categoriaId
            ? _value.categoriaId
            : categoriaId // ignore: cast_nullable_to_non_nullable
                  as int?,
        categoriaString: freezed == categoriaString
            ? _value.categoriaString
            : categoriaString // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FinancialCardModelImpl implements _FinancialCardModel {
  const _$FinancialCardModelImpl({
    this.id,
    this.name,
    this.logo,
    this.active,
    this.destaque,
    @JsonKey(name: 'link_externo') this.linkExterno,
    @JsonKey(name: 'renda_minima') this.rendaMinima,
    this.tipo,
    this.bandeira,
    this.anuidade,
    @JsonKey(name: 'demais_anuidade') this.demaisAnuidade,
    this.diferencial,
    this.beneficios,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'external_id') this.externalId,
    this.categoria,
    @JsonKey(name: 'categoria_id') this.categoriaId,
    @JsonKey(name: 'categoria_string') this.categoriaString,
  });

  factory _$FinancialCardModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FinancialCardModelImplFromJson(json);

  @override
  final int? id;
  @override
  final String? name;
  @override
  final String? logo;
  @override
  final bool? active;
  @override
  final bool? destaque;
  @override
  @JsonKey(name: 'link_externo')
  final String? linkExterno;
  @override
  @JsonKey(name: 'renda_minima')
  final String? rendaMinima;
  @override
  final String? tipo;
  @override
  final String? bandeira;
  @override
  final String? anuidade;
  @override
  @JsonKey(name: 'demais_anuidade')
  final String? demaisAnuidade;
  @override
  final String? diferencial;
  @override
  final String? beneficios;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'external_id')
  final String? externalId;
  @override
  final String? categoria;
  @override
  @JsonKey(name: 'categoria_id')
  final int? categoriaId;
  @override
  @JsonKey(name: 'categoria_string')
  final String? categoriaString;

  @override
  String toString() {
    return 'FinancialCardModel(id: $id, name: $name, logo: $logo, active: $active, destaque: $destaque, linkExterno: $linkExterno, rendaMinima: $rendaMinima, tipo: $tipo, bandeira: $bandeira, anuidade: $anuidade, demaisAnuidade: $demaisAnuidade, diferencial: $diferencial, beneficios: $beneficios, createdAt: $createdAt, externalId: $externalId, categoria: $categoria, categoriaId: $categoriaId, categoriaString: $categoriaString)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FinancialCardModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.logo, logo) || other.logo == logo) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.destaque, destaque) ||
                other.destaque == destaque) &&
            (identical(other.linkExterno, linkExterno) ||
                other.linkExterno == linkExterno) &&
            (identical(other.rendaMinima, rendaMinima) ||
                other.rendaMinima == rendaMinima) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.bandeira, bandeira) ||
                other.bandeira == bandeira) &&
            (identical(other.anuidade, anuidade) ||
                other.anuidade == anuidade) &&
            (identical(other.demaisAnuidade, demaisAnuidade) ||
                other.demaisAnuidade == demaisAnuidade) &&
            (identical(other.diferencial, diferencial) ||
                other.diferencial == diferencial) &&
            (identical(other.beneficios, beneficios) ||
                other.beneficios == beneficios) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.externalId, externalId) ||
                other.externalId == externalId) &&
            (identical(other.categoria, categoria) ||
                other.categoria == categoria) &&
            (identical(other.categoriaId, categoriaId) ||
                other.categoriaId == categoriaId) &&
            (identical(other.categoriaString, categoriaString) ||
                other.categoriaString == categoriaString));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    logo,
    active,
    destaque,
    linkExterno,
    rendaMinima,
    tipo,
    bandeira,
    anuidade,
    demaisAnuidade,
    diferencial,
    beneficios,
    createdAt,
    externalId,
    categoria,
    categoriaId,
    categoriaString,
  );

  /// Create a copy of FinancialCardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FinancialCardModelImplCopyWith<_$FinancialCardModelImpl> get copyWith =>
      __$$FinancialCardModelImplCopyWithImpl<_$FinancialCardModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FinancialCardModelImplToJson(this);
  }
}

abstract class _FinancialCardModel implements FinancialCardModel {
  const factory _FinancialCardModel({
    final int? id,
    final String? name,
    final String? logo,
    final bool? active,
    final bool? destaque,
    @JsonKey(name: 'link_externo') final String? linkExterno,
    @JsonKey(name: 'renda_minima') final String? rendaMinima,
    final String? tipo,
    final String? bandeira,
    final String? anuidade,
    @JsonKey(name: 'demais_anuidade') final String? demaisAnuidade,
    final String? diferencial,
    final String? beneficios,
    @JsonKey(name: 'created_at') final String? createdAt,
    @JsonKey(name: 'external_id') final String? externalId,
    final String? categoria,
    @JsonKey(name: 'categoria_id') final int? categoriaId,
    @JsonKey(name: 'categoria_string') final String? categoriaString,
  }) = _$FinancialCardModelImpl;

  factory _FinancialCardModel.fromJson(Map<String, dynamic> json) =
      _$FinancialCardModelImpl.fromJson;

  @override
  int? get id;
  @override
  String? get name;
  @override
  String? get logo;
  @override
  bool? get active;
  @override
  bool? get destaque;
  @override
  @JsonKey(name: 'link_externo')
  String? get linkExterno;
  @override
  @JsonKey(name: 'renda_minima')
  String? get rendaMinima;
  @override
  String? get tipo;
  @override
  String? get bandeira;
  @override
  String? get anuidade;
  @override
  @JsonKey(name: 'demais_anuidade')
  String? get demaisAnuidade;
  @override
  String? get diferencial;
  @override
  String? get beneficios;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'external_id')
  String? get externalId;
  @override
  String? get categoria;
  @override
  @JsonKey(name: 'categoria_id')
  int? get categoriaId;
  @override
  @JsonKey(name: 'categoria_string')
  String? get categoriaString;

  /// Create a copy of FinancialCardModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FinancialCardModelImplCopyWith<_$FinancialCardModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

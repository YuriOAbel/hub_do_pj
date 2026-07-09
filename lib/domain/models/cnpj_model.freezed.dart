// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cnpj_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CnpjModel _$CnpjModelFromJson(Map<String, dynamic> json) {
  return _CnpjModel.fromJson(json);
}

/// @nodoc
mixin _$CnpjModel {
  String? get abertura => throw _privateConstructorUsedError;
  String? get situacao => throw _privateConstructorUsedError;
  String? get tipo => throw _privateConstructorUsedError;
  String? get nome => throw _privateConstructorUsedError;
  String? get fantasia => throw _privateConstructorUsedError;
  String? get porte => throw _privateConstructorUsedError;
  @JsonKey(name: 'natureza_juridica')
  String? get naturezaJuridica => throw _privateConstructorUsedError;
  @JsonKey(name: 'atividade_principal')
  List<AtividadeModel>? get atividadePrincipal =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'atividades_secundarias')
  List<AtividadeModel>? get atividadesSecundarias =>
      throw _privateConstructorUsedError;
  List<QsaModel>? get qsa => throw _privateConstructorUsedError;
  String? get logradouro => throw _privateConstructorUsedError;
  String? get numero => throw _privateConstructorUsedError;
  String? get complemento => throw _privateConstructorUsedError;
  String? get municipio => throw _privateConstructorUsedError;
  String? get bairro => throw _privateConstructorUsedError;
  String? get uf => throw _privateConstructorUsedError;
  String? get cep => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get telefone => throw _privateConstructorUsedError;
  @JsonKey(name: 'data_situacao')
  String? get dataSituacao => throw _privateConstructorUsedError;
  String? get cnpj => throw _privateConstructorUsedError;
  @JsonKey(name: 'ultima_atualizacao')
  String? get ultimaAtualizacao => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get efr => throw _privateConstructorUsedError;
  @JsonKey(name: 'motivo_situacao')
  String? get motivoSituacao => throw _privateConstructorUsedError;
  @JsonKey(name: 'situacao_especial')
  String? get situacaoEspecial => throw _privateConstructorUsedError;
  @JsonKey(name: 'data_situacao_especial')
  String? get dataSituacaoEspecial => throw _privateConstructorUsedError;
  @JsonKey(name: 'capital_social')
  String? get capitalSocial => throw _privateConstructorUsedError;
  BillingModel? get billing => throw _privateConstructorUsedError;
  @JsonKey(name: 'dt_save')
  String? get dtSave => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  /// Serializes this CnpjModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CnpjModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CnpjModelCopyWith<CnpjModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CnpjModelCopyWith<$Res> {
  factory $CnpjModelCopyWith(CnpjModel value, $Res Function(CnpjModel) then) =
      _$CnpjModelCopyWithImpl<$Res, CnpjModel>;
  @useResult
  $Res call({
    String? abertura,
    String? situacao,
    String? tipo,
    String? nome,
    String? fantasia,
    String? porte,
    @JsonKey(name: 'natureza_juridica') String? naturezaJuridica,
    @JsonKey(name: 'atividade_principal')
    List<AtividadeModel>? atividadePrincipal,
    @JsonKey(name: 'atividades_secundarias')
    List<AtividadeModel>? atividadesSecundarias,
    List<QsaModel>? qsa,
    String? logradouro,
    String? numero,
    String? complemento,
    String? municipio,
    String? bairro,
    String? uf,
    String? cep,
    String? email,
    String? telefone,
    @JsonKey(name: 'data_situacao') String? dataSituacao,
    String? cnpj,
    @JsonKey(name: 'ultima_atualizacao') String? ultimaAtualizacao,
    String? status,
    String? efr,
    @JsonKey(name: 'motivo_situacao') String? motivoSituacao,
    @JsonKey(name: 'situacao_especial') String? situacaoEspecial,
    @JsonKey(name: 'data_situacao_especial') String? dataSituacaoEspecial,
    @JsonKey(name: 'capital_social') String? capitalSocial,
    BillingModel? billing,
    @JsonKey(name: 'dt_save') String? dtSave,
    String? message,
  });

  $BillingModelCopyWith<$Res>? get billing;
}

/// @nodoc
class _$CnpjModelCopyWithImpl<$Res, $Val extends CnpjModel>
    implements $CnpjModelCopyWith<$Res> {
  _$CnpjModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CnpjModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? abertura = freezed,
    Object? situacao = freezed,
    Object? tipo = freezed,
    Object? nome = freezed,
    Object? fantasia = freezed,
    Object? porte = freezed,
    Object? naturezaJuridica = freezed,
    Object? atividadePrincipal = freezed,
    Object? atividadesSecundarias = freezed,
    Object? qsa = freezed,
    Object? logradouro = freezed,
    Object? numero = freezed,
    Object? complemento = freezed,
    Object? municipio = freezed,
    Object? bairro = freezed,
    Object? uf = freezed,
    Object? cep = freezed,
    Object? email = freezed,
    Object? telefone = freezed,
    Object? dataSituacao = freezed,
    Object? cnpj = freezed,
    Object? ultimaAtualizacao = freezed,
    Object? status = freezed,
    Object? efr = freezed,
    Object? motivoSituacao = freezed,
    Object? situacaoEspecial = freezed,
    Object? dataSituacaoEspecial = freezed,
    Object? capitalSocial = freezed,
    Object? billing = freezed,
    Object? dtSave = freezed,
    Object? message = freezed,
  }) {
    return _then(
      _value.copyWith(
            abertura: freezed == abertura
                ? _value.abertura
                : abertura // ignore: cast_nullable_to_non_nullable
                      as String?,
            situacao: freezed == situacao
                ? _value.situacao
                : situacao // ignore: cast_nullable_to_non_nullable
                      as String?,
            tipo: freezed == tipo
                ? _value.tipo
                : tipo // ignore: cast_nullable_to_non_nullable
                      as String?,
            nome: freezed == nome
                ? _value.nome
                : nome // ignore: cast_nullable_to_non_nullable
                      as String?,
            fantasia: freezed == fantasia
                ? _value.fantasia
                : fantasia // ignore: cast_nullable_to_non_nullable
                      as String?,
            porte: freezed == porte
                ? _value.porte
                : porte // ignore: cast_nullable_to_non_nullable
                      as String?,
            naturezaJuridica: freezed == naturezaJuridica
                ? _value.naturezaJuridica
                : naturezaJuridica // ignore: cast_nullable_to_non_nullable
                      as String?,
            atividadePrincipal: freezed == atividadePrincipal
                ? _value.atividadePrincipal
                : atividadePrincipal // ignore: cast_nullable_to_non_nullable
                      as List<AtividadeModel>?,
            atividadesSecundarias: freezed == atividadesSecundarias
                ? _value.atividadesSecundarias
                : atividadesSecundarias // ignore: cast_nullable_to_non_nullable
                      as List<AtividadeModel>?,
            qsa: freezed == qsa
                ? _value.qsa
                : qsa // ignore: cast_nullable_to_non_nullable
                      as List<QsaModel>?,
            logradouro: freezed == logradouro
                ? _value.logradouro
                : logradouro // ignore: cast_nullable_to_non_nullable
                      as String?,
            numero: freezed == numero
                ? _value.numero
                : numero // ignore: cast_nullable_to_non_nullable
                      as String?,
            complemento: freezed == complemento
                ? _value.complemento
                : complemento // ignore: cast_nullable_to_non_nullable
                      as String?,
            municipio: freezed == municipio
                ? _value.municipio
                : municipio // ignore: cast_nullable_to_non_nullable
                      as String?,
            bairro: freezed == bairro
                ? _value.bairro
                : bairro // ignore: cast_nullable_to_non_nullable
                      as String?,
            uf: freezed == uf
                ? _value.uf
                : uf // ignore: cast_nullable_to_non_nullable
                      as String?,
            cep: freezed == cep
                ? _value.cep
                : cep // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            telefone: freezed == telefone
                ? _value.telefone
                : telefone // ignore: cast_nullable_to_non_nullable
                      as String?,
            dataSituacao: freezed == dataSituacao
                ? _value.dataSituacao
                : dataSituacao // ignore: cast_nullable_to_non_nullable
                      as String?,
            cnpj: freezed == cnpj
                ? _value.cnpj
                : cnpj // ignore: cast_nullable_to_non_nullable
                      as String?,
            ultimaAtualizacao: freezed == ultimaAtualizacao
                ? _value.ultimaAtualizacao
                : ultimaAtualizacao // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            efr: freezed == efr
                ? _value.efr
                : efr // ignore: cast_nullable_to_non_nullable
                      as String?,
            motivoSituacao: freezed == motivoSituacao
                ? _value.motivoSituacao
                : motivoSituacao // ignore: cast_nullable_to_non_nullable
                      as String?,
            situacaoEspecial: freezed == situacaoEspecial
                ? _value.situacaoEspecial
                : situacaoEspecial // ignore: cast_nullable_to_non_nullable
                      as String?,
            dataSituacaoEspecial: freezed == dataSituacaoEspecial
                ? _value.dataSituacaoEspecial
                : dataSituacaoEspecial // ignore: cast_nullable_to_non_nullable
                      as String?,
            capitalSocial: freezed == capitalSocial
                ? _value.capitalSocial
                : capitalSocial // ignore: cast_nullable_to_non_nullable
                      as String?,
            billing: freezed == billing
                ? _value.billing
                : billing // ignore: cast_nullable_to_non_nullable
                      as BillingModel?,
            dtSave: freezed == dtSave
                ? _value.dtSave
                : dtSave // ignore: cast_nullable_to_non_nullable
                      as String?,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of CnpjModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BillingModelCopyWith<$Res>? get billing {
    if (_value.billing == null) {
      return null;
    }

    return $BillingModelCopyWith<$Res>(_value.billing!, (value) {
      return _then(_value.copyWith(billing: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CnpjModelImplCopyWith<$Res>
    implements $CnpjModelCopyWith<$Res> {
  factory _$$CnpjModelImplCopyWith(
    _$CnpjModelImpl value,
    $Res Function(_$CnpjModelImpl) then,
  ) = __$$CnpjModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? abertura,
    String? situacao,
    String? tipo,
    String? nome,
    String? fantasia,
    String? porte,
    @JsonKey(name: 'natureza_juridica') String? naturezaJuridica,
    @JsonKey(name: 'atividade_principal')
    List<AtividadeModel>? atividadePrincipal,
    @JsonKey(name: 'atividades_secundarias')
    List<AtividadeModel>? atividadesSecundarias,
    List<QsaModel>? qsa,
    String? logradouro,
    String? numero,
    String? complemento,
    String? municipio,
    String? bairro,
    String? uf,
    String? cep,
    String? email,
    String? telefone,
    @JsonKey(name: 'data_situacao') String? dataSituacao,
    String? cnpj,
    @JsonKey(name: 'ultima_atualizacao') String? ultimaAtualizacao,
    String? status,
    String? efr,
    @JsonKey(name: 'motivo_situacao') String? motivoSituacao,
    @JsonKey(name: 'situacao_especial') String? situacaoEspecial,
    @JsonKey(name: 'data_situacao_especial') String? dataSituacaoEspecial,
    @JsonKey(name: 'capital_social') String? capitalSocial,
    BillingModel? billing,
    @JsonKey(name: 'dt_save') String? dtSave,
    String? message,
  });

  @override
  $BillingModelCopyWith<$Res>? get billing;
}

/// @nodoc
class __$$CnpjModelImplCopyWithImpl<$Res>
    extends _$CnpjModelCopyWithImpl<$Res, _$CnpjModelImpl>
    implements _$$CnpjModelImplCopyWith<$Res> {
  __$$CnpjModelImplCopyWithImpl(
    _$CnpjModelImpl _value,
    $Res Function(_$CnpjModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CnpjModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? abertura = freezed,
    Object? situacao = freezed,
    Object? tipo = freezed,
    Object? nome = freezed,
    Object? fantasia = freezed,
    Object? porte = freezed,
    Object? naturezaJuridica = freezed,
    Object? atividadePrincipal = freezed,
    Object? atividadesSecundarias = freezed,
    Object? qsa = freezed,
    Object? logradouro = freezed,
    Object? numero = freezed,
    Object? complemento = freezed,
    Object? municipio = freezed,
    Object? bairro = freezed,
    Object? uf = freezed,
    Object? cep = freezed,
    Object? email = freezed,
    Object? telefone = freezed,
    Object? dataSituacao = freezed,
    Object? cnpj = freezed,
    Object? ultimaAtualizacao = freezed,
    Object? status = freezed,
    Object? efr = freezed,
    Object? motivoSituacao = freezed,
    Object? situacaoEspecial = freezed,
    Object? dataSituacaoEspecial = freezed,
    Object? capitalSocial = freezed,
    Object? billing = freezed,
    Object? dtSave = freezed,
    Object? message = freezed,
  }) {
    return _then(
      _$CnpjModelImpl(
        abertura: freezed == abertura
            ? _value.abertura
            : abertura // ignore: cast_nullable_to_non_nullable
                  as String?,
        situacao: freezed == situacao
            ? _value.situacao
            : situacao // ignore: cast_nullable_to_non_nullable
                  as String?,
        tipo: freezed == tipo
            ? _value.tipo
            : tipo // ignore: cast_nullable_to_non_nullable
                  as String?,
        nome: freezed == nome
            ? _value.nome
            : nome // ignore: cast_nullable_to_non_nullable
                  as String?,
        fantasia: freezed == fantasia
            ? _value.fantasia
            : fantasia // ignore: cast_nullable_to_non_nullable
                  as String?,
        porte: freezed == porte
            ? _value.porte
            : porte // ignore: cast_nullable_to_non_nullable
                  as String?,
        naturezaJuridica: freezed == naturezaJuridica
            ? _value.naturezaJuridica
            : naturezaJuridica // ignore: cast_nullable_to_non_nullable
                  as String?,
        atividadePrincipal: freezed == atividadePrincipal
            ? _value._atividadePrincipal
            : atividadePrincipal // ignore: cast_nullable_to_non_nullable
                  as List<AtividadeModel>?,
        atividadesSecundarias: freezed == atividadesSecundarias
            ? _value._atividadesSecundarias
            : atividadesSecundarias // ignore: cast_nullable_to_non_nullable
                  as List<AtividadeModel>?,
        qsa: freezed == qsa
            ? _value._qsa
            : qsa // ignore: cast_nullable_to_non_nullable
                  as List<QsaModel>?,
        logradouro: freezed == logradouro
            ? _value.logradouro
            : logradouro // ignore: cast_nullable_to_non_nullable
                  as String?,
        numero: freezed == numero
            ? _value.numero
            : numero // ignore: cast_nullable_to_non_nullable
                  as String?,
        complemento: freezed == complemento
            ? _value.complemento
            : complemento // ignore: cast_nullable_to_non_nullable
                  as String?,
        municipio: freezed == municipio
            ? _value.municipio
            : municipio // ignore: cast_nullable_to_non_nullable
                  as String?,
        bairro: freezed == bairro
            ? _value.bairro
            : bairro // ignore: cast_nullable_to_non_nullable
                  as String?,
        uf: freezed == uf
            ? _value.uf
            : uf // ignore: cast_nullable_to_non_nullable
                  as String?,
        cep: freezed == cep
            ? _value.cep
            : cep // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        telefone: freezed == telefone
            ? _value.telefone
            : telefone // ignore: cast_nullable_to_non_nullable
                  as String?,
        dataSituacao: freezed == dataSituacao
            ? _value.dataSituacao
            : dataSituacao // ignore: cast_nullable_to_non_nullable
                  as String?,
        cnpj: freezed == cnpj
            ? _value.cnpj
            : cnpj // ignore: cast_nullable_to_non_nullable
                  as String?,
        ultimaAtualizacao: freezed == ultimaAtualizacao
            ? _value.ultimaAtualizacao
            : ultimaAtualizacao // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        efr: freezed == efr
            ? _value.efr
            : efr // ignore: cast_nullable_to_non_nullable
                  as String?,
        motivoSituacao: freezed == motivoSituacao
            ? _value.motivoSituacao
            : motivoSituacao // ignore: cast_nullable_to_non_nullable
                  as String?,
        situacaoEspecial: freezed == situacaoEspecial
            ? _value.situacaoEspecial
            : situacaoEspecial // ignore: cast_nullable_to_non_nullable
                  as String?,
        dataSituacaoEspecial: freezed == dataSituacaoEspecial
            ? _value.dataSituacaoEspecial
            : dataSituacaoEspecial // ignore: cast_nullable_to_non_nullable
                  as String?,
        capitalSocial: freezed == capitalSocial
            ? _value.capitalSocial
            : capitalSocial // ignore: cast_nullable_to_non_nullable
                  as String?,
        billing: freezed == billing
            ? _value.billing
            : billing // ignore: cast_nullable_to_non_nullable
                  as BillingModel?,
        dtSave: freezed == dtSave
            ? _value.dtSave
            : dtSave // ignore: cast_nullable_to_non_nullable
                  as String?,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CnpjModelImpl implements _CnpjModel {
  const _$CnpjModelImpl({
    this.abertura,
    this.situacao,
    this.tipo,
    this.nome,
    this.fantasia,
    this.porte,
    @JsonKey(name: 'natureza_juridica') this.naturezaJuridica,
    @JsonKey(name: 'atividade_principal')
    final List<AtividadeModel>? atividadePrincipal,
    @JsonKey(name: 'atividades_secundarias')
    final List<AtividadeModel>? atividadesSecundarias,
    final List<QsaModel>? qsa,
    this.logradouro,
    this.numero,
    this.complemento,
    this.municipio,
    this.bairro,
    this.uf,
    this.cep,
    this.email,
    this.telefone,
    @JsonKey(name: 'data_situacao') this.dataSituacao,
    this.cnpj,
    @JsonKey(name: 'ultima_atualizacao') this.ultimaAtualizacao,
    this.status,
    this.efr,
    @JsonKey(name: 'motivo_situacao') this.motivoSituacao,
    @JsonKey(name: 'situacao_especial') this.situacaoEspecial,
    @JsonKey(name: 'data_situacao_especial') this.dataSituacaoEspecial,
    @JsonKey(name: 'capital_social') this.capitalSocial,
    this.billing,
    @JsonKey(name: 'dt_save') this.dtSave,
    this.message,
  }) : _atividadePrincipal = atividadePrincipal,
       _atividadesSecundarias = atividadesSecundarias,
       _qsa = qsa;

  factory _$CnpjModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CnpjModelImplFromJson(json);

  @override
  final String? abertura;
  @override
  final String? situacao;
  @override
  final String? tipo;
  @override
  final String? nome;
  @override
  final String? fantasia;
  @override
  final String? porte;
  @override
  @JsonKey(name: 'natureza_juridica')
  final String? naturezaJuridica;
  final List<AtividadeModel>? _atividadePrincipal;
  @override
  @JsonKey(name: 'atividade_principal')
  List<AtividadeModel>? get atividadePrincipal {
    final value = _atividadePrincipal;
    if (value == null) return null;
    if (_atividadePrincipal is EqualUnmodifiableListView)
      return _atividadePrincipal;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<AtividadeModel>? _atividadesSecundarias;
  @override
  @JsonKey(name: 'atividades_secundarias')
  List<AtividadeModel>? get atividadesSecundarias {
    final value = _atividadesSecundarias;
    if (value == null) return null;
    if (_atividadesSecundarias is EqualUnmodifiableListView)
      return _atividadesSecundarias;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<QsaModel>? _qsa;
  @override
  List<QsaModel>? get qsa {
    final value = _qsa;
    if (value == null) return null;
    if (_qsa is EqualUnmodifiableListView) return _qsa;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? logradouro;
  @override
  final String? numero;
  @override
  final String? complemento;
  @override
  final String? municipio;
  @override
  final String? bairro;
  @override
  final String? uf;
  @override
  final String? cep;
  @override
  final String? email;
  @override
  final String? telefone;
  @override
  @JsonKey(name: 'data_situacao')
  final String? dataSituacao;
  @override
  final String? cnpj;
  @override
  @JsonKey(name: 'ultima_atualizacao')
  final String? ultimaAtualizacao;
  @override
  final String? status;
  @override
  final String? efr;
  @override
  @JsonKey(name: 'motivo_situacao')
  final String? motivoSituacao;
  @override
  @JsonKey(name: 'situacao_especial')
  final String? situacaoEspecial;
  @override
  @JsonKey(name: 'data_situacao_especial')
  final String? dataSituacaoEspecial;
  @override
  @JsonKey(name: 'capital_social')
  final String? capitalSocial;
  @override
  final BillingModel? billing;
  @override
  @JsonKey(name: 'dt_save')
  final String? dtSave;
  @override
  final String? message;

  @override
  String toString() {
    return 'CnpjModel(abertura: $abertura, situacao: $situacao, tipo: $tipo, nome: $nome, fantasia: $fantasia, porte: $porte, naturezaJuridica: $naturezaJuridica, atividadePrincipal: $atividadePrincipal, atividadesSecundarias: $atividadesSecundarias, qsa: $qsa, logradouro: $logradouro, numero: $numero, complemento: $complemento, municipio: $municipio, bairro: $bairro, uf: $uf, cep: $cep, email: $email, telefone: $telefone, dataSituacao: $dataSituacao, cnpj: $cnpj, ultimaAtualizacao: $ultimaAtualizacao, status: $status, efr: $efr, motivoSituacao: $motivoSituacao, situacaoEspecial: $situacaoEspecial, dataSituacaoEspecial: $dataSituacaoEspecial, capitalSocial: $capitalSocial, billing: $billing, dtSave: $dtSave, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CnpjModelImpl &&
            (identical(other.abertura, abertura) ||
                other.abertura == abertura) &&
            (identical(other.situacao, situacao) ||
                other.situacao == situacao) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.nome, nome) || other.nome == nome) &&
            (identical(other.fantasia, fantasia) ||
                other.fantasia == fantasia) &&
            (identical(other.porte, porte) || other.porte == porte) &&
            (identical(other.naturezaJuridica, naturezaJuridica) ||
                other.naturezaJuridica == naturezaJuridica) &&
            const DeepCollectionEquality().equals(
              other._atividadePrincipal,
              _atividadePrincipal,
            ) &&
            const DeepCollectionEquality().equals(
              other._atividadesSecundarias,
              _atividadesSecundarias,
            ) &&
            const DeepCollectionEquality().equals(other._qsa, _qsa) &&
            (identical(other.logradouro, logradouro) ||
                other.logradouro == logradouro) &&
            (identical(other.numero, numero) || other.numero == numero) &&
            (identical(other.complemento, complemento) ||
                other.complemento == complemento) &&
            (identical(other.municipio, municipio) ||
                other.municipio == municipio) &&
            (identical(other.bairro, bairro) || other.bairro == bairro) &&
            (identical(other.uf, uf) || other.uf == uf) &&
            (identical(other.cep, cep) || other.cep == cep) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.telefone, telefone) ||
                other.telefone == telefone) &&
            (identical(other.dataSituacao, dataSituacao) ||
                other.dataSituacao == dataSituacao) &&
            (identical(other.cnpj, cnpj) || other.cnpj == cnpj) &&
            (identical(other.ultimaAtualizacao, ultimaAtualizacao) ||
                other.ultimaAtualizacao == ultimaAtualizacao) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.efr, efr) || other.efr == efr) &&
            (identical(other.motivoSituacao, motivoSituacao) ||
                other.motivoSituacao == motivoSituacao) &&
            (identical(other.situacaoEspecial, situacaoEspecial) ||
                other.situacaoEspecial == situacaoEspecial) &&
            (identical(other.dataSituacaoEspecial, dataSituacaoEspecial) ||
                other.dataSituacaoEspecial == dataSituacaoEspecial) &&
            (identical(other.capitalSocial, capitalSocial) ||
                other.capitalSocial == capitalSocial) &&
            (identical(other.billing, billing) || other.billing == billing) &&
            (identical(other.dtSave, dtSave) || other.dtSave == dtSave) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    abertura,
    situacao,
    tipo,
    nome,
    fantasia,
    porte,
    naturezaJuridica,
    const DeepCollectionEquality().hash(_atividadePrincipal),
    const DeepCollectionEquality().hash(_atividadesSecundarias),
    const DeepCollectionEquality().hash(_qsa),
    logradouro,
    numero,
    complemento,
    municipio,
    bairro,
    uf,
    cep,
    email,
    telefone,
    dataSituacao,
    cnpj,
    ultimaAtualizacao,
    status,
    efr,
    motivoSituacao,
    situacaoEspecial,
    dataSituacaoEspecial,
    capitalSocial,
    billing,
    dtSave,
    message,
  ]);

  /// Create a copy of CnpjModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CnpjModelImplCopyWith<_$CnpjModelImpl> get copyWith =>
      __$$CnpjModelImplCopyWithImpl<_$CnpjModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CnpjModelImplToJson(this);
  }
}

abstract class _CnpjModel implements CnpjModel {
  const factory _CnpjModel({
    final String? abertura,
    final String? situacao,
    final String? tipo,
    final String? nome,
    final String? fantasia,
    final String? porte,
    @JsonKey(name: 'natureza_juridica') final String? naturezaJuridica,
    @JsonKey(name: 'atividade_principal')
    final List<AtividadeModel>? atividadePrincipal,
    @JsonKey(name: 'atividades_secundarias')
    final List<AtividadeModel>? atividadesSecundarias,
    final List<QsaModel>? qsa,
    final String? logradouro,
    final String? numero,
    final String? complemento,
    final String? municipio,
    final String? bairro,
    final String? uf,
    final String? cep,
    final String? email,
    final String? telefone,
    @JsonKey(name: 'data_situacao') final String? dataSituacao,
    final String? cnpj,
    @JsonKey(name: 'ultima_atualizacao') final String? ultimaAtualizacao,
    final String? status,
    final String? efr,
    @JsonKey(name: 'motivo_situacao') final String? motivoSituacao,
    @JsonKey(name: 'situacao_especial') final String? situacaoEspecial,
    @JsonKey(name: 'data_situacao_especial') final String? dataSituacaoEspecial,
    @JsonKey(name: 'capital_social') final String? capitalSocial,
    final BillingModel? billing,
    @JsonKey(name: 'dt_save') final String? dtSave,
    final String? message,
  }) = _$CnpjModelImpl;

  factory _CnpjModel.fromJson(Map<String, dynamic> json) =
      _$CnpjModelImpl.fromJson;

  @override
  String? get abertura;
  @override
  String? get situacao;
  @override
  String? get tipo;
  @override
  String? get nome;
  @override
  String? get fantasia;
  @override
  String? get porte;
  @override
  @JsonKey(name: 'natureza_juridica')
  String? get naturezaJuridica;
  @override
  @JsonKey(name: 'atividade_principal')
  List<AtividadeModel>? get atividadePrincipal;
  @override
  @JsonKey(name: 'atividades_secundarias')
  List<AtividadeModel>? get atividadesSecundarias;
  @override
  List<QsaModel>? get qsa;
  @override
  String? get logradouro;
  @override
  String? get numero;
  @override
  String? get complemento;
  @override
  String? get municipio;
  @override
  String? get bairro;
  @override
  String? get uf;
  @override
  String? get cep;
  @override
  String? get email;
  @override
  String? get telefone;
  @override
  @JsonKey(name: 'data_situacao')
  String? get dataSituacao;
  @override
  String? get cnpj;
  @override
  @JsonKey(name: 'ultima_atualizacao')
  String? get ultimaAtualizacao;
  @override
  String? get status;
  @override
  String? get efr;
  @override
  @JsonKey(name: 'motivo_situacao')
  String? get motivoSituacao;
  @override
  @JsonKey(name: 'situacao_especial')
  String? get situacaoEspecial;
  @override
  @JsonKey(name: 'data_situacao_especial')
  String? get dataSituacaoEspecial;
  @override
  @JsonKey(name: 'capital_social')
  String? get capitalSocial;
  @override
  BillingModel? get billing;
  @override
  @JsonKey(name: 'dt_save')
  String? get dtSave;
  @override
  String? get message;

  /// Create a copy of CnpjModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CnpjModelImplCopyWith<_$CnpjModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:consulta_cnpj_new/domain/models/atividade_model.dart';

part 'cnpj_model.freezed.dart';
part 'cnpj_model.g.dart';

@freezed
class CnpjModel with _$CnpjModel {
  const factory CnpjModel({
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
  }) = _CnpjModel;

  factory CnpjModel.fromJson(Map<String, dynamic> json) =>
      _$CnpjModelFromJson(json);
}

extension CnpjModelX on CnpjModel {
  String get fullAddress {
    final parts = [
      logradouro,
      numero,
      complemento,
      bairro,
      municipio,
      uf,
      cep,
    ].where((p) => p != null && p.isNotEmpty).join(', ');
    return parts;
  }
}

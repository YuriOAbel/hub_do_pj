// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cnpj_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CnpjModelImpl _$$CnpjModelImplFromJson(Map<String, dynamic> json) =>
    _$CnpjModelImpl(
      abertura: json['abertura'] as String?,
      situacao: json['situacao'] as String?,
      tipo: json['tipo'] as String?,
      nome: json['nome'] as String?,
      fantasia: json['fantasia'] as String?,
      porte: json['porte'] as String?,
      naturezaJuridica: json['natureza_juridica'] as String?,
      atividadePrincipal: (json['atividade_principal'] as List<dynamic>?)
          ?.map((e) => AtividadeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      atividadesSecundarias: (json['atividades_secundarias'] as List<dynamic>?)
          ?.map((e) => AtividadeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      qsa: (json['qsa'] as List<dynamic>?)
          ?.map((e) => QsaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      logradouro: json['logradouro'] as String?,
      numero: json['numero'] as String?,
      complemento: json['complemento'] as String?,
      municipio: json['municipio'] as String?,
      bairro: json['bairro'] as String?,
      uf: json['uf'] as String?,
      cep: json['cep'] as String?,
      email: json['email'] as String?,
      telefone: json['telefone'] as String?,
      dataSituacao: json['data_situacao'] as String?,
      cnpj: json['cnpj'] as String?,
      ultimaAtualizacao: json['ultima_atualizacao'] as String?,
      status: json['status'] as String?,
      efr: json['efr'] as String?,
      motivoSituacao: json['motivo_situacao'] as String?,
      situacaoEspecial: json['situacao_especial'] as String?,
      dataSituacaoEspecial: json['data_situacao_especial'] as String?,
      capitalSocial: json['capital_social'] as String?,
      billing: json['billing'] == null
          ? null
          : BillingModel.fromJson(json['billing'] as Map<String, dynamic>),
      dtSave: json['dt_save'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$CnpjModelImplToJson(_$CnpjModelImpl instance) =>
    <String, dynamic>{
      'abertura': instance.abertura,
      'situacao': instance.situacao,
      'tipo': instance.tipo,
      'nome': instance.nome,
      'fantasia': instance.fantasia,
      'porte': instance.porte,
      'natureza_juridica': instance.naturezaJuridica,
      'atividade_principal': instance.atividadePrincipal,
      'atividades_secundarias': instance.atividadesSecundarias,
      'qsa': instance.qsa,
      'logradouro': instance.logradouro,
      'numero': instance.numero,
      'complemento': instance.complemento,
      'municipio': instance.municipio,
      'bairro': instance.bairro,
      'uf': instance.uf,
      'cep': instance.cep,
      'email': instance.email,
      'telefone': instance.telefone,
      'data_situacao': instance.dataSituacao,
      'cnpj': instance.cnpj,
      'ultima_atualizacao': instance.ultimaAtualizacao,
      'status': instance.status,
      'efr': instance.efr,
      'motivo_situacao': instance.motivoSituacao,
      'situacao_especial': instance.situacaoEspecial,
      'data_situacao_especial': instance.dataSituacaoEspecial,
      'capital_social': instance.capitalSocial,
      'billing': instance.billing,
      'dt_save': instance.dtSave,
      'message': instance.message,
    };

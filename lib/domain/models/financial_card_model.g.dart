// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FinancialCardModelImpl _$$FinancialCardModelImplFromJson(
  Map<String, dynamic> json,
) => _$FinancialCardModelImpl(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  logo: json['logo'] as String?,
  active: json['active'] as bool?,
  destaque: json['destaque'] as bool?,
  linkExterno: json['link_externo'] as String?,
  rendaMinima: json['renda_minima'] as String?,
  tipo: json['tipo'] as String?,
  bandeira: json['bandeira'] as String?,
  anuidade: json['anuidade'] as String?,
  demaisAnuidade: json['demais_anuidade'] as String?,
  diferencial: json['diferencial'] as String?,
  beneficios: json['beneficios'] as String?,
  createdAt: json['created_at'] as String?,
  externalId: json['external_id'] as String?,
  categoria: json['categoria'] as String?,
  categoriaId: (json['categoria_id'] as num?)?.toInt(),
  categoriaString: json['categoria_string'] as String?,
);

Map<String, dynamic> _$$FinancialCardModelImplToJson(
  _$FinancialCardModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'logo': instance.logo,
  'active': instance.active,
  'destaque': instance.destaque,
  'link_externo': instance.linkExterno,
  'renda_minima': instance.rendaMinima,
  'tipo': instance.tipo,
  'bandeira': instance.bandeira,
  'anuidade': instance.anuidade,
  'demais_anuidade': instance.demaisAnuidade,
  'diferencial': instance.diferencial,
  'beneficios': instance.beneficios,
  'created_at': instance.createdAt,
  'external_id': instance.externalId,
  'categoria': instance.categoria,
  'categoria_id': instance.categoriaId,
  'categoria_string': instance.categoriaString,
};

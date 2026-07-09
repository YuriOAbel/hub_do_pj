// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nome_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NomeModelImpl _$$NomeModelImplFromJson(Map<String, dynamic> json) =>
    _$NomeModelImpl(
      cnpj: json['cnpj'] as String?,
      nomeFantasia: json['fantasia'] as String?,
      razaoSocial: json['razao_social'] as String?,
    );

Map<String, dynamic> _$$NomeModelImplToJson(_$NomeModelImpl instance) =>
    <String, dynamic>{
      'cnpj': instance.cnpj,
      'fantasia': instance.nomeFantasia,
      'razao_social': instance.razaoSocial,
    };

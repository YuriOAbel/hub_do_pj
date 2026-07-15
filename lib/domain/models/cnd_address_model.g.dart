// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cnd_address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CndAddressModelImpl _$$CndAddressModelImplFromJson(
  Map<String, dynamic> json,
) => _$CndAddressModelImpl(
  cep: json['cep'] as String? ?? '',
  logradouro: json['logradouro'] as String? ?? '',
  numero: json['numero'] as String? ?? '',
  complemento: json['complemento'] as String?,
  bairro: json['bairro'] as String? ?? '',
  cidade: json['cidade'] as String? ?? '',
  uf: json['uf'] as String? ?? '',
  telefone: json['telefone'] as String?,
);

Map<String, dynamic> _$$CndAddressModelImplToJson(
  _$CndAddressModelImpl instance,
) => <String, dynamic>{
  'cep': instance.cep,
  'logradouro': instance.logradouro,
  'numero': instance.numero,
  'complemento': instance.complemento,
  'bairro': instance.bairro,
  'cidade': instance.cidade,
  'uf': instance.uf,
  'telefone': instance.telefone,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'atividade_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AtividadeModelImpl _$$AtividadeModelImplFromJson(Map<String, dynamic> json) =>
    _$AtividadeModelImpl(
      code: json['code'] as String?,
      text: json['text'] as String?,
    );

Map<String, dynamic> _$$AtividadeModelImplToJson(
  _$AtividadeModelImpl instance,
) => <String, dynamic>{'code': instance.code, 'text': instance.text};

_$QsaModelImpl _$$QsaModelImplFromJson(Map<String, dynamic> json) =>
    _$QsaModelImpl(
      nome: json['nome'] as String?,
      qual: json['qual'] as String?,
    );

Map<String, dynamic> _$$QsaModelImplToJson(_$QsaModelImpl instance) =>
    <String, dynamic>{'nome': instance.nome, 'qual': instance.qual};

_$BillingModelImpl _$$BillingModelImplFromJson(Map<String, dynamic> json) =>
    _$BillingModelImpl(
      free: json['free'] as bool?,
      database: json['database'] as bool?,
    );

Map<String, dynamic> _$$BillingModelImplToJson(_$BillingModelImpl instance) =>
    <String, dynamic>{'free': instance.free, 'database': instance.database};

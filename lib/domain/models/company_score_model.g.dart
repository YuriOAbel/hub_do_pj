// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_score_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompanyScoreResultImpl _$$CompanyScoreResultImplFromJson(
  Map<String, dynamic> json,
) => _$CompanyScoreResultImpl(
  id: json['id'] as String,
  profileId: json['profileId'] as String?,
  cnpj: json['cnpj'] as String,
  companyName: json['companyName'] as String?,
  answers:
      json['answers'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  score: (json['score'] as num).toInt(),
  band: json['band'] as String,
  gaps:
      (json['gaps'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$$CompanyScoreResultImplToJson(
  _$CompanyScoreResultImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'profileId': instance.profileId,
  'cnpj': instance.cnpj,
  'companyName': instance.companyName,
  'answers': instance.answers,
  'score': instance.score,
  'band': instance.band,
  'gaps': instance.gaps,
  'createdAt': instance.createdAt,
};

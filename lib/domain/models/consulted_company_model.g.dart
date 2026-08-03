// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consulted_company_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConsultedCompanyModelImpl _$$ConsultedCompanyModelImplFromJson(
  Map<String, dynamic> json,
) => _$ConsultedCompanyModelImpl(
  id: json['id'] as String,
  profileId: json['profileId'] as String,
  cnpjDigits: json['cnpjDigits'] as String,
  companyName: json['companyName'] as String,
  situacao: json['situacao'] as String?,
  fantasia: json['fantasia'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
  lastConsultedAt: json['lastConsultedAt'] as String,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String?,
  orders:
      (json['orders'] as List<dynamic>?)
          ?.map((e) => CndOrderModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ConsultedCompanyModelImplToJson(
  _$ConsultedCompanyModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'profileId': instance.profileId,
  'cnpjDigits': instance.cnpjDigits,
  'companyName': instance.companyName,
  'situacao': instance.situacao,
  'fantasia': instance.fantasia,
  'metadata': instance.metadata,
  'lastConsultedAt': instance.lastConsultedAt,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'orders': instance.orders,
};

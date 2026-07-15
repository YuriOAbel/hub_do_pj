// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cnd_order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CndOrderModelImpl _$$CndOrderModelImplFromJson(Map<String, dynamic> json) =>
    _$CndOrderModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      guestEmail: json['guestEmail'] as String,
      guestPhone: json['guestPhone'] as String?,
      productId: json['productId'] as String,
      selectedProductIds: (json['selectedProductIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      totalCents: (json['totalCents'] as num?)?.toInt(),
      cnpj: json['cnpj'] as String,
      companyName: json['companyName'] as String,
      address: json['address'] == null
          ? null
          : CndAddressModel.fromJson(json['address'] as Map<String, dynamic>),
      status: json['status'] as String,
      paymentStatus: json['paymentStatus'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$$CndOrderModelImplToJson(_$CndOrderModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'guestEmail': instance.guestEmail,
      'guestPhone': instance.guestPhone,
      'productId': instance.productId,
      'selectedProductIds': instance.selectedProductIds,
      'totalCents': instance.totalCents,
      'cnpj': instance.cnpj,
      'companyName': instance.companyName,
      'address': instance.address,
      'status': instance.status,
      'paymentStatus': instance.paymentStatus,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

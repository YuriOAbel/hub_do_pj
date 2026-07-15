// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppNotificationModelImpl _$$AppNotificationModelImplFromJson(
  Map<String, dynamic> json,
) => _$AppNotificationModelImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  type: json['type'] as String? ?? 'content',
  route: json['route'] as String?,
  productKind: json['productKind'] as String?,
  read: json['read'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$AppNotificationModelImplToJson(
  _$AppNotificationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'body': instance.body,
  'type': instance.type,
  'route': instance.route,
  'productKind': instance.productKind,
  'read': instance.read,
  'createdAt': instance.createdAt.toIso8601String(),
};

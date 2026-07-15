// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cnd_catalog_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CndCertificateItemImpl _$$CndCertificateItemImplFromJson(
  Map<String, dynamic> json,
) => _$CndCertificateItemImpl(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String,
  subtitle: json['subtitle'] as String?,
);

Map<String, dynamic> _$$CndCertificateItemImplToJson(
  _$CndCertificateItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'subtitle': instance.subtitle,
};

_$CndCatalogProductImpl _$$CndCatalogProductImplFromJson(
  Map<String, dynamic> json,
) => _$CndCatalogProductImpl(
  id: json['id'] as String,
  kind: json['kind'] as String,
  name: json['name'] as String,
  shortLabel: json['shortLabel'] as String,
  priceCents: (json['priceCents'] as num).toInt(),
);

Map<String, dynamic> _$$CndCatalogProductImplToJson(
  _$CndCatalogProductImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'kind': instance.kind,
  'name': instance.name,
  'shortLabel': instance.shortLabel,
  'priceCents': instance.priceCents,
};

_$CndCatalogModelImpl _$$CndCatalogModelImplFromJson(
  Map<String, dynamic> json,
) => _$CndCatalogModelImpl(
  packageId: json['packageId'] as String,
  packageName: json['packageName'] as String,
  whatsappNumber: json['whatsappNumber'] as String,
  defaultKind: json['defaultKind'] as String? ?? 'cnd',
  products:
      (json['products'] as List<dynamic>?)
          ?.map((e) => CndCatalogProduct.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  certificates:
      (json['certificates'] as List<dynamic>?)
          ?.map((e) => CndCertificateItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$CndCatalogModelImplToJson(
  _$CndCatalogModelImpl instance,
) => <String, dynamic>{
  'packageId': instance.packageId,
  'packageName': instance.packageName,
  'whatsappNumber': instance.whatsappNumber,
  'defaultKind': instance.defaultKind,
  'products': instance.products,
  'certificates': instance.certificates,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BannerConfigModelImpl _$$BannerConfigModelImplFromJson(
  Map<String, dynamic> json,
) => _$BannerConfigModelImpl(
  imageUrl: json['image_url'] as String?,
  url: json['url'] as String?,
  key: json['key'] as String?,
);

Map<String, dynamic> _$$BannerConfigModelImplToJson(
  _$BannerConfigModelImpl instance,
) => <String, dynamic>{
  'image_url': instance.imageUrl,
  'url': instance.url,
  'key': instance.key,
};

_$AppRemoteConfigModelImpl _$$AppRemoteConfigModelImplFromJson(
  Map<String, dynamic> json,
) => _$AppRemoteConfigModelImpl(
  activateSmartlook: json['activate_smartlook'] as bool? ?? false,
  prospecting: json['prospecting'] as bool? ?? false,
  restriction: json['restriction'] as bool? ?? false,
  searchAdvanced: json['search_advanced'] as bool? ?? false,
  enableBanner: json['enable_banner'] as bool? ?? false,
  enableSearchNamed: json['enable_search_named'] as bool? ?? true,
  banners: json['banners'] as String? ?? '{"imgs":[]}',
  secondsAds: (json['seconds_ads'] as num?)?.toInt() ?? 60,
);

Map<String, dynamic> _$$AppRemoteConfigModelImplToJson(
  _$AppRemoteConfigModelImpl instance,
) => <String, dynamic>{
  'activate_smartlook': instance.activateSmartlook,
  'prospecting': instance.prospecting,
  'restriction': instance.restriction,
  'search_advanced': instance.searchAdvanced,
  'enable_banner': instance.enableBanner,
  'enable_search_named': instance.enableSearchNamed,
  'banners': instance.banners,
  'seconds_ads': instance.secondsAds,
};

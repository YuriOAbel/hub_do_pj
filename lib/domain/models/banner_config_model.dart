import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner_config_model.freezed.dart';
part 'banner_config_model.g.dart';

@freezed
class BannerConfigModel with _$BannerConfigModel {
  const factory BannerConfigModel({
    @JsonKey(name: 'image_url') String? imageUrl,
    String? url,
    String? key,
  }) = _BannerConfigModel;

  factory BannerConfigModel.fromJson(Map<String, dynamic> json) =>
      _$BannerConfigModelFromJson(json);
}

@freezed
class AppRemoteConfigModel with _$AppRemoteConfigModel {
  const factory AppRemoteConfigModel({
    @JsonKey(name: 'activate_smartlook') @Default(false) bool activateSmartlook,
    @Default(false) bool prospecting,
    @Default(false) bool restriction,
    @JsonKey(name: 'search_advanced') @Default(false) bool searchAdvanced,
    @JsonKey(name: 'enable_banner') @Default(false) bool enableBanner,
    @JsonKey(name: 'enable_search_named') @Default(true) bool enableSearchNamed,
    @Default('{"imgs":[]}') String banners,
    @JsonKey(name: 'seconds_ads') @Default(60) int secondsAds,
  }) = _AppRemoteConfigModel;

  factory AppRemoteConfigModel.fromJson(Map<String, dynamic> json) =>
      _$AppRemoteConfigModelFromJson(json);

  static const defaultConfig = AppRemoteConfigModel();
}

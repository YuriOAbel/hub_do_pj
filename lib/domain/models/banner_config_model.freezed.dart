// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'banner_config_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BannerConfigModel _$BannerConfigModelFromJson(Map<String, dynamic> json) {
  return _BannerConfigModel.fromJson(json);
}

/// @nodoc
mixin _$BannerConfigModel {
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  String? get key => throw _privateConstructorUsedError;

  /// Serializes this BannerConfigModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BannerConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BannerConfigModelCopyWith<BannerConfigModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BannerConfigModelCopyWith<$Res> {
  factory $BannerConfigModelCopyWith(
    BannerConfigModel value,
    $Res Function(BannerConfigModel) then,
  ) = _$BannerConfigModelCopyWithImpl<$Res, BannerConfigModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'image_url') String? imageUrl,
    String? url,
    String? key,
  });
}

/// @nodoc
class _$BannerConfigModelCopyWithImpl<$Res, $Val extends BannerConfigModel>
    implements $BannerConfigModelCopyWith<$Res> {
  _$BannerConfigModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BannerConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageUrl = freezed,
    Object? url = freezed,
    Object? key = freezed,
  }) {
    return _then(
      _value.copyWith(
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            url: freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String?,
            key: freezed == key
                ? _value.key
                : key // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BannerConfigModelImplCopyWith<$Res>
    implements $BannerConfigModelCopyWith<$Res> {
  factory _$$BannerConfigModelImplCopyWith(
    _$BannerConfigModelImpl value,
    $Res Function(_$BannerConfigModelImpl) then,
  ) = __$$BannerConfigModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'image_url') String? imageUrl,
    String? url,
    String? key,
  });
}

/// @nodoc
class __$$BannerConfigModelImplCopyWithImpl<$Res>
    extends _$BannerConfigModelCopyWithImpl<$Res, _$BannerConfigModelImpl>
    implements _$$BannerConfigModelImplCopyWith<$Res> {
  __$$BannerConfigModelImplCopyWithImpl(
    _$BannerConfigModelImpl _value,
    $Res Function(_$BannerConfigModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BannerConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageUrl = freezed,
    Object? url = freezed,
    Object? key = freezed,
  }) {
    return _then(
      _$BannerConfigModelImpl(
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        url: freezed == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String?,
        key: freezed == key
            ? _value.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BannerConfigModelImpl implements _BannerConfigModel {
  const _$BannerConfigModelImpl({
    @JsonKey(name: 'image_url') this.imageUrl,
    this.url,
    this.key,
  });

  factory _$BannerConfigModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BannerConfigModelImplFromJson(json);

  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  final String? url;
  @override
  final String? key;

  @override
  String toString() {
    return 'BannerConfigModel(imageUrl: $imageUrl, url: $url, key: $key)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BannerConfigModelImpl &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.key, key) || other.key == key));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, imageUrl, url, key);

  /// Create a copy of BannerConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BannerConfigModelImplCopyWith<_$BannerConfigModelImpl> get copyWith =>
      __$$BannerConfigModelImplCopyWithImpl<_$BannerConfigModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BannerConfigModelImplToJson(this);
  }
}

abstract class _BannerConfigModel implements BannerConfigModel {
  const factory _BannerConfigModel({
    @JsonKey(name: 'image_url') final String? imageUrl,
    final String? url,
    final String? key,
  }) = _$BannerConfigModelImpl;

  factory _BannerConfigModel.fromJson(Map<String, dynamic> json) =
      _$BannerConfigModelImpl.fromJson;

  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  String? get url;
  @override
  String? get key;

  /// Create a copy of BannerConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BannerConfigModelImplCopyWith<_$BannerConfigModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AppRemoteConfigModel _$AppRemoteConfigModelFromJson(Map<String, dynamic> json) {
  return _AppRemoteConfigModel.fromJson(json);
}

/// @nodoc
mixin _$AppRemoteConfigModel {
  @JsonKey(name: 'activate_smartlook')
  bool get activateSmartlook => throw _privateConstructorUsedError;
  bool get prospecting => throw _privateConstructorUsedError;
  bool get restriction => throw _privateConstructorUsedError;
  @JsonKey(name: 'search_advanced')
  bool get searchAdvanced => throw _privateConstructorUsedError;
  @JsonKey(name: 'enable_banner')
  bool get enableBanner => throw _privateConstructorUsedError;
  @JsonKey(name: 'enable_search_named')
  bool get enableSearchNamed => throw _privateConstructorUsedError;
  String get banners => throw _privateConstructorUsedError;
  @JsonKey(name: 'seconds_ads')
  int get secondsAds => throw _privateConstructorUsedError;

  /// Serializes this AppRemoteConfigModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppRemoteConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppRemoteConfigModelCopyWith<AppRemoteConfigModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppRemoteConfigModelCopyWith<$Res> {
  factory $AppRemoteConfigModelCopyWith(
    AppRemoteConfigModel value,
    $Res Function(AppRemoteConfigModel) then,
  ) = _$AppRemoteConfigModelCopyWithImpl<$Res, AppRemoteConfigModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'activate_smartlook') bool activateSmartlook,
    bool prospecting,
    bool restriction,
    @JsonKey(name: 'search_advanced') bool searchAdvanced,
    @JsonKey(name: 'enable_banner') bool enableBanner,
    @JsonKey(name: 'enable_search_named') bool enableSearchNamed,
    String banners,
    @JsonKey(name: 'seconds_ads') int secondsAds,
  });
}

/// @nodoc
class _$AppRemoteConfigModelCopyWithImpl<
  $Res,
  $Val extends AppRemoteConfigModel
>
    implements $AppRemoteConfigModelCopyWith<$Res> {
  _$AppRemoteConfigModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppRemoteConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activateSmartlook = null,
    Object? prospecting = null,
    Object? restriction = null,
    Object? searchAdvanced = null,
    Object? enableBanner = null,
    Object? enableSearchNamed = null,
    Object? banners = null,
    Object? secondsAds = null,
  }) {
    return _then(
      _value.copyWith(
            activateSmartlook: null == activateSmartlook
                ? _value.activateSmartlook
                : activateSmartlook // ignore: cast_nullable_to_non_nullable
                      as bool,
            prospecting: null == prospecting
                ? _value.prospecting
                : prospecting // ignore: cast_nullable_to_non_nullable
                      as bool,
            restriction: null == restriction
                ? _value.restriction
                : restriction // ignore: cast_nullable_to_non_nullable
                      as bool,
            searchAdvanced: null == searchAdvanced
                ? _value.searchAdvanced
                : searchAdvanced // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableBanner: null == enableBanner
                ? _value.enableBanner
                : enableBanner // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableSearchNamed: null == enableSearchNamed
                ? _value.enableSearchNamed
                : enableSearchNamed // ignore: cast_nullable_to_non_nullable
                      as bool,
            banners: null == banners
                ? _value.banners
                : banners // ignore: cast_nullable_to_non_nullable
                      as String,
            secondsAds: null == secondsAds
                ? _value.secondsAds
                : secondsAds // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppRemoteConfigModelImplCopyWith<$Res>
    implements $AppRemoteConfigModelCopyWith<$Res> {
  factory _$$AppRemoteConfigModelImplCopyWith(
    _$AppRemoteConfigModelImpl value,
    $Res Function(_$AppRemoteConfigModelImpl) then,
  ) = __$$AppRemoteConfigModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'activate_smartlook') bool activateSmartlook,
    bool prospecting,
    bool restriction,
    @JsonKey(name: 'search_advanced') bool searchAdvanced,
    @JsonKey(name: 'enable_banner') bool enableBanner,
    @JsonKey(name: 'enable_search_named') bool enableSearchNamed,
    String banners,
    @JsonKey(name: 'seconds_ads') int secondsAds,
  });
}

/// @nodoc
class __$$AppRemoteConfigModelImplCopyWithImpl<$Res>
    extends _$AppRemoteConfigModelCopyWithImpl<$Res, _$AppRemoteConfigModelImpl>
    implements _$$AppRemoteConfigModelImplCopyWith<$Res> {
  __$$AppRemoteConfigModelImplCopyWithImpl(
    _$AppRemoteConfigModelImpl _value,
    $Res Function(_$AppRemoteConfigModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppRemoteConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activateSmartlook = null,
    Object? prospecting = null,
    Object? restriction = null,
    Object? searchAdvanced = null,
    Object? enableBanner = null,
    Object? enableSearchNamed = null,
    Object? banners = null,
    Object? secondsAds = null,
  }) {
    return _then(
      _$AppRemoteConfigModelImpl(
        activateSmartlook: null == activateSmartlook
            ? _value.activateSmartlook
            : activateSmartlook // ignore: cast_nullable_to_non_nullable
                  as bool,
        prospecting: null == prospecting
            ? _value.prospecting
            : prospecting // ignore: cast_nullable_to_non_nullable
                  as bool,
        restriction: null == restriction
            ? _value.restriction
            : restriction // ignore: cast_nullable_to_non_nullable
                  as bool,
        searchAdvanced: null == searchAdvanced
            ? _value.searchAdvanced
            : searchAdvanced // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableBanner: null == enableBanner
            ? _value.enableBanner
            : enableBanner // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableSearchNamed: null == enableSearchNamed
            ? _value.enableSearchNamed
            : enableSearchNamed // ignore: cast_nullable_to_non_nullable
                  as bool,
        banners: null == banners
            ? _value.banners
            : banners // ignore: cast_nullable_to_non_nullable
                  as String,
        secondsAds: null == secondsAds
            ? _value.secondsAds
            : secondsAds // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppRemoteConfigModelImpl implements _AppRemoteConfigModel {
  const _$AppRemoteConfigModelImpl({
    @JsonKey(name: 'activate_smartlook') this.activateSmartlook = false,
    this.prospecting = false,
    this.restriction = false,
    @JsonKey(name: 'search_advanced') this.searchAdvanced = false,
    @JsonKey(name: 'enable_banner') this.enableBanner = false,
    @JsonKey(name: 'enable_search_named') this.enableSearchNamed = true,
    this.banners = '{"imgs":[]}',
    @JsonKey(name: 'seconds_ads') this.secondsAds = 60,
  });

  factory _$AppRemoteConfigModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppRemoteConfigModelImplFromJson(json);

  @override
  @JsonKey(name: 'activate_smartlook')
  final bool activateSmartlook;
  @override
  @JsonKey()
  final bool prospecting;
  @override
  @JsonKey()
  final bool restriction;
  @override
  @JsonKey(name: 'search_advanced')
  final bool searchAdvanced;
  @override
  @JsonKey(name: 'enable_banner')
  final bool enableBanner;
  @override
  @JsonKey(name: 'enable_search_named')
  final bool enableSearchNamed;
  @override
  @JsonKey()
  final String banners;
  @override
  @JsonKey(name: 'seconds_ads')
  final int secondsAds;

  @override
  String toString() {
    return 'AppRemoteConfigModel(activateSmartlook: $activateSmartlook, prospecting: $prospecting, restriction: $restriction, searchAdvanced: $searchAdvanced, enableBanner: $enableBanner, enableSearchNamed: $enableSearchNamed, banners: $banners, secondsAds: $secondsAds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppRemoteConfigModelImpl &&
            (identical(other.activateSmartlook, activateSmartlook) ||
                other.activateSmartlook == activateSmartlook) &&
            (identical(other.prospecting, prospecting) ||
                other.prospecting == prospecting) &&
            (identical(other.restriction, restriction) ||
                other.restriction == restriction) &&
            (identical(other.searchAdvanced, searchAdvanced) ||
                other.searchAdvanced == searchAdvanced) &&
            (identical(other.enableBanner, enableBanner) ||
                other.enableBanner == enableBanner) &&
            (identical(other.enableSearchNamed, enableSearchNamed) ||
                other.enableSearchNamed == enableSearchNamed) &&
            (identical(other.banners, banners) || other.banners == banners) &&
            (identical(other.secondsAds, secondsAds) ||
                other.secondsAds == secondsAds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    activateSmartlook,
    prospecting,
    restriction,
    searchAdvanced,
    enableBanner,
    enableSearchNamed,
    banners,
    secondsAds,
  );

  /// Create a copy of AppRemoteConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppRemoteConfigModelImplCopyWith<_$AppRemoteConfigModelImpl>
  get copyWith =>
      __$$AppRemoteConfigModelImplCopyWithImpl<_$AppRemoteConfigModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AppRemoteConfigModelImplToJson(this);
  }
}

abstract class _AppRemoteConfigModel implements AppRemoteConfigModel {
  const factory _AppRemoteConfigModel({
    @JsonKey(name: 'activate_smartlook') final bool activateSmartlook,
    final bool prospecting,
    final bool restriction,
    @JsonKey(name: 'search_advanced') final bool searchAdvanced,
    @JsonKey(name: 'enable_banner') final bool enableBanner,
    @JsonKey(name: 'enable_search_named') final bool enableSearchNamed,
    final String banners,
    @JsonKey(name: 'seconds_ads') final int secondsAds,
  }) = _$AppRemoteConfigModelImpl;

  factory _AppRemoteConfigModel.fromJson(Map<String, dynamic> json) =
      _$AppRemoteConfigModelImpl.fromJson;

  @override
  @JsonKey(name: 'activate_smartlook')
  bool get activateSmartlook;
  @override
  bool get prospecting;
  @override
  bool get restriction;
  @override
  @JsonKey(name: 'search_advanced')
  bool get searchAdvanced;
  @override
  @JsonKey(name: 'enable_banner')
  bool get enableBanner;
  @override
  @JsonKey(name: 'enable_search_named')
  bool get enableSearchNamed;
  @override
  String get banners;
  @override
  @JsonKey(name: 'seconds_ads')
  int get secondsAds;

  /// Create a copy of AppRemoteConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppRemoteConfigModelImplCopyWith<_$AppRemoteConfigModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plan_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PlanModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get priceText => throw _privateConstructorUsedError;
  bool get isSelected => throw _privateConstructorUsedError;
  String? get trialInfoText => throw _privateConstructorUsedError;
  int get tier => throw _privateConstructorUsedError;
  String? get badgeText => throw _privateConstructorUsedError;
  String? get subtitle => throw _privateConstructorUsedError;

  /// Billing period suffix from RC (`/mês`, `/ano`).
  String? get periodLabel => throw _privateConstructorUsedError;

  /// Store product identifier (RevenueCat `StoreProduct.identifier`).
  String? get productId => throw _privateConstructorUsedError;

  /// Numeric price from store (`StoreProduct.price`) for analytics.
  double get price => throw _privateConstructorUsedError;

  /// ISO currency code (`StoreProduct.currencyCode`), default BRL.
  String get currencyCode => throw _privateConstructorUsedError;

  /// Create a copy of PlanModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanModelCopyWith<PlanModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanModelCopyWith<$Res> {
  factory $PlanModelCopyWith(PlanModel value, $Res Function(PlanModel) then) =
      _$PlanModelCopyWithImpl<$Res, PlanModel>;
  @useResult
  $Res call({
    String id,
    String title,
    String priceText,
    bool isSelected,
    String? trialInfoText,
    int tier,
    String? badgeText,
    String? subtitle,
    String? periodLabel,
    String? productId,
    double price,
    String currencyCode,
  });
}

/// @nodoc
class _$PlanModelCopyWithImpl<$Res, $Val extends PlanModel>
    implements $PlanModelCopyWith<$Res> {
  _$PlanModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? priceText = null,
    Object? isSelected = null,
    Object? trialInfoText = freezed,
    Object? tier = null,
    Object? badgeText = freezed,
    Object? subtitle = freezed,
    Object? periodLabel = freezed,
    Object? productId = freezed,
    Object? price = null,
    Object? currencyCode = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            priceText: null == priceText
                ? _value.priceText
                : priceText // ignore: cast_nullable_to_non_nullable
                      as String,
            isSelected: null == isSelected
                ? _value.isSelected
                : isSelected // ignore: cast_nullable_to_non_nullable
                      as bool,
            trialInfoText: freezed == trialInfoText
                ? _value.trialInfoText
                : trialInfoText // ignore: cast_nullable_to_non_nullable
                      as String?,
            tier: null == tier
                ? _value.tier
                : tier // ignore: cast_nullable_to_non_nullable
                      as int,
            badgeText: freezed == badgeText
                ? _value.badgeText
                : badgeText // ignore: cast_nullable_to_non_nullable
                      as String?,
            subtitle: freezed == subtitle
                ? _value.subtitle
                : subtitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            periodLabel: freezed == periodLabel
                ? _value.periodLabel
                : periodLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
            productId: freezed == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String?,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            currencyCode: null == currencyCode
                ? _value.currencyCode
                : currencyCode // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlanModelImplCopyWith<$Res>
    implements $PlanModelCopyWith<$Res> {
  factory _$$PlanModelImplCopyWith(
    _$PlanModelImpl value,
    $Res Function(_$PlanModelImpl) then,
  ) = __$$PlanModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String priceText,
    bool isSelected,
    String? trialInfoText,
    int tier,
    String? badgeText,
    String? subtitle,
    String? periodLabel,
    String? productId,
    double price,
    String currencyCode,
  });
}

/// @nodoc
class __$$PlanModelImplCopyWithImpl<$Res>
    extends _$PlanModelCopyWithImpl<$Res, _$PlanModelImpl>
    implements _$$PlanModelImplCopyWith<$Res> {
  __$$PlanModelImplCopyWithImpl(
    _$PlanModelImpl _value,
    $Res Function(_$PlanModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlanModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? priceText = null,
    Object? isSelected = null,
    Object? trialInfoText = freezed,
    Object? tier = null,
    Object? badgeText = freezed,
    Object? subtitle = freezed,
    Object? periodLabel = freezed,
    Object? productId = freezed,
    Object? price = null,
    Object? currencyCode = null,
  }) {
    return _then(
      _$PlanModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        priceText: null == priceText
            ? _value.priceText
            : priceText // ignore: cast_nullable_to_non_nullable
                  as String,
        isSelected: null == isSelected
            ? _value.isSelected
            : isSelected // ignore: cast_nullable_to_non_nullable
                  as bool,
        trialInfoText: freezed == trialInfoText
            ? _value.trialInfoText
            : trialInfoText // ignore: cast_nullable_to_non_nullable
                  as String?,
        tier: null == tier
            ? _value.tier
            : tier // ignore: cast_nullable_to_non_nullable
                  as int,
        badgeText: freezed == badgeText
            ? _value.badgeText
            : badgeText // ignore: cast_nullable_to_non_nullable
                  as String?,
        subtitle: freezed == subtitle
            ? _value.subtitle
            : subtitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        periodLabel: freezed == periodLabel
            ? _value.periodLabel
            : periodLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
        productId: freezed == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String?,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        currencyCode: null == currencyCode
            ? _value.currencyCode
            : currencyCode // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$PlanModelImpl implements _PlanModel {
  const _$PlanModelImpl({
    required this.id,
    required this.title,
    required this.priceText,
    this.isSelected = false,
    this.trialInfoText,
    this.tier = 1,
    this.badgeText,
    this.subtitle,
    this.periodLabel,
    this.productId,
    this.price = 0,
    this.currencyCode = 'BRL',
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String priceText;
  @override
  @JsonKey()
  final bool isSelected;
  @override
  final String? trialInfoText;
  @override
  @JsonKey()
  final int tier;
  @override
  final String? badgeText;
  @override
  final String? subtitle;

  /// Billing period suffix from RC (`/mês`, `/ano`).
  @override
  final String? periodLabel;

  /// Store product identifier (RevenueCat `StoreProduct.identifier`).
  @override
  final String? productId;

  /// Numeric price from store (`StoreProduct.price`) for analytics.
  @override
  @JsonKey()
  final double price;

  /// ISO currency code (`StoreProduct.currencyCode`), default BRL.
  @override
  @JsonKey()
  final String currencyCode;

  @override
  String toString() {
    return 'PlanModel(id: $id, title: $title, priceText: $priceText, isSelected: $isSelected, trialInfoText: $trialInfoText, tier: $tier, badgeText: $badgeText, subtitle: $subtitle, periodLabel: $periodLabel, productId: $productId, price: $price, currencyCode: $currencyCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.priceText, priceText) ||
                other.priceText == priceText) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected) &&
            (identical(other.trialInfoText, trialInfoText) ||
                other.trialInfoText == trialInfoText) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.badgeText, badgeText) ||
                other.badgeText == badgeText) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            (identical(other.periodLabel, periodLabel) ||
                other.periodLabel == periodLabel) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    priceText,
    isSelected,
    trialInfoText,
    tier,
    badgeText,
    subtitle,
    periodLabel,
    productId,
    price,
    currencyCode,
  );

  /// Create a copy of PlanModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanModelImplCopyWith<_$PlanModelImpl> get copyWith =>
      __$$PlanModelImplCopyWithImpl<_$PlanModelImpl>(this, _$identity);
}

abstract class _PlanModel implements PlanModel {
  const factory _PlanModel({
    required final String id,
    required final String title,
    required final String priceText,
    final bool isSelected,
    final String? trialInfoText,
    final int tier,
    final String? badgeText,
    final String? subtitle,
    final String? periodLabel,
    final String? productId,
    final double price,
    final String currencyCode,
  }) = _$PlanModelImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  String get priceText;
  @override
  bool get isSelected;
  @override
  String? get trialInfoText;
  @override
  int get tier;
  @override
  String? get badgeText;
  @override
  String? get subtitle;

  /// Billing period suffix from RC (`/mês`, `/ano`).
  @override
  String? get periodLabel;

  /// Store product identifier (RevenueCat `StoreProduct.identifier`).
  @override
  String? get productId;

  /// Numeric price from store (`StoreProduct.price`) for analytics.
  @override
  double get price;

  /// ISO currency code (`StoreProduct.currencyCode`), default BRL.
  @override
  String get currencyCode;

  /// Create a copy of PlanModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanModelImplCopyWith<_$PlanModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

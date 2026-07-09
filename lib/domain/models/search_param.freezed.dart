// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_param.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SearchParam _$SearchParamFromJson(Map<String, dynamic> json) {
  return _SearchParam.fromJson(json);
}

/// @nodoc
mixin _$SearchParam {
  String get term => throw _privateConstructorUsedError;
  SearchOrigin get origin => throw _privateConstructorUsedError;

  /// Serializes this SearchParam to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchParam
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchParamCopyWith<SearchParam> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchParamCopyWith<$Res> {
  factory $SearchParamCopyWith(
    SearchParam value,
    $Res Function(SearchParam) then,
  ) = _$SearchParamCopyWithImpl<$Res, SearchParam>;
  @useResult
  $Res call({String term, SearchOrigin origin});
}

/// @nodoc
class _$SearchParamCopyWithImpl<$Res, $Val extends SearchParam>
    implements $SearchParamCopyWith<$Res> {
  _$SearchParamCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchParam
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? term = null, Object? origin = null}) {
    return _then(
      _value.copyWith(
            term: null == term
                ? _value.term
                : term // ignore: cast_nullable_to_non_nullable
                      as String,
            origin: null == origin
                ? _value.origin
                : origin // ignore: cast_nullable_to_non_nullable
                      as SearchOrigin,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchParamImplCopyWith<$Res>
    implements $SearchParamCopyWith<$Res> {
  factory _$$SearchParamImplCopyWith(
    _$SearchParamImpl value,
    $Res Function(_$SearchParamImpl) then,
  ) = __$$SearchParamImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String term, SearchOrigin origin});
}

/// @nodoc
class __$$SearchParamImplCopyWithImpl<$Res>
    extends _$SearchParamCopyWithImpl<$Res, _$SearchParamImpl>
    implements _$$SearchParamImplCopyWith<$Res> {
  __$$SearchParamImplCopyWithImpl(
    _$SearchParamImpl _value,
    $Res Function(_$SearchParamImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchParam
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? term = null, Object? origin = null}) {
    return _then(
      _$SearchParamImpl(
        term: null == term
            ? _value.term
            : term // ignore: cast_nullable_to_non_nullable
                  as String,
        origin: null == origin
            ? _value.origin
            : origin // ignore: cast_nullable_to_non_nullable
                  as SearchOrigin,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchParamImpl implements _SearchParam {
  const _$SearchParamImpl({
    required this.term,
    this.origin = SearchOrigin.home,
  });

  factory _$SearchParamImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchParamImplFromJson(json);

  @override
  final String term;
  @override
  @JsonKey()
  final SearchOrigin origin;

  @override
  String toString() {
    return 'SearchParam(term: $term, origin: $origin)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchParamImpl &&
            (identical(other.term, term) || other.term == term) &&
            (identical(other.origin, origin) || other.origin == origin));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, term, origin);

  /// Create a copy of SearchParam
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchParamImplCopyWith<_$SearchParamImpl> get copyWith =>
      __$$SearchParamImplCopyWithImpl<_$SearchParamImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchParamImplToJson(this);
  }
}

abstract class _SearchParam implements SearchParam {
  const factory _SearchParam({
    required final String term,
    final SearchOrigin origin,
  }) = _$SearchParamImpl;

  factory _SearchParam.fromJson(Map<String, dynamic> json) =
      _$SearchParamImpl.fromJson;

  @override
  String get term;
  @override
  SearchOrigin get origin;

  /// Create a copy of SearchParam
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchParamImplCopyWith<_$SearchParamImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'company_score_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CompanyScoreResult _$CompanyScoreResultFromJson(Map<String, dynamic> json) {
  return _CompanyScoreResult.fromJson(json);
}

/// @nodoc
mixin _$CompanyScoreResult {
  String get id => throw _privateConstructorUsedError;
  String? get profileId => throw _privateConstructorUsedError;
  String get cnpj => throw _privateConstructorUsedError;
  String? get companyName => throw _privateConstructorUsedError;
  Map<String, dynamic> get answers => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  String get band => throw _privateConstructorUsedError;
  List<String> get gaps => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CompanyScoreResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CompanyScoreResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompanyScoreResultCopyWith<CompanyScoreResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompanyScoreResultCopyWith<$Res> {
  factory $CompanyScoreResultCopyWith(
    CompanyScoreResult value,
    $Res Function(CompanyScoreResult) then,
  ) = _$CompanyScoreResultCopyWithImpl<$Res, CompanyScoreResult>;
  @useResult
  $Res call({
    String id,
    String? profileId,
    String cnpj,
    String? companyName,
    Map<String, dynamic> answers,
    int score,
    String band,
    List<String> gaps,
    String createdAt,
  });
}

/// @nodoc
class _$CompanyScoreResultCopyWithImpl<$Res, $Val extends CompanyScoreResult>
    implements $CompanyScoreResultCopyWith<$Res> {
  _$CompanyScoreResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompanyScoreResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? profileId = freezed,
    Object? cnpj = null,
    Object? companyName = freezed,
    Object? answers = null,
    Object? score = null,
    Object? band = null,
    Object? gaps = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            profileId: freezed == profileId
                ? _value.profileId
                : profileId // ignore: cast_nullable_to_non_nullable
                      as String?,
            cnpj: null == cnpj
                ? _value.cnpj
                : cnpj // ignore: cast_nullable_to_non_nullable
                      as String,
            companyName: freezed == companyName
                ? _value.companyName
                : companyName // ignore: cast_nullable_to_non_nullable
                      as String?,
            answers: null == answers
                ? _value.answers
                : answers // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
            band: null == band
                ? _value.band
                : band // ignore: cast_nullable_to_non_nullable
                      as String,
            gaps: null == gaps
                ? _value.gaps
                : gaps // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CompanyScoreResultImplCopyWith<$Res>
    implements $CompanyScoreResultCopyWith<$Res> {
  factory _$$CompanyScoreResultImplCopyWith(
    _$CompanyScoreResultImpl value,
    $Res Function(_$CompanyScoreResultImpl) then,
  ) = __$$CompanyScoreResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? profileId,
    String cnpj,
    String? companyName,
    Map<String, dynamic> answers,
    int score,
    String band,
    List<String> gaps,
    String createdAt,
  });
}

/// @nodoc
class __$$CompanyScoreResultImplCopyWithImpl<$Res>
    extends _$CompanyScoreResultCopyWithImpl<$Res, _$CompanyScoreResultImpl>
    implements _$$CompanyScoreResultImplCopyWith<$Res> {
  __$$CompanyScoreResultImplCopyWithImpl(
    _$CompanyScoreResultImpl _value,
    $Res Function(_$CompanyScoreResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CompanyScoreResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? profileId = freezed,
    Object? cnpj = null,
    Object? companyName = freezed,
    Object? answers = null,
    Object? score = null,
    Object? band = null,
    Object? gaps = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$CompanyScoreResultImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        profileId: freezed == profileId
            ? _value.profileId
            : profileId // ignore: cast_nullable_to_non_nullable
                  as String?,
        cnpj: null == cnpj
            ? _value.cnpj
            : cnpj // ignore: cast_nullable_to_non_nullable
                  as String,
        companyName: freezed == companyName
            ? _value.companyName
            : companyName // ignore: cast_nullable_to_non_nullable
                  as String?,
        answers: null == answers
            ? _value._answers
            : answers // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        band: null == band
            ? _value.band
            : band // ignore: cast_nullable_to_non_nullable
                  as String,
        gaps: null == gaps
            ? _value._gaps
            : gaps // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CompanyScoreResultImpl extends _CompanyScoreResult {
  const _$CompanyScoreResultImpl({
    required this.id,
    this.profileId,
    required this.cnpj,
    this.companyName,
    final Map<String, dynamic> answers = const <String, dynamic>{},
    required this.score,
    required this.band,
    final List<String> gaps = const <String>[],
    required this.createdAt,
  }) : _answers = answers,
       _gaps = gaps,
       super._();

  factory _$CompanyScoreResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompanyScoreResultImplFromJson(json);

  @override
  final String id;
  @override
  final String? profileId;
  @override
  final String cnpj;
  @override
  final String? companyName;
  final Map<String, dynamic> _answers;
  @override
  @JsonKey()
  Map<String, dynamic> get answers {
    if (_answers is EqualUnmodifiableMapView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_answers);
  }

  @override
  final int score;
  @override
  final String band;
  final List<String> _gaps;
  @override
  @JsonKey()
  List<String> get gaps {
    if (_gaps is EqualUnmodifiableListView) return _gaps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gaps);
  }

  @override
  final String createdAt;

  @override
  String toString() {
    return 'CompanyScoreResult(id: $id, profileId: $profileId, cnpj: $cnpj, companyName: $companyName, answers: $answers, score: $score, band: $band, gaps: $gaps, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompanyScoreResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.profileId, profileId) ||
                other.profileId == profileId) &&
            (identical(other.cnpj, cnpj) || other.cnpj == cnpj) &&
            (identical(other.companyName, companyName) ||
                other.companyName == companyName) &&
            const DeepCollectionEquality().equals(other._answers, _answers) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.band, band) || other.band == band) &&
            const DeepCollectionEquality().equals(other._gaps, _gaps) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    profileId,
    cnpj,
    companyName,
    const DeepCollectionEquality().hash(_answers),
    score,
    band,
    const DeepCollectionEquality().hash(_gaps),
    createdAt,
  );

  /// Create a copy of CompanyScoreResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompanyScoreResultImplCopyWith<_$CompanyScoreResultImpl> get copyWith =>
      __$$CompanyScoreResultImplCopyWithImpl<_$CompanyScoreResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CompanyScoreResultImplToJson(this);
  }
}

abstract class _CompanyScoreResult extends CompanyScoreResult {
  const factory _CompanyScoreResult({
    required final String id,
    final String? profileId,
    required final String cnpj,
    final String? companyName,
    final Map<String, dynamic> answers,
    required final int score,
    required final String band,
    final List<String> gaps,
    required final String createdAt,
  }) = _$CompanyScoreResultImpl;
  const _CompanyScoreResult._() : super._();

  factory _CompanyScoreResult.fromJson(Map<String, dynamic> json) =
      _$CompanyScoreResultImpl.fromJson;

  @override
  String get id;
  @override
  String? get profileId;
  @override
  String get cnpj;
  @override
  String? get companyName;
  @override
  Map<String, dynamic> get answers;
  @override
  int get score;
  @override
  String get band;
  @override
  List<String> get gaps;
  @override
  String get createdAt;

  /// Create a copy of CompanyScoreResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompanyScoreResultImplCopyWith<_$CompanyScoreResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

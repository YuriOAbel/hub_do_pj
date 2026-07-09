// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_param.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SearchParamImpl _$$SearchParamImplFromJson(Map<String, dynamic> json) =>
    _$SearchParamImpl(
      term: json['term'] as String,
      origin:
          $enumDecodeNullable(_$SearchOriginEnumMap, json['origin']) ??
          SearchOrigin.home,
    );

Map<String, dynamic> _$$SearchParamImplToJson(_$SearchParamImpl instance) =>
    <String, dynamic>{
      'term': instance.term,
      'origin': _$SearchOriginEnumMap[instance.origin]!,
    };

const _$SearchOriginEnumMap = {
  SearchOrigin.home: 'home',
  SearchOrigin.advanced: 'advanced',
};

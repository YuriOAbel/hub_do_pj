import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_param.freezed.dart';
part 'search_param.g.dart';

@JsonEnum()
enum SearchOrigin { home, advanced }

@freezed
class SearchParam with _$SearchParam {
  const factory SearchParam({
    required String term,
    @Default(SearchOrigin.home) SearchOrigin origin,
  }) = _SearchParam;

  factory SearchParam.fromJson(Map<String, dynamic> json) =>
      _$SearchParamFromJson(json);
}

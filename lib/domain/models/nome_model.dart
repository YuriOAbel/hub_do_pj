import 'package:freezed_annotation/freezed_annotation.dart';

part 'nome_model.freezed.dart';
part 'nome_model.g.dart';

@freezed
class NomeModel with _$NomeModel {
  const factory NomeModel({
    String? cnpj,
    @JsonKey(name: 'fantasia') String? nomeFantasia,
    @JsonKey(name: 'razao_social') String? razaoSocial,
  }) = _NomeModel;

  factory NomeModel.fromJson(Map<String, dynamic> json) =>
      _$NomeModelFromJson(json);
}

extension NomeModelX on NomeModel {
  String get displayName => nomeFantasia ?? razaoSocial ?? cnpj ?? '';
}

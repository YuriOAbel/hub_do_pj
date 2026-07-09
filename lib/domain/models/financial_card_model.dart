import 'package:freezed_annotation/freezed_annotation.dart';

part 'financial_card_model.freezed.dart';
part 'financial_card_model.g.dart';

@freezed
class FinancialCardModel with _$FinancialCardModel {
  const factory FinancialCardModel({
    int? id,
    String? name,
    String? logo,
    bool? active,
    bool? destaque,
    @JsonKey(name: 'link_externo') String? linkExterno,
    @JsonKey(name: 'renda_minima') String? rendaMinima,
    String? tipo,
    String? bandeira,
    String? anuidade,
    @JsonKey(name: 'demais_anuidade') String? demaisAnuidade,
    String? diferencial,
    String? beneficios,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'external_id') String? externalId,
    String? categoria,
    @JsonKey(name: 'categoria_id') int? categoriaId,
    @JsonKey(name: 'categoria_string') String? categoriaString,
  }) = _FinancialCardModel;

  factory FinancialCardModel.fromJson(Map<String, dynamic> json) =>
      _$FinancialCardModelFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'atividade_model.freezed.dart';
part 'atividade_model.g.dart';

@freezed
class AtividadeModel with _$AtividadeModel {
  const factory AtividadeModel({
    String? code,
    String? text,
  }) = _AtividadeModel;

  factory AtividadeModel.fromJson(Map<String, dynamic> json) =>
      _$AtividadeModelFromJson(json);
}

@freezed
class QsaModel with _$QsaModel {
  const factory QsaModel({
    String? nome,
    String? qual,
  }) = _QsaModel;

  factory QsaModel.fromJson(Map<String, dynamic> json) =>
      _$QsaModelFromJson(json);
}

@freezed
class BillingModel with _$BillingModel {
  const factory BillingModel({
    bool? free,
    bool? database,
  }) = _BillingModel;

  factory BillingModel.fromJson(Map<String, dynamic> json) =>
      _$BillingModelFromJson(json);
}

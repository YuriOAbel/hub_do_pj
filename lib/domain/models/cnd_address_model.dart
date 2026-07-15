import 'package:freezed_annotation/freezed_annotation.dart';

part 'cnd_address_model.freezed.dart';
part 'cnd_address_model.g.dart';

@freezed
class CndAddressModel with _$CndAddressModel {
  const factory CndAddressModel({
    @Default('') String cep,
    @Default('') String logradouro,
    @Default('') String numero,
    String? complemento,
    @Default('') String bairro,
    @Default('') String cidade,
    @Default('') String uf,
    String? telefone,
  }) = _CndAddressModel;

  factory CndAddressModel.fromJson(Map<String, dynamic> json) =>
      _$CndAddressModelFromJson(json);
}

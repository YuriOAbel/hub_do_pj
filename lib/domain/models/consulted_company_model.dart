import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_order_model.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';

part 'consulted_company_model.freezed.dart';
part 'consulted_company_model.g.dart';

@freezed
class ConsultedCompanyModel with _$ConsultedCompanyModel {
  const ConsultedCompanyModel._();

  const factory ConsultedCompanyModel({
    required String id,
    required String profileId,
    required String cnpjDigits,
    required String companyName,
    String? situacao,
    String? fantasia,
    @Default({}) Map<String, dynamic> metadata,
    required String lastConsultedAt,
    required String createdAt,
    String? updatedAt,
    @Default([]) List<CndOrderModel> orders,
  }) = _ConsultedCompanyModel;

  factory ConsultedCompanyModel.fromJson(Map<String, dynamic> json) =>
      _$ConsultedCompanyModelFromJson(json);

  bool get hasOrders => orders.isNotEmpty;

  /// Rebuilds a [CnpjModel] from metadata when possible, else minimal fields.
  CnpjModel toCnpjModel() {
    if (metadata.isNotEmpty) {
      try {
        return CnpjModel.fromJson(Map<String, dynamic>.from(metadata));
      } catch (_) {
        // Fall through to minimal model.
      }
    }
    return CnpjModel(
      cnpj: cnpjDigits,
      nome: companyName,
      fantasia: fantasia,
      situacao: situacao,
    );
  }
}

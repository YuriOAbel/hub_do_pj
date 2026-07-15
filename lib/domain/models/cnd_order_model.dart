import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_address_model.dart';

part 'cnd_order_model.freezed.dart';
part 'cnd_order_model.g.dart';

enum CndOrderDisplayStatus {
  pending,
  processing,
  completed,
  cancelled,
}

@freezed
class CndOrderModel with _$CndOrderModel {
  const CndOrderModel._();

  const factory CndOrderModel({
    required String id,
    String? userId,
    required String guestEmail,
    String? guestPhone,
    required String productId,
    List<String>? selectedProductIds,
    int? totalCents,
    required String cnpj,
    required String companyName,
    CndAddressModel? address,
    required String status,
    required String paymentStatus,
    required String createdAt,
    String? updatedAt,
  }) = _CndOrderModel;

  factory CndOrderModel.fromJson(Map<String, dynamic> json) =>
      _$CndOrderModelFromJson(json);

  CndOrderDisplayStatus get displayStatus {
    if (status == 'cancelado') return CndOrderDisplayStatus.cancelled;
    if (status == 'concluido') return CndOrderDisplayStatus.completed;
    if (status == 'processando' ||
        (status == 'em_analise' && paymentStatus == 'paid')) {
      return CndOrderDisplayStatus.processing;
    }
    return CndOrderDisplayStatus.pending;
  }

  String get displayStatusLabel => switch (displayStatus) {
        CndOrderDisplayStatus.pending => 'Pendente',
        CndOrderDisplayStatus.processing => 'Processando',
        CndOrderDisplayStatus.completed => 'Concluído',
        CndOrderDisplayStatus.cancelled => 'Cancelado',
      };

  String get shortId =>
      id.length >= 8 ? id.substring(0, 8) : id;
}

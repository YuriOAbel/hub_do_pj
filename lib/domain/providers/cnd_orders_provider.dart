import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_catalog_model.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_order_model.dart';
import 'package:consulta_cnpj_new/services/cnd_orders_service.dart';

part 'cnd_orders_provider.g.dart';

@riverpod
class CndCatalog extends _$CndCatalog {
  @override
  Future<CndCatalogModel> build() {
    return CndOrdersService.instance.loadCatalog();
  }
}

@riverpod
class CndOrders extends _$CndOrders {
  @override
  Future<List<CndOrderModel>> build() {
    return CndOrdersService.instance.listOrdersForCurrentUser();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => CndOrdersService.instance.listOrdersForCurrentUser(),
    );
  }

  Future<CndOrderModel> markOrderPaid(
    String orderId, {
    String? paymentId,
  }) async {
    final order = await CndOrdersService.instance.markOrderPaid(
      orderId,
      paymentId: paymentId,
    );
    await refresh();
    return order;
  }
}

@riverpod
class CndOrdersFilter extends _$CndOrdersFilter {
  @override
  CndOrderDisplayStatus? build() => null;

  void setFilter(CndOrderDisplayStatus? status) {
    state = status;
  }
}

const _activeOrderStatuses = {'em_analise', 'processando', 'concluido'};

/// Latest active order per product kind for a CNPJ (digits).
@riverpod
Future<Map<String, CndOrderModel>> activeOrdersForCnpj(
  Ref ref,
  String cnpjDigits,
) async {
  final digits = cnpjDigits.replaceAll(RegExp(r'\D'), '');
  final orders = await ref.watch(cndOrdersProvider.future);
  final catalog = await ref.watch(cndCatalogProvider.future);

  final result = <String, CndOrderModel>{};
  for (final order in orders) {
    if (!_activeOrderStatuses.contains(order.status)) continue;
    final orderDigits = order.cnpj.replaceAll(RegExp(r'\D'), '');
    if (orderDigits != digits) continue;
    final kind = catalog.kindForProductId(order.productId);
    if (result.containsKey(kind)) continue;
    result[kind] = order;
  }
  return result;
}

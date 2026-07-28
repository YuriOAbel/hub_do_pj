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

  Future<CndOrderModel> markOrderPaid(String orderId) async {
    final order = await CndOrdersService.instance.markOrderPaid(orderId);
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

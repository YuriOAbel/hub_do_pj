import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_order_model.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/services/cnd_orders_service.dart';
import 'package:consulta_cnpj_new/services/cnpj_search_exception.dart';
import 'package:consulta_cnpj_new/services/cnpj_search_service.dart';
import 'package:consulta_cnpj_new/services/consulted_companies_service.dart';
import 'package:cpf_cnpj_validator/cnpj_validator.dart';

part 'cnd_request_provider.g.dart';

@riverpod
class CndCompanyLookup extends _$CndCompanyLookup {
  @override
  AsyncValue<CnpjModel?> build() => const AsyncData(null);

  Future<CnpjModel?> lookup(String rawCnpj) async {
    final digits = CNPJValidator.strip(rawCnpj);
    if (digits.length != 14 || !CNPJValidator.isValid(digits)) {
      state = const AsyncData(null);
      return null;
    }

    state = const AsyncLoading();
    try {
      final result = await CnpjSearchService.instance.getByCnpj(digits);
      await ConsultedCompaniesService.instance.upsertFromCnpj(result);
      state = AsyncData(result);
      return result;
    } on CnpjSearchException catch (e, st) {
      state = AsyncError(e, st);
      return null;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  void clear() {
    state = const AsyncData(null);
  }
}

@riverpod
class CndOrderSubmit extends _$CndOrderSubmit {
  @override
  AsyncValue<CndOrderModel?> build() => const AsyncData(null);

  Future<CndOrderModel> submit({
    required CnpjModel company,
    required String email,
    required String phone,
    required String productKind,
  }) async {
    state = const AsyncLoading();
    try {
      final order = await CndOrdersService.instance.createOrder(
        company: company,
        guestEmail: email,
        guestPhone: phone,
        productKind: productKind,
      );
      state = AsyncData(order);
      return order;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

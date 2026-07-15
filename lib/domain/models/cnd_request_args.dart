import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_order_model.dart';

/// Entry args for [AppRoutes.cndRequest] (kind-only or prefilled edit).
class CndRequestEntryArgs {
  const CndRequestEntryArgs({
    this.productKind = 'cnd',
    this.prefill,
  });

  final String productKind;
  final CndRequestArgs? prefill;
}

/// Typed args for [AppRoutes.cndConfirm] / request prefill.
class CndRequestArgs {
  const CndRequestArgs({
    required this.cnpj,
    required this.email,
    required this.phone,
    this.productKind = 'cnd',
  });

  final CnpjModel cnpj;
  final String email;
  final String phone;
  final String productKind;

  CndRequestEntryArgs toEntry() => CndRequestEntryArgs(
        productKind: productKind,
        prefill: this,
      );
}

/// Typed args for [AppRoutes.cndOrderDetail].
class CndOrderDetailArgs {
  const CndOrderDetailArgs({
    required this.order,
  });

  final CndOrderModel order;
}

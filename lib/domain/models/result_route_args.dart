import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';

/// Typed args for [AppRoutes.result].
class ResultRouteArgs {
  const ResultRouteArgs({
    required this.cnpj,
    this.fromOnboarding = false,
  });

  final CnpjModel cnpj;
  final bool fromOnboarding;
}

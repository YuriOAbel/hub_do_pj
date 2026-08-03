import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';

/// Typed args for [AppRoutes.companyOffer].
class CompanyOfferRouteArgs {
  const CompanyOfferRouteArgs({
    required this.cnpj,
    this.fromOnboarding = false,
    this.consultedCompanyId,
  });

  final CnpjModel cnpj;
  final bool fromOnboarding;
  final String? consultedCompanyId;
}

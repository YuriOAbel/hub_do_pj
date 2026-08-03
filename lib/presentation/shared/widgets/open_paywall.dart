import 'package:flutter/material.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';
import 'package:consulta_cnpj_new/services/paywall/revenuecat_config.dart';

/// Opens original or consumable paywall based on [RevenueCatConfig] gate + origin.
Future<T?> openPaywall<T extends Object?>(
  BuildContext context,
  PaywallRouteArgs args,
) {
  final routeName = _routeFor(args);
  return Navigator.pushNamed<T>(
    context,
    routeName,
    arguments: args,
  );
}

String _routeFor(PaywallRouteArgs args) {
  if (!RevenueCatConfig.useConsumablePaywallExperiment) {
    return AppRoutes.paywall;
  }

  switch (args.origin) {
    case PaywallOrigin.cnd:
    case PaywallOrigin.score:
    case PaywallOrigin.scoreLimit:
      return AppRoutes.paywallConsumables;
    case PaywallOrigin.searchLimit:
    case PaywallOrigin.appOpen:
    case PaywallOrigin.home:
    case PaywallOrigin.result:
    case PaywallOrigin.favorite:
    case PaywallOrigin.share:
    case PaywallOrigin.contact:
    case PaywallOrigin.onboarding:
      return AppRoutes.paywall;
  }
}

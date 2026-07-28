import 'package:flutter/material.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/routes/app_routes.dart';

Future<T?> openPaywall<T extends Object?>(
  BuildContext context,
  PaywallRouteArgs args,
) {
  return Navigator.pushNamed<T>(
    context,
    AppRoutes.paywall,
    arguments: args,
  );
}

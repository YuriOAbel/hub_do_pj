import 'package:flutter/material.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/domain/models/search_param.dart';
import 'package:consulta_cnpj_new/presentation/calculator_screen/calculator_screen.dart';
import 'package:consulta_cnpj_new/presentation/evaluation_screen/evaluation_screen.dart';
import 'package:consulta_cnpj_new/presentation/financial_cards_screen/financial_cards_screen.dart';
import 'package:consulta_cnpj_new/presentation/home_screen/home_screen.dart';
import 'package:consulta_cnpj_new/presentation/location_permission_screen/location_permission_screen.dart';
import 'package:consulta_cnpj_new/presentation/not_available_screen/not_available_screen.dart';
import 'package:consulta_cnpj_new/presentation/paywall_screen/paywall_screen.dart';
import 'package:consulta_cnpj_new/presentation/refer_friend_screen/refer_friend_screen.dart';
import 'package:consulta_cnpj_new/presentation/result_screen/result_screen.dart';
import 'package:consulta_cnpj_new/presentation/search_advanced_screen/filter_detail_screen.dart';
import 'package:consulta_cnpj_new/presentation/search_advanced_screen/search_advanced_screen.dart';
import 'package:consulta_cnpj_new/presentation/splash_screen/splash_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const locationPermission = '/location-permission';
  static const home = '/home';
  static const result = '/result';
  static const searchAdvanced = '/search-advanced';
  static const searchAdvancedFilter = '/search-advanced/filter';
  static const paywall = '/paywall';
  static const calculator = '/calculator';
  static const referFriend = '/refer-friend';
  static const evaluation = '/evaluation';
  static const notAvailable = '/not-available';
  static const financialCards = '/financial-cards';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _page(const SplashScreen(), settings);
      case locationPermission:
        return _page(const LocationPermissionScreen(), settings);
      case home:
        return _page(const HomeScreen(), settings);
      case result:
        final args = settings.arguments as CnpjModel;
        return _page(ResultScreen(cnpj: args), settings);
      case searchAdvanced:
        final args = settings.arguments as SearchParam?;
        return _page(SearchAdvancedScreen(initialParam: args), settings);
      case searchAdvancedFilter:
        final args = settings.arguments as String? ?? 'empresa';
        return _page(FilterDetailScreen(filterType: args), settings);
      case paywall:
        final args =
            settings.arguments as PaywallOrigin? ?? PaywallOrigin.home;
        return _page(PaywallScreen(origin: args), settings);
      case calculator:
        return _page(const CalculatorScreen(), settings);
      case referFriend:
        return _page(const ReferFriendScreen(), settings);
      case evaluation:
        return _page(const EvaluationScreen(), settings);
      case notAvailable:
        final args = settings.arguments as String? ?? '';
        return _page(NotAvailableScreen(origin: args), settings);
      case financialCards:
        return _page(const FinancialCardsScreen(), settings);
      default:
        return _page(const SplashScreen(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _page(Widget child, RouteSettings settings) {
    return MaterialPageRoute(settings: settings, builder: (_) => child);
  }
}

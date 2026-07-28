import 'package:flutter/material.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_request_args.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';
import 'package:consulta_cnpj_new/domain/models/company_score_entry_args.dart';
import 'package:consulta_cnpj_new/domain/models/home_entry_args.dart';
import 'package:consulta_cnpj_new/domain/models/plan_model.dart';
import 'package:consulta_cnpj_new/domain/models/result_route_args.dart';
import 'package:consulta_cnpj_new/domain/models/search_param.dart';
import 'package:consulta_cnpj_new/presentation/calculator_screen/calculator_screen.dart';
import 'package:consulta_cnpj_new/presentation/cnd_confirm_screen/cnd_confirm_screen.dart';
import 'package:consulta_cnpj_new/presentation/cnd_order_detail_screen/cnd_order_detail_screen.dart';
import 'package:consulta_cnpj_new/presentation/cnd_orders_screen/cnd_orders_screen.dart';
import 'package:consulta_cnpj_new/presentation/cnd_request_screen/cnd_request_screen.dart';
import 'package:consulta_cnpj_new/presentation/company_score_list_screen/company_score_list_screen.dart';
import 'package:consulta_cnpj_new/presentation/company_score_screen/company_score_screen.dart';
import 'package:consulta_cnpj_new/presentation/evaluation_screen/evaluation_screen.dart';
import 'package:consulta_cnpj_new/presentation/home_screen/home_screen.dart';
import 'package:consulta_cnpj_new/presentation/not_available_screen/not_available_screen.dart';
import 'package:consulta_cnpj_new/domain/models/app_notification_model.dart';
import 'package:consulta_cnpj_new/presentation/notification_center_screen/notification_center_screen.dart';
import 'package:consulta_cnpj_new/presentation/notification_content_screen/notification_content_screen.dart';
import 'package:consulta_cnpj_new/presentation/onboarding_screen/onboarding_screen.dart';
import 'package:consulta_cnpj_new/presentation/paywall_screen/paywall_screen.dart';
import 'package:consulta_cnpj_new/presentation/profile_edit_screen/profile_edit_screen.dart';
import 'package:consulta_cnpj_new/presentation/refer_friend_screen/refer_friend_screen.dart';
import 'package:consulta_cnpj_new/presentation/result_screen/result_screen.dart';
import 'package:consulta_cnpj_new/presentation/search_advanced_screen/filter_detail_screen.dart';
import 'package:consulta_cnpj_new/presentation/search_advanced_screen/search_advanced_screen.dart';
import 'package:consulta_cnpj_new/presentation/settings_screen/settings_screen.dart';
import 'package:consulta_cnpj_new/presentation/splash_screen/splash_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const onboarding = '/onboarding';
  static const result = '/result';
  static const searchAdvanced = '/search-advanced';
  static const searchAdvancedFilter = '/search-advanced/filter';
  static const paywall = '/paywall';
  static const calculator = '/calculator';
  static const referFriend = '/refer-friend';
  static const evaluation = '/evaluation';
  static const notAvailable = '/not-available';
  static const notifications = '/notifications';
  static const notificationContent = '/notification-content';
  static const settings = '/settings';
  static const profileEdit = '/settings/profile';
  static const companyScore = '/company-score';
  static const companyScoreList = '/company-score/list';
  static const cndRequest = '/cnd/request';
  static const cndConfirm = '/cnd/confirm';
  static const cndOrders = '/cnd/orders';
  static const cndOrderDetail = '/cnd/orders/detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _page(const SplashScreen(), settings);
      case home:
        final homeArgs = settings.arguments is HomeEntryArgs
            ? settings.arguments as HomeEntryArgs
            : const HomeEntryArgs();
        return _page(HomeScreen(entry: homeArgs), settings);
      case onboarding:
        return _page(const OnboardingScreen(), settings);
      case result:
        final args = settings.arguments;
        if (args is ResultRouteArgs) {
          return _page(
            ResultScreen(
              cnpj: args.cnpj,
              fromOnboarding: args.fromOnboarding,
            ),
            settings,
          );
        }
        return _page(
          ResultScreen(cnpj: args as CnpjModel),
          settings,
        );
      case searchAdvanced:
        final args = settings.arguments as SearchParam?;
        return _page(SearchAdvancedScreen(initialParam: args), settings);
      case searchAdvancedFilter:
        final args = settings.arguments as String? ?? 'empresa';
        return _page(FilterDetailScreen(filterType: args), settings);
      case paywall:
        final raw = settings.arguments;
        final args = switch (raw) {
          PaywallRouteArgs a => a,
          PaywallOrigin o => PaywallRouteArgs(origin: o),
          _ => const PaywallRouteArgs(origin: PaywallOrigin.home),
        };
        return _page(PaywallScreen(args: args), settings);
      case calculator:
        return _page(const CalculatorScreen(), settings);
      case referFriend:
        return _page(const ReferFriendScreen(), settings);
      case evaluation:
        return _page(const EvaluationScreen(), settings);
      case notAvailable:
        final args = settings.arguments as String? ?? '';
        return _page(NotAvailableScreen(origin: args), settings);
      case notifications:
        return _page(const NotificationCenterScreen(), settings);
      case notificationContent:
        final args = settings.arguments as NotificationContentArgs? ??
            const NotificationContentArgs(title: '', body: '');
        return _page(NotificationContentScreen(args: args), settings);
      case AppRoutes.settings:
        return _page(const SettingsScreen(), settings);
      case AppRoutes.profileEdit:
        return _page(const ProfileEditScreen(), settings);
      case companyScore:
        final entry = settings.arguments is CompanyScoreEntryArgs
            ? settings.arguments as CompanyScoreEntryArgs
            : null;
        return _page(CompanyScoreScreen(entry: entry), settings);
      case companyScoreList:
        return _page(const CompanyScoreListScreen(), settings);
      case cndRequest:
        final raw = settings.arguments;
        final entry = switch (raw) {
          CndRequestEntryArgs e => e,
          CndRequestArgs a => a.toEntry(),
          _ => const CndRequestEntryArgs(),
        };
        return _page(CndRequestScreen(entry: entry), settings);
      case cndConfirm:
        final args = settings.arguments as CndRequestArgs;
        return _page(CndConfirmScreen(args: args), settings);
      case cndOrders:
        return _page(const CndOrdersScreen(), settings);
      case cndOrderDetail:
        final args = settings.arguments as CndOrderDetailArgs;
        return _page(CndOrderDetailScreen(order: args.order), settings);
      default:
        return _page(const SplashScreen(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _page(Widget child, RouteSettings settings) {
    return MaterialPageRoute(settings: settings, builder: (_) => child);
  }
}

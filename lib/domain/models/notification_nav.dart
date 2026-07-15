import 'package:consulta_cnpj_new/domain/models/app_notification_model.dart';
import 'package:consulta_cnpj_new/domain/models/cnd_request_args.dart';

/// Resolved navigation target from an inbox / FCM notification.
class NotificationNavTarget {
  const NotificationNavTarget({
    required this.route,
    this.arguments,
  });

  final String route;
  final Object? arguments;
}

/// Maps [AppNotificationModel] type/route → named route + typed args.
///
/// Route strings must match [AppRoutes] constants.
class NotificationNav {
  NotificationNav._();

  static const contentRoute = '/notification-content';
  static const cndOrdersRoute = '/cnd/orders';
  static const cndRequestRoute = '/cnd/request';
  static const notAvailableRoute = '/not-available';
  static const companyScoreRoute = '/company-score';
  static const paywallRoute = '/paywall';

  static NotificationNavTarget resolve(AppNotificationModel item) {
    final explicit = item.route?.trim();
    if (explicit != null &&
        explicit.isNotEmpty &&
        !explicit.startsWith('http')) {
      return NotificationNavTarget(
        route: explicit,
        arguments: _argsForRoute(explicit, item),
      );
    }

    return switch (item.type) {
      'cnd' => const NotificationNavTarget(route: cndOrdersRoute),
      'monitoramento' => const NotificationNavTarget(
          route: notAvailableRoute,
          arguments: 'monitorar',
        ),
      'restricao' => NotificationNavTarget(
          route: cndRequestRoute,
          arguments: CndRequestEntryArgs(
            productKind: item.productKind ?? 'restricao',
          ),
        ),
      'protesto' => NotificationNavTarget(
          route: cndRequestRoute,
          arguments: CndRequestEntryArgs(
            productKind: item.productKind ?? 'protesto',
          ),
        ),
      'score' => const NotificationNavTarget(route: companyScoreRoute),
      'premium' => const NotificationNavTarget(route: paywallRoute),
      _ => NotificationNavTarget(
          route: contentRoute,
          arguments: NotificationContentArgs(
            title: item.title,
            body: item.body,
          ),
        ),
    };
  }

  static Object? _argsForRoute(String route, AppNotificationModel item) {
    if (route == contentRoute) {
      return NotificationContentArgs(title: item.title, body: item.body);
    }
    if (route == notAvailableRoute) {
      return item.productKind ?? 'monitorar';
    }
    if (route == cndRequestRoute) {
      final kind = item.productKind ??
          (item.type == 'protesto' ? 'protesto' : 'restricao');
      return CndRequestEntryArgs(productKind: kind);
    }
    return null;
  }
}

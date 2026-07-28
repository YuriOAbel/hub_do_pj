import 'dart:io';

import 'package:consulta_cnpj_new/domain/models/app_notification_model.dart';
import 'package:consulta_cnpj_new/firebase_options.dart';
import 'package:consulta_cnpj_new/services/local_notification_inbox_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final item = FirebaseMessagingService.inboxItemFromMessage(message);
  await LocalNotificationInboxService.instance.save(item);
}

class FirebaseMessagingService {
  static final FirebaseMessagingService instance = FirebaseMessagingService._();
  FirebaseMessagingService._();

  /// Called when user opens a push from the system tray.
  void Function(AppNotificationModel item)? onOpenNotification;

  /// Called after inbox was mutated (foreground save).
  VoidCallback? onInboxUpdated;

  String? _fcmToken;
  bool _permissionRequested = false;
  bool _listenersBound = false;

  String? get fcmToken => _fcmToken;

  /// Wires FCM listeners. Does **not** show the OS permission dialog —
  /// call [requestPermission] at the product moment.
  Future<void> init() async {
    try {
      final messaging = FirebaseMessaging.instance;

      await messaging.subscribeToTopic('geral');

      if (!_listenersBound) {
        _listenersBound = true;
        messaging.onTokenRefresh.listen((token) {
          _fcmToken = token;
          if (kDebugMode) {
            debugPrint('FirebaseMessagingService FCM token refresh: $token');
          }
        });
        FirebaseMessaging.onMessage.listen(_onForegroundMessage);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);
      }

      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        await _handleOpenedMessage(initial);
      }
    } catch (e) {
      debugPrint('FirebaseMessagingService.init: $e');
    }
  }

  /// Shows the system notification permission prompt (once per install).
  Future<void> requestPermission() async {
    if (_permissionRequested) return;
    _permissionRequested = true;
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      if (Platform.isAndroid) {
        await Permission.notification.request();
      }

      _fcmToken = await messaging.getToken();
      if (kDebugMode) {
        debugPrint('FirebaseMessagingService FCM token: $_fcmToken');
      }
    } catch (e) {
      debugPrint('FirebaseMessagingService.requestPermission: $e');
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final item = inboxItemFromMessage(message);
    await LocalNotificationInboxService.instance.save(item);
    onInboxUpdated?.call();
  }

  Future<void> _handleOpenedMessage(RemoteMessage message) async {
    final item = inboxItemFromMessage(message);
    if (!await LocalNotificationInboxService.instance.contains(item.id)) {
      await LocalNotificationInboxService.instance.save(item);
    }
    await LocalNotificationInboxService.instance.markRead(item.id);
    onInboxUpdated?.call();
    onOpenNotification?.call(item.copyWith(read: true));
  }

  static AppNotificationModel inboxItemFromMessage(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;

    var type = (data['type'] ?? '').toString().trim();
    if (type.isEmpty && data['tag'] == 'notif_premium') {
      type = 'premium';
    }
    if (type.isEmpty) type = 'content';

    final routeRaw = data['route'] ?? data['url'];
    final route = routeRaw?.toString().trim();
    final productKind = data['product_kind']?.toString().trim();

    final title = (notification?.title ?? data['title'] ?? '').toString();
    final body = (notification?.body ?? data['body'] ?? '').toString();

    final messageId = message.messageId?.trim();
    final id = (messageId != null && messageId.isNotEmpty)
        ? messageId
        : '${title.hashCode}_${body.hashCode}_${message.sentTime?.millisecondsSinceEpoch ?? 0}';

    return AppNotificationModel(
      id: id,
      title: title.isEmpty ? 'Notificação' : title,
      body: body,
      type: type,
      route: (route != null && route.isNotEmpty) ? route : null,
      productKind:
          (productKind != null && productKind.isNotEmpty) ? productKind : null,
      read: false,
      createdAt: message.sentTime ?? DateTime.now(),
    );
  }

  Future<void> subscribeRestriction() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('restricao');
    } catch (e) {
      debugPrint('FirebaseMessagingService.subscribeRestriction: $e');
    }
  }
}

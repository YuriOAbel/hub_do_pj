import 'dart:convert';
import 'dart:io';

import 'package:consulta_cnpj_new/domain/models/app_notification_model.dart';
import 'package:consulta_cnpj_new/firebase_options.dart';
import 'package:consulta_cnpj_new/services/local_notification_inbox_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'cnpj_consulta_default',
    'Notificações',
    description: 'Alertas e avisos do CNPJ Consulta',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Called when user opens a push (system tray or local banner).
  void Function(AppNotificationModel item)? onOpenNotification;

  /// Called after inbox was mutated (foreground save).
  VoidCallback? onInboxUpdated;

  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  Future<void> init() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      if (Platform.isAndroid) {
        await Permission.notification.request();
      }

      await _initLocalNotifications();

      await messaging.subscribeToTopic('geral');

      _fcmToken = await messaging.getToken();
      if (kDebugMode) {
        debugPrint('FirebaseMessagingService FCM token: $_fcmToken');
      }
      messaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        if (kDebugMode) {
          debugPrint('FirebaseMessagingService FCM token refresh: $token');
        }
      });

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);

      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        await _handleOpenedMessage(initial);
      }
    } catch (e) {
      debugPrint('FirebaseMessagingService.init: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        final item = _itemFromPayload(payload);
        if (item == null) return;
        onOpenNotification?.call(item);
      },
    );

    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final item = inboxItemFromMessage(message);
    await LocalNotificationInboxService.instance.save(item);
    onInboxUpdated?.call();

    final notification = message.notification;
    if (notification == null && item.title.isEmpty && item.body.isEmpty) {
      return;
    }

    final title = notification?.title ?? item.title;
    final body = notification?.body ?? item.body;

    await _localNotifications.show(
      item.id.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: _payloadFromItem(item),
    );
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

  static String _payloadFromItem(AppNotificationModel item) {
    return jsonEncode(item.toJson());
  }

  static AppNotificationModel? _itemFromPayload(String payload) {
    try {
      final map = jsonDecode(payload);
      if (map is! Map) return null;
      return AppNotificationModel.fromJson(
        Map<String, dynamic>.from(map),
      );
    } catch (_) {
      // Legacy payloads were plain route strings.
      if (payload.startsWith('/') && !payload.startsWith('http')) {
        return AppNotificationModel(
          id: 'legacy_${payload.hashCode}',
          title: 'Notificação',
          body: '',
          type: 'content',
          route: payload,
          createdAt: DateTime.now(),
        );
      }
      return null;
    }
  }

  Future<void> subscribeRestriction() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('restricao');
    } catch (e) {
      debugPrint('FirebaseMessagingService.subscribeRestriction: $e');
    }
  }
}

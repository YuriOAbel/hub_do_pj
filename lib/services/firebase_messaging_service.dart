import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService instance =
      FirebaseMessagingService._();
  FirebaseMessagingService._();

  void Function(String route)? onNavigate;

  Future<void> init() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      await messaging.subscribeToTopic('geral');

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _handleMessage(message);
      });

      final initial = await messaging.getInitialMessage();
      if (initial != null) _handleMessage(initial);
    } catch (e) {
      debugPrint('FirebaseMessagingService.init: $e');
    }
  }

  void _handleMessage(RemoteMessage message) {
    final tag = message.data['tag'];
    if (tag == 'notif_premium') {
      onNavigate?.call('/paywall');
      return;
    }
    final type = message.data['type'];
    final url = message.data['url'];
    if (type == 'url' && url != null) {
      onNavigate?.call(url);
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

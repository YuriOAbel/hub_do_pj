import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:consulta_cnpj_new/domain/models/app_notification_model.dart';

class LocalNotificationInboxService {
  static final LocalNotificationInboxService instance =
      LocalNotificationInboxService._();
  LocalNotificationInboxService._();

  static const String storageKey = 'notification_inbox_key';

  Future<List<AppNotificationModel>> getAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(storageKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map(
            (e) => AppNotificationModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('LocalNotificationInboxService.getAll: $e');
      return [];
    }
  }

  Future<void> save(AppNotificationModel item) async {
    final list = await getAll();
    final existing = list.where((e) => e.id == item.id).firstOrNull;
    list.removeWhere((e) => e.id == item.id);
    final toSave = existing != null && existing.read
        ? item.copyWith(read: true)
        : item;
    list.insert(0, toSave);
    await _persist(list);
  }

  Future<void> markRead(String id) async {
    final list = await getAll();
    final index = list.indexWhere((e) => e.id == id);
    if (index < 0) return;
    final item = list[index];
    if (item.read) return;
    list[index] = item.copyWith(read: true);
    await _persist(list);
  }

  Future<bool> hasUnread() async {
    final list = await getAll();
    return list.any((e) => !e.read);
  }

  Future<bool> contains(String id) async {
    final list = await getAll();
    return list.any((e) => e.id == id);
  }

  Future<void> _persist(List<AppNotificationModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(storageKey, encoded);
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(storageKey);
    } catch (e) {
      debugPrint('LocalNotificationInboxService.clearAll: $e');
    }
  }
}

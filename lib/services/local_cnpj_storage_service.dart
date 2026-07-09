import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:consulta_cnpj_new/domain/models/cnpj_model.dart';

abstract class _LocalCnpjListService {
  String get storageKey;

  Future<List<CnpjModel>> getAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(storageKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => CnpjModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      debugPrint('LocalCnpjListService.getAll: $e');
      return [];
    }
  }

  Future<void> save(CnpjModel item) async {
    final list = await getAll();
    list.removeWhere((e) => e.cnpj == item.cnpj);
    list.insert(0, item.copyWith(dtSave: DateTime.now().toIso8601String()));
    await _persist(list);
  }

  Future<void> remove(CnpjModel item) async {
    final list = await getAll();
    list.removeWhere((e) => e.cnpj == item.cnpj);
    await _persist(list);
  }

  Future<bool> contains(CnpjModel item) async {
    final list = await getAll();
    return list.any((e) => e.cnpj == item.cnpj);
  }

  Future<void> _persist(List<CnpjModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(storageKey, encoded);
  }
}

class LocalHistoryService extends _LocalCnpjListService {
  static final LocalHistoryService instance = LocalHistoryService._();
  LocalHistoryService._();

  @override
  String get storageKey => 'hist_key';
}

class LocalFavoritesService extends _LocalCnpjListService {
  static final LocalFavoritesService instance = LocalFavoritesService._();
  LocalFavoritesService._();

  @override
  String get storageKey => 'favorite_key';

  Future<void> toggle(CnpjModel item) async {
    if (await contains(item)) {
      await remove(item);
    } else {
      await save(item);
    }
  }
}

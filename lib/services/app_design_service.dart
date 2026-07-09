import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppDesignService {
  static final AppDesignService instance = AppDesignService._();
  AppDesignService._();

  Map<String, dynamic> _colors = {};
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final raw = await rootBundle.loadString('assets/config/design.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _colors = Map<String, dynamic>.from(json['colors'] as Map);
      _initialized = true;
    } catch (e) {
      debugPrint('AppDesignService.init: $e');
    }
  }

  Color color(String key) {
    final hex = _colors[key] as String?;
    if (hex == null) return Colors.transparent;
    return _fromHex(hex);
  }

  Color _fromHex(String hex) {
    final value = hex.replaceFirst('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }
}

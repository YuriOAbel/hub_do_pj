import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeTutorialService {
  static final HomeTutorialService instance = HomeTutorialService._();
  HomeTutorialService._();

  static const _seenKey = 'home_tutorial_seen';

  Future<bool> hasSeenTutorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_seenKey) ?? false;
    } catch (e) {
      debugPrint('HomeTutorialService.hasSeenTutorial: $e');
      return false;
    }
  }

  Future<void> markTutorialSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_seenKey, true);
    } catch (e) {
      debugPrint('HomeTutorialService.markTutorialSeen: $e');
    }
  }
}

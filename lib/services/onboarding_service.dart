import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static final OnboardingService instance = OnboardingService._();
  OnboardingService._();

  static const _completedKey = 'onboarding_completed';
  static const _nameKey = 'onboarding_name';
  static const _personTypeKey = 'onboarding_person_type';
  static const _occupationIdKey = 'onboarding_occupation_id';
  static const _occupationOtherKey = 'onboarding_occupation_other';
  static const _interestsKey = 'onboarding_interests';
  static const _companyInfosKey = 'onboarding_company_infos';

  Future<bool> isCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_completedKey) ?? false;
    } catch (e) {
      debugPrint('OnboardingService.isCompleted: $e');
      return false;
    }
  }

  Future<void> saveAnswers({
    required String name,
    String? personType,
    String? occupationId,
    String? occupationOther,
    required List<String> interests,
    required List<String> companyInfos,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_nameKey, name);
      if (personType != null) {
        await prefs.setString(_personTypeKey, personType);
      }
      if (occupationId != null) {
        await prefs.setString(_occupationIdKey, occupationId);
      }
      if (occupationOther != null && occupationOther.isNotEmpty) {
        await prefs.setString(_occupationOtherKey, occupationOther);
      }
      await prefs.setString(_interestsKey, jsonEncode(interests));
      await prefs.setString(_companyInfosKey, jsonEncode(companyInfos));
    } catch (e) {
      debugPrint('OnboardingService.saveAnswers: $e');
    }
  }

  Future<void> markCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_completedKey, true);
    } catch (e) {
      debugPrint('OnboardingService.markCompleted: $e');
    }
  }

  Future<String?> getName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_nameKey);
    } catch (e) {
      debugPrint('OnboardingService.getName: $e');
      return null;
    }
  }
}

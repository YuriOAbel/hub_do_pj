import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Native store in-app review (iOS StoreKit / Android Play In-App Review).
///
/// Quotas are enforced by Apple/Google — dialog may not appear even when
/// [requestReview] succeeds. Throttle locally to avoid burning quota.
class InAppReviewService {
  static final InAppReviewService instance = InAppReviewService._();
  InAppReviewService._();

  static const _lastRequestedKey = 'in_app_review_last_requested_ms';
  static const _cooldown = Duration(days: 30);

  /// Lets iOS present SKStoreReviewController before the next navigation.
  static const settleAfterPresent = Duration(milliseconds: 1200);

  final InAppReview _review = InAppReview.instance;
  bool _promptedThisSession = false;

  /// Shows native review UI when available and not throttled.
  ///
  /// Returns `true` if [InAppReview.requestReview] was called.
  Future<bool> requestReview({
    Duration settleDelay = settleAfterPresent,
  }) async {
    try {
      if (_promptedThisSession) {
        debugPrint('InAppReviewService: skip — already prompted this session');
        return false;
      }

      if (!await _cooldownElapsed()) {
        debugPrint('InAppReviewService: skip — cooldown');
        return false;
      }

      final available = await _review.isAvailable();
      if (!available) {
        debugPrint('InAppReviewService: skip — not available on device');
        return false;
      }

      _promptedThisSession = true;
      await _markRequested();
      debugPrint('InAppReviewService: requesting native review');
      await _review.requestReview();

      if (settleDelay > Duration.zero) {
        await Future<void>.delayed(settleDelay);
      }
      return true;
    } catch (e) {
      debugPrint('InAppReviewService.requestReview: $e');
      return false;
    }
  }

  /// After current frame + short pause — use when previous route was popped.
  Future<bool> requestReviewDeferred({
    Duration delay = const Duration(milliseconds: 600),
  }) {
    final completer = Completer<bool>();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(delay);
      final result = await requestReview(settleDelay: Duration.zero);
      if (!completer.isCompleted) completer.complete(result);
    });
    return completer.future;
  }

  Future<bool> _cooldownElapsed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastMs = prefs.getInt(_lastRequestedKey);
      if (lastMs == null) return true;
      final elapsed = DateTime.now().millisecondsSinceEpoch - lastMs;
      return elapsed >= _cooldown.inMilliseconds;
    } catch (e) {
      debugPrint('InAppReviewService._cooldownElapsed: $e');
      return true;
    }
  }

  Future<void> _markRequested() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _lastRequestedKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('InAppReviewService._markRequested: $e');
    }
  }
}

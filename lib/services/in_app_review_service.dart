import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';

class InAppReviewService {
  static final InAppReviewService instance = InAppReviewService._();
  InAppReviewService._();

  final InAppReview _review = InAppReview.instance;

  Future<void> requestReview() async {
    try {
      if (await _review.isAvailable()) {
        await _review.requestReview();
      }
    } catch (e) {
      debugPrint('InAppReviewService.requestReview: $e');
    }
  }
}

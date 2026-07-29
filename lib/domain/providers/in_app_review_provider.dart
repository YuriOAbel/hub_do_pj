import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/core/helpers/firebase_analytics_helper.dart';
import 'package:consulta_cnpj_new/services/in_app_review_service.dart';

part 'in_app_review_provider.g.dart';

@riverpod
class InAppReviewPrompt extends _$InAppReviewPrompt {
  @override
  int build() => 0;

  /// Immediate native prompt (awaits settle so iOS can present before nav).
  Future<bool> request() async {
    final shown = await InAppReviewService.instance.requestReview();
    if (shown) {
      await FirebaseAnalyticsHelper.instance.logInAppReviewRequested();
    }
    return shown;
  }

  /// After route pop — next frame, no settle wait.
  void requestDeferred() {
    InAppReviewService.instance.requestReviewDeferred().then((shown) {
      if (shown) {
        FirebaseAnalyticsHelper.instance.logInAppReviewRequested();
      }
    });
  }
}

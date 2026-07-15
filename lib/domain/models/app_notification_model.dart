import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification_model.freezed.dart';
part 'app_notification_model.g.dart';

/// Local inbox notification (SharedPreferences).
@freezed
sealed class AppNotificationModel with _$AppNotificationModel {
  const factory AppNotificationModel({
    required String id,
    required String title,
    required String body,
    @Default('content') String type,
    String? route,
    String? productKind,
    @Default(false) bool read,
    required DateTime createdAt,
  }) = _AppNotificationModel;

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationModelFromJson(json);
}

/// Typed args for [AppRoutes.notificationContent].
class NotificationContentArgs {
  const NotificationContentArgs({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

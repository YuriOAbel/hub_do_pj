import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/core/utils/local_min_delay.dart';
import 'package:consulta_cnpj_new/domain/models/app_notification_model.dart';
import 'package:consulta_cnpj_new/services/local_notification_inbox_service.dart';

part 'notification_list_provider.g.dart';

@riverpod
class NotificationList extends _$NotificationList {
  @override
  Future<List<AppNotificationModel>> build() {
    return withLocalMinDelay(LocalNotificationInboxService.instance.getAll());
  }

  Future<void> save(AppNotificationModel item) async {
    await LocalNotificationInboxService.instance.save(item);
    state = AsyncData(await LocalNotificationInboxService.instance.getAll());
  }

  Future<void> markRead(String id) async {
    await LocalNotificationInboxService.instance.markRead(id);
    state = AsyncData(await LocalNotificationInboxService.instance.getAll());
  }

  Future<void> refreshList() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => withLocalMinDelay(LocalNotificationInboxService.instance.getAll()),
    );
  }
}

@riverpod
bool notificationHasUnread(Ref ref) {
  final async = ref.watch(notificationListProvider);
  return async.maybeWhen(
    data: (items) => items.any((e) => !e.read),
    orElse: () => false,
  );
}

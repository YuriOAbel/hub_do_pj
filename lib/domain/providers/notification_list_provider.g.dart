// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationHasUnreadHash() =>
    r'c2aa7057a7c58549ec980715bc20a09aff53db07';

/// See also [notificationHasUnread].
@ProviderFor(notificationHasUnread)
final notificationHasUnreadProvider = AutoDisposeProvider<bool>.internal(
  notificationHasUnread,
  name: r'notificationHasUnreadProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationHasUnreadHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationHasUnreadRef = AutoDisposeProviderRef<bool>;
String _$notificationListHash() => r'571c58ec6688cc554508760e3abcf2358293dcdf';

/// See also [NotificationList].
@ProviderFor(NotificationList)
final notificationListProvider =
    AutoDisposeAsyncNotifierProvider<
      NotificationList,
      List<AppNotificationModel>
    >.internal(
      NotificationList.new,
      name: r'notificationListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationList =
    AutoDisposeAsyncNotifier<List<AppNotificationModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

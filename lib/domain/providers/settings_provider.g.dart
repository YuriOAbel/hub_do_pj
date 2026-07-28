// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsVersionHash() => r'8eaeaf755c2976a9d93b5c55141773d7b47ab528';

/// See also [SettingsVersion].
@ProviderFor(SettingsVersion)
final settingsVersionProvider =
    AutoDisposeAsyncNotifierProvider<SettingsVersion, String>.internal(
      SettingsVersion.new,
      name: r'settingsVersionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settingsVersionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SettingsVersion = AutoDisposeAsyncNotifier<String>;
String _$settingsActionsHash() => r'd022c5365b220fe11f0f9c9b56c0bdaa9e5b8963';

/// See also [SettingsActions].
@ProviderFor(SettingsActions)
final settingsActionsProvider =
    AutoDisposeNotifierProvider<SettingsActions, void>.internal(
      SettingsActions.new,
      name: r'settingsActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settingsActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SettingsActions = AutoDisposeNotifier<void>;
String _$accountDeletionHash() => r'9d21c4c513af7716e659b806cd843471e2b991cf';

/// See also [AccountDeletion].
@ProviderFor(AccountDeletion)
final accountDeletionProvider =
    AutoDisposeNotifierProvider<AccountDeletion, AsyncValue<void>>.internal(
      AccountDeletion.new,
      name: r'accountDeletionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$accountDeletionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AccountDeletion = AutoDisposeNotifier<AsyncValue<void>>;
String _$profileEditHash() => r'd68e8ba96e7c852ad97c2077b0f1a5d6dcfb48eb';

/// See also [ProfileEdit].
@ProviderFor(ProfileEdit)
final profileEditProvider =
    AutoDisposeNotifierProvider<ProfileEdit, AsyncValue<void>>.internal(
      ProfileEdit.new,
      name: r'profileEditProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileEditHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProfileEdit = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

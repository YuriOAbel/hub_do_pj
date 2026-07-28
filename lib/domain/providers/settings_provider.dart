import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:consulta_cnpj_new/core/utils/local_min_delay.dart';
import 'package:consulta_cnpj_new/services/settings_service.dart';

part 'settings_provider.g.dart';

@riverpod
class SettingsVersion extends _$SettingsVersion {
  @override
  Future<String> build() {
    return withLocalMinDelay(SettingsService.instance.appVersionLabel());
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => withLocalMinDelay(SettingsService.instance.appVersionLabel()),
    );
  }
}

@riverpod
class SettingsActions extends _$SettingsActions {
  @override
  void build() {}

  Future<void> openTerms() => SettingsService.instance.openTerms();

  Future<void> openPrivacy() => SettingsService.instance.openPrivacy();

  Future<void> openSupportEmail() =>
      SettingsService.instance.openSupportEmail();

  Future<void> openWhatsApp() => SettingsService.instance.openWhatsApp();

  Future<void> openManageSubscription() =>
      SettingsService.instance.openManageSubscription();
}

@riverpod
class AccountDeletion extends _$AccountDeletion {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> deleteAccount() async {
    state = const AsyncLoading();
    try {
      await SettingsService.instance.deleteAccount();
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

@riverpod
class ProfileEdit extends _$ProfileEdit {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> saveName(String name) async {
    state = const AsyncLoading();
    try {
      await SettingsService.instance.updateDisplayName(name);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

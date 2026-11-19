import 'package:autobook/core/di/shared_preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications_enabled_provider.g.dart';

const _notificationsEnabledStorageKey = 'notifications_enabled';

@Riverpod(keepAlive: true)
class NotificationsEnabled extends _$NotificationsEnabled {
  @override
  Future<bool> build() async {
    try {
      final preferences = await ref.watch(sharedPreferencesProvider.future);
      return preferences.getBool(_notificationsEnabledStorageKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = AsyncData(enabled);
    try {
      final preferences = await ref.read(sharedPreferencesProvider.future);
      await preferences.setBool(_notificationsEnabledStorageKey, enabled);
    } catch (_) {
      return;
    }
  }
}

import 'package:autobook/core/di/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_theme_mode_provider.g.dart';

const _appThemeModeStorageKey = 'app_theme_mode';

ThemeMode? appThemeModeFromCode(String? code) {
  return switch (code) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => null,
  };
}

String _themeModeCode(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };
}

@Riverpod(keepAlive: true)
class AppThemeMode extends _$AppThemeMode {
  @override
  Future<ThemeMode?> build() async {
    try {
      final preferences = await ref.watch(sharedPreferencesProvider.future);
      final storedCode = preferences.getString(_appThemeModeStorageKey);
      return appThemeModeFromCode(storedCode);
    } catch (_) {
      return null;
    }
  }

  Future<void> select(ThemeMode mode) async {
    state = AsyncData(mode);
    try {
      final preferences = await ref.read(sharedPreferencesProvider.future);
      await preferences.setString(
        _appThemeModeStorageKey,
        _themeModeCode(mode),
      );
    } catch (_) {
      return;
    }
  }
}

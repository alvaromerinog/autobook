import 'package:autobook/app/localization/app_language.dart';
import 'package:autobook/core/di/shared_preferences_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_locale_provider.g.dart';

const _appLanguageStorageKey = 'app_language';
const _fallbackLocales = [Locale('en'), Locale('es')];

Locale resolveAppLocale(List<Locale>? systemLocales, {Locale? override}) {
  if (override != null) {
    return override;
  }
  return basicLocaleListResolution(systemLocales, _fallbackLocales);
}

@Riverpod(keepAlive: true)
class AppLocale extends _$AppLocale {
  @override
  Future<Locale?> build() async {
    try {
      final preferences = await ref.watch(sharedPreferencesProvider.future);
      final storedCode = preferences.getString(_appLanguageStorageKey);
      final language = appLanguageFromCode(storedCode);
      return language == null ? null : Locale(language.code);
    } catch (_) {
      return null;
    }
  }

  Future<void> select(AppLanguage language) async {
    state = AsyncData(Locale(language.code));
    try {
      final preferences = await ref.read(sharedPreferencesProvider.future);
      await preferences.setString(_appLanguageStorageKey, language.code);
    } catch (_) {
      return;
    }
  }
}

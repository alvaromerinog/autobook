import 'package:autobook/app/localization/app_language.dart';
import 'package:autobook/app/localization/app_locale_provider.dart';
import 'package:autobook/core/di/shared_preferences_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLanguage', () {
    test('exposes only Spanish and English', () {
      expect(AppLanguage.values, [AppLanguage.spanish, AppLanguage.english]);
    });

    test('maps each language to its code and endonym', () {
      expect(AppLanguage.spanish.code, 'es');
      expect(AppLanguage.spanish.endonym, 'Español');
      expect(AppLanguage.english.code, 'en');
      expect(AppLanguage.english.endonym, 'English');
    });
  });

  group('appLanguageFromCode', () {
    test('parses supported codes', () {
      expect(appLanguageFromCode('es'), AppLanguage.spanish);
      expect(appLanguageFromCode('en'), AppLanguage.english);
    });

    test('rejects missing and unsupported codes', () {
      expect(appLanguageFromCode(null), isNull);
      expect(appLanguageFromCode(''), isNull);
      expect(appLanguageFromCode('fr'), isNull);
      expect(appLanguageFromCode('system'), isNull);
    });

    test('rejects codes that are not exactly lowercase language tags', () {
      expect(appLanguageFromCode('ES'), isNull);
      expect(appLanguageFromCode('es-MX'), isNull);
      expect(appLanguageFromCode('en-GB'), isNull);
      expect(appLanguageFromCode(' es'), isNull);
    });
  });

  group('resolveAppLocale', () {
    test('keeps a supported system locale', () {
      expect(resolveAppLocale([const Locale('en')]), const Locale('en'));
      expect(resolveAppLocale([const Locale('es')]), const Locale('es'));
    });

    test('drops the region of a supported system locale', () {
      expect(resolveAppLocale([const Locale('en', 'GB')]), const Locale('en'));
      expect(resolveAppLocale([const Locale('es', 'MX')]), const Locale('es'));
    });

    test('picks the first supported locale in preference order', () {
      expect(
        resolveAppLocale([const Locale('fr'), const Locale('es', 'MX')]),
        const Locale('es'),
      );
      expect(
        resolveAppLocale([const Locale('fr'), const Locale('en', 'GB')]),
        const Locale('en'),
      );
    });

    test('falls back to English for unsupported locales', () {
      expect(resolveAppLocale([const Locale('fr')]), const Locale('en'));
      expect(
        resolveAppLocale([const Locale('de'), const Locale('it')]),
        const Locale('en'),
      );
    });

    test('falls back to English without system locales', () {
      expect(resolveAppLocale(null), const Locale('en'));
      expect(resolveAppLocale(const []), const Locale('en'));
    });

    test('prefers an explicit override over system locales', () {
      expect(
        resolveAppLocale([const Locale('es')], override: const Locale('en')),
        const Locale('en'),
      );
      expect(
        resolveAppLocale(null, override: const Locale('es')),
        const Locale('es'),
      );
    });
  });

  group('AppLocale', () {
    Future<SharedPreferences> preferencesWith(
      Map<String, Object> storedValues,
    ) async {
      SharedPreferences.setMockInitialValues(storedValues);
      return SharedPreferences.getInstance();
    }

    ProviderContainer containerWith(SharedPreferences preferences) {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(AsyncData(preferences)),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    Future<ProviderContainer> loadedContainerWith(
      SharedPreferences preferences,
    ) async {
      final container = containerWith(preferences);
      await container.read(appLocaleProvider.future);
      return container;
    }

    group('build', () {
      test('returns no override when nothing is stored', () async {
        final preferences = await preferencesWith({});
        final container = containerWith(preferences);

        final restored = await container.read(appLocaleProvider.future);

        expect(restored, isNull);
        expect(preferences.getKeys(), isEmpty);
      });

      test('restores a stored English override', () async {
        final preferences = await preferencesWith({'app_language': 'en'});
        final container = containerWith(preferences);

        final restored = await container.read(appLocaleProvider.future);

        expect(restored, const Locale('en'));
      });

      test('restores a stored Spanish override', () async {
        final preferences = await preferencesWith({'app_language': 'es'});
        final container = containerWith(preferences);

        final restored = await container.read(appLocaleProvider.future);

        expect(restored, const Locale('es'));
      });

      test('leaves malformed and unsupported codes untouched', () async {
        final invalidCodes = ['fr', '', 'ES', 'en-GB', ' es ', 'system'];

        for (final storedCode in invalidCodes) {
          final preferences = await preferencesWith({
            'app_language': storedCode,
          });
          final container = containerWith(preferences);

          final restored = await container.read(appLocaleProvider.future);

          expect(restored, isNull, reason: 'stored "$storedCode"');
          expect(
            preferences.getString('app_language'),
            storedCode,
            reason: 'stored "$storedCode" was rewritten',
          );
          expect(
            preferences.getKeys().where((key) => key == 'app_language'),
            hasLength(1),
          );
        }
      });

      test('returns no override when preferences fail to load', () async {
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWith(
              (ref) => Future<SharedPreferences>.error(
                Exception('storage unavailable'),
              ),
            ),
          ],
          retry: (_, _) => null,
        );
        addTearDown(container.dispose);

        final restored = await container.read(appLocaleProvider.future);

        expect(restored, isNull);
        expect(container.read(appLocaleProvider).value, isNull);
      });
    });

    group('select', () {
      test('exposes Spanish immediately and persists its code', () async {
        final preferences = await preferencesWith({});
        final container = await loadedContainerWith(preferences);

        final pending = container
            .read(appLocaleProvider.notifier)
            .select(AppLanguage.spanish);

        expect(container.read(appLocaleProvider).value, const Locale('es'));

        await pending;

        expect(preferences.getString('app_language'), 'es');
        expect(preferences.getKeys(), contains('app_language'));
        expect(
          preferences.getKeys().where((key) => key == 'app_language'),
          hasLength(1),
        );
      });

      test('exposes English immediately and persists its code', () async {
        final preferences = await preferencesWith({});
        final container = await loadedContainerWith(preferences);

        final pending = container
            .read(appLocaleProvider.notifier)
            .select(AppLanguage.english);

        expect(container.read(appLocaleProvider).value, const Locale('en'));

        await pending;

        expect(preferences.getString('app_language'), 'en');
      });

      test('overwrites a previous selection', () async {
        final preferences = await preferencesWith({'app_language': 'es'});
        final container = await loadedContainerWith(preferences);

        await container
            .read(appLocaleProvider.notifier)
            .select(AppLanguage.english);

        expect(container.read(appLocaleProvider).value, const Locale('en'));
        expect(preferences.getString('app_language'), 'en');
      });

      test('restores the selection in a fresh controller', () async {
        final preferences = await preferencesWith({});
        final container = await loadedContainerWith(preferences);

        await container
            .read(appLocaleProvider.notifier)
            .select(AppLanguage.spanish);

        final freshContainer = containerWith(preferences);
        final restored = await freshContainer.read(appLocaleProvider.future);

        expect(restored, const Locale('es'));
        expect(
          freshContainer.read(appLocaleProvider).value,
          const Locale('es'),
        );
        expect(
          preferences.getKeys().where((key) => key == 'app_language'),
          hasLength(1),
        );
      });
    });
  });
}

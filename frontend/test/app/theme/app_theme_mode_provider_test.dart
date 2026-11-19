import 'package:autobook/app/theme/app_theme_mode_provider.dart';
import 'package:autobook/core/di/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('appThemeModeFromCode', () {
    test('parses supported codes', () {
      expect(appThemeModeFromCode('light'), ThemeMode.light);
      expect(appThemeModeFromCode('dark'), ThemeMode.dark);
    });

    test('rejects missing and unsupported codes', () {
      expect(appThemeModeFromCode(null), isNull);
      expect(appThemeModeFromCode(''), isNull);
      expect(appThemeModeFromCode('system'), isNull);
      expect(appThemeModeFromCode('Light'), isNull);
      expect(appThemeModeFromCode(' light'), isNull);
    });
  });

  group('AppThemeMode', () {
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
      await container.read(appThemeModeProvider.future);
      return container;
    }

    group('build', () {
      test('returns no override when nothing is stored', () async {
        final preferences = await preferencesWith({});
        final container = containerWith(preferences);

        final restored = await container.read(appThemeModeProvider.future);

        expect(restored, isNull);
        expect(preferences.getKeys(), isEmpty);
      });

      test('restores a stored light override', () async {
        final preferences = await preferencesWith({'app_theme_mode': 'light'});
        final container = containerWith(preferences);

        final restored = await container.read(appThemeModeProvider.future);

        expect(restored, ThemeMode.light);
      });

      test('restores a stored dark override', () async {
        final preferences = await preferencesWith({'app_theme_mode': 'dark'});
        final container = containerWith(preferences);

        final restored = await container.read(appThemeModeProvider.future);

        expect(restored, ThemeMode.dark);
      });

      test('treats unsupported codes as no override', () async {
        final invalidCodes = ['system', '', 'Light', 'light ', 'black'];

        for (final storedCode in invalidCodes) {
          final preferences = await preferencesWith({
            'app_theme_mode': storedCode,
          });
          final container = containerWith(preferences);

          final restored = await container.read(appThemeModeProvider.future);

          expect(restored, isNull, reason: 'stored "$storedCode"');
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

        final restored = await container.read(appThemeModeProvider.future);

        expect(restored, isNull);
        expect(container.read(appThemeModeProvider).value, isNull);
      });
    });

    group('select', () {
      test('exposes dark immediately and persists its code', () async {
        final preferences = await preferencesWith({});
        final container = await loadedContainerWith(preferences);

        final pending = container
            .read(appThemeModeProvider.notifier)
            .select(ThemeMode.dark);

        expect(container.read(appThemeModeProvider).value, ThemeMode.dark);

        await pending;

        expect(preferences.getString('app_theme_mode'), 'dark');
        expect(
          preferences.getKeys().where((key) => key == 'app_theme_mode'),
          hasLength(1),
        );
      });

      test('exposes light immediately and persists its code', () async {
        final preferences = await preferencesWith({});
        final container = await loadedContainerWith(preferences);

        final pending = container
            .read(appThemeModeProvider.notifier)
            .select(ThemeMode.light);

        expect(container.read(appThemeModeProvider).value, ThemeMode.light);

        await pending;

        expect(preferences.getString('app_theme_mode'), 'light');
      });

      test('overwrites a previous selection', () async {
        final preferences = await preferencesWith({'app_theme_mode': 'dark'});
        final container = await loadedContainerWith(preferences);

        await container
            .read(appThemeModeProvider.notifier)
            .select(ThemeMode.light);

        expect(container.read(appThemeModeProvider).value, ThemeMode.light);
        expect(preferences.getString('app_theme_mode'), 'light');
      });

      test('restores the selection in a fresh container', () async {
        final preferences = await preferencesWith({});
        final container = await loadedContainerWith(preferences);

        await container
            .read(appThemeModeProvider.notifier)
            .select(ThemeMode.dark);

        final freshContainer = containerWith(preferences);
        final restored = await freshContainer.read(appThemeModeProvider.future);

        expect(restored, ThemeMode.dark);
        expect(freshContainer.read(appThemeModeProvider).value, ThemeMode.dark);
        expect(
          preferences.getKeys().where((key) => key == 'app_theme_mode'),
          hasLength(1),
        );
      });

      test('keeps the selection when persisting fails', () async {
        final mockPreferences = MockSharedPreferences();
        when(() => mockPreferences.getString(any())).thenReturn(null);
        when(
          () => mockPreferences.setString(any(), any()),
        ).thenThrow(Exception('write failed'));
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(
              AsyncData(mockPreferences),
            ),
          ],
        );
        addTearDown(container.dispose);
        await container.read(appThemeModeProvider.future);

        await container
            .read(appThemeModeProvider.notifier)
            .select(ThemeMode.dark);

        expect(container.read(appThemeModeProvider).value, ThemeMode.dark);
      });
    });
  });
}

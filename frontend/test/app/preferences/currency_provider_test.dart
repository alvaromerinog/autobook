import 'package:autobook/app/preferences/currency_provider.dart';
import 'package:autobook/core/di/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Currency', () {
    test('exposes only euro and dollar', () {
      expect(Currency.values, [Currency.euro, Currency.dollar]);
    });

    test('maps each currency to its code', () {
      expect(Currency.euro.code, 'euro');
      expect(Currency.dollar.code, 'dollar');
    });
  });

  group('currencyFromCode', () {
    test('parses supported codes', () {
      expect(currencyFromCode('euro'), Currency.euro);
      expect(currencyFromCode('dollar'), Currency.dollar);
    });

    test('rejects missing and unsupported codes', () {
      expect(currencyFromCode(null), isNull);
      expect(currencyFromCode(''), isNull);
      expect(currencyFromCode('EUR'), isNull);
      expect(currencyFromCode('dollar '), isNull);
    });
  });

  group('CurrencySetting', () {
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
      await container.read(currencySettingProvider.future);
      return container;
    }

    group('build', () {
      test('defaults to euro when nothing is stored', () async {
        final preferences = await preferencesWith({});
        final container = containerWith(preferences);

        final restored = await container.read(currencySettingProvider.future);

        expect(restored, Currency.euro);
        expect(preferences.getKeys(), isEmpty);
      });

      test('restores a stored dollar selection', () async {
        final preferences = await preferencesWith({'currency': 'dollar'});
        final container = containerWith(preferences);

        final restored = await container.read(currencySettingProvider.future);

        expect(restored, Currency.dollar);
      });

      test('falls back to euro on unsupported codes', () async {
        final invalidCodes = ['', 'Dollar', 'dollar ', 'yen', 'USD'];

        for (final storedCode in invalidCodes) {
          final preferences = await preferencesWith({'currency': storedCode});
          final container = containerWith(preferences);

          final restored = await container.read(currencySettingProvider.future);

          expect(restored, Currency.euro, reason: 'stored "$storedCode"');
        }
      });

      test('defaults to euro when preferences fail to load', () async {
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

        final restored = await container.read(currencySettingProvider.future);

        expect(restored, Currency.euro);
        expect(container.read(currencySettingProvider).value, Currency.euro);
      });
    });

    group('select', () {
      test('exposes dollar immediately and persists its code', () async {
        final preferences = await preferencesWith({});
        final container = await loadedContainerWith(preferences);

        final pending = container
            .read(currencySettingProvider.notifier)
            .select(Currency.dollar);

        expect(container.read(currencySettingProvider).value, Currency.dollar);

        await pending;

        expect(preferences.getString('currency'), 'dollar');
        expect(
          preferences.getKeys().where((key) => key == 'currency'),
          hasLength(1),
        );
      });

      test('overwrites a previous selection', () async {
        final preferences = await preferencesWith({'currency': 'dollar'});
        final container = await loadedContainerWith(preferences);

        await container
            .read(currencySettingProvider.notifier)
            .select(Currency.euro);

        expect(container.read(currencySettingProvider).value, Currency.euro);
        expect(preferences.getString('currency'), 'euro');
      });

      test('restores the selection in a fresh container', () async {
        final preferences = await preferencesWith({});
        final container = await loadedContainerWith(preferences);

        await container
            .read(currencySettingProvider.notifier)
            .select(Currency.dollar);

        final freshContainer = containerWith(preferences);
        final restored = await freshContainer.read(
          currencySettingProvider.future,
        );

        expect(restored, Currency.dollar);
        expect(
          freshContainer.read(currencySettingProvider).value,
          Currency.dollar,
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
        await container.read(currencySettingProvider.future);

        await container
            .read(currencySettingProvider.notifier)
            .select(Currency.dollar);

        expect(container.read(currencySettingProvider).value, Currency.dollar);
      });
    });
  });
}

import 'package:autobook/app/preferences/distance_unit_provider.dart';
import 'package:autobook/core/di/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DistanceUnit', () {
    test('exposes only kilometers and miles', () {
      expect(DistanceUnit.values, [
        DistanceUnit.kilometers,
        DistanceUnit.miles,
      ]);
    });

    test('maps each unit to its code', () {
      expect(DistanceUnit.kilometers.code, 'kilometers');
      expect(DistanceUnit.miles.code, 'miles');
    });
  });

  group('distanceUnitFromCode', () {
    test('parses supported codes', () {
      expect(distanceUnitFromCode('kilometers'), DistanceUnit.kilometers);
      expect(distanceUnitFromCode('miles'), DistanceUnit.miles);
    });

    test('rejects missing and unsupported codes', () {
      expect(distanceUnitFromCode(null), isNull);
      expect(distanceUnitFromCode(''), isNull);
      expect(distanceUnitFromCode('Kilometers'), isNull);
      expect(distanceUnitFromCode('miles '), isNull);
    });
  });

  group('DistanceUnitSetting', () {
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
      await container.read(distanceUnitSettingProvider.future);
      return container;
    }

    group('build', () {
      test('defaults to kilometers when nothing is stored', () async {
        final preferences = await preferencesWith({});
        final container = containerWith(preferences);

        final restored = await container.read(
          distanceUnitSettingProvider.future,
        );

        expect(restored, DistanceUnit.kilometers);
        expect(preferences.getKeys(), isEmpty);
      });

      test('restores a stored miles selection', () async {
        final preferences = await preferencesWith({'distance_unit': 'miles'});
        final container = containerWith(preferences);

        final restored = await container.read(
          distanceUnitSettingProvider.future,
        );

        expect(restored, DistanceUnit.miles);
      });

      test('falls back to kilometers on unsupported codes', () async {
        final invalidCodes = ['', 'Miles', 'miles ', 'meters'];

        for (final storedCode in invalidCodes) {
          final preferences = await preferencesWith({
            'distance_unit': storedCode,
          });
          final container = containerWith(preferences);

          final restored = await container.read(
            distanceUnitSettingProvider.future,
          );

          expect(
            restored,
            DistanceUnit.kilometers,
            reason: 'stored "$storedCode"',
          );
        }
      });

      test('defaults to kilometers when preferences fail to load', () async {
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

        final restored = await container.read(
          distanceUnitSettingProvider.future,
        );

        expect(restored, DistanceUnit.kilometers);
        expect(
          container.read(distanceUnitSettingProvider).value,
          DistanceUnit.kilometers,
        );
      });
    });

    group('select', () {
      test('exposes miles immediately and persists its code', () async {
        final preferences = await preferencesWith({});
        final container = await loadedContainerWith(preferences);

        final pending = container
            .read(distanceUnitSettingProvider.notifier)
            .select(DistanceUnit.miles);

        expect(
          container.read(distanceUnitSettingProvider).value,
          DistanceUnit.miles,
        );

        await pending;

        expect(preferences.getString('distance_unit'), 'miles');
        expect(
          preferences.getKeys().where((key) => key == 'distance_unit'),
          hasLength(1),
        );
      });

      test('overwrites a previous selection', () async {
        final preferences = await preferencesWith({'distance_unit': 'miles'});
        final container = await loadedContainerWith(preferences);

        await container
            .read(distanceUnitSettingProvider.notifier)
            .select(DistanceUnit.kilometers);

        expect(
          container.read(distanceUnitSettingProvider).value,
          DistanceUnit.kilometers,
        );
        expect(preferences.getString('distance_unit'), 'kilometers');
      });

      test('restores the selection in a fresh container', () async {
        final preferences = await preferencesWith({});
        final container = await loadedContainerWith(preferences);

        await container
            .read(distanceUnitSettingProvider.notifier)
            .select(DistanceUnit.miles);

        final freshContainer = containerWith(preferences);
        final restored = await freshContainer.read(
          distanceUnitSettingProvider.future,
        );

        expect(restored, DistanceUnit.miles);
        expect(
          freshContainer.read(distanceUnitSettingProvider).value,
          DistanceUnit.miles,
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
        await container.read(distanceUnitSettingProvider.future);

        await container
            .read(distanceUnitSettingProvider.notifier)
            .select(DistanceUnit.miles);

        expect(
          container.read(distanceUnitSettingProvider).value,
          DistanceUnit.miles,
        );
      });
    });
  });
}

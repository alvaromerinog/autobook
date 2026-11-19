import 'package:autobook/app/preferences/notifications_enabled_provider.dart';
import 'package:autobook/core/di/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationsEnabled', () {
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
      await container.read(notificationsEnabledProvider.future);
      return container;
    }

    group('build', () {
      test('defaults to disabled when nothing is stored', () async {
        final preferences = await preferencesWith({});
        final container = containerWith(preferences);

        final restored = await container.read(
          notificationsEnabledProvider.future,
        );

        expect(restored, isFalse);
        expect(preferences.getKeys(), isEmpty);
      });

      test('restores a stored enabled selection', () async {
        final preferences = await preferencesWith({
          'notifications_enabled': true,
        });
        final container = containerWith(preferences);

        final restored = await container.read(
          notificationsEnabledProvider.future,
        );

        expect(restored, isTrue);
      });

      test('restores a stored disabled selection', () async {
        final preferences = await preferencesWith({
          'notifications_enabled': false,
        });
        final container = containerWith(preferences);

        final restored = await container.read(
          notificationsEnabledProvider.future,
        );

        expect(restored, isFalse);
      });

      test('defaults to disabled when preferences fail to load', () async {
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
          notificationsEnabledProvider.future,
        );

        expect(restored, isFalse);
        expect(container.read(notificationsEnabledProvider).value, isFalse);
      });
    });

    group('setEnabled', () {
      test('exposes enabled immediately and persists it', () async {
        final preferences = await preferencesWith({});
        final container = await loadedContainerWith(preferences);

        final pending = container
            .read(notificationsEnabledProvider.notifier)
            .setEnabled(true);

        expect(container.read(notificationsEnabledProvider).value, isTrue);

        await pending;

        expect(preferences.getBool('notifications_enabled'), isTrue);
        expect(
          preferences.getKeys().where((key) => key == 'notifications_enabled'),
          hasLength(1),
        );
      });

      test('overwrites a previous selection', () async {
        final preferences = await preferencesWith({
          'notifications_enabled': true,
        });
        final container = await loadedContainerWith(preferences);

        await container
            .read(notificationsEnabledProvider.notifier)
            .setEnabled(false);

        expect(container.read(notificationsEnabledProvider).value, isFalse);
        expect(preferences.getBool('notifications_enabled'), isFalse);
      });

      test('restores the selection in a fresh container', () async {
        final preferences = await preferencesWith({});
        final container = await loadedContainerWith(preferences);

        await container
            .read(notificationsEnabledProvider.notifier)
            .setEnabled(true);

        final freshContainer = containerWith(preferences);
        final restored = await freshContainer.read(
          notificationsEnabledProvider.future,
        );

        expect(restored, isTrue);
        expect(freshContainer.read(notificationsEnabledProvider).value, isTrue);
      });

      test('keeps the selection when persisting fails', () async {
        final mockPreferences = MockSharedPreferences();
        when(() => mockPreferences.getBool(any())).thenReturn(null);
        when(
          () => mockPreferences.setBool(any(), any()),
        ).thenThrow(Exception('write failed'));
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(
              AsyncData(mockPreferences),
            ),
          ],
        );
        addTearDown(container.dispose);
        await container.read(notificationsEnabledProvider.future);

        await container
            .read(notificationsEnabledProvider.notifier)
            .setEnabled(true);

        expect(container.read(notificationsEnabledProvider).value, isTrue);
      });
    });
  });
}

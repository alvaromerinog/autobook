import 'package:autobook/core/di/shared_preferences_provider.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/settings/data/file_delivery/file_saver.dart';
import 'package:autobook/features/settings/data/repositories/autobook_data_repository.dart';
import 'package:autobook/features/settings/presentation/providers/backup_providers.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockAutobookDataRepository extends Mock
    implements AutobookDataRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BackupController', () {
    group('createBackup', () {
      test('persists the last backup timestamp after delivery', () async {
        SharedPreferences.setMockInitialValues({});
        final preferences = await SharedPreferences.getInstance();
        final mockRepository = MockAutobookDataRepository();
        when(
          () => mockRepository.loadAll(),
        ).thenAnswer((_) async => (<Car>[], <Maintenance>[]));
        final deliveredFileNames = <String>[];
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(AsyncData(preferences)),
            autobookDataRepositoryProvider.overrideWithValue(mockRepository),
            fileDeliveryProvider.overrideWithValue(({
              required fileName,
              required bytes,
            }) async {
              deliveredFileNames.add(fileName);
            }),
          ],
        );
        addTearDown(container.dispose);
        await container.read(lastBackupAtProvider.future);

        final result = await container
            .read(backupControllerProvider)
            .createBackup();

        final storedBackupAt = preferences.getString('last_backup_at');
        expect(result, isA<BackupSucceeded>());
        expect(storedBackupAt, isNotNull);
        expect(DateTime.tryParse(storedBackupAt!), isNotNull);
        expect(
          container.read(lastBackupAtProvider).value,
          DateTime.parse(storedBackupAt),
        );
        expect(
          deliveredFileNames.single,
          matches(RegExp(r'^autobook_backup_\d{8}_\d{4}\.json$')),
        );
        expect(
          deliveredFileNames.single,
          backupFileName(DateTime.parse(storedBackupAt)),
        );
      });

      test(
        'reports failure and records nothing when delivery throws',
        () async {
          SharedPreferences.setMockInitialValues({});
          final preferences = await SharedPreferences.getInstance();
          final mockRepository = MockAutobookDataRepository();
          when(
            () => mockRepository.loadAll(),
          ).thenAnswer((_) async => (<Car>[], <Maintenance>[]));
          final container = ProviderContainer(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(
                AsyncData(preferences),
              ),
              autobookDataRepositoryProvider.overrideWithValue(mockRepository),
              fileDeliveryProvider.overrideWithValue(({
                required fileName,
                required bytes,
              }) async {
                throw Exception('delivery failed');
              }),
            ],
          );
          addTearDown(container.dispose);
          await container.read(lastBackupAtProvider.future);

          final result = await container
              .read(backupControllerProvider)
              .createBackup();

          expect(result, isA<BackupFailed>());
          expect(preferences.getString('last_backup_at'), isNull);
          expect(container.read(lastBackupAtProvider).value, isNull);
        },
      );
    });
  });

  group('LastBackupAt', () {
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
      await container.read(lastBackupAtProvider.future);
      return container;
    }

    group('build', () {
      test('returns null when nothing is stored', () async {
        final preferences = await preferencesWith({});
        final container = containerWith(preferences);

        final restored = await container.read(lastBackupAtProvider.future);

        expect(restored, isNull);
        expect(preferences.getKeys(), isEmpty);
      });

      test('restores a stored timestamp', () async {
        final exportedAt = DateTime(2026, 11, 1, 10, 30);
        final preferences = await preferencesWith({
          'last_backup_at': exportedAt.toIso8601String(),
        });
        final container = containerWith(preferences);

        final restored = await container.read(lastBackupAtProvider.future);

        expect(restored, exportedAt);
      });

      test('treats a malformed stored value as absent', () async {
        final preferences = await preferencesWith({'last_backup_at': 'soon'});
        final container = containerWith(preferences);

        final restored = await container.read(lastBackupAtProvider.future);

        expect(restored, isNull);
      });
    });

    group('record', () {
      test('exposes the timestamp immediately and persists it', () async {
        final preferences = await preferencesWith({});
        final container = await loadedContainerWith(preferences);
        final exportedAt = DateTime(2026, 11, 19, 9, 45);

        final pending = container
            .read(lastBackupAtProvider.notifier)
            .record(exportedAt);

        expect(container.read(lastBackupAtProvider).value, exportedAt);

        await pending;

        final storedBackupAt = preferences.getString('last_backup_at');
        expect(storedBackupAt, exportedAt.toIso8601String());
        expect(
          preferences.getKeys().where((key) => key == 'last_backup_at'),
          hasLength(1),
        );
      });

      test('keeps the state when persisting fails', () async {
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
        await container.read(lastBackupAtProvider.future);
        final exportedAt = DateTime(2026, 11, 19, 9, 45);

        await container.read(lastBackupAtProvider.notifier).record(exportedAt);

        expect(container.read(lastBackupAtProvider).value, exportedAt);
      });
    });
  });
}

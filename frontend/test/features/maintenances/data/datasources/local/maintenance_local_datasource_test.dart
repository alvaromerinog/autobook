import 'package:autobook/features/maintenances/data/datasources/local/maintenance_local_datasource.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/features/vehicles/data/datasources/local/app_database.dart';
import 'package:autobook/features/vehicles/domain/entities/sync_state.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/maintenance_fixtures.dart';

void main() {
  late AppDatabase db;
  late MaintenanceLocalDataSource datasource;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    datasource = MaintenanceLocalDatasourceImpl(db);
  });

  tearDown(() async => await db.close());

  group('MaintenanceLocalDataSource', () {
    group('getAll', () {
      test('given rows inserted out of date order, '
          'when getAll is called, '
          'then returns rows sorted by date desc and updatedAt desc',
          () async {
        // given
        const carId = 'car-1';
        final m1 = buildMaintenance(
          id: 'a',
          carId: carId,
          date: '2026-01-05',
        );
        final m2 = buildMaintenance(
          id: 'b',
          carId: carId,
          date: '2026-03-12',
        );
        final m3 = buildMaintenance(
          id: 'c',
          carId: carId,
          date: '2025-11-18',
        );
        await datasource.insertPending(m1);
        await datasource.insertPending(m2);
        await datasource.insertPending(m3);

        // when
        final rows = await datasource.getAll(carId);

        // then
        expect(rows.map((m) => m.id), ['b', 'a', 'c']);
      });

      test('given rows of other cars, '
          'when getAll is called with a carId, '
          'then only that car rows are returned, sorted by date desc',
          () async {
        // given
        await datasource.insertPending(
          buildMaintenance(id: 'x', carId: 'other', date: '2026-05-01'),
        );
        await datasource.insertPending(
          buildMaintenance(id: 'y', carId: 'car-1', date: '2026-02-01'),
        );
        await datasource.insertPending(
          buildMaintenance(id: 'z', carId: 'car-1', date: '2026-04-01'),
        );

        // when
        final rows = await datasource.getAll('car-1');

        // then
        expect(rows.map((m) => m.id), ['z', 'y']);
      });
    });
  });
}
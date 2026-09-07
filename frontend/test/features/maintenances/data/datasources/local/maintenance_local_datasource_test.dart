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
          'then returns rows sorted by date desc and updatedAt desc', () async {
        // given
        const carId = 'car-1';
        final m1 = buildMaintenance(id: 'a', carId: carId, date: '2026-01-05');
        final m2 = buildMaintenance(id: 'b', carId: carId, date: '2026-03-12');
        final m3 = buildMaintenance(id: 'c', carId: carId, date: '2025-11-18');
        await datasource.insertPending(m1);
        await datasource.insertPending(m2);
        await datasource.insertPending(m3);

        // when
        final rows = await datasource.getAll(carId);

        // then
        expect(rows.map((m) => m.id), ['b', 'a', 'c']);
      });

      test(
        'given rows of other cars, '
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
        },
      );
    });

    group('getOne', () {
      test('given rows of several cars, '
          'when getOne is called with a carId, '
          'then only that car row is matched', () async {
        // given
        final otherCarRow = buildMaintenance(
          id: 'x',
          carId: 'other',
          type: MaintenanceType.battery,
        );
        await datasource.insertPending(otherCarRow);
        await datasource.insertPending(oilChangeMarch);

        // when
        final found = await datasource.getOne('car-1', '1');
        final wrongScope = await datasource.getOne('car-1', 'x');
        final missing = await datasource.getOne('nope', '1');

        // then
        expect(found, oilChangeMarch);
        expect(wrongScope, isNull);
        expect(missing, isNull);
      });

      test('given no row for the id, '
          'when getOne is called, '
          'then returns null', () async {
        // given
        await datasource.insertPending(oilChangeMarch);

        // when
        final found = await datasource.getOne('car-1', 'missing');

        // then
        expect(found, isNull);
      });
    });

    group('insertPending', () {
      test('given a new maintenance, '
          'when insertPending is called, '
          'then the row exists with state pendingCreate', () async {
        // given
        const maintenance = oilChangeMarch;

        // when
        await datasource.insertPending(maintenance);

        // then
        expect(await datasource.getAll('car-1'), [maintenance]);
        final pendingMaintenances = await datasource.getPending();
        expect(pendingMaintenances, hasLength(1));
        expect(pendingMaintenances.single.maintenance, maintenance);
        expect(
          pendingMaintenances.single.syncState,
          SyncStateEnum.pendingCreate,
        );
      });
    });

    group('upsertPending', () {
      test('given an existing synced row, '
          'when upsertPending is called with pendingUpdate, '
          'then the row is updated with state pendingUpdate', () async {
        // given
        await datasource.upsertAll([oilChangeMarch]);

        // when
        final updatedMaintenance = oilChangeMarch.copyWith(
          mileage: 10500,
          cost: 60,
        );
        await datasource.upsertPending(
          updatedMaintenance,
          syncState: SyncStateEnum.pendingUpdate,
        );

        // then
        final pendingMaintenances = await datasource.getPending();
        expect(pendingMaintenances, hasLength(1));
        expect(pendingMaintenances.single.maintenance, updatedMaintenance);
        expect(
          pendingMaintenances.single.syncState,
          SyncStateEnum.pendingUpdate,
        );
      });
    });

    group('getPending', () {
      test(
        'given synced and pending rows, '
        'when getPending is called, '
        'then only non-synced rows are returned with states intact',
        () async {
          // given
          await datasource.upsertAll([tireSwapJanuary]);
          await datasource.insertPending(brakesPending);
          await datasource.upsertPending(
            batteryPending,
            syncState: SyncStateEnum.pendingUpdate,
          );

          // when
          final pendingMaintenances = await datasource.getPending();

          // then
          final pendingIds = pendingMaintenances.map((p) => p.maintenance.id);
          expect(pendingIds, containsAll(['pend1', 'pend2']));
          expect(pendingIds, isNot(contains('2')));
          final pendingById = {
            for (final p in pendingMaintenances) p.maintenance.id: p.syncState,
          };
          expect(pendingById['pend1'], SyncStateEnum.pendingCreate);
          expect(pendingById['pend2'], SyncStateEnum.pendingUpdate);
        },
      );
    });

    group('countPending', () {
      test('given synced and pending rows across cars, '
          'when countPending is called, '
          'then returns only non-synced rows of that car', () async {
        // given
        await datasource.upsertAll([tireSwapJanuary]);
        await datasource.insertPending(brakesPending);
        await datasource.upsertPending(
          batteryPending,
          syncState: SyncStateEnum.pendingDelete,
        );
        await datasource.insertPending(
          buildMaintenance(id: 'o1', carId: 'other', date: '2026-05-01'),
        );

        // when
        final pendingCount = await datasource.countPending('car-1');

        // then
        expect(pendingCount, 2);
      });

      test('given no pending rows for the car, '
          'when countPending is called, '
          'then returns zero', () async {
        // given
        await datasource.upsertAll([oilChangeMarch]);

        // when
        final pendingCount = await datasource.countPending('car-1');

        // then
        expect(pendingCount, 0);
      });
    });

    group('markSynced', () {
      test('given a pending row, '
          'when markSynced is called, '
          'then the row is excluded from getPending afterwards', () async {
        // given
        await datasource.insertPending(brakesPending);

        // when
        await datasource.markSynced('pend1');

        // then
        expect(await datasource.getPending(), isEmpty);
        expect(await datasource.getAll('car-1'), [brakesPending]);
        expect(await datasource.countPending('car-1'), 0);
      });
    });

    group('markPendingDelete', () {
      test('given a synced row, '
          'when markPendingDelete is called, '
          'then the row shows pendingDelete in getPending and '
          'pendingDeleteIds', () async {
        // given
        await datasource.upsertAll([oilChangeMarch]);

        // when
        await datasource.markPendingDelete('1');

        // then
        final pendingMaintenances = await datasource.getPending();
        expect(pendingMaintenances, hasLength(1));
        expect(pendingMaintenances.single.maintenance, oilChangeMarch);
        expect(
          pendingMaintenances.single.syncState,
          SyncStateEnum.pendingDelete,
        );
        expect(await datasource.pendingDeleteIds('car-1'), {'1'});
      });
    });

    group('hardDelete', () {
      test('given an inserted row, '
          'when hardDelete is called, '
          'then the row disappears from getAll and getPending', () async {
        // given
        await datasource.insertPending(brakesPending);

        // when
        await datasource.hardDelete('pend1');

        // then
        expect(await datasource.getAll('car-1'), isEmpty);
        expect(await datasource.getPending(), isEmpty);
      });
    });

    group('hardDeleteForCar', () {
      test('given rows of several cars, '
          'when hardDeleteForCar is called, '
          'then only that car rows are removed', () async {
        // given
        await datasource.insertPending(oilChangeMarch);
        await datasource.insertPending(tireSwapJanuary);
        await datasource.insertPending(
          buildMaintenance(id: 'x1', carId: 'other', date: '2026-05-01'),
        );

        // when
        await datasource.hardDeleteForCar('car-1');

        // then
        expect(await datasource.getAll('car-1'), isEmpty);
        expect((await datasource.getAll('other')).map((m) => m.id), ['x1']);
      });
    });

    group('syncStateOf', () {
      test('given no row for the id, '
          'when syncStateOf is called, '
          'then returns null', () async {
        // given
        await datasource.upsertAll([oilChangeMarch]);

        // when
        final state = await datasource.syncStateOf('missing');

        // then
        expect(state, isNull);
      });

      test('given a row with a sync state, '
          'when syncStateOf is called, '
          'then returns that state', () async {
        // given
        await datasource.insertPending(brakesPending);

        // when
        final state = await datasource.syncStateOf('pend1');

        // then
        expect(state, SyncStateEnum.pendingCreate);
      });
    });

    group('getAllWithStates', () {
      test('given rows with mixed states, '
          'when getAllWithStates is called, '
          'then returns every row of that car with its sync state', () async {
        // given
        await datasource.upsertAll([oilChangeMarch]);
        await datasource.insertPending(brakesPending);
        await datasource.upsertPending(
          tireSwapJanuary.copyWith(cost: 130),
          syncState: SyncStateEnum.pendingUpdate,
        );
        await datasource.insertPending(
          buildMaintenance(id: 'z9', carId: 'other', date: '2026-06-01'),
        );

        // when
        final rows = await datasource.getAllWithStates('car-1');

        // then
        final byId = {for (final row in rows) row.maintenance.id: row};
        expect(byId, hasLength(3));
        expect(byId['1']!.syncState, SyncStateEnum.synced);
        expect(byId['pend1']!.syncState, SyncStateEnum.pendingCreate);
        expect(byId['2']!.syncState, SyncStateEnum.pendingUpdate);
      });
    });

    group('pendingDeleteIds', () {
      test('given only some rows pending delete, '
          'when pendingDeleteIds is called, '
          'then returns only those ids of that car', () async {
        // given
        await datasource.upsertAll([oilChangeMarch]);
        await datasource.upsertPending(
          brakesPending,
          syncState: SyncStateEnum.pendingDelete,
        );
        await datasource.upsertPending(
          buildMaintenance(id: 'q1', carId: 'other', date: '2026-07-01'),
          syncState: SyncStateEnum.pendingDelete,
        );

        // when
        final ids = await datasource.pendingDeleteIds('car-1');

        // then
        expect(ids, {'pend1'});
      });
    });

    group('upsertAll', () {
      test('given a new maintenance, '
          'when upsertAll is called, '
          'then the row defaults to synced', () async {
        // given
        const maintenance = oilChangeMarch;

        // when
        await datasource.upsertAll([maintenance]);

        // then
        expect(await datasource.getAll('car-1'), [maintenance]);
        expect(await datasource.getPending(), isEmpty);
        expect(await datasource.countPending('car-1'), 0);
        expect(await datasource.syncStateOf('1'), SyncStateEnum.synced);
      });

      test('given a pending row already stored, '
          'when upsertAll updates it on conflict, '
          'then the syncState column is preserved', () async {
        // given
        await datasource.insertPending(brakesPending);

        // when
        final remoteBrakes = brakesPending.copyWith(garage: 'Remote Garage');
        await datasource.upsertAll([remoteBrakes]);

        // then
        final pendingMaintenances = await datasource.getPending();
        expect(pendingMaintenances, hasLength(1));
        expect(pendingMaintenances.single.maintenance, remoteBrakes);
        expect(
          pendingMaintenances.single.syncState,
          SyncStateEnum.pendingCreate,
        );
      });
    });
  });
}

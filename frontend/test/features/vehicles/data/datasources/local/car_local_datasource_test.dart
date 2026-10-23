import 'package:autobook/features/vehicles/data/datasources/local/app_database.dart';
import 'package:autobook/features/vehicles/data/datasources/local/car_local_datasource.dart';
import 'package:autobook/features/vehicles/domain/entities/sync_state.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/car_fixtures.dart';

void main() {
  late AppDatabase db;
  late CarLocalDataSource datasource;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    datasource = CarLocalDatasourceImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('CarLocalDataSource', () {
    group('insertPending', () {
      test('given a new car, '
          'when insertPending is called, '
          'then the row exists with state pendingCreate', () async {
        const car = toyotaCorolla;

        await datasource.insertPending(car);

        final cars = await datasource.getAll();
        expect(cars, [car]);
        final pendingCars = await datasource.getPending();
        expect(pendingCars, hasLength(1));
        expect(pendingCars.single.car, car);
        expect(pendingCars.single.syncState, SyncStateEnum.pendingCreate);
      });
    });

    group('upsertPending', () {
      test('given an existing synced car, '
          'when upsertPending is called with pendingUpdate, '
          'then the row is updated with state pendingUpdate', () async {
        const car = toyotaCorolla;
        await datasource.upsertAll([car]);

        final updatedCar = buildCar(color: 'Red', mileage: 45000);
        await datasource.upsertPending(
          updatedCar,
          syncState: SyncStateEnum.pendingUpdate,
        );

        final pendingCars = await datasource.getPending();
        expect(pendingCars, hasLength(1));
        expect(pendingCars.single.car, updatedCar);
        expect(pendingCars.single.syncState, SyncStateEnum.pendingUpdate);
      });
    });

    group('getPending', () {
      test(
        'given synced and pending cars, '
        'when getPending is called, '
        'then only non-synced rows are returned with states intact',
        () async {
          await datasource.upsertAll([fordFocus]);
          await datasource.insertPending(fiat500);
          await datasource.upsertPending(
            alfaGiulia,
            syncState: SyncStateEnum.pendingUpdate,
          );

          final pendingCars = await datasource.getPending();

          final pendingIds = pendingCars.map((p) => p.car.id);
          expect(pendingIds, containsAll(['pend1', 'pend2']));
          expect(pendingIds, isNot(contains('2')));
          final pendingById = {
            for (final pending in pendingCars)
              pending.car.id: pending.syncState,
          };
          expect(pendingById['pend1'], SyncStateEnum.pendingCreate);
          expect(pendingById['pend2'], SyncStateEnum.pendingUpdate);
        },
      );
    });

    group('countPending', () {
      test('given synced and pending cars, '
          'when countPending is called, '
          'then returns only the number of non-synced rows', () async {
        await datasource.upsertAll([fordFocus]);
        await datasource.insertPending(fiat500);
        await datasource.upsertPending(
          alfaGiulia,
          syncState: SyncStateEnum.pendingUpdate,
        );

        final pendingCount = await datasource.countPending();

        expect(pendingCount, 2);
      });

      test('given no pending cars, '
          'when countPending is called, '
          'then returns zero', () async {
        await datasource.upsertAll([fordFocus]);

        final pendingCount = await datasource.countPending();

        expect(pendingCount, 0);
      });
    });

    group('markSynced', () {
      test('given a pending car, '
          'when markSynced is called, '
          'then the row is excluded from getPending afterwards', () async {
        await datasource.insertPending(fiat500);

        await datasource.markSynced('pend1');

        expect(await datasource.getPending(), isEmpty);
        expect(await datasource.getAll(), [fiat500]);
      });
    });

    group('markPendingDelete', () {
      test('given a synced car, '
          'when markPendingDelete is called, '
          'then the row shows pendingDelete in getPending and '
          'pendingDeleteIds', () async {
        await datasource.upsertAll([toyotaCorolla]);

        await datasource.markPendingDelete('1');

        final pendingCars = await datasource.getPending();
        expect(pendingCars, hasLength(1));
        expect(pendingCars.single.car, toyotaCorolla);
        expect(pendingCars.single.syncState, SyncStateEnum.pendingDelete);
        expect(await datasource.pendingDeleteIds(), {'1'});
      });
    });

    group('hardDelete', () {
      test('given an inserted car, '
          'when hardDelete is called, '
          'then the row disappears from getAll and getPending', () async {
        await datasource.insertPending(fiat500);

        await datasource.hardDelete('pend1');

        expect(await datasource.getAll(), isEmpty);
        expect(await datasource.getPending(), isEmpty);
      });
    });

    group('hardDeleteMany', () {
      test('given three rows, '
          'when hardDeleteMany is called with two ids, '
          'then only those ids are removed', () async {
        await datasource.upsertAll([toyotaCorolla, fordFocus, renaultMegane]);

        await datasource.hardDeleteMany(['1', 'n1']);

        final remaining = (await datasource.getAll()).map((c) => c.id);
        expect(remaining, ['2']);
      });

      test('given an empty id list, '
          'when hardDeleteMany is called, '
          'then no rows are removed', () async {
        await datasource.upsertAll([toyotaCorolla]);

        await datasource.hardDeleteMany([]);

        expect(await datasource.getAll(), [toyotaCorolla]);
      });
    });

    group('syncStateOf', () {
      test('given no row for the id, '
          'when syncStateOf is called, '
          'then returns null', () async {
        await datasource.upsertAll([toyotaCorolla]);

        final state = await datasource.syncStateOf('missing');

        expect(state, isNull);
      });

      test('given a row with a sync state, '
          'when syncStateOf is called, '
          'then returns that state', () async {
        await datasource.insertPending(fiat500);

        final state = await datasource.syncStateOf('pend1');

        expect(state, SyncStateEnum.pendingCreate);
      });
    });

    group('getAllWithStates', () {
      test('given rows with mixed states, '
          'when getAllWithStates is called, '
          'then returns every row with its sync state', () async {
        await datasource.upsertAll([toyotaCorolla]);
        await datasource.upsertPending(
          fiat500,
          syncState: SyncStateEnum.pendingDelete,
        );

        final rows = await datasource.getAllWithStates();

        final byId = {for (final row in rows) row.car.id: row.syncState};
        expect(byId['1'], SyncStateEnum.synced);
        expect(byId['pend1'], SyncStateEnum.pendingDelete);
      });
    });

    group('pendingDeleteIds', () {
      test('given only some rows pending delete, '
          'when pendingDeleteIds is called, '
          'then returns only those ids', () async {
        await datasource.upsertAll([toyotaCorolla]);
        await datasource.upsertPending(
          fiat500,
          syncState: SyncStateEnum.pendingDelete,
        );

        final ids = await datasource.pendingDeleteIds();

        expect(ids, {'pend1'});
      });
    });

    group('upsertAll', () {
      test('given a new car, '
          'when upsertAll is called, '
          'then the row defaults to synced', () async {
        const car = toyotaCorolla;

        await datasource.upsertAll([car]);

        expect(await datasource.getAll(), [car]);
        expect(await datasource.getPending(), isEmpty);
        expect(await datasource.countPending(), 0);
      });

      test('given a pending car already stored, '
          'when upsertAll updates it on conflict, '
          'then the pending state is preserved', () async {
        await datasource.insertPending(fiat500);

        final remoteFiat = buildCar(id: 'pend1', color: 'Blue');
        await datasource.upsertAll([remoteFiat]);

        final pendingCars = await datasource.getPending();
        expect(pendingCars, hasLength(1));
        expect(pendingCars.single.car, remoteFiat);
        expect(pendingCars.single.syncState, SyncStateEnum.pendingCreate);
      });
    });
  });
}

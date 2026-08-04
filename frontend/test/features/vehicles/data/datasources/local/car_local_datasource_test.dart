import 'package:autobook/features/vehicles/data/datasources/local/app_database.dart';
import 'package:autobook/features/vehicles/data/datasources/local/car_local_datasource.dart';
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
        // given
        const car = toyotaCorolla;

        // when
        await datasource.insertPending(car);

        // then
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
        // given
        const car = toyotaCorolla;
        await datasource.upsertAll([car]);

        // when
        final updatedCar = buildCar(color: 'Red', mileage: 45000);
        await datasource.upsertPending(
          updatedCar,
          syncState: SyncStateEnum.pendingUpdate,
        );

        // then
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
          // given
          await datasource.upsertAll([fordFocus]);
          await datasource.insertPending(fiat500);
          await datasource.upsertPending(
            alfaGiulia,
            syncState: SyncStateEnum.pendingUpdate,
          );

          // when
          final pendingCars = await datasource.getPending();

          // then
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
        // given
        await datasource.upsertAll([fordFocus]);
        await datasource.insertPending(fiat500);
        await datasource.upsertPending(
          alfaGiulia,
          syncState: SyncStateEnum.pendingUpdate,
        );

        // when
        final pendingCount = await datasource.countPending();

        // then
        expect(pendingCount, 2);
      });

      test('given no pending cars, '
          'when countPending is called, '
          'then returns zero', () async {
        // given
        await datasource.upsertAll([fordFocus]);

        // when
        final pendingCount = await datasource.countPending();

        // then
        expect(pendingCount, 0);
      });
    });

    group('markSynced', () {
      test('given a pending car, '
          'when markSynced is called, '
          'then the row is excluded from getPending afterwards', () async {
        // given
        await datasource.insertPending(fiat500);

        // when
        await datasource.markSynced('pend1');

        // then
        expect(await datasource.getPending(), isEmpty);
        expect(await datasource.getAll(), [fiat500]);
      });
    });

    group('upsertAll', () {
      test('given a new car, '
          'when upsertAll is called, '
          'then the row defaults to synced', () async {
        // given
        const car = toyotaCorolla;

        // when
        await datasource.upsertAll([car]);

        // then
        expect(await datasource.getAll(), [car]);
        expect(await datasource.getPending(), isEmpty);
        expect(await datasource.countPending(), 0);
      });

      test('given a pending car already stored, '
          'when upsertAll updates it on conflict, '
          'then the pending state is preserved', () async {
        // given
        await datasource.insertPending(fiat500);

        // when
        final remoteFiat = buildCar(id: 'pend1', color: 'Blue');
        await datasource.upsertAll([remoteFiat]);

        // then
        final pendingCars = await datasource.getPending();
        expect(pendingCars, hasLength(1));
        expect(pendingCars.single.car, remoteFiat);
        expect(pendingCars.single.syncState, SyncStateEnum.pendingCreate);
      });
    });
  });
}

import 'package:autobook/features/maintenances/data/datasources/local/maintenance_local_datasource.dart';
import 'package:autobook/features/settings/data/repositories/autobook_data_repository.dart';
import 'package:autobook/features/vehicles/data/datasources/local/app_database.dart';
import 'package:autobook/features/vehicles/data/datasources/local/car_local_datasource.dart';
import 'package:autobook/features/vehicles/domain/entities/sync_state.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../maintenances/fixtures/maintenance_fixtures.dart';
import '../../../vehicles/fixtures/car_fixtures.dart';

void main() {
  late AppDatabase db;
  late AutobookDataRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = AutobookDataRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('AutobookDataRepository', () {
    group('replaceAll', () {
      test('given existing rows, '
          'when replaceAll is called, '
          'then only the restored rows remain', () async {
        final carDatasource = CarLocalDatasourceImpl(db);
        final maintenanceDatasource = MaintenanceLocalDatasourceImpl(db);
        await carDatasource.upsertAll([toyotaCorolla, fordFocus]);
        await maintenanceDatasource.upsertAll([oilChangeMarch]);

        await repository.replaceAll(
          cars: [renaultMegane],
          maintenances: [tireSwapJanuary],
        );

        final (restoredCars, restoredMaintenances) = await repository.loadAll();
        expect(restoredCars, [renaultMegane]);
        expect(restoredMaintenances, [tireSwapJanuary]);
      });

      test('given restored rows, '
          'when replaceAll inserts them, '
          'then every row is pendingCreate', () async {
        final carDatasource = CarLocalDatasourceImpl(db);
        final maintenanceDatasource = MaintenanceLocalDatasourceImpl(db);

        await repository.replaceAll(
          cars: [toyotaCorolla],
          maintenances: [oilChangeMarch],
        );

        final pendingCars = await carDatasource.getPending();
        expect(pendingCars.single.car, toyotaCorolla);
        expect(pendingCars.single.syncState, SyncStateEnum.pendingCreate);
        final pendingMaintenances = await maintenanceDatasource.getPending();
        expect(pendingMaintenances.single.maintenance, oilChangeMarch);
        expect(
          pendingMaintenances.single.syncState,
          SyncStateEnum.pendingCreate,
        );
      });

      test('given existing rows, '
          'when replaceAll is called with empty lists, '
          'then the database is left empty', () async {
        final carDatasource = CarLocalDatasourceImpl(db);
        final maintenanceDatasource = MaintenanceLocalDatasourceImpl(db);
        await carDatasource.upsertAll([toyotaCorolla]);
        await maintenanceDatasource.upsertAll([oilChangeMarch]);

        await repository.replaceAll(cars: [], maintenances: []);

        final (restoredCars, restoredMaintenances) = await repository.loadAll();
        expect(restoredCars, isEmpty);
        expect(restoredMaintenances, isEmpty);
      });
    });
  });
}

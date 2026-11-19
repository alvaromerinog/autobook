import 'package:autobook/core/di/app_database_provider.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/features/vehicles/data/datasources/local/app_database.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/domain/entities/sync_state.dart';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'autobook_data_repository.g.dart';

@Riverpod(keepAlive: true)
AutobookDataRepository autobookDataRepository(Ref ref) {
  return AutobookDataRepository(ref.watch(appDatabaseProvider));
}

class AutobookDataRepository {
  AutobookDataRepository(this._db);

  final AppDatabase _db;

  Car _toCarEntity(CarEntry e) => Car(
    id: e.id,
    brand: e.brand,
    model: e.model,
    year: e.year,
    licensePlate: e.licensePlate,
    color: e.color,
    mileage: e.mileage,
  );

  Maintenance _toMaintenanceEntity(MaintenanceEntry e) => Maintenance(
    id: e.id,
    carId: e.carId,
    type: MaintenanceType.fromString(e.type),
    date: e.date,
    mileage: e.mileage,
    cost: e.cost,
    garage: e.garage,
    notes: e.notes,
  );

  Future<(List<Car>, List<Maintenance>)> loadAll() async {
    final carRows = await _db.select(_db.carsTable).get();
    final maintenanceRows = await _db.select(_db.maintenancesTable).get();
    return (
      carRows.map(_toCarEntity).toList(),
      maintenanceRows.map(_toMaintenanceEntity).toList(),
    );
  }

  CarsTableCompanion _toCarCompanion(Car car) => CarsTableCompanion(
    id: Value(car.id),
    brand: Value(car.brand),
    model: Value(car.model),
    year: Value(car.year),
    licensePlate: Value(car.licensePlate),
    color: Value(car.color),
    mileage: Value(car.mileage),
    syncState: const Value(SyncStateEnum.pendingCreate),
    updatedAt: Value(DateTime.now()),
  );

  MaintenancesTableCompanion _toMaintenanceCompanion(Maintenance m) =>
      MaintenancesTableCompanion(
        id: Value(m.id),
        carId: Value(m.carId),
        type: Value(m.type.name),
        date: Value(m.date),
        mileage: Value(m.mileage),
        cost: Value(m.cost),
        garage: Value(m.garage),
        notes: Value(m.notes),
        syncState: const Value(SyncStateEnum.pendingCreate),
        updatedAt: Value(DateTime.now()),
      );

  Future<void> replaceAll({
    required List<Car> cars,
    required List<Maintenance> maintenances,
  }) {
    return _db.transaction(() async {
      await _db.delete(_db.carsTable).go();
      await _db.delete(_db.maintenancesTable).go();
      await _db.batch((batch) {
        for (final car in cars) {
          batch.insert(_db.carsTable, _toCarCompanion(car));
        }
        for (final maintenance in maintenances) {
          batch.insert(
            _db.maintenancesTable,
            _toMaintenanceCompanion(maintenance),
          );
        }
      });
    });
  }
}

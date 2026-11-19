import 'package:autobook/core/di/app_database_provider.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/features/vehicles/data/datasources/local/app_database.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
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
}

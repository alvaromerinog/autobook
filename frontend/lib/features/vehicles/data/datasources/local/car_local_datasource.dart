import 'package:autobook/core/di/app_database_provider.dart';
import 'package:autobook/features/vehicles/data/datasources/local/app_database.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'car_local_datasource.g.dart';

@riverpod
CarLocalDataSource carLocalDatasource(Ref ref) {
  return CarLocalDatasourceImpl(ref.watch(appDatabaseProvider));
}

abstract class CarLocalDataSource {
  Future<List<Car>> getAll();
  Future<void> upsertAll(List<Car> cars);
  Future<void> insertPending(Car car);
  Future<List<Car>> getPending();
  Future<void> markSynced(String id);
}

class CarLocalDatasourceImpl implements CarLocalDataSource {
  CarLocalDatasourceImpl(this._db);

  final AppDatabase _db;

  Car _toEntity(CarEntry e) => Car(
    id: e.id,
    brand: e.brand,
    model: e.model,
    year: e.year,
    licensePlate: e.licensePlate,
    color: e.color,
    mileage: e.mileage,
  );

  CarsTableCompanion _toCompanion(Car car, {bool isPending = false}) =>
      CarsTableCompanion(
        id: Value(car.id),
        brand: Value(car.brand),
        model: Value(car.model),
        year: Value(car.year),
        licensePlate: Value(car.licensePlate),
        color: Value(car.color),
        mileage: Value(car.mileage),
        isPending: Value(isPending),
        updatedAt: Value(DateTime.now()),
      );

  // Companion for upsert that omits isPending so existing pending rows keep
  // their flag intact when server data is written over them.
  CarsTableCompanion _toUpsertCompanion(Car car) => CarsTableCompanion(
    id: Value(car.id),
    brand: Value(car.brand),
    model: Value(car.model),
    year: Value(car.year),
    licensePlate: Value(car.licensePlate),
    color: Value(car.color),
    mileage: Value(car.mileage),
    updatedAt: Value(DateTime.timestamp()),
  );

  @override
  Future<List<Car>> getAll() async {
    final rows = await _db.select(_db.carsTable).get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<void> upsertAll(List<Car> cars) async {
    await _db.batch((batch) {
      for (final car in cars) {
        batch.insert(
          _db.carsTable,
          _toUpsertCompanion(car),
          onConflict: DoUpdate((_) => _toUpsertCompanion(car)),
        );
      }
    });
  }

  @override
  Future<void> insertPending(Car car) async {
    await _db
        .into(_db.carsTable)
        .insertOnConflictUpdate(_toCompanion(car, isPending: true));
  }

  @override
  Future<List<Car>> getPending() async {
    final rows = await (_db.select(
      _db.carsTable,
    )..where((t) => t.isPending.equals(true))).get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<void> markSynced(String id) async {
    await (_db.update(_db.carsTable)..where((t) => t.id.equals(id))).write(
      const CarsTableCompanion(isPending: Value(false)),
    );
  }
}

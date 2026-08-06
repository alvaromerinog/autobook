import 'package:autobook/core/di/app_database_provider.dart';
import 'package:autobook/features/vehicles/data/datasources/local/app_database.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/domain/entities/sync_state.dart';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'car_local_datasource.g.dart';

@riverpod
CarLocalDataSource carLocalDatasource(Ref ref) {
  return CarLocalDatasourceImpl(ref.watch(appDatabaseProvider));
}

typedef PendingCar = ({Car car, SyncStateEnum syncState});

abstract class CarLocalDataSource {
  Future<List<Car>> getAll();
  Future<void> upsertAll(List<Car> cars);
  Future<void> insertPending(Car car);
  Future<void> upsertPending(Car car, {required SyncStateEnum syncState});
  Future<List<PendingCar>> getPending();
  Future<int> countPending();
  Future<void> markSynced(String id);
  Future<void> markPendingDelete(String id);
  Future<void> hardDelete(String id);
  Future<Set<String>> pendingDeleteIds();
  Future<SyncStateEnum?> syncStateOf(String id);
  Future<void> hardDeleteMany(Iterable<String> ids);
  Future<List<PendingCar>> getAllWithStates();
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

  PendingCar _toPendingCar(CarEntry e) =>
      (car: _toEntity(e), syncState: e.syncState);

  CarsTableCompanion _toCompanion(Car car, SyncStateEnum syncState) =>
      CarsTableCompanion(
        id: Value(car.id),
        brand: Value(car.brand),
        model: Value(car.model),
        year: Value(car.year),
        licensePlate: Value(car.licensePlate),
        color: Value(car.color),
        mileage: Value(car.mileage),
        syncState: Value(syncState),
        updatedAt: Value(DateTime.now()),
      );

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
        .insertOnConflictUpdate(_toCompanion(car, SyncStateEnum.pendingCreate));
  }

  @override
  Future<void> upsertPending(
    Car car, {
    required SyncStateEnum syncState,
  }) async {
    await _db
        .into(_db.carsTable)
        .insertOnConflictUpdate(_toCompanion(car, syncState));
  }

  @override
  Future<List<PendingCar>> getPending() async {
    final rows = await (_db.select(
      _db.carsTable,
    )..where((t) => t.syncState.isNotInValues([SyncStateEnum.synced]))).get();
    return rows.map(_toPendingCar).toList();
  }

  @override
  Future<int> countPending() async {
    final countExpression = countAll();
    final query = _db.selectOnly(_db.carsTable)
      ..addColumns([countExpression])
      ..where(_db.carsTable.syncState.isNotInValues([SyncStateEnum.synced]));
    final row = await query.getSingle();
    return row.read(countExpression) ?? 0;
  }

  @override
  Future<void> markSynced(String id) async {
    await (_db.update(_db.carsTable)..where((t) => t.id.equals(id))).write(
      const CarsTableCompanion(syncState: Value(SyncStateEnum.synced)),
    );
  }

  @override
  Future<void> markPendingDelete(String id) async {
    await (_db.update(_db.carsTable)..where((t) => t.id.equals(id))).write(
      const CarsTableCompanion(syncState: Value(SyncStateEnum.pendingDelete)),
    );
  }

  @override
  Future<void> hardDelete(String id) async {
    await (_db.delete(_db.carsTable)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<Set<String>> pendingDeleteIds() async {
    final rows =
        await (_db.select(_db.carsTable)..where(
              (t) => t.syncState.isInValues([SyncStateEnum.pendingDelete]),
            ))
            .get();
    return rows.map((e) => e.id).toSet();
  }

  @override
  Future<SyncStateEnum?> syncStateOf(String id) async {
    final rows = await (_db.select(
      _db.carsTable,
    )..where((t) => t.id.equals(id))).get();
    final first = rows.firstOrNull;
    return first?.syncState;
  }

  @override
  Future<void> hardDeleteMany(Iterable<String> ids) async {
    final idSet = ids.toSet();
    if (idSet.isEmpty) return;
    await (_db.delete(_db.carsTable)..where((t) => t.id.isIn(idSet))).go();
  }

  @override
  Future<List<PendingCar>> getAllWithStates() async {
    final rows = await _db.select(_db.carsTable).get();
    return rows.map(_toPendingCar).toList();
  }
}

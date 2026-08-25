import 'package:autobook/core/di/app_database_provider.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/features/vehicles/data/datasources/local/app_database.dart';
import 'package:autobook/features/vehicles/domain/entities/sync_state.dart';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'maintenance_local_datasource.g.dart';

@riverpod
MaintenanceLocalDataSource maintenanceLocalDatasource(Ref ref) {
  return MaintenanceLocalDatasourceImpl(ref.watch(appDatabaseProvider));
}

typedef PendingMaintenance = ({
  Maintenance maintenance,
  SyncStateEnum syncState,
});

abstract class MaintenanceLocalDataSource {
  Future<List<Maintenance>> getAll(String carId);
  Future<Maintenance?> getOne(String carId, String id);
  Future<void> upsertAll(List<Maintenance> maintenances);
  Future<void> insertPending(Maintenance maintenance);
  Future<void> upsertPending(
    Maintenance maintenance, {
    required SyncStateEnum syncState,
  });
  Future<List<PendingMaintenance>> getPending();
  Future<int> countPending(String carId);
  Future<void> markSynced(String id);
  Future<void> markPendingDelete(String id);
  Future<void> hardDelete(String id);
  Future<void> hardDeleteForCar(String carId);
  Future<Set<String>> pendingDeleteIds(String carId);
  Future<SyncStateEnum?> syncStateOf(String id);
  Future<List<PendingMaintenance>> getAllWithStates(String carId);
}

class MaintenanceLocalDatasourceImpl implements MaintenanceLocalDataSource {
  MaintenanceLocalDatasourceImpl(this._db);

  final AppDatabase _db;

  Maintenance _toEntity(MaintenanceEntry e) => Maintenance(
    id: e.id,
    carId: e.carId,
    type: MaintenanceType.fromString(e.type),
    date: e.date,
    mileage: e.mileage,
    cost: e.cost,
    garage: e.garage,
    notes: e.notes,
  );

  PendingMaintenance _toPending(MaintenanceEntry e) =>
      (maintenance: _toEntity(e), syncState: e.syncState);

  MaintenancesTableCompanion _toCompanion(
    Maintenance m,
    SyncStateEnum syncState,
  ) => MaintenancesTableCompanion(
    id: Value(m.id),
    carId: Value(m.carId),
    type: Value(m.type.name),
    date: Value(m.date),
    mileage: Value(m.mileage),
    cost: Value(m.cost),
    garage: Value(m.garage),
    notes: Value(m.notes),
    syncState: Value(syncState),
    updatedAt: Value(DateTime.now()),
  );

  MaintenancesTableCompanion _toUpsertCompanion(Maintenance m) =>
      MaintenancesTableCompanion(
        id: Value(m.id),
        carId: Value(m.carId),
        type: Value(m.type.name),
        date: Value(m.date),
        mileage: Value(m.mileage),
        cost: Value(m.cost),
        garage: Value(m.garage),
        notes: Value(m.notes),
        updatedAt: Value(DateTime.timestamp()),
      );

  @override
  Future<List<Maintenance>> getAll(String carId) async {
    final rows =
        await (_db.select(_db.maintenancesTable)
              ..where((t) => t.carId.equals(carId))
              ..orderBy([
                (t) => OrderingTerm.desc(t.date),
                (t) => OrderingTerm.desc(t.updatedAt),
              ]))
            .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<Maintenance?> getOne(String carId, String id) async {
    final rows = await (_db.select(
      _db.maintenancesTable,
    )..where((t) => t.carId.equals(carId) & t.id.equals(id))).get();
    return rows.firstOrNull == null ? null : _toEntity(rows.first);
  }

  @override
  Future<void> upsertAll(List<Maintenance> maintenances) async {
    await _db.batch((batch) {
      for (final m in maintenances) {
        batch.insert(
          _db.maintenancesTable,
          _toUpsertCompanion(m),
          onConflict: DoUpdate((_) => _toUpsertCompanion(m)),
        );
      }
    });
  }

  @override
  Future<void> insertPending(Maintenance m) async {
    await _db
        .into(_db.maintenancesTable)
        .insertOnConflictUpdate(_toCompanion(m, SyncStateEnum.pendingCreate));
  }

  @override
  Future<void> upsertPending(
    Maintenance m, {
    required SyncStateEnum syncState,
  }) async {
    await _db
        .into(_db.maintenancesTable)
        .insertOnConflictUpdate(_toCompanion(m, syncState));
  }

  @override
  Future<List<PendingMaintenance>> getPending() async {
    final rows = await (_db.select(
      _db.maintenancesTable,
    )..where((t) => t.syncState.isNotInValues([SyncStateEnum.synced]))).get();
    return rows.map(_toPending).toList();
  }

  @override
  Future<int> countPending(String carId) async {
    final countExpr = countAll();
    final query = _db.selectOnly(_db.maintenancesTable)
      ..addColumns([countExpr])
      ..where(_db.maintenancesTable.carId.equals(carId))
      ..where(
        _db.maintenancesTable.syncState.isNotInValues([SyncStateEnum.synced]),
      );
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  @override
  Future<void> markSynced(String id) async {
    await (_db.update(
      _db.maintenancesTable,
    )..where((t) => t.id.equals(id))).write(
      const MaintenancesTableCompanion(syncState: Value(SyncStateEnum.synced)),
    );
  }

  @override
  Future<void> markPendingDelete(String id) async {
    await (_db.update(
      _db.maintenancesTable,
    )..where((t) => t.id.equals(id))).write(
      const MaintenancesTableCompanion(
        syncState: Value(SyncStateEnum.pendingDelete),
      ),
    );
  }

  @override
  Future<void> hardDelete(String id) async {
    await (_db.delete(
      _db.maintenancesTable,
    )..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> hardDeleteForCar(String carId) async {
    await (_db.delete(
      _db.maintenancesTable,
    )..where((t) => t.carId.equals(carId))).go();
  }

  @override
  Future<Set<String>> pendingDeleteIds(String carId) async {
    final rows =
        await (_db.select(_db.maintenancesTable)..where(
              (t) =>
                  t.carId.equals(carId) &
                  t.syncState.isInValues([SyncStateEnum.pendingDelete]),
            ))
            .get();
    return rows.map((e) => e.id).toSet();
  }

  @override
  Future<SyncStateEnum?> syncStateOf(String id) async {
    final rows = await (_db.select(
      _db.maintenancesTable,
    )..where((t) => t.id.equals(id))).get();
    return rows.firstOrNull?.syncState;
  }

  @override
  Future<List<PendingMaintenance>> getAllWithStates(String carId) async {
    final rows = await (_db.select(
      _db.maintenancesTable,
    )..where((t) => t.carId.equals(carId))).get();
    return rows.map(_toPending).toList();
  }
}

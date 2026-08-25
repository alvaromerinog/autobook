import 'package:autobook/core/error/failures.dart';
import 'package:autobook/core/network/connectivity_service.dart';
import 'package:autobook/features/maintenances/data/datasources/local/maintenance_local_datasource.dart';
import 'package:autobook/features/maintenances/data/datasources/remote/maintenance_remote_datasource.dart';
import 'package:autobook/features/maintenances/data/models/maintenance_dto.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_remote_sync_event.dart';
import 'package:autobook/features/maintenances/domain/repositories/maintenance_repository.dart';
import 'package:autobook/features/vehicles/domain/entities/sync_state.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'maintenance_repository.g.dart';

@Riverpod(keepAlive: true)
IMaintenanceRepository maintenanceRepository(Ref ref) {
  return MaintenanceRepository(
    local: ref.watch(maintenanceLocalDatasourceProvider),
    remote: ref.watch(maintenanceRemoteDatasourceProvider),
    connectivity: ref.watch(connectivityServiceProvider),
  );
}

class MaintenanceRepository implements IMaintenanceRepository {
  MaintenanceRepository({
    required MaintenanceLocalDataSource local,
    required MaintenanceRemoteDataSource remote,
    required ConnectivityService connectivity,
  }) : _local = local,
       _remote = remote,
       _connectivity = connectivity;

  final MaintenanceLocalDataSource _local;
  final MaintenanceRemoteDataSource _remote;
  final ConnectivityService _connectivity;

  final _syncingIds = <String>{};

  Future<void> _push(
    Maintenance m, {
    required Future<void> Function() remoteCall,
    required Future<void> Function() settle,
    int? tombstoneStatus,
  }) async {
    if (!await _connectivity.isConnected()) return;
    try {
      await remoteCall();
      await settle();
    } on DioException catch (e) {
      if (tombstoneStatus != null &&
          e.response?.statusCode == tombstoneStatus) {
        await settle();
        return;
      }
      if (e.response != null) {
        throw ServerFailure(e.response?.statusCode ?? 0);
      }
      throw const NetworkFailure();
    } catch (_) {
      throw const NetworkFailure();
    }
  }

  @override
  Future<List<Maintenance>> getAll(String carId) async {
    try {
      return await _local.getAll(carId);
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }

  @override
  Future<Maintenance?> getOne(String carId, String id) async {
    try {
      return await _local.getOne(carId, id);
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }

  @override
  Future<List<MaintenanceRemoteSyncEvent>> refreshFromRemote(
    String carId,
  ) async {
    if (!await _connectivity.isConnected()) return [];
    final List<Maintenance> remoteMaintenances;
    try {
      final response = await _remote.fetchForCar(carId);
      remoteMaintenances = response.maintenances
          .map((dto) => dto.toDomain())
          .toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerFailure(e.response?.statusCode ?? 0);
      }
      throw const NetworkFailure();
    } catch (_) {
      throw const NetworkFailure();
    }
    final List<PendingMaintenance> localRows;
    try {
      localRows = await _local.getAllWithStates(carId);
    } catch (e) {
      throw CacheFailure(e.toString());
    }
    final remoteIds = remoteMaintenances.map((m) => m.id).toSet();
    final locallyPendingIds = localRows
        .where((row) => row.syncState != SyncStateEnum.synced)
        .map((row) => row.maintenance.id)
        .toSet();
    final toHardDelete = <String>[];
    final events = <MaintenanceRemoteSyncEvent>[];
    for (final row in localRows) {
      if (remoteIds.contains(row.maintenance.id)) continue;
      switch (row.syncState) {
        case SyncStateEnum.pendingDelete:
          toHardDelete.add(row.maintenance.id);
        case SyncStateEnum.synced:
          toHardDelete.add(row.maintenance.id);
          events.add(MaintenanceRemoteSyncEvent.remoteDeleted(row.maintenance));
        case SyncStateEnum.pendingUpdate:
          toHardDelete.add(row.maintenance.id);
          events.add(
            MaintenanceRemoteSyncEvent.remoteDeletedWithPendingUpdate(
              row.maintenance,
            ),
          );
        case SyncStateEnum.pendingCreate:
          break;
      }
    }
    try {
      await _local.upsertAll(
        remoteMaintenances
            .where((m) => !locallyPendingIds.contains(m.id))
            .toList(),
      );
      for (final id in toHardDelete) {
        await _local.hardDelete(id);
      }
    } catch (e) {
      throw CacheFailure(e.toString());
    }
    return events;
  }

  @override
  Future<void> create(Maintenance m) async {
    if (!_syncingIds.add(m.id)) return;
    try {
      await _local.insertPending(m);
      await _push(
        m,
        remoteCall: () => _remote.create(m.carId, MaintenanceDto.fromDomain(m)),
        tombstoneStatus: 409,
        settle: () => _local.markSynced(m.id),
      );
    } finally {
      _syncingIds.remove(m.id);
    }
  }

  @override
  Future<void> update(Maintenance m) async {
    if (!_syncingIds.add(m.id)) return;
    try {
      await _local.upsertPending(m, syncState: SyncStateEnum.pendingUpdate);
      await _push(
        m,
        remoteCall: () =>
            _remote.update(m.carId, m.id, MaintenanceDto.fromDomain(m)),
        settle: () => _local.markSynced(m.id),
      );
    } finally {
      _syncingIds.remove(m.id);
    }
  }

  @override
  Future<void> delete(Maintenance m) async {
    if (!_syncingIds.add(m.id)) {
      throw const CacheFailure('delete while sync in flight');
    }
    try {
      final state = await _local.syncStateOf(m.id);
      if (state == SyncStateEnum.pendingCreate) {
        await _local.hardDelete(m.id);
        return;
      }
      await _local.markPendingDelete(m.id);
      await _push(
        m,
        remoteCall: () => _remote.delete(m.carId, m.id),
        tombstoneStatus: 404,
        settle: () => _local.hardDelete(m.id),
      );
    } finally {
      _syncingIds.remove(m.id);
    }
  }

  @override
  Future<Set<String>> pendingDeleteIds(String carId) async {
    try {
      return await _local.pendingDeleteIds(carId);
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }

  @override
  Future<void> syncPending() async {
    final List<PendingMaintenance> pending;
    try {
      pending = await _local.getPending();
    } catch (e) {
      throw CacheFailure(e.toString());
    }
    for (final p in pending) {
      if (!_syncingIds.add(p.maintenance.id)) continue;
      try {
        switch (p.syncState) {
          case SyncStateEnum.pendingCreate:
            await _push(
              p.maintenance,
              remoteCall: () => _remote.create(
                p.maintenance.carId,
                MaintenanceDto.fromDomain(p.maintenance),
              ),
              tombstoneStatus: 409,
              settle: () => _local.markSynced(p.maintenance.id),
            );
          case SyncStateEnum.pendingUpdate:
            await _push(
              p.maintenance,
              remoteCall: () => _remote.update(
                p.maintenance.carId,
                p.maintenance.id,
                MaintenanceDto.fromDomain(p.maintenance),
              ),
              settle: () => _local.markSynced(p.maintenance.id),
            );
          case SyncStateEnum.pendingDelete:
            await _push(
              p.maintenance,
              remoteCall: () =>
                  _remote.delete(p.maintenance.carId, p.maintenance.id),
              tombstoneStatus: 404,
              settle: () => _local.hardDelete(p.maintenance.id),
            );
          case SyncStateEnum.synced:
            assert(false);
        }
      } on Failure {
        continue;
      } on Exception {
        continue;
      } finally {
        _syncingIds.remove(p.maintenance.id);
      }
    }
  }

  @override
  Future<bool> hasPending(String carId) async {
    try {
      return await _local.countPending(carId) > 0;
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }
}

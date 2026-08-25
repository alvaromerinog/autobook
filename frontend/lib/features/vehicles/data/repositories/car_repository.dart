import 'package:autobook/core/error/failures.dart';
import 'package:autobook/core/network/connectivity_service.dart';
import 'package:autobook/features/maintenances/data/datasources/local/'
    'maintenance_local_datasource.dart';
import 'package:autobook/features/vehicles/data/datasources/local/car_local_datasource.dart';
import 'package:autobook/features/vehicles/data/datasources/remote/car_remote_datasource.dart';
import 'package:autobook/features/vehicles/data/models/car_dto.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/domain/entities/remote_sync_event.dart';
import 'package:autobook/features/vehicles/domain/entities/sync_state.dart';
import 'package:autobook/features/vehicles/domain/repositories/car_repository.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'car_repository.g.dart';

@Riverpod(keepAlive: true)
ICarRepository carRepository(Ref ref) {
  return CarRepository(
    local: ref.watch(carLocalDatasourceProvider),
    remote: ref.watch(carRemoteDatasourceProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    maintenanceLocal: ref.watch(maintenanceLocalDatasourceProvider),
  );
}

class CarRepository implements ICarRepository {
  CarRepository({
    required CarLocalDataSource local,
    required CarRemoteDataSource remote,
    required ConnectivityService connectivity,
    required MaintenanceLocalDataSource maintenanceLocal,
  }) : _local = local,
       _remote = remote,
       _connectivity = connectivity,
       _maintenanceLocal = maintenanceLocal;

  final CarLocalDataSource _local;
  final CarRemoteDataSource _remote;
  final ConnectivityService _connectivity;
  final MaintenanceLocalDataSource _maintenanceLocal;

  final _syncingIds = <String>{};

  Future<void> _push(
    Car car, {
    required Future<void> Function() remoteCall,
    required Future<void> Function() settle,
    int? tombstoneStatus,
    Future<void> Function()? tombstoneSettle,
  }) async {
    if (!await _connectivity.isConnected()) return;
    try {
      await remoteCall();
      await settle();
    } on DioException catch (e) {
      if (tombstoneStatus != null &&
          e.response?.statusCode == tombstoneStatus) {
        await (tombstoneSettle ?? settle)();
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
  Future<List<Car>> getAll() async {
    try {
      return await _local.getAll();
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }

  @override
  Future<List<RemoteSyncEvent>> refreshFromRemote() async {
    if (!await _connectivity.isConnected()) return [];
    final List<Car> remoteCars;
    try {
      final response = await _remote.fetchAll();
      remoteCars = response.cars.map((dto) => dto.toDomain()).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerFailure(e.response?.statusCode ?? 0);
      }
      throw const NetworkFailure();
    } catch (_) {
      throw const NetworkFailure();
    }
    final List<PendingCar> localRows;
    try {
      localRows = await _local.getAllWithStates();
    } catch (e) {
      throw CacheFailure(e.toString());
    }
    final remoteIds = remoteCars.map((c) => c.id).toSet();
    final locallyPendingIds = localRows
        .where((row) => row.syncState != SyncStateEnum.synced)
        .map((row) => row.car.id)
        .toSet();
    final toHardDelete = <String>[];
    final events = <RemoteSyncEvent>[];
    for (final row in localRows) {
      if (remoteIds.contains(row.car.id)) continue;
      switch (row.syncState) {
        case SyncStateEnum.pendingDelete:
          toHardDelete.add(row.car.id);
        case SyncStateEnum.synced:
          toHardDelete.add(row.car.id);
          events.add(RemoteSyncEvent.remoteDeleted(row.car));
        case SyncStateEnum.pendingUpdate:
          toHardDelete.add(row.car.id);
          events.add(RemoteSyncEvent.remoteDeletedWithPendingUpdate(row.car));
        case SyncStateEnum.pendingCreate:
          break;
      }
    }
    try {
      await _local.upsertAll(
        remoteCars.where((c) => !locallyPendingIds.contains(c.id)).toList(),
      );
      await _local.hardDeleteMany(toHardDelete);
      for (final deletedId in toHardDelete) {
        await _maintenanceLocal.hardDeleteForCar(deletedId);
      }
    } catch (e) {
      throw CacheFailure(e.toString());
    }
    return events;
  }

  @override
  Future<void> create(Car car) async {
    if (!_syncingIds.add(car.id)) return;
    try {
      await _local.insertPending(car);
      await _push(
        car,
        remoteCall: () => _remote.create(CarDto.fromDomain(car)),
        tombstoneStatus: 409,
        settle: () => _local.markSynced(car.id),
      );
    } finally {
      _syncingIds.remove(car.id);
    }
  }

  @override
  Future<void> update(Car car) async {
    if (!_syncingIds.add(car.id)) return;
    try {
      await _local.upsertPending(car, syncState: SyncStateEnum.pendingUpdate);
      await _push(
        car,
        remoteCall: () => _remote.update(car.id, CarDto.fromDomain(car)),
        tombstoneStatus: 404,
        settle: () => _local.markSynced(car.id),
        tombstoneSettle: () => _local.hardDelete(car.id),
      );
    } finally {
      _syncingIds.remove(car.id);
    }
  }

  @override
  Future<void> delete(Car car) async {
    if (!_syncingIds.add(car.id)) {
      throw const CacheFailure('delete while sync in flight');
    }
    try {
      final state = await _local.syncStateOf(car.id);
      if (state == SyncStateEnum.pendingCreate) {
        await _local.hardDelete(car.id);
        return;
      }
      await _local.markPendingDelete(car.id);
      await _push(
        car,
        remoteCall: () => _remote.delete(car.id),
        tombstoneStatus: 404,
        settle: () async {
          await _local.hardDelete(car.id);
          await _maintenanceLocal.hardDeleteForCar(car.id);
        },
      );
    } finally {
      _syncingIds.remove(car.id);
    }
  }

  @override
  Future<Set<String>> pendingDeleteIds() async {
    try {
      return await _local.pendingDeleteIds();
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }

  @override
  Future<void> syncPending() async {
    final List<PendingCar> pendingCars;
    try {
      pendingCars = await _local.getPending();
    } catch (e) {
      throw CacheFailure(e.toString());
    }
    for (final pending in pendingCars) {
      if (!_syncingIds.add(pending.car.id)) continue;
      try {
        switch (pending.syncState) {
          case SyncStateEnum.pendingCreate:
            await _push(
              pending.car,
              remoteCall: () => _remote.create(CarDto.fromDomain(pending.car)),
              tombstoneStatus: 409,
              settle: () => _local.markSynced(pending.car.id),
            );
          case SyncStateEnum.pendingUpdate:
            await _push(
              pending.car,
              remoteCall: () => _remote.update(
                pending.car.id,
                CarDto.fromDomain(pending.car),
              ),
              tombstoneStatus: 404,
              settle: () => _local.markSynced(pending.car.id),
              tombstoneSettle: () => _local.hardDelete(pending.car.id),
            );
          case SyncStateEnum.pendingDelete:
            await _push(
              pending.car,
              remoteCall: () => _remote.delete(pending.car.id),
              tombstoneStatus: 404,
              settle: () => _local.hardDelete(pending.car.id),
            );
          case SyncStateEnum.synced:
            assert(false);
        }
      } on Failure {
        continue;
      } on Exception {
        continue;
      } finally {
        _syncingIds.remove(pending.car.id);
      }
    }
  }

  @override
  Future<bool> hasPending() async {
    try {
      return await _local.countPending() > 0;
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }
}

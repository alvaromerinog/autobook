import 'package:autobook/core/error/failures.dart';
import 'package:autobook/core/network/connectivity_service.dart';
import 'package:autobook/features/vehicles/data/datasources/local/car_local_datasource.dart';
import 'package:autobook/features/vehicles/data/datasources/remote/car_remote_datasource.dart';
import 'package:autobook/features/vehicles/data/models/car_dto.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
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
  );
}

class CarRepository implements ICarRepository {
  CarRepository({
    required CarLocalDataSource local,
    required CarRemoteDataSource remote,
    required ConnectivityService connectivity,
  }) : _local = local,
       _remote = remote,
       _connectivity = connectivity;

  final CarLocalDataSource _local;
  final CarRemoteDataSource _remote;
  final ConnectivityService _connectivity;

  final _syncingIds = <String>{};

  Future<void> _push(
    Car car, {
    required Future<void> Function() remoteCall,
    int? tombstoneStatus,
  }) async {
    if (!await _connectivity.isConnected()) return;
    if (!_syncingIds.add(car.id)) return;
    try {
      await remoteCall();
      await _local.markSynced(car.id);
    } on DioException catch (e) {
      if (tombstoneStatus != null &&
          e.response?.statusCode == tombstoneStatus) {
        await _local.markSynced(car.id);
        return;
      }
      if (e.response != null) {
        throw ServerFailure(e.response?.statusCode ?? 0);
      }
      throw const NetworkFailure();
    } catch (_) {
      throw const NetworkFailure();
    } finally {
      _syncingIds.remove(car.id);
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
  Future<List<String>> refreshFromRemote() async {
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
    final toHardDelete = <String>[];
    final events = <String>[];
    for (final row in localRows) {
      if (remoteIds.contains(row.car.id)) continue;
      switch (row.syncState) {
        case SyncStateEnum.pendingDelete:
          toHardDelete.add(row.car.id);
        case SyncStateEnum.synced:
          toHardDelete.add(row.car.id);
          events.add('Coche ${row.car.brand} ${row.car.model} eliminado');
        case SyncStateEnum.pendingUpdate:
          toHardDelete.add(row.car.id);
          events.add(
            'Coche ${row.car.brand} ${row.car.model} eliminado, '
            'edición descartada',
          );
        case SyncStateEnum.pendingCreate:
          break;
      }
    }
    try {
      await _local.upsertAll(remoteCars);
      await _local.hardDeleteMany(toHardDelete);
    } catch (e) {
      throw CacheFailure(e.toString());
    }
    return events;
  }

  @override
  Future<void> create(Car car) async {
    await _local.insertPending(car);
    await _push(
      car,
      remoteCall: () => _remote.create(CarDto.fromDomain(car)),
      tombstoneStatus: 409,
    );
  }

  @override
  Future<void> update(Car car) async {
    await _local.upsertPending(car, syncState: SyncStateEnum.pendingUpdate);
    await _push(
      car,
      remoteCall: () => _remote.update(car.id, CarDto.fromDomain(car)),
    );
  }

  @override
  Future<void> delete(Car car) async {
    final state = await _local.syncStateOf(car.id);
    if (state == SyncStateEnum.pendingCreate) {
      await _local.hardDelete(car.id);
      return;
    }
    await _local.markPendingDelete(car.id);
    await _pushDelete(car);
  }

  Future<void> _pushDelete(Car car) async {
    if (!await _connectivity.isConnected()) return;
    if (!_syncingIds.add(car.id)) return;
    try {
      await _remote.delete(car.id);
      await _local.hardDelete(car.id);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        await _local.hardDelete(car.id);
        return;
      }
      if (e.response != null) {
        throw ServerFailure(e.response?.statusCode ?? 0);
      }
      throw const NetworkFailure();
    } catch (_) {
      throw const NetworkFailure();
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
      try {
        switch (pending.syncState) {
          case SyncStateEnum.pendingCreate:
            await _push(
              pending.car,
              remoteCall: () => _remote.create(CarDto.fromDomain(pending.car)),
              tombstoneStatus: 409,
            );
          case SyncStateEnum.pendingUpdate:
            await _push(
              pending.car,
              remoteCall: () => _remote.update(
                pending.car.id,
                CarDto.fromDomain(pending.car),
              ),
            );
          case SyncStateEnum.pendingDelete:
            await _pushDelete(pending.car);
          case SyncStateEnum.synced:
            assert(false);
        }
      } on Failure {
        continue;
      } on Exception {
        continue;
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

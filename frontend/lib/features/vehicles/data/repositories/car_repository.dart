import 'package:autobook/core/error/failures.dart';
import 'package:autobook/core/network/connectivity_service.dart';
import 'package:autobook/features/vehicles/data/datasources/local/car_local_datasource.dart';
import 'package:autobook/features/vehicles/data/datasources/remote/car_remote_datasource.dart';
import 'package:autobook/features/vehicles/data/models/car_dto.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
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

  // Tracks car IDs currently being posted by create() to prevent
  // syncPending() from double-posting the same car in a concurrent flush.
  final _syncingIds = <String>{};

  @override
  Future<List<Car>> getAll() async {
    try {
      return await _local.getAll();
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }

  @override
  Future<void> refreshFromRemote() async {
    if (!await _connectivity.isConnected()) return;
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
    try {
      await _local.upsertAll(remoteCars);
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }

  @override
  Future<void> create(Car car) async {
    await _local.insertPending(car);
    if (!await _connectivity.isConnected()) return;
    // Guard against concurrent remote posts for the same car id.
    if (!_syncingIds.add(car.id)) return;
    try {
      await _remote.create(CarDto.fromDomain(car));
      await _local.markSynced(car.id);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
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
  Future<void> syncPending() async {
    final List<Car> pendingCars;
    try {
      pendingCars = await _local.getPending();
    } catch (e) {
      throw CacheFailure(e.toString());
    }
    for (final car in pendingCars) {
      if (!_syncingIds.add(car.id)) continue;
      try {
        await _remote.create(CarDto.fromDomain(car));
        await _local.markSynced(car.id);
      } on DioException catch (e) {
        if (e.response?.statusCode == 409) {
          await _local.markSynced(car.id);
        }
        continue;
      } on Exception catch (_) {
        continue;
      } finally {
        _syncingIds.remove(car.id);
      }
    }
  }

  @override
  Future<bool> hasPending() async {
    try {
      final pending = await _local.getPending();
      return pending.isNotEmpty;
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }
}

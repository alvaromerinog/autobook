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
  })  : _local = local,
        _remote = remote,
        _connectivity = connectivity;

  final CarLocalDataSource _local;
  final CarRemoteDataSource _remote;
  final ConnectivityService _connectivity;

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
    try {
      final response = await _remote.fetchAll();
      await _local.upsertAll(
        response.cars.map((dto) => dto.toDomain()).toList(),
      );
    } on DioException catch (e) {
      throw ServerFailure(e.response?.statusCode ?? 0);
    } catch (_) {
      throw const NetworkFailure();
    }
  }

  @override
  Future<void> create(Car car) async {
    await _local.insertPending(car);
    if (!await _connectivity.isConnected()) return;
    try {
      await _remote.create(CarDto.fromDomain(car));
      await _local.markSynced(car.id);
    } on DioException catch (e) {
      throw ServerFailure(e.response?.statusCode ?? 0);
    } catch (_) {
      throw const NetworkFailure();
    }
  }

  @override
  Future<void> syncPending() async {
    final pendingCars = await _local.getPending();
    for (final car in pendingCars) {
      try {
        await _remote.create(CarDto.fromDomain(car));
        await _local.markSynced(car.id);
      } catch (_) {
        continue;
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

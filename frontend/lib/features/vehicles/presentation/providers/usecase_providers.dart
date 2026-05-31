import 'package:autobook/core/di/uuid_id_generator.dart';
import 'package:autobook/features/vehicles/data/repositories/car_repository.dart';
import 'package:autobook/features/vehicles/domain/usecases/create_car_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/get_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/has_pending_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/refresh_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/sync_pending_cars_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'usecase_providers.g.dart';

@riverpod
GetCarsUseCase getCarsUseCase(Ref ref) =>
    GetCarsUseCase(ref.watch(carRepositoryProvider));

@riverpod
CreateCarUseCase createCarUseCase(Ref ref) => CreateCarUseCase(
      ref.watch(carRepositoryProvider),
      ref.watch(idGeneratorProvider),
    );

@riverpod
RefreshCarsUseCase refreshCarsUseCase(Ref ref) =>
    RefreshCarsUseCase(ref.watch(carRepositoryProvider));

@riverpod
SyncPendingCarsUseCase syncPendingCarsUseCase(Ref ref) =>
    SyncPendingCarsUseCase(ref.watch(carRepositoryProvider));

@riverpod
HasPendingCarsUseCase hasPendingCarsUseCase(Ref ref) =>
    HasPendingCarsUseCase(ref.watch(carRepositoryProvider));

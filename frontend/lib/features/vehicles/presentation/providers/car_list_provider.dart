import 'dart:async';

import 'package:autobook/core/error/failures.dart';
import 'package:autobook/core/sync/sync_coordinator.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/domain/usecases/create_car_usecase.dart';
import 'package:autobook/features/vehicles/presentation/providers/usecase_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'car_list_provider.g.dart';

typedef CarListState = ({
  List<Car> cars,
  Failure? syncError,
  bool hasPendingSync,
});

@riverpod
class CarList extends _$CarList {
  @override
  Future<CarListState> build() async {
    final coordinator = ref.read(syncCoordinatorProvider);
    final unregister = coordinator.register(syncPendingCars);
    ref.onDispose(unregister);

    Failure? syncError;
    var cachedCars = <Car>[];
    var hasPendingSync = false;
    try {
      (cachedCars, hasPendingSync) = await _readCarsWithPending();
    } on Failure catch (f) {
      syncError = f;
    }

    _syncInBackground(existingError: syncError);

    return (
      cars: cachedCars,
      syncError: syncError,
      hasPendingSync: hasPendingSync,
    );
  }

  Future<(List<Car>, bool)> _readCarsWithPending() async {
    final getCars = ref.read(getCarsUseCaseProvider);
    final hasPending = ref.read(hasPendingCarsUseCaseProvider);
    return await (getCars.call(), hasPending.call()).wait;
  }

  Future<void> _emitAfter(
    Future<void> Function() mutation, {
    bool rethrowError = true,
  }) async {
    Failure? syncError;
    try {
      await mutation();
    } on Failure catch (f) {
      syncError = f;
    }

    var cars = <Car>[];
    var hasPendingSync = false;
    try {
      (cars, hasPendingSync) = await _readCarsWithPending();
    } on Failure catch (f) {
      syncError ??= f;
    }

    state = AsyncData((
      cars: cars,
      syncError: syncError,
      hasPendingSync: hasPendingSync,
    ));

    if (rethrowError && syncError != null) throw syncError;
  }

  void _syncInBackground({Failure? existingError}) {
    var cancelled = false;
    ref.onDispose(() => cancelled = true);
    final refreshCars = ref.read(refreshCarsUseCaseProvider);
    final syncPending = ref.read(syncPendingCarsUseCaseProvider);
    unawaited(
      _refreshAndSync(
        existingError: existingError,
        isCancelled: () => cancelled,
        refreshCars: () => refreshCars.call(),
        syncPendingCars: () => syncPending.call(),
      ),
    );
  }

  Future<void> _refreshAndSync({
    Failure? existingError,
    required bool Function() isCancelled,
    required Future<void> Function() refreshCars,
    required Future<void> Function() syncPendingCars,
  }) async {
    Failure? syncError = existingError;
    try {
      await refreshCars();
    } on Failure catch (f) {
      syncError = f;
    }

    if (isCancelled()) return;

    try {
      await syncPendingCars();
    } on Failure catch (f) {
      syncError ??= f;
    }

    if (isCancelled()) return;

    var refreshedCars = <Car>[];
    var hasPendingSync = false;
    try {
      (refreshedCars, hasPendingSync) = await _readCarsWithPending();
    } on Failure catch (f) {
      syncError ??= f;
    }

    if (isCancelled()) return;

    state = AsyncData((
      cars: refreshedCars,
      syncError: syncError,
      hasPendingSync: hasPendingSync,
    ));
  }

  Future<void> add(CarDraft draft) =>
      _emitAfter(() => ref.read(createCarUseCaseProvider).call(draft));

  Future<void> updateCar(CarDraft draft, Car existing) => _emitAfter(
    () => ref.read(updateCarUseCaseProvider).call(draft, existing),
  );

  Future<void> syncPendingCars() => _emitAfter(
    () => ref.read(syncPendingCarsUseCaseProvider).call(),
    rethrowError: false,
  );
}

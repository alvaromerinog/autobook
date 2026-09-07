import 'dart:async';

import 'package:autobook/core/error/failures.dart';
import 'package:autobook/core/sync/sync_coordinator.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/domain/entities/remote_sync_event.dart';
import 'package:autobook/features/vehicles/domain/usecases/create_car_usecase.dart';
import 'package:autobook/features/vehicles/presentation/providers/usecase_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'car_list_provider.g.dart';

typedef CarListState = ({
  List<Car> cars,
  Failure? syncError,
  bool hasPendingSync,
  Set<String> pendingDeleteIds,
  List<RemoteSyncEvent> remoteSyncEvents,
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
    var pendingDeleteIds = <String>{};
    try {
      (cachedCars, hasPendingSync, pendingDeleteIds) =
          await _readCarsWithPending();
    } on Failure catch (f) {
      syncError = f;
    }

    _syncInBackground(existingError: syncError);

    return (
      cars: cachedCars,
      syncError: syncError,
      hasPendingSync: hasPendingSync,
      pendingDeleteIds: pendingDeleteIds,
      remoteSyncEvents: const <RemoteSyncEvent>[],
    );
  }

  Future<(List<Car>, bool, Set<String>)> _readCarsWithPending() async {
    final getCars = ref.read(getCarsUseCaseProvider);
    final hasPending = ref.read(hasPendingCarsUseCaseProvider);
    final pendingDeleteIds = ref.read(pendingDeleteIdsUseCaseProvider);
    final (cars, pending, pendingIds) = await (
      getCars.call(),
      hasPending.call(),
      pendingDeleteIds.call(),
    ).wait;
    return (cars, pending, pendingIds);
  }

  Future<void> _emitAfter(
    Future<void> Function() mutation, {
    bool rethrowError = true,
  }) async {
    var cancelled = false;
    ref.onDispose(() => cancelled = true);

    Failure? syncError;
    try {
      await mutation();
    } on Failure catch (f) {
      syncError = f;
    }

    if (!cancelled) {
      var cars = <Car>[];
      var hasPendingSync = false;
      var pendingDeleteIds = <String>{};
      try {
        (cars, hasPendingSync, pendingDeleteIds) = await _readCarsWithPending();
      } on Failure catch (f) {
        syncError ??= f;
      }

      if (cancelled) return;

      state = AsyncData((
        cars: cars,
        syncError: syncError,
        hasPendingSync: hasPendingSync,
        pendingDeleteIds: pendingDeleteIds,
        remoteSyncEvents: const [],
      ));
    }

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
    required Future<List<RemoteSyncEvent>> Function() refreshCars,
    required Future<void> Function() syncPendingCars,
  }) async {
    Failure? syncError = existingError;
    var remoteSyncEvents = <RemoteSyncEvent>[];
    try {
      remoteSyncEvents = await refreshCars();
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
    var pendingDeleteIds = <String>{};
    try {
      (refreshedCars, hasPendingSync, pendingDeleteIds) =
          await _readCarsWithPending();
    } on Failure catch (f) {
      syncError ??= f;
    }

    if (isCancelled()) return;

    state = AsyncData((
      cars: refreshedCars,
      syncError: syncError,
      hasPendingSync: hasPendingSync,
      pendingDeleteIds: pendingDeleteIds,
      remoteSyncEvents: remoteSyncEvents,
    ));
  }

  Future<void> add(CarDraft draft) =>
      _emitAfter(() => ref.read(createCarUseCaseProvider).call(draft));

  Future<void> updateCar(CarDraft draft, Car existing) => _emitAfter(
    () => ref.read(updateCarUseCaseProvider).call(draft, existing),
  );

  Future<void> deleteCar(Car car) =>
      _emitAfter(() => ref.read(deleteCarUseCaseProvider).call(car));

  void clearRemoteChangeBanner() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData((
      cars: current.cars,
      syncError: current.syncError,
      hasPendingSync: current.hasPendingSync,
      pendingDeleteIds: current.pendingDeleteIds,
      remoteSyncEvents: const [],
    ));
  }

  Future<void> syncPendingCars() => _emitAfter(
    () => ref.read(syncPendingCarsUseCaseProvider).call(),
    rethrowError: false,
  );
}

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
      cachedCars = await ref.read(getCarsUseCaseProvider).call();
      hasPendingSync = await ref.read(hasPendingCarsUseCaseProvider).call();
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

  void _syncInBackground({Failure? existingError}) {
    var cancelled = false;
    ref.onDispose(() => cancelled = true);
    final refreshCars = ref.read(refreshCarsUseCaseProvider);
    final syncPending = ref.read(syncPendingCarsUseCaseProvider);
    final getCars = ref.read(getCarsUseCaseProvider);
    final hasPending = ref.read(hasPendingCarsUseCaseProvider);
    unawaited(
      _refreshAndSync(
        existingError: existingError,
        isCancelled: () => cancelled,
        refreshCars: () => refreshCars.call(),
        syncPendingCars: () => syncPending.call(),
        getCars: () => getCars.call(),
        hasPending: () => hasPending.call(),
      ),
    );
  }

  Future<void> _refreshAndSync({
    Failure? existingError,
    required bool Function() isCancelled,
    required Future<void> Function() refreshCars,
    required Future<void> Function() syncPendingCars,
    required Future<List<Car>> Function() getCars,
    required Future<bool> Function() hasPending,
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
      refreshedCars = await getCars();
      hasPendingSync = await hasPending();
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

  Future<void> add(CarDraft draft) async {
    Failure? syncError;
    try {
      await ref.read(createCarUseCaseProvider).call(draft);
    } on Failure catch (f) {
      syncError = f;
    }

    var cars = <Car>[];
    var hasPendingSync = false;
    try {
      cars = await ref.read(getCarsUseCaseProvider).call();
      hasPendingSync = await ref.read(hasPendingCarsUseCaseProvider).call();
    } on Failure catch (f) {
      syncError ??= f;
    }

    state = AsyncData((
      cars: cars,
      syncError: syncError,
      hasPendingSync: hasPendingSync,
    ));

    if (syncError != null) throw syncError;
  }

  Future<void> syncPendingCars() async {
    Failure? syncError;
    try {
      await ref.read(syncPendingCarsUseCaseProvider).call();
    } on Failure catch (f) {
      syncError = f;
    }

    var cars = <Car>[];
    var hasPendingSync = false;
    try {
      cars = await ref.read(getCarsUseCaseProvider).call();
      hasPendingSync = await ref.read(hasPendingCarsUseCaseProvider).call();
    } on Failure catch (f) {
      syncError ??= f;
    }

    state = AsyncData((
      cars: cars,
      syncError: syncError,
      hasPendingSync: hasPendingSync,
    ));
  }
}

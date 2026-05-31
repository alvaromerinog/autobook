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
    coordinator.register(syncPendingCars);
    ref.onDispose(coordinator.unregister);

    Failure? syncError;
    try {
      await ref.read(refreshCarsUseCaseProvider).call();
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

    return (cars: cars, syncError: syncError, hasPendingSync: hasPendingSync);
  }

  Future<void> add(CarDraft draft) async {
    Failure? syncError;
    try {
      await ref.read(createCarUseCaseProvider).call(draft);
    } on Failure catch (f) {
      syncError = f;
    }

    final cars = await ref.read(getCarsUseCaseProvider).call();
    final hasPendingSync = await ref.read(hasPendingCarsUseCaseProvider).call();
    state = AsyncData((
      cars: cars,
      syncError: syncError,
      hasPendingSync: hasPendingSync,
    ));

    if (syncError != null) throw syncError;
  }

  Future<void> syncPendingCars() async {
    await ref.read(syncPendingCarsUseCaseProvider).call();
    final cars = await ref.read(getCarsUseCaseProvider).call();
    final hasPendingSync = await ref.read(hasPendingCarsUseCaseProvider).call();
    state = AsyncData((
      cars: cars,
      syncError: null,
      hasPendingSync: hasPendingSync,
    ));
  }
}

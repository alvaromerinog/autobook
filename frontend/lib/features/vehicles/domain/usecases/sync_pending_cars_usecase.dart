import 'package:autobook/features/vehicles/domain/repositories/car_repository.dart';

class SyncPendingCarsUseCase {
  const SyncPendingCarsUseCase(this._repo);

  final ICarRepository _repo;

  Future<void> call() => _repo.syncPending();
}

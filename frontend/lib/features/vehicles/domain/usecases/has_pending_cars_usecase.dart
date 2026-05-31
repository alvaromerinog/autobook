import 'package:autobook/features/vehicles/domain/repositories/car_repository.dart';

class HasPendingCarsUseCase {
  const HasPendingCarsUseCase(this._repo);

  final ICarRepository _repo;

  Future<bool> call() => _repo.hasPending();
}

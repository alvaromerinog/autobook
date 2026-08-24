import 'package:autobook/features/vehicles/domain/repositories/car_repository.dart';

class PendingDeleteIdsUseCase {
  const PendingDeleteIdsUseCase(this._repo);

  final ICarRepository _repo;

  Future<Set<String>> call() => _repo.pendingDeleteIds();
}

import 'package:autobook/features/vehicles/domain/repositories/car_repository.dart';

class RefreshCarsUseCase {
  const RefreshCarsUseCase(this._repo);

  final ICarRepository _repo;

  Future<List<String>> call() => _repo.refreshFromRemote();
}

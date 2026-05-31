import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/domain/repositories/car_repository.dart';

class GetCarsUseCase {
  const GetCarsUseCase(this._repo);

  final ICarRepository _repo;

  Future<List<Car>> call() => _repo.getAll();
}

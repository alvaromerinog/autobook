import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/domain/repositories/car_repository.dart';

class DeleteCarUseCase {
  const DeleteCarUseCase(this._repo);

  final ICarRepository _repo;

  Future<void> call(Car car) => _repo.delete(car);
}

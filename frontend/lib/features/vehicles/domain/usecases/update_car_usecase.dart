import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/domain/repositories/car_repository.dart';

class UpdateCarUseCase {
  const UpdateCarUseCase(this._repo);

  final ICarRepository _repo;

  Future<Car> call(Car car) async {
    await _repo.update(car);
    return car;
  }
}

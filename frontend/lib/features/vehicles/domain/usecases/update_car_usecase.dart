import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/domain/repositories/car_repository.dart';
import 'package:autobook/features/vehicles/domain/usecases/create_car_usecase.dart';

class UpdateCarUseCase {
  const UpdateCarUseCase(this._repo);

  final ICarRepository _repo;

  Future<Car> call(CarDraft draft, Car existing) async {
    final updatedCar = existing.copyWith(
      brand: draft.brand,
      model: draft.model,
      year: draft.year,
      licensePlate: draft.licensePlate,
      color: draft.color,
      mileage: draft.mileage,
    );
    await _repo.update(updatedCar);
    return updatedCar;
  }
}

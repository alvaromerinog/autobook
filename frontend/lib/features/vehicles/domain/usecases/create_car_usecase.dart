import 'package:autobook/core/id/id_generator.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/domain/repositories/car_repository.dart';

/// Raw form input for creating a [Car]; the id is assigned by the use case.
typedef CarDraft = ({
  String brand,
  String model,
  int year,
  String licensePlate,
  String? color,
  int? mileage,
});

class CreateCarUseCase {
  const CreateCarUseCase(this._repo, this._ids);

  final ICarRepository _repo;
  final IdGenerator _ids;

  Future<Car> call(CarDraft draft) async {
    final car = Car(
      id: _ids.newId(),
      brand: draft.brand,
      model: draft.model,
      year: draft.year,
      licensePlate: draft.licensePlate,
      color: draft.color,
      mileage: draft.mileage,
    );
    await _repo.create(car);
    return car;
  }
}

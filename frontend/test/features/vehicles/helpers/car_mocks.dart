import 'package:autobook/features/vehicles/data/models/car_dto.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/domain/repositories/car_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockCarRepository extends Mock implements ICarRepository {}

const _emptyCar = Car(id: '', brand: '', model: '', year: 0, licensePlate: '');
const _emptyCarDto = CarDto(
  id: '',
  brand: '',
  model: '',
  year: 0,
  licensePlate: '',
);

void registerCarFallbacks() {
  registerFallbackValue(_emptyCar);
  registerFallbackValue(_emptyCarDto);
}

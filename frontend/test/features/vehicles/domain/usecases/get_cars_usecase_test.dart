import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/domain/repositories/car_repository.dart';
import 'package:autobook/features/vehicles/domain/usecases/get_cars_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCarRepository extends Mock implements ICarRepository {}

void main() {
  late MockCarRepository mockRepo;
  late GetCarsUseCase useCase;

  setUp(() {
    mockRepo = MockCarRepository();
    useCase = GetCarsUseCase(mockRepo);
  });

  group('GetCarsUseCase', () {
    test(
      'given repository returns cars, '
      'when call runs, '
      'then delegates to getAll and returns the list',
      () async {
        // given
        const cars = [
          Car(
            id: '1',
            brand: 'Toyota',
            model: 'Corolla',
            year: 2020,
            licensePlate: '1234 ABC',
          ),
        ];
        when(() => mockRepo.getAll()).thenAnswer((_) async => cars);

        // when
        final result = await useCase();

        // then
        expect(result, cars);
        verify(() => mockRepo.getAll()).called(1);
      },
    );
  });
}

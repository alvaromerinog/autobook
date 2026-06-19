import 'package:autobook/features/vehicles/domain/usecases/get_cars_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/car_fixtures.dart';
import '../../helpers/car_mocks.dart';

void main() {
  late MockCarRepository mockRepo;
  late GetCarsUseCase useCase;

  setUp(() {
    mockRepo = MockCarRepository();
    useCase = GetCarsUseCase(mockRepo);
  });

  group('GetCarsUseCase', () {
    test('given repository returns cars, '
        'when call runs, '
        'then delegates to getAll and returns the list', () async {
      // given
      when(() => mockRepo.getAll()).thenAnswer((_) async => oneCarList);

      // when
      final result = await useCase();

      // then
      expect(result, oneCarList);
      verify(() => mockRepo.getAll()).called(1);
    });
  });
}

import 'package:autobook/core/error/failures.dart';
import 'package:autobook/features/vehicles/domain/usecases/update_car_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/car_fixtures.dart';
import '../../helpers/car_mocks.dart';

void main() {
  late MockCarRepository mockRepo;
  late UpdateCarUseCase useCase;

  setUpAll(() {
    registerCarFallbacks();
  });

  setUp(() {
    mockRepo = MockCarRepository();
    useCase = UpdateCarUseCase(mockRepo);
  });

  group('UpdateCarUseCase', () {
    test('given a draft and an existing car, '
        'when call runs, '
        'then persists and returns the merged car', () async {
      // given
      final mergedCar = buildCar(
        model: 'Corolla Hybrid',
        year: 2021,
        licensePlate: '9999 XXX',
        color: 'Red',
        mileage: 45000,
      );
      when(() => mockRepo.update(any())).thenAnswer((_) async {});

      // when
      final result = await useCase(corollaDraft, toyotaCorolla);

      // then
      expect(result, mergedCar);
      verify(() => mockRepo.update(mergedCar)).called(1);
    });

    test('given the repository throws a Failure, '
        'when call runs, '
        'then the Failure propagates', () async {
      // given
      when(() => mockRepo.update(any())).thenThrow(const NetworkFailure());

      // when / then
      await expectLater(
        () => useCase(corollaDraft, toyotaCorolla),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}

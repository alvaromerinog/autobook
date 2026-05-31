import 'package:autobook/core/error/failures.dart';
import 'package:autobook/core/id/id_generator.dart';
import 'package:autobook/features/vehicles/domain/usecases/create_car_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/car_fixtures.dart';
import '../../helpers/car_mocks.dart';

class MockIdGenerator extends Mock implements IdGenerator {}

void main() {
  late MockCarRepository mockRepo;
  late MockIdGenerator mockIds;
  late CreateCarUseCase useCase;

  const draft = (
    brand: 'Toyota',
    model: 'Corolla',
    year: 2020,
    licensePlate: '1234 ABC',
    color: 'Blanco',
    mileage: 45000,
  );

  setUpAll(() {
    registerCarFallbacks();
  });

  setUp(() {
    mockRepo = MockCarRepository();
    mockIds = MockIdGenerator();
    useCase = CreateCarUseCase(mockRepo, mockIds);
  });

  group('CreateCarUseCase', () {
    test(
      'given a draft, '
      'when call runs, '
      'then builds a car with a generated id, persists it and returns it',
      () async {
        // given
        when(() => mockIds.newId()).thenReturn('generated-id');
        when(() => mockRepo.create(any())).thenAnswer((_) async {});

        // when
        final result = await useCase(draft);

        // then
        final expectedCar = buildCar(
          id: 'generated-id',
          color: 'Blanco',
          mileage: 45000,
        );
        expect(result, expectedCar);
        verify(() => mockIds.newId()).called(1);
        verify(() => mockRepo.create(expectedCar)).called(1);
      },
    );

    test(
      'given the repository throws a Failure, '
      'when call runs, '
      'then the Failure propagates',
      () async {
        // given
        when(() => mockIds.newId()).thenReturn('generated-id');
        when(() => mockRepo.create(any()))
            .thenThrow(const NetworkFailure());

        // when / then
        await expectLater(
          () => useCase(draft),
          throwsA(isA<NetworkFailure>()),
        );
      },
    );
  });
}

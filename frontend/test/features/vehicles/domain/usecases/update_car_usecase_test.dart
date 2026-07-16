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
    test('given a car, '
        'when call runs, '
        'then persists it and returns it', () async {
      // given
      when(() => mockRepo.update(any())).thenAnswer((_) async {});

      // when
      final result = await useCase(toyotaCorolla);

      // then
      expect(result, toyotaCorolla);
      verify(() => mockRepo.update(toyotaCorolla)).called(1);
    });

    test('given the repository throws a Failure, '
        'when call runs, '
        'then the Failure propagates', () async {
      // given
      when(() => mockRepo.update(any())).thenThrow(const NetworkFailure());

      // when / then
      await expectLater(
        () => useCase(toyotaCorolla),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}

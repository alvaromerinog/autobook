import 'package:autobook/core/error/failures.dart';
import 'package:autobook/features/vehicles/domain/usecases/delete_car_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/car_fixtures.dart';
import '../../helpers/car_mocks.dart';

void main() {
  late MockCarRepository mockRepo;
  late DeleteCarUseCase useCase;

  setUpAll(() {
    registerCarFallbacks();
  });

  setUp(() {
    mockRepo = MockCarRepository();
    useCase = DeleteCarUseCase(mockRepo);
  });

  group('DeleteCarUseCase', () {
    test('given delete succeeds, '
        'when call(car) runs, '
        'then repository.delete is called once and returns', () async {
      // given
      when(() => mockRepo.delete(any())).thenAnswer((_) async {});

      // when
      await useCase(toyotaCorolla);

      // then
      verify(() => mockRepo.delete(toyotaCorolla)).called(1);
    });

    test('given repository.delete throws a Failure, '
        'when call(car) runs, '
        'then the Failure propagates', () async {
      // given
      when(() => mockRepo.delete(any())).thenThrow(const NetworkFailure());

      // when / then
      await expectLater(
        () => useCase(toyotaCorolla),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}

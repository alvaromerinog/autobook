import 'package:autobook/features/vehicles/domain/usecases/has_pending_cars_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/car_mocks.dart';

void main() {
  late MockCarRepository mockRepo;
  late HasPendingCarsUseCase useCase;

  setUp(() {
    mockRepo = MockCarRepository();
    useCase = HasPendingCarsUseCase(mockRepo);
  });

  group('HasPendingCarsUseCase', () {
    test('given repository has pending cars, '
        'when call runs, '
        'then returns true', () async {
      when(() => mockRepo.hasPending()).thenAnswer((_) async => true);

      final result = await useCase();

      expect(result, isTrue);
      verify(() => mockRepo.hasPending()).called(1);
    });

    test('given repository has no pending cars, '
        'when call runs, '
        'then returns false', () async {
      when(() => mockRepo.hasPending()).thenAnswer((_) async => false);

      final result = await useCase();

      expect(result, isFalse);
      verify(() => mockRepo.hasPending()).called(1);
    });
  });
}

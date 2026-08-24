import 'package:autobook/core/error/failures.dart';
import 'package:autobook/features/vehicles/domain/usecases/pending_delete_ids_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/car_mocks.dart';

void main() {
  late MockCarRepository mockRepo;
  late PendingDeleteIdsUseCase useCase;

  setUpAll(() {
    registerCarFallbacks();
  });

  setUp(() {
    mockRepo = MockCarRepository();
    useCase = PendingDeleteIdsUseCase(mockRepo);
  });

  group('PendingDeleteIdsUseCase', () {
    test('given the repository returns pending delete ids, '
        'when call runs, '
        'then delegates to pendingDeleteIds', () async {
      // given
      when(
        () => mockRepo.pendingDeleteIds(),
      ).thenAnswer((_) async => {'1', '2'});

      // when
      final ids = await useCase();

      // then
      expect(ids, {'1', '2'});
      verify(() => mockRepo.pendingDeleteIds()).called(1);
    });

    test('given the repository throws a Failure, '
        'when call runs, '
        'then the Failure propagates', () async {
      // given
      when(
        () => mockRepo.pendingDeleteIds(),
      ).thenThrow(const CacheFailure('db error'));

      // when / then
      await expectLater(() => useCase(), throwsA(isA<CacheFailure>()));
    });
  });
}

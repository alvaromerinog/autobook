import 'package:autobook/features/vehicles/domain/usecases/sync_pending_cars_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/car_mocks.dart';

void main() {
  late MockCarRepository mockRepo;
  late SyncPendingCarsUseCase useCase;

  setUp(() {
    mockRepo = MockCarRepository();
    useCase = SyncPendingCarsUseCase(mockRepo);
  });

  group('SyncPendingCarsUseCase', () {
    test(
      'given repository syncs successfully, '
      'when call runs, '
      'then delegates to syncPending',
      () async {
        // given
        when(() => mockRepo.syncPending()).thenAnswer((_) async {});

        // when
        await useCase();

        // then
        verify(() => mockRepo.syncPending()).called(1);
      },
    );
  });
}

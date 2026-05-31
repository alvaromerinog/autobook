import 'package:autobook/core/error/failures.dart';
import 'package:autobook/features/vehicles/domain/usecases/refresh_cars_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/car_mocks.dart';

void main() {
  late MockCarRepository mockRepo;
  late RefreshCarsUseCase useCase;

  setUp(() {
    mockRepo = MockCarRepository();
    useCase = RefreshCarsUseCase(mockRepo);
  });

  group('RefreshCarsUseCase', () {
    test(
      'given repository refreshes successfully, '
      'when call runs, '
      'then delegates to refreshFromRemote',
      () async {
        // given
        when(() => mockRepo.refreshFromRemote()).thenAnswer((_) async {});

        // when
        await useCase();

        // then
        verify(() => mockRepo.refreshFromRemote()).called(1);
      },
    );

    test(
      'given repository throws a Failure, '
      'when call runs, '
      'then the Failure propagates',
      () async {
        // given
        when(() => mockRepo.refreshFromRemote())
            .thenThrow(const ServerFailure(500));

        // when / then
        await expectLater(
          () => useCase(),
          throwsA(isA<ServerFailure>()),
        );
      },
    );
  });
}

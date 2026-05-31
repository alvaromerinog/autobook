import 'package:autobook/core/error/failures.dart';
import 'package:autobook/core/sync/sync_coordinator.dart';
import 'package:autobook/features/vehicles/domain/usecases/get_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/has_pending_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/refresh_cars_usecase.dart';
import 'package:autobook/features/vehicles/presentation/providers/car_list_provider.dart';
import 'package:autobook/features/vehicles/presentation/providers/usecase_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/car_fixtures.dart';
import '../../helpers/car_mocks.dart';

void main() {
  late MockCarRepository mockRepo;

  setUp(() {
    mockRepo = MockCarRepository();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        syncCoordinatorProvider.overrideWithValue(SyncCoordinator()),
        getCarsUseCaseProvider.overrideWithValue(GetCarsUseCase(mockRepo)),
        refreshCarsUseCaseProvider
            .overrideWithValue(RefreshCarsUseCase(mockRepo)),
        hasPendingCarsUseCaseProvider
            .overrideWithValue(HasPendingCarsUseCase(mockRepo)),
      ],
    );
    addTearDown(container.dispose);
    // Keep the autoDispose provider alive for the duration of the test.
    container.listen(carListProvider, (_, __) {});
    return container;
  }

  group('CarList', () {
    test(
      'given remote refresh and local read succeed, '
      'when build runs, '
      'then exposes the cars without a sync error',
      () async {
        // given
        when(() => mockRepo.refreshFromRemote()).thenAnswer((_) async {});
        when(() => mockRepo.getAll()).thenAnswer((_) async => oneCarList);
        when(() => mockRepo.hasPending()).thenAnswer((_) async => false);

        // when
        final container = makeContainer();
        final state = await container.read(carListProvider.future);

        // then
        expect(state.cars, oneCarList);
        expect(state.syncError, isNull);
        expect(state.hasPendingSync, isFalse);
      },
    );

    test(
      'given the local data source throws a non-Failure error, '
      'when build runs, '
      'then the provider ends in an error state',
      () async {
        // given
        when(() => mockRepo.refreshFromRemote()).thenAnswer((_) async {});
        when(() => mockRepo.getAll())
            .thenThrow(StateError('database unavailable'));
        when(() => mockRepo.hasPending()).thenAnswer((_) async => false);

        // when
        final container = makeContainer();

        // then
        await expectLater(
          container.read(carListProvider.future),
          throwsA(isA<StateError>()),
        );
        expect(container.read(carListProvider).hasError, isTrue);
      },
    );

    test(
      'given the local read fails with a CacheFailure, '
      'when build runs, '
      'then it surfaces the failure as syncError with an empty list '
      'instead of erroring',
      () async {
        // given
        when(() => mockRepo.refreshFromRemote()).thenAnswer((_) async {});
        when(() => mockRepo.getAll())
            .thenThrow(const CacheFailure('database unavailable'));
        when(() => mockRepo.hasPending()).thenAnswer((_) async => false);

        // when
        final container = makeContainer();
        final state = await container.read(carListProvider.future);

        // then
        expect(state.cars, isEmpty);
        expect(state.syncError, isA<CacheFailure>());
        expect(container.read(carListProvider).hasError, isFalse);
      },
    );

    test(
      'given the remote refresh fails with a Failure, '
      'when build runs, '
      'then cars still load and the failure is surfaced as syncError',
      () async {
        // given
        when(() => mockRepo.refreshFromRemote())
            .thenThrow(const NetworkFailure());
        when(() => mockRepo.getAll()).thenAnswer((_) async => oneCarList);
        when(() => mockRepo.hasPending()).thenAnswer((_) async => true);

        // when
        final container = makeContainer();
        final state = await container.read(carListProvider.future);

        // then
        expect(state.cars, oneCarList);
        expect(state.syncError, isA<NetworkFailure>());
        expect(state.hasPendingSync, isTrue);
      },
    );
  });
}

import 'package:autobook/core/error/failures.dart';
import 'package:autobook/core/id/id_generator.dart';
import 'package:autobook/core/sync/sync_coordinator.dart';
import 'package:autobook/features/vehicles/domain/usecases/create_car_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/get_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/has_pending_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/refresh_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/sync_pending_cars_usecase.dart';
import 'package:autobook/features/vehicles/presentation/providers/car_list_provider.dart';
import 'package:autobook/features/vehicles/presentation/providers/usecase_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/car_fixtures.dart';
import '../../helpers/car_mocks.dart';

class MockIdGenerator extends Mock implements IdGenerator {}

void main() {
  late MockCarRepository mockRepo;
  late MockIdGenerator mockIds;

  setUpAll(() {
    registerCarFallbacks();
  });

  setUp(() {
    mockRepo = MockCarRepository();
    mockIds = MockIdGenerator();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        syncCoordinatorProvider.overrideWithValue(SyncCoordinator()),
        getCarsUseCaseProvider.overrideWithValue(GetCarsUseCase(mockRepo)),
        refreshCarsUseCaseProvider.overrideWithValue(
          RefreshCarsUseCase(mockRepo),
        ),
        hasPendingCarsUseCaseProvider.overrideWithValue(
          HasPendingCarsUseCase(mockRepo),
        ),
        createCarUseCaseProvider.overrideWithValue(
          CreateCarUseCase(mockRepo, mockIds),
        ),
        syncPendingCarsUseCaseProvider.overrideWithValue(
          SyncPendingCarsUseCase(mockRepo),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Keep the autoDispose provider alive for the duration of the test.
    container.listen(carListProvider, (_, __) {});
    return container;
  }

  group('CarList', () {
    group('build', () {
      test('given remote refresh and local read succeed, '
          'when build runs, '
          'then exposes the cars without a sync error', () async {
        // given
        when(() => mockRepo.refreshFromRemote()).thenAnswer((_) async {});
        when(() => mockRepo.syncPending()).thenAnswer((_) async {});
        when(() => mockRepo.getAll()).thenAnswer((_) async => oneCarList);
        when(() => mockRepo.hasPending()).thenAnswer((_) async => false);

        // when
        final container = makeContainer();
        final state = await container.read(carListProvider.future);

        // then
        expect(state.cars, oneCarList);
        expect(state.syncError, isNull);
        expect(state.hasPendingSync, isFalse);
      });

      test('given the local data source throws a non-Failure error, '
          'when build runs, '
          'then the provider ends in an error state', () async {
        // given
        when(() => mockRepo.refreshFromRemote()).thenAnswer((_) async {});
        when(() => mockRepo.syncPending()).thenAnswer((_) async {});
        when(
          () => mockRepo.getAll(),
        ).thenThrow(StateError('database unavailable'));
        when(() => mockRepo.hasPending()).thenAnswer((_) async => false);

        // when
        final container = makeContainer();

        // then
        await expectLater(
          container.read(carListProvider.future),
          throwsA(isA<StateError>()),
        );
        expect(container.read(carListProvider).hasError, isTrue);
      });

      test('given the local read fails with a CacheFailure, '
          'when build runs, '
          'then it surfaces the failure as syncError with an empty list '
          'instead of erroring', () async {
        // given
        when(() => mockRepo.refreshFromRemote()).thenAnswer((_) async {});
        when(() => mockRepo.syncPending()).thenAnswer((_) async {});
        when(
          () => mockRepo.getAll(),
        ).thenThrow(const CacheFailure('database unavailable'));

        // when
        final container = makeContainer();
        final state = await container.read(carListProvider.future);

        // then
        expect(state.cars, isEmpty);
        expect(state.syncError, isA<CacheFailure>());
        expect(state.hasPendingSync, isFalse);
        expect(container.read(carListProvider).hasError, isFalse);
      });

      test(
        'given the remote refresh fails with a Failure, '
        'when build runs, '
        'then cars still load and the failure is surfaced as syncError',
        () async {
          // given
          when(
            () => mockRepo.refreshFromRemote(),
          ).thenThrow(const NetworkFailure());
          when(() => mockRepo.syncPending()).thenAnswer((_) async {});
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

    group('add', () {
      test('given create succeeds, '
          'when add is called, '
          'then state is updated with the new car list and no error', () async {
        // given
        when(() => mockRepo.refreshFromRemote()).thenAnswer((_) async {});
        when(() => mockRepo.syncPending()).thenAnswer((_) async {});
        when(() => mockRepo.getAll()).thenAnswer((_) async => oneCarList);
        when(() => mockRepo.hasPending()).thenAnswer((_) async => false);
        when(() => mockIds.newId()).thenReturn('new-id');
        when(() => mockRepo.create(any())).thenAnswer((_) async {});
        const draft = (
          brand: 'Honda',
          model: 'Civic',
          year: 2023,
          licensePlate: '9999 ZZZ',
          color: null,
          mileage: null,
        );

        final container = makeContainer();
        await container.read(carListProvider.future);

        // when
        await container.read(carListProvider.notifier).add(draft);

        // then
        final state = await container.read(carListProvider.future);
        expect(state.syncError, isNull);
        verify(() => mockRepo.create(any())).called(1);
      });

      test('given create fails, '
          'when add is called, '
          'then state is still updated with the current car list and the '
          'error is rethrown', () async {
        // given
        when(() => mockRepo.refreshFromRemote()).thenAnswer((_) async {});
        when(() => mockRepo.syncPending()).thenAnswer((_) async {});
        when(() => mockRepo.getAll()).thenAnswer((_) async => oneCarList);
        when(() => mockRepo.hasPending()).thenAnswer((_) async => true);
        when(() => mockIds.newId()).thenReturn('new-id');
        when(() => mockRepo.create(any())).thenThrow(const NetworkFailure());
        const draft = (
          brand: 'Honda',
          model: 'Civic',
          year: 2023,
          licensePlate: '9999 ZZZ',
          color: null,
          mileage: null,
        );

        final container = makeContainer();
        await container.read(carListProvider.future);

        // when / then
        await expectLater(
          () => container.read(carListProvider.notifier).add(draft),
          throwsA(isA<NetworkFailure>()),
        );

        // State is still updated despite the error so UI stays coherent.
        final state = await container.read(carListProvider.future);
        expect(state.syncError, isA<NetworkFailure>());
        expect(state.cars, oneCarList);
      });
    });

    group('syncPendingCars via coordinator flush', () {
      test('given pending cars exist, '
          'when the coordinator flushes, '
          'then syncPendingCars runs and state is updated', () async {
        // given
        when(() => mockRepo.refreshFromRemote()).thenAnswer((_) async {});
        when(() => mockRepo.syncPending()).thenAnswer((_) async {});
        when(() => mockRepo.getAll()).thenAnswer((_) async => oneCarList);
        when(() => mockRepo.hasPending()).thenAnswer((_) async => false);

        final container = makeContainer();
        await container.read(carListProvider.future);
        clearInteractions(mockRepo);

        // when
        when(() => mockRepo.syncPending()).thenAnswer((_) async {});
        when(() => mockRepo.getAll()).thenAnswer((_) async => oneCarList);
        when(() => mockRepo.hasPending()).thenAnswer((_) async => false);
        await container.read(syncCoordinatorProvider).flush();

        // then
        final state = await container.read(carListProvider.future);
        expect(state.hasPendingSync, isFalse);
        expect(state.syncError, isNull);
        verify(() => mockRepo.syncPending()).called(1);
      });
    });
  });
}

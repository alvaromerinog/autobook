import 'dart:async';

import 'package:autobook/core/error/failures.dart';
import 'package:autobook/core/id/id_generator.dart';
import 'package:autobook/core/sync/sync_coordinator.dart';
import 'package:autobook/features/vehicles/domain/entities/remote_sync_event.dart';
import 'package:autobook/features/vehicles/domain/usecases/create_car_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/delete_car_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/get_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/has_pending_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/pending_delete_ids_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/refresh_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/sync_pending_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/update_car_usecase.dart';
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
    when(() => mockRepo.pendingDeleteIds()).thenAnswer((_) async => <String>{});
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
        updateCarUseCaseProvider.overrideWithValue(UpdateCarUseCase(mockRepo)),
        deleteCarUseCaseProvider.overrideWithValue(DeleteCarUseCase(mockRepo)),
        pendingDeleteIdsUseCaseProvider.overrideWithValue(
          PendingDeleteIdsUseCase(mockRepo),
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
        when(
          () => mockRepo.refreshFromRemote(),
        ).thenAnswer((_) async => <RemoteSyncEvent>[]);
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
        when(
          () => mockRepo.refreshFromRemote(),
        ).thenAnswer((_) async => <RemoteSyncEvent>[]);
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
        when(
          () => mockRepo.refreshFromRemote(),
        ).thenAnswer((_) async => <RemoteSyncEvent>[]);
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

      test('given the remote refresh fails with a Failure, '
          'when build runs, '
          'then local data renders first without sync error, '
          'and eventual state captures the failure', () async {
        // given
        when(
          () => mockRepo.refreshFromRemote(),
        ).thenThrow(const NetworkFailure());
        when(() => mockRepo.syncPending()).thenAnswer((_) async {});
        when(() => mockRepo.getAll()).thenAnswer((_) async => oneCarList);
        when(() => mockRepo.hasPending()).thenAnswer((_) async => true);

        // when
        final container = makeContainer();
        final initial = await container.read(carListProvider.future);

        // then — local data emitted without waiting for remote
        expect(initial.cars, oneCarList);
        expect(initial.syncError, isNull);
        expect(initial.hasPendingSync, isTrue);

        // when — let background sync complete
        for (var i = 0; i < 10; i++) {
          await Future.delayed(Duration.zero);
        }

        // then — eventual state has the sync error
        final eventual = container.read(carListProvider).requireValue;
        expect(eventual.cars, oneCarList);
        expect(eventual.syncError, isA<NetworkFailure>());
        expect(eventual.hasPendingSync, isTrue);
      });

      test('given a slow remote, '
          'when build runs, '
          'then local data is emitted before remote completes', () async {
        // given
        final remoteCompleter = Completer<List<RemoteSyncEvent>>();
        when(
          () => mockRepo.refreshFromRemote(),
        ).thenAnswer((_) => remoteCompleter.future);
        when(() => mockRepo.syncPending()).thenAnswer((_) async {});
        when(() => mockRepo.getAll()).thenAnswer((_) async => oneCarList);
        when(() => mockRepo.hasPending()).thenAnswer((_) async => false);

        // when
        final container = makeContainer();
        final initial = await container.read(carListProvider.future);

        // then — local data returned, remote still pending
        expect(initial.cars, oneCarList);
        expect(initial.syncError, isNull);

        // complete remote and flush
        remoteCompleter.complete(const <RemoteSyncEvent>[]);
        for (var i = 0; i < 10; i++) {
          await Future.delayed(Duration.zero);
        }

        // then — background sync completed without error
        final eventual = container.read(carListProvider).requireValue;
        expect(eventual.cars, oneCarList);
        expect(eventual.syncError, isNull);
        verify(() => mockRepo.refreshFromRemote()).called(1);
      });

      test('given refreshFromRemote reports a remote deletion, '
          'when build runs, '
          'then remoteSyncEvents captures the event', () async {
        // given
        when(() => mockRepo.refreshFromRemote()).thenAnswer(
          (_) async => [const RemoteSyncEvent.remoteDeleted(toyotaCorolla)],
        );
        when(() => mockRepo.syncPending()).thenAnswer((_) async {});
        when(() => mockRepo.getAll()).thenAnswer((_) async => oneCarList);
        when(() => mockRepo.hasPending()).thenAnswer((_) async => false);

        // when
        final container = makeContainer();
        await container.read(carListProvider.future);
        for (var i = 0; i < 10; i++) {
          await Future.delayed(Duration.zero);
        }

        // then — background refresh surfaced the event
        final state = container.read(carListProvider).requireValue;
        expect(state.remoteSyncEvents, [
          const RemoteSyncEvent.remoteDeleted(toyotaCorolla),
        ]);
      });
    });

    group('add', () {
      test('given create succeeds, '
          'when add is called, '
          'then state is updated with the new car list and no error', () async {
        // given
        when(
          () => mockRepo.refreshFromRemote(),
        ).thenAnswer((_) async => <RemoteSyncEvent>[]);
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
        when(
          () => mockRepo.refreshFromRemote(),
        ).thenAnswer((_) async => <RemoteSyncEvent>[]);
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

    group('update', () {
      test(
        'given update succeeds, '
        'when update is called, '
        'then state is refreshed with the current car list and no error',
        () async {
          // given
          when(
            () => mockRepo.refreshFromRemote(),
          ).thenAnswer((_) async => <RemoteSyncEvent>[]);
          when(() => mockRepo.syncPending()).thenAnswer((_) async {});
          when(() => mockRepo.getAll()).thenAnswer((_) async => oneCarList);
          when(() => mockRepo.hasPending()).thenAnswer((_) async => false);
          when(() => mockRepo.update(any())).thenAnswer((_) async {});
          final mergedCar = buildCar(
            model: 'Corolla Hybrid',
            year: 2021,
            licensePlate: '9999 XXX',
            color: 'Red',
            mileage: 45000,
          );

          final container = makeContainer();
          await container.read(carListProvider.future);

          // when
          await container
              .read(carListProvider.notifier)
              .updateCar(corollaDraft, toyotaCorolla);

          // then
          final state = await container.read(carListProvider.future);
          expect(state.syncError, isNull);
          verify(() => mockRepo.update(mergedCar)).called(1);
        },
      );

      test('given update fails, '
          'when update is called, '
          'then state is refreshed with the current car list and the '
          'error is rethrown', () async {
        // given
        when(
          () => mockRepo.refreshFromRemote(),
        ).thenAnswer((_) async => <RemoteSyncEvent>[]);
        when(() => mockRepo.syncPending()).thenAnswer((_) async {});
        when(() => mockRepo.getAll()).thenAnswer((_) async => oneCarList);
        when(() => mockRepo.hasPending()).thenAnswer((_) async => true);
        when(() => mockRepo.update(any())).thenThrow(const NetworkFailure());

        final container = makeContainer();
        await container.read(carListProvider.future);

        // when / then
        await expectLater(
          () => container
              .read(carListProvider.notifier)
              .updateCar(corollaDraft, toyotaCorolla),
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
        when(
          () => mockRepo.refreshFromRemote(),
        ).thenAnswer((_) async => <RemoteSyncEvent>[]);
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

      test(
        'given syncPending fails, '
        'when syncPendingCars is called, '
        'then state captures the syncError and no error is rethrown',
        () async {
          // given
          when(
            () => mockRepo.refreshFromRemote(),
          ).thenAnswer((_) async => <RemoteSyncEvent>[]);
          when(() => mockRepo.syncPending()).thenAnswer((_) async {});
          when(() => mockRepo.getAll()).thenAnswer((_) async => oneCarList);
          when(() => mockRepo.hasPending()).thenAnswer((_) async => true);

          final container = makeContainer();
          await container.read(carListProvider.future);
          clearInteractions(mockRepo);

          when(() => mockRepo.syncPending()).thenThrow(const NetworkFailure());
          when(() => mockRepo.getAll()).thenAnswer((_) async => oneCarList);
          when(() => mockRepo.hasPending()).thenAnswer((_) async => true);

          // when — syncPendingCars swallows the error (rethrowError: false)
          await container.read(carListProvider.notifier).syncPendingCars();

          // then — the error is captured in state, not rethrown
          final state = await container.read(carListProvider.future);
          expect(state.syncError, isA<NetworkFailure>());
          expect(state.hasPendingSync, isTrue);
          verify(() => mockRepo.syncPending()).called(1);
        },
      );
    });

    group('deleteCar', () {
      test(
        'given delete succeeds, '
        'when deleteCar is called, '
        'then state exposes the pending delete ids and pending sync',
        () async {
          // given
          when(
            () => mockRepo.refreshFromRemote(),
          ).thenAnswer((_) async => <RemoteSyncEvent>[]);
          when(() => mockRepo.syncPending()).thenAnswer((_) async {});
          when(() => mockRepo.getAll()).thenAnswer((_) async => oneCarList);
          when(() => mockRepo.hasPending()).thenAnswer((_) async => true);
          when(
            () => mockRepo.pendingDeleteIds(),
          ).thenAnswer((_) async => {'1'});
          when(() => mockRepo.delete(any())).thenAnswer((_) async {});

          final container = makeContainer();
          await container.read(carListProvider.future);

          // when
          await container
              .read(carListProvider.notifier)
              .deleteCar(toyotaCorolla);

          // then
          final state = await container.read(carListProvider.future);
          expect(state.cars, oneCarList);
          expect(state.pendingDeleteIds, {'1'});
          expect(state.hasPendingSync, isTrue);
          expect(state.syncError, isNull);
          verify(() => mockRepo.delete(toyotaCorolla)).called(1);
        },
      );

      test(
        'given delete fails with a NetworkFailure, '
        'when deleteCar is called, '
        'then the error is captured and the row stays pending delete',
        () async {
          // given
          when(
            () => mockRepo.refreshFromRemote(),
          ).thenAnswer((_) async => <RemoteSyncEvent>[]);
          when(() => mockRepo.syncPending()).thenAnswer((_) async {});
          when(() => mockRepo.getAll()).thenAnswer((_) async => oneCarList);
          when(() => mockRepo.hasPending()).thenAnswer((_) async => true);
          when(
            () => mockRepo.pendingDeleteIds(),
          ).thenAnswer((_) async => {'1'});
          when(() => mockRepo.delete(any())).thenThrow(const NetworkFailure());

          final container = makeContainer();
          await container.read(carListProvider.future);

          // when / then
          await expectLater(
            () => container
                .read(carListProvider.notifier)
                .deleteCar(toyotaCorolla),
            throwsA(isA<NetworkFailure>()),
          );

          // then — state still coherent with the pending delete exposed
          final state = await container.read(carListProvider.future);
          expect(state.syncError, isA<NetworkFailure>());
          expect(state.cars, oneCarList);
          expect(state.pendingDeleteIds, {'1'});
        },
      );
    });

    group('clearRemoteChangeBanner', () {
      test('given state with remote sync events, '
          'when clearRemoteChangeBanner is called, '
          'then the events are cleared', () async {
        // given
        when(() => mockRepo.refreshFromRemote()).thenAnswer(
          (_) async => [const RemoteSyncEvent.remoteDeleted(toyotaCorolla)],
        );
        when(() => mockRepo.syncPending()).thenAnswer((_) async {});
        when(() => mockRepo.getAll()).thenAnswer((_) async => oneCarList);
        when(() => mockRepo.hasPending()).thenAnswer((_) async => false);

        final container = makeContainer();
        await container.read(carListProvider.future);
        for (var i = 0; i < 10; i++) {
          await Future.delayed(Duration.zero);
        }
        final withMessages = container.read(carListProvider).requireValue;
        expect(withMessages.remoteSyncEvents, isNotEmpty);

        // when
        container.read(carListProvider.notifier).clearRemoteChangeBanner();

        // then
        final cleared = container.read(carListProvider).requireValue;
        expect(cleared.remoteSyncEvents, isEmpty);
        expect(cleared.cars, oneCarList);
      });
    });
  });
}

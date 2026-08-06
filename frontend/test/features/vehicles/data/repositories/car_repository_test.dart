import 'dart:async';

import 'package:autobook/core/error/failures.dart';
import 'package:autobook/core/network/connectivity_service.dart';
import 'package:autobook/features/vehicles/data/datasources/local/car_local_datasource.dart';
import 'package:autobook/features/vehicles/data/datasources/remote/car_remote_datasource.dart';
import 'package:autobook/features/vehicles/data/models/car_dto.dart';
import 'package:autobook/features/vehicles/data/repositories/car_repository.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/domain/entities/remote_sync_event.dart';
import 'package:autobook/features/vehicles/domain/entities/sync_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/car_fixtures.dart';
import '../../helpers/car_mocks.dart';

class MockCarLocalDataSource extends Mock implements CarLocalDataSource {}

class MockCarRemoteDataSource extends Mock implements CarRemoteDataSource {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late MockCarLocalDataSource mockLocal;
  late MockCarRemoteDataSource mockRemote;
  late MockConnectivityService mockConnectivity;
  late CarRepository repo;

  setUpAll(() {
    registerCarFallbacks();
  });

  setUp(() {
    mockLocal = MockCarLocalDataSource();
    mockRemote = MockCarRemoteDataSource();
    mockConnectivity = MockConnectivityService();
    repo = CarRepository(
      local: mockLocal,
      remote: mockRemote,
      connectivity: mockConnectivity,
    );
  });

  group('CarRepository', () {
    group('refreshFromRemote', () {
      test('given api returns empty list, '
          'when refreshFromRemote runs, '
          'then upserts empty list', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRemote.fetchAll(),
        ).thenAnswer((_) async => const CarsListResponse(cars: []));
        when(
          () => mockLocal.getAllWithStates(),
        ).thenAnswer((_) async => <PendingCar>[]);
        when(() => mockLocal.upsertAll(any())).thenAnswer((_) async {});
        when(() => mockLocal.hardDeleteMany(any())).thenAnswer((_) async {});

        // when
        final events = await repo.refreshFromRemote();

        // then
        verify(() => mockLocal.upsertAll([])).called(1);
        expect(events, isEmpty);
      });

      test('given api returns two cars, '
          'when refreshFromRemote runs, '
          'then upserts both cars', () async {
        // given
        const car1 = toyotaCorolla;
        const car2 = fordFocus;
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.fetchAll()).thenAnswer(
          (_) async => CarsListResponse(
            cars: [CarDto.fromDomain(car1), CarDto.fromDomain(car2)],
          ),
        );
        when(
          () => mockLocal.getAllWithStates(),
        ).thenAnswer((_) async => <PendingCar>[]);
        when(() => mockLocal.upsertAll(any())).thenAnswer((_) async {});
        when(() => mockLocal.hardDeleteMany(any())).thenAnswer((_) async {});

        // when
        final events = await repo.refreshFromRemote();

        // then
        final captured = verify(
          () => mockLocal.upsertAll(captureAny()),
        ).captured;
        final upserted = captured.first as List<Car>;
        expect(upserted, hasLength(2));
        expect(upserted[0].id, '1');
        expect(upserted[1].id, '2');
        expect(events, isEmpty);
      });

      test('given api throws a generic exception, '
          'when refreshFromRemote runs, '
          'then throws NetworkFailure', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.fetchAll()).thenThrow(Exception('network error'));

        // when / then
        await expectLater(
          () => repo.refreshFromRemote(),
          throwsA(isA<NetworkFailure>()),
        );
      });

      test('given api throws a DioException, '
          'when refreshFromRemote runs, '
          'then throws ServerFailure with status code', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.fetchAll()).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars'),
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(path: '/cars'),
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        // when / then
        await expectLater(
          () => repo.refreshFromRemote(),
          throwsA(isA<ServerFailure>()),
        );
      });

      test('given api throws a DioException with no response, '
          'when refreshFromRemote runs, '
          'then throws NetworkFailure', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.fetchAll()).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        // when / then
        await expectLater(
          () => repo.refreshFromRemote(),
          throwsA(isA<NetworkFailure>()),
        );
      });

      test('given upsertAll throws after a successful fetch, '
          'when refreshFromRemote runs, '
          'then throws CacheFailure', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRemote.fetchAll(),
        ).thenAnswer((_) async => const CarsListResponse(cars: []));
        when(
          () => mockLocal.getAllWithStates(),
        ).thenAnswer((_) async => <PendingCar>[]);
        when(
          () => mockLocal.upsertAll(any()),
        ).thenThrow(StateError('db error'));

        // when / then
        await expectLater(
          () => repo.refreshFromRemote(),
          throwsA(isA<CacheFailure>()),
        );
      });

      test('given device is offline, '
          'when refreshFromRemote runs, '
          'then skips remote call and returns no events', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => false);

        // when
        final events = await repo.refreshFromRemote();

        // then
        expect(events, isEmpty);
        verifyNever(() => mockRemote.fetchAll());
      });

      test('given a synced car missing from the remote list, '
          'when refreshFromRemote runs, '
          'then hard deletes it and emits an eliminated event', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRemote.fetchAll(),
        ).thenAnswer((_) async => const CarsListResponse(cars: []));
        when(() => mockLocal.getAllWithStates()).thenAnswer(
          (_) async => [(car: toyotaCorolla, syncState: SyncStateEnum.synced)],
        );
        when(() => mockLocal.upsertAll(any())).thenAnswer((_) async {});
        when(() => mockLocal.hardDeleteMany(any())).thenAnswer((_) async {});

        // when
        final events = await repo.refreshFromRemote();

        // then
        verify(() => mockLocal.hardDeleteMany(['1'])).called(1);
        expect(events, [const RemoteSyncEvent.remoteDeleted(toyotaCorolla)]);
      });

      test('given a pendingUpdate car missing from the remote list, '
          'when refreshFromRemote runs, '
          'then hard deletes it and emits a discarded-edit event', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRemote.fetchAll(),
        ).thenAnswer((_) async => const CarsListResponse(cars: []));
        when(() => mockLocal.getAllWithStates()).thenAnswer(
          (_) async => [
            (car: toyotaCorolla, syncState: SyncStateEnum.pendingUpdate),
          ],
        );
        when(() => mockLocal.upsertAll(any())).thenAnswer((_) async {});
        when(() => mockLocal.hardDeleteMany(any())).thenAnswer((_) async {});

        // when
        final events = await repo.refreshFromRemote();

        // then
        verify(() => mockLocal.hardDeleteMany(['1'])).called(1);
        expect(events, [
          const RemoteSyncEvent.remoteDeletedWithPendingUpdate(toyotaCorolla),
        ]);
      });

      test('given a pendingDelete car missing from the remote list, '
          'when refreshFromRemote runs, '
          'then hard deletes it without an event', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRemote.fetchAll(),
        ).thenAnswer((_) async => const CarsListResponse(cars: []));
        when(() => mockLocal.getAllWithStates()).thenAnswer(
          (_) async => [
            (car: toyotaCorolla, syncState: SyncStateEnum.pendingDelete),
          ],
        );
        when(() => mockLocal.upsertAll(any())).thenAnswer((_) async {});
        when(() => mockLocal.hardDeleteMany(any())).thenAnswer((_) async {});

        // when
        final events = await repo.refreshFromRemote();

        // then
        verify(() => mockLocal.hardDeleteMany(['1'])).called(1);
        expect(events, isEmpty);
      });

      test('given a pendingDelete car still present in the remote list, '
          'when refreshFromRemote runs, '
          'then it is not reconciled and no event is emitted', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.fetchAll()).thenAnswer(
          (_) async =>
              CarsListResponse(cars: [CarDto.fromDomain(toyotaCorolla)]),
        );
        when(() => mockLocal.getAllWithStates()).thenAnswer(
          (_) async => [
            (car: toyotaCorolla, syncState: SyncStateEnum.pendingDelete),
          ],
        );
        when(() => mockLocal.upsertAll(any())).thenAnswer((_) async {});
        when(() => mockLocal.hardDeleteMany(any())).thenAnswer((_) async {});

        // when
        final events = await repo.refreshFromRemote();

        // then
        verify(() => mockLocal.hardDeleteMany([])).called(1);
        expect(events, isEmpty);
      });

      test('given a pendingCreate car missing from the remote list, '
          'when refreshFromRemote runs, '
          'then it is left intact and no event is emitted', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRemote.fetchAll(),
        ).thenAnswer((_) async => const CarsListResponse(cars: []));
        when(() => mockLocal.getAllWithStates()).thenAnswer(
          (_) async => [(car: fiat500, syncState: SyncStateEnum.pendingCreate)],
        );
        when(() => mockLocal.upsertAll(any())).thenAnswer((_) async {});
        when(() => mockLocal.hardDeleteMany(any())).thenAnswer((_) async {});

        // when
        final events = await repo.refreshFromRemote();

        // then
        verify(() => mockLocal.hardDeleteMany([])).called(1);
        expect(events, isEmpty);
      });

      test('given a known car in the remote list, '
          'when refreshFromRemote runs, '
          'then upsertAll updates it and no row is deleted', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.fetchAll()).thenAnswer(
          (_) async =>
              CarsListResponse(cars: [CarDto.fromDomain(toyotaCorolla)]),
        );
        when(() => mockLocal.getAllWithStates()).thenAnswer(
          (_) async => [(car: toyotaCorolla, syncState: SyncStateEnum.synced)],
        );
        when(() => mockLocal.upsertAll(any())).thenAnswer((_) async {});
        when(() => mockLocal.hardDeleteMany(any())).thenAnswer((_) async {});

        // when
        final events = await repo.refreshFromRemote();

        // then
        verify(() => mockLocal.hardDeleteMany([])).called(1);
        verify(() => mockLocal.upsertAll([toyotaCorolla])).called(1);
        expect(events, isEmpty);
      });
    });

    group('create', () {
      test('given device is online, '
          'when create is called with a new car, '
          'then inserts as pending, calls remote, and marks synced', () async {
        // given
        const newCar = renaultMegane;
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockLocal.insertPending(any())).thenAnswer((_) async {});
        when(() => mockRemote.create(any())).thenAnswer((_) async {});
        when(() => mockLocal.markSynced(any())).thenAnswer((_) async {});

        // when
        await repo.create(newCar);

        // then
        verify(() => mockLocal.insertPending(newCar)).called(1);
        verify(() => mockRemote.create(any())).called(1);
        verify(() => mockLocal.markSynced('n1')).called(1);
      });

      test('given device is offline, '
          'when create is called, '
          'then inserts as pending and does not call remote', () async {
        // given
        const newCar = peugeot208;
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => false);
        when(() => mockLocal.insertPending(any())).thenAnswer((_) async {});

        // when
        await repo.create(newCar);

        // then
        verify(() => mockLocal.insertPending(newCar)).called(1);
        verifyNever(() => mockRemote.create(any()));
        verifyNever(() => mockLocal.markSynced(any()));
      });

      test('given device is online but api throws, '
          'when create is called, '
          'then throws Failure and car stays as pending', () async {
        // given
        const newCar = volkswagenGolf;
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockLocal.insertPending(any())).thenAnswer((_) async {});
        when(
          () => mockRemote.create(any()),
        ).thenThrow(Exception('server error'));

        // when / then
        await expectLater(() => repo.create(newCar), throwsA(isA<Failure>()));
        verify(() => mockLocal.insertPending(newCar)).called(1);
        verifyNever(() => mockLocal.markSynced(any()));
      });

      test(
        'given device is online but api throws a connectionTimeout DioException, '
        'when create is called, '
        'then throws NetworkFailure and car stays pending',
        () async {
          // given
          const newCar = volkswagenGolf;
          when(
            () => mockConnectivity.isConnected(),
          ).thenAnswer((_) async => true);
          when(() => mockLocal.insertPending(any())).thenAnswer((_) async {});
          when(() => mockRemote.create(any())).thenThrow(
            DioException(
              requestOptions: RequestOptions(path: '/cars'),
              type: DioExceptionType.connectionTimeout,
            ),
          );

          // when / then
          await expectLater(
            () => repo.create(newCar),
            throwsA(isA<NetworkFailure>()),
          );
          verify(() => mockLocal.insertPending(newCar)).called(1);
          verifyNever(() => mockLocal.markSynced(any()));
        },
      );

      test('given remote create returns 409, '
          'when create is called, '
          'then marks synced to stop retrying and does not throw', () async {
        // given
        const newCar = volkswagenGolf;
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockLocal.insertPending(any())).thenAnswer((_) async {});
        when(() => mockRemote.create(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars'),
            response: Response(
              statusCode: 409,
              requestOptions: RequestOptions(path: '/cars'),
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        when(() => mockLocal.markSynced(any())).thenAnswer((_) async {});

        // when
        await repo.create(newCar);

        // then
        verify(() => mockLocal.markSynced('f1')).called(1);
      });
    });

    group('getAll', () {
      test('given the local data source throws, '
          'when getAll runs, '
          'then maps the error to a CacheFailure', () async {
        // given
        when(
          () => mockLocal.getAll(),
        ).thenThrow(StateError('database unavailable'));

        // when / then
        await expectLater(() => repo.getAll(), throwsA(isA<CacheFailure>()));
      });
    });

    group('hasPending', () {
      test('given pending cars exist, '
          'when hasPending runs, '
          'then returns true', () async {
        // given
        when(() => mockLocal.countPending()).thenAnswer((_) async => 2);

        // when
        final pending = await repo.hasPending();

        // then
        expect(pending, isTrue);
      });

      test('given no pending cars, '
          'when hasPending runs, '
          'then returns false', () async {
        // given
        when(() => mockLocal.countPending()).thenAnswer((_) async => 0);

        // when
        final pending = await repo.hasPending();

        // then
        expect(pending, isFalse);
      });

      test('given the local data source throws, '
          'when hasPending runs, '
          'then maps the error to a CacheFailure', () async {
        // given
        when(
          () => mockLocal.countPending(),
        ).thenThrow(StateError('database unavailable'));

        // when / then
        await expectLater(
          () => repo.hasPending(),
          throwsA(isA<CacheFailure>()),
        );
      });
    });

    group('update', () {
      test('given device is online, '
          'when update is called, '
          'then upserts as pending update, calls remote update, '
          'and marks synced', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockLocal.upsertPending(
            any(),
            syncState: any(named: 'syncState'),
          ),
        ).thenAnswer((_) async {});
        when(() => mockRemote.update(any(), any())).thenAnswer((_) async {});
        when(() => mockLocal.markSynced(any())).thenAnswer((_) async {});

        // when
        await repo.update(toyotaCorolla);

        // then
        verify(
          () => mockLocal.upsertPending(
            toyotaCorolla,
            syncState: SyncStateEnum.pendingUpdate,
          ),
        ).called(1);
        verify(() => mockRemote.update('1', any())).called(1);
        verify(() => mockLocal.markSynced('1')).called(1);
      });

      test('given device is offline, '
          'when update is called, '
          'then upserts as pending update and does not call remote', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => false);
        when(
          () => mockLocal.upsertPending(
            any(),
            syncState: any(named: 'syncState'),
          ),
        ).thenAnswer((_) async {});

        // when
        await repo.update(toyotaCorolla);

        // then
        verify(
          () => mockLocal.upsertPending(
            toyotaCorolla,
            syncState: SyncStateEnum.pendingUpdate,
          ),
        ).called(1);
        verifyNever(() => mockRemote.update(any(), any()));
        verifyNever(() => mockLocal.markSynced(any()));
      });

      test('given remote update returns 404, '
          'when update is called, '
          'then throws ServerFailure and car stays pending without marking '
          'synced', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockLocal.upsertPending(
            any(),
            syncState: any(named: 'syncState'),
          ),
        ).thenAnswer((_) async {});
        when(() => mockRemote.update(any(), any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars/1'),
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(path: '/cars/1'),
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        // when / then
        await expectLater(
          () => repo.update(toyotaCorolla),
          throwsA(isA<ServerFailure>()),
        );
        verifyNever(() => mockLocal.markSynced(any()));
      });

      test('given remote update returns a server error, '
          'when update is called, '
          'then throws ServerFailure and car stays pending', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockLocal.upsertPending(
            any(),
            syncState: any(named: 'syncState'),
          ),
        ).thenAnswer((_) async {});
        when(() => mockRemote.update(any(), any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars/1'),
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(path: '/cars/1'),
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        // when / then
        await expectLater(
          () => repo.update(toyotaCorolla),
          throwsA(isA<ServerFailure>()),
        );
        verifyNever(() => mockLocal.markSynced(any()));
      });
    });

    group('delete', () {
      test(
        'given device is online and car is synced, '
        'when delete is called, '
        'then marks pending delete, calls remote delete and hard deletes',
        () async {
          // given
          when(
            () => mockLocal.syncStateOf('1'),
          ).thenAnswer((_) async => SyncStateEnum.synced);
          when(
            () => mockLocal.markPendingDelete(any()),
          ).thenAnswer((_) async {});
          when(
            () => mockConnectivity.isConnected(),
          ).thenAnswer((_) async => true);
          when(() => mockRemote.delete(any())).thenAnswer((_) async {});
          when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

          // when
          await repo.delete(toyotaCorolla);

          // then
          verify(() => mockLocal.markPendingDelete('1')).called(1);
          verify(() => mockRemote.delete('1')).called(1);
          verify(() => mockLocal.hardDelete('1')).called(1);
        },
      );

      test(
        'given device is online and car is pendingUpdate, '
        'when delete is called, '
        'then marks pending delete without a remote update and hard deletes',
        () async {
          // given
          when(
            () => mockLocal.syncStateOf('1'),
          ).thenAnswer((_) async => SyncStateEnum.pendingUpdate);
          when(
            () => mockLocal.markPendingDelete(any()),
          ).thenAnswer((_) async {});
          when(
            () => mockConnectivity.isConnected(),
          ).thenAnswer((_) async => true);
          when(() => mockRemote.delete(any())).thenAnswer((_) async {});
          when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

          // when
          await repo.delete(toyotaCorolla);

          // then
          verify(() => mockLocal.markPendingDelete('1')).called(1);
          verifyNever(() => mockRemote.update(any(), any()));
          verify(() => mockRemote.delete('1')).called(1);
          verify(() => mockLocal.hardDelete('1')).called(1);
        },
      );

      test('given car is pendingCreate, '
          'when delete is called, '
          'then hard deletes locally and never calls remote', () async {
        // given
        when(
          () => mockLocal.syncStateOf('pend1'),
        ).thenAnswer((_) async => SyncStateEnum.pendingCreate);
        when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

        // when
        await repo.delete(fiat500);

        // then
        verify(() => mockLocal.hardDelete('pend1')).called(1);
        verifyNever(() => mockRemote.delete(any()));
        verifyNever(() => mockLocal.markPendingDelete(any()));
      });

      test('given a pendingCreate car whose push is in flight, '
          'when delete is called, '
          'then throws CacheFailure and does not hard delete', () async {
        // given — a create in flight holds the id in _syncingIds
        when(
          () => mockLocal.syncStateOf('pend1'),
        ).thenAnswer((_) async => SyncStateEnum.pendingCreate);
        when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockLocal.insertPending(any())).thenAnswer((_) async {});
        final remoteCompleter = Completer<void>();
        when(
          () => mockRemote.create(any()),
        ).thenAnswer((_) => remoteCompleter.future);
        when(() => mockLocal.markSynced(any())).thenAnswer((_) async {});
        final createFuture = repo.create(fiat500);
        // remote.create invoked only after the id entered _syncingIds
        for (var i = 0; i < 10; i++) {
          await Future.delayed(Duration.zero);
        }
        verify(() => mockRemote.create(CarDto.fromDomain(fiat500))).called(1);

        // when / then
        await expectLater(
          () => repo.delete(fiat500),
          throwsA(isA<CacheFailure>()),
        );
        verifyNever(() => mockLocal.hardDelete(any()));

        // when — complete the in-flight push so no future leaks
        remoteCompleter.complete();
        await createFuture;
      });

      test('given device is offline and car is synced, '
          'when delete is called, '
          'then marks pending delete and never calls remote', () async {
        // given
        when(
          () => mockLocal.syncStateOf('1'),
        ).thenAnswer((_) async => SyncStateEnum.synced);
        when(() => mockLocal.markPendingDelete(any())).thenAnswer((_) async {});
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => false);

        // when
        await repo.delete(toyotaCorolla);

        // then
        verify(() => mockLocal.markPendingDelete('1')).called(1);
        verifyNever(() => mockRemote.delete(any()));
        verifyNever(() => mockLocal.hardDelete(any()));
      });

      test('given remote delete returns 404, '
          'when delete is called, '
          'then treats it as success and hard deletes', () async {
        // given
        when(
          () => mockLocal.syncStateOf('1'),
        ).thenAnswer((_) async => SyncStateEnum.synced);
        when(() => mockLocal.markPendingDelete(any())).thenAnswer((_) async {});
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.delete(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars/1'),
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(path: '/cars/1'),
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

        // when
        await repo.delete(toyotaCorolla);

        // then
        verify(() => mockLocal.hardDelete('1')).called(1);
      });

      test('given remote delete returns 500, '
          'when delete is called, '
          'then throws ServerFailure and row stays pending delete', () async {
        // given
        when(
          () => mockLocal.syncStateOf('1'),
        ).thenAnswer((_) async => SyncStateEnum.synced);
        when(() => mockLocal.markPendingDelete(any())).thenAnswer((_) async {});
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.delete(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars/1'),
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(path: '/cars/1'),
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        // when / then
        await expectLater(
          () => repo.delete(toyotaCorolla),
          throwsA(isA<ServerFailure>()),
        );
        verifyNever(() => mockLocal.hardDelete(any()));
        verify(() => mockLocal.markPendingDelete('1')).called(1);
      });

      test('given remote delete times out, '
          'when delete is called, '
          'then throws NetworkFailure and row stays pending delete', () async {
        // given
        when(
          () => mockLocal.syncStateOf('1'),
        ).thenAnswer((_) async => SyncStateEnum.synced);
        when(() => mockLocal.markPendingDelete(any())).thenAnswer((_) async {});
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.delete(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars/1'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        // when / then
        await expectLater(
          () => repo.delete(toyotaCorolla),
          throwsA(isA<NetworkFailure>()),
        );
        verifyNever(() => mockLocal.hardDelete(any()));
        verify(() => mockLocal.markPendingDelete('1')).called(1);
      });
    });

    group('pendingDeleteIds', () {
      test('given the local data source returns ids, '
          'when pendingDeleteIds is called, '
          'then returns the same set', () async {
        // given
        when(
          () => mockLocal.pendingDeleteIds(),
        ).thenAnswer((_) async => {'a', 'b'});

        // when
        final ids = await repo.pendingDeleteIds();

        // then
        expect(ids, {'a', 'b'});
      });

      test('given the local data source throws, '
          'when pendingDeleteIds is called, '
          'then maps the error to a CacheFailure', () async {
        // given
        when(
          () => mockLocal.pendingDeleteIds(),
        ).thenThrow(StateError('database unavailable'));

        // when / then
        await expectLater(
          () => repo.pendingDeleteIds(),
          throwsA(isA<CacheFailure>()),
        );
      });
    });

    group('syncPending', () {
      test('given one pending car and device is online, '
          'when syncPending is called, '
          'then sends to api and marks synced', () async {
        // given
        when(() => mockLocal.getPending()).thenAnswer(
          (_) async => [(car: fiat500, syncState: SyncStateEnum.pendingCreate)],
        );
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.create(any())).thenAnswer((_) async {});
        when(() => mockLocal.markSynced(any())).thenAnswer((_) async {});

        // when
        await repo.syncPending();

        // then
        verify(() => mockRemote.create(any())).called(1);
        verify(() => mockLocal.markSynced('pend1')).called(1);
      });

      test('given 2 pending cars and second fails to sync, '
          'when syncPending is called, '
          'then first is synced and second stays pending', () async {
        // given
        when(() => mockLocal.getPending()).thenAnswer(
          (_) async => [
            (car: fiat500, syncState: SyncStateEnum.pendingCreate),
            (car: alfaGiulia, syncState: SyncStateEnum.pendingCreate),
          ],
        );
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        var callCount = 0;
        when(() => mockRemote.create(any())).thenAnswer((_) async {
          callCount++;
          if (callCount == 2) throw Exception('server error');
        });
        when(() => mockLocal.markSynced(any())).thenAnswer((_) async {});

        // when
        await repo.syncPending();

        // then
        verify(() => mockLocal.markSynced('pend1')).called(1);
        verifyNever(() => mockLocal.markSynced('pend2'));
      });

      test('given all createCar calls fail, '
          'when syncPending is called, '
          'then all pending cars stay pending', () async {
        // given
        when(() => mockLocal.getPending()).thenAnswer(
          (_) async => [(car: fiat500, syncState: SyncStateEnum.pendingCreate)],
        );
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRemote.create(any()),
        ).thenThrow(Exception('server error'));

        // when
        await repo.syncPending();

        // then
        verifyNever(() => mockLocal.markSynced(any()));
      });

      test('given getPending throws, '
          'when syncPending is called, '
          'then throws CacheFailure', () async {
        // given
        when(
          () => mockLocal.getPending(),
        ).thenThrow(StateError('database unavailable'));

        // when / then
        await expectLater(
          () => repo.syncPending(),
          throwsA(isA<CacheFailure>()),
        );
      });

      test('given one updated pending car and device is online, '
          'when syncPending is called, '
          'then calls remote update and marks synced', () async {
        // given
        when(() => mockLocal.getPending()).thenAnswer(
          (_) async => [(car: fiat500, syncState: SyncStateEnum.pendingUpdate)],
        );
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.update(any(), any())).thenAnswer((_) async {});
        when(() => mockLocal.markSynced(any())).thenAnswer((_) async {});

        // when
        await repo.syncPending();

        // then
        verify(() => mockRemote.update('pend1', any())).called(1);
        verifyNever(() => mockRemote.create(any()));
        verify(() => mockLocal.markSynced('pend1')).called(1);
      });

      test('given remote create returns 409 during the flush, '
          'when syncPending is called, '
          'then marks synced to stop retrying', () async {
        // given
        when(() => mockLocal.getPending()).thenAnswer(
          (_) async => [(car: fiat500, syncState: SyncStateEnum.pendingCreate)],
        );
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.create(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars'),
            response: Response(
              statusCode: 409,
              requestOptions: RequestOptions(path: '/cars'),
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        when(() => mockLocal.markSynced(any())).thenAnswer((_) async {});

        // when
        await repo.syncPending();

        // then
        verify(() => mockLocal.markSynced('pend1')).called(1);
      });

      test('given remote update returns 404 during the flush, '
          'when syncPending is called, '
          'then the car stays pending and is not marked synced', () async {
        // given
        when(() => mockLocal.getPending()).thenAnswer(
          (_) async => [(car: fiat500, syncState: SyncStateEnum.pendingUpdate)],
        );
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.update(any(), any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars/pend1'),
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(path: '/cars/pend1'),
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        // when
        await repo.syncPending();

        // then
        verifyNever(() => mockLocal.markSynced(any()));
      });

      test('given a pendingDelete row and device is online, '
          'when syncPending is called, '
          'then calls remote delete and hard deletes', () async {
        // given
        when(() => mockLocal.getPending()).thenAnswer(
          (_) async => [(car: fiat500, syncState: SyncStateEnum.pendingDelete)],
        );
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.delete(any())).thenAnswer((_) async {});
        when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

        // when
        await repo.syncPending();

        // then
        verify(() => mockRemote.delete('pend1')).called(1);
        verify(() => mockLocal.hardDelete('pend1')).called(1);
      });

      test('given a pendingDelete row receives a 404, '
          'when syncPending is called, '
          'then hard deletes without throwing', () async {
        // given
        when(() => mockLocal.getPending()).thenAnswer(
          (_) async => [(car: fiat500, syncState: SyncStateEnum.pendingDelete)],
        );
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.delete(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars/pend1'),
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(path: '/cars/pend1'),
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

        // when
        await repo.syncPending();

        // then
        verify(() => mockLocal.hardDelete('pend1')).called(1);
      });

      test('given a pendingDelete row fails with a 500, '
          'when syncPending is called, '
          'then hard delete is not called and the row stays pending', () async {
        // given
        when(() => mockLocal.getPending()).thenAnswer(
          (_) async => [(car: fiat500, syncState: SyncStateEnum.pendingDelete)],
        );
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.delete(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars/pend1'),
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(path: '/cars/pend1'),
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        // when
        await repo.syncPending();

        // then
        verifyNever(() => mockLocal.hardDelete(any()));
      });

      test('given a mixed queue of pendingCreate and pendingDelete, '
          'when syncPending is called, '
          'then both are processed in order and one failure does not abort '
          'the other', () async {
        // given
        when(() => mockLocal.getPending()).thenAnswer(
          (_) async => [
            (car: fiat500, syncState: SyncStateEnum.pendingCreate),
            (car: alfaGiulia, syncState: SyncStateEnum.pendingDelete),
          ],
        );
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.create(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars'),
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(path: '/cars'),
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        when(() => mockRemote.delete(any())).thenAnswer((_) async {});
        when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

        // when
        await repo.syncPending();

        // then
        verify(() => mockRemote.delete('pend2')).called(1);
        verify(() => mockLocal.hardDelete('pend2')).called(1);
      });
    });
  });
}

import 'dart:async';

import 'package:autobook/core/error/failures.dart';
import 'package:autobook/core/network/connectivity_service.dart';
import 'package:autobook/features/maintenances/data/datasources/local/'
    'maintenance_local_datasource.dart';
import 'package:autobook/features/maintenances/data/datasources/remote/'
    'maintenance_remote_datasource.dart';
import 'package:autobook/features/maintenances/data/models/'
    'maintenance_dto.dart';
import 'package:autobook/features/maintenances/data/repositories/'
    'maintenance_repository.dart';
import 'package:autobook/features/maintenances/domain/entities/'
    'maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/'
    'maintenance_remote_sync_event.dart';
import 'package:autobook/features/vehicles/domain/entities/sync_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/maintenance_fixtures.dart';

class MockMaintenanceLocalDataSource extends Mock
    implements MaintenanceLocalDataSource {}

class MockMaintenanceRemoteDataSource extends Mock
    implements MaintenanceRemoteDataSource {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late MockMaintenanceLocalDataSource mockLocal;
  late MockMaintenanceRemoteDataSource mockRemote;
  late MockConnectivityService mockConnectivity;
  late MaintenanceRepository repo;

  setUpAll(() {
    registerFallbackValue(oilChangeMarch);
    registerFallbackValue(
      const MaintenanceDto(
        id: '',
        carId: '',
        type: 'oil',
        date: '',
        mileage: 0,
        cost: 0,
      ),
    );
    registerFallbackValue((
      maintenance: oilChangeMarch,
      syncState: SyncStateEnum.synced,
    ));
    registerFallbackValue(SyncStateEnum.synced);
    registerFallbackValue(const <Maintenance>[]);
  });

  setUp(() {
    mockLocal = MockMaintenanceLocalDataSource();
    mockRemote = MockMaintenanceRemoteDataSource();
    mockConnectivity = MockConnectivityService();
    repo = MaintenanceRepository(
      local: mockLocal,
      remote: mockRemote,
      connectivity: mockConnectivity,
    );
  });

  group('MaintenanceRepository', () {
    group('getAll', () {
      test('given the local data source throws, '
          'when getAll runs, '
          'then maps the error to a CacheFailure', () async {
        // given
        when(
          () => mockLocal.getAll('car-1'),
        ).thenThrow(StateError('database unavailable'));

        // when / then
        await expectLater(
          () => repo.getAll('car-1'),
          throwsA(isA<CacheFailure>()),
        );
      });
    });

    group('refreshFromRemote', () {
      test('given device is offline, '
          'when refreshFromRemote runs, '
          'then skips the remote call and returns no events', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => false);

        // when
        final events = await repo.refreshFromRemote('car-1');

        // then
        expect(events, isEmpty);
        verifyNever(() => mockRemote.fetchForCar(any()));
      });

      test('given api returns two maintenances, '
          'when refreshFromRemote runs, '
          'then upserts both rows', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.fetchForCar('car-1')).thenAnswer(
          (_) async => MaintenancesListResponse(
            maintenances: [
              MaintenanceDto.fromDomain(oilChangeMarch),
              MaintenanceDto.fromDomain(tireSwapJanuary),
            ],
          ),
        );
        when(
          () => mockLocal.getAllWithStates('car-1'),
        ).thenAnswer((_) async => <PendingMaintenance>[]);
        when(() => mockLocal.upsertAll(any())).thenAnswer((_) async {});
        when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

        // when
        final events = await repo.refreshFromRemote('car-1');

        // then
        final captured = verify(
          () => mockLocal.upsertAll(captureAny()),
        ).captured;
        final upserted = captured.first as List<Maintenance>;
        expect(upserted, hasLength(2));
        expect(upserted[0].id, '1');
        expect(upserted[1].id, '2');
        expect(events, isEmpty);
      });

      test('given api throws a DioException with a response, '
          'when refreshFromRemote runs, '
          'then throws ServerFailure with status code', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.fetchForCar('car-1')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars/car-1/maintenances'),
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(path: '/cars/car-1/maintenances'),
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        // when / then
        await expectLater(
          () => repo.refreshFromRemote('car-1'),
          throwsA(isA<ServerFailure>()),
        );
      });

      test('given api throws a generic exception, '
          'when refreshFromRemote runs, '
          'then throws NetworkFailure', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRemote.fetchForCar('car-1'),
        ).thenThrow(Exception('network error'));

        // when / then
        await expectLater(
          () => repo.refreshFromRemote('car-1'),
          throwsA(isA<NetworkFailure>()),
        );
      });

      test('given getAllWithStates throws, '
          'when refreshFromRemote runs, '
          'then throws CacheFailure', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.fetchForCar('car-1')).thenAnswer(
          (_) async => const MaintenancesListResponse(maintenances: []),
        );
        when(
          () => mockLocal.getAllWithStates('car-1'),
        ).thenThrow(StateError('database unavailable'));

        // when / then
        await expectLater(
          () => repo.refreshFromRemote('car-1'),
          throwsA(isA<CacheFailure>()),
        );
      });

      test('given upsertAll throws after a successful fetch, '
          'when refreshFromRemote runs, '
          'then throws CacheFailure', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.fetchForCar('car-1')).thenAnswer(
          (_) async => const MaintenancesListResponse(maintenances: []),
        );
        when(
          () => mockLocal.getAllWithStates('car-1'),
        ).thenAnswer((_) async => <PendingMaintenance>[]);
        when(
          () => mockLocal.upsertAll(any()),
        ).thenThrow(StateError('db error'));

        // when / then
        await expectLater(
          () => repo.refreshFromRemote('car-1'),
          throwsA(isA<CacheFailure>()),
        );
      });

      test('given a local pendingUpdate id exists remotely, '
          'when refreshFromRemote runs, '
          'then upsertAll skips that id', () async {
        // given
        final staleRemote = oilChangeMarch.copyWith(cost: 99);
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.fetchForCar('car-1')).thenAnswer(
          (_) async => MaintenancesListResponse(
            maintenances: [MaintenanceDto.fromDomain(staleRemote)],
          ),
        );
        when(() => mockLocal.getAllWithStates('car-1')).thenAnswer(
          (_) async => [
            (
              maintenance: oilChangeMarch,
              syncState: SyncStateEnum.pendingUpdate,
            ),
          ],
        );
        when(() => mockLocal.upsertAll(any())).thenAnswer((_) async {});
        when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

        // when
        final events = await repo.refreshFromRemote('car-1');

        // then
        final captured = verify(
          () => mockLocal.upsertAll(captureAny()),
        ).captured;
        final upserted = captured.first as List<Maintenance>;
        expect(upserted, isEmpty);
        expect(events, isEmpty);
      });

      test('given a local pendingCreate id exists remotely, '
          'when refreshFromRemote runs, '
          'then upsertAll skips that id too', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.fetchForCar('car-1')).thenAnswer(
          (_) async => MaintenancesListResponse(
            maintenances: [MaintenanceDto.fromDomain(brakesPending)],
          ),
        );
        when(() => mockLocal.getAllWithStates('car-1')).thenAnswer(
          (_) async => [
            (
              maintenance: brakesPending,
              syncState: SyncStateEnum.pendingCreate,
            ),
          ],
        );
        when(() => mockLocal.upsertAll(any())).thenAnswer((_) async {});
        when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

        // when
        final events = await repo.refreshFromRemote('car-1');

        // then
        final captured = verify(
          () => mockLocal.upsertAll(captureAny()),
        ).captured;
        final upserted = captured.first as List<Maintenance>;
        expect(upserted, isEmpty);
        expect(events, isEmpty);
      });

      test('given a synced row missing from the remote list, '
          'when refreshFromRemote runs, '
          'then hard deletes it and emits a remoteDeleted event', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.fetchForCar('car-1')).thenAnswer(
          (_) async => const MaintenancesListResponse(maintenances: []),
        );
        when(() => mockLocal.getAllWithStates('car-1')).thenAnswer(
          (_) async => [
            (maintenance: oilChangeMarch, syncState: SyncStateEnum.synced),
          ],
        );
        when(() => mockLocal.upsertAll(any())).thenAnswer((_) async {});
        when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

        // when
        final events = await repo.refreshFromRemote('car-1');

        // then
        verify(() => mockLocal.hardDelete('1')).called(1);
        expect(events, [
          const MaintenanceRemoteSyncEvent.remoteDeleted(oilChangeMarch),
        ]);
      });

      test('given a pendingUpdate row missing from the remote list, '
          'when refreshFromRemote runs, '
          'then hard deletes it and emits the discarded-edit event', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.fetchForCar('car-1')).thenAnswer(
          (_) async => const MaintenancesListResponse(maintenances: []),
        );
        when(() => mockLocal.getAllWithStates('car-1')).thenAnswer(
          (_) async => [
            (
              maintenance: oilChangeMarch,
              syncState: SyncStateEnum.pendingUpdate,
            ),
          ],
        );
        when(() => mockLocal.upsertAll(any())).thenAnswer((_) async {});
        when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

        // when
        final events = await repo.refreshFromRemote('car-1');

        // then
        verify(() => mockLocal.hardDelete('1')).called(1);
        expect(events, [
          const MaintenanceRemoteSyncEvent.remoteDeletedWithPendingUpdate(
            oilChangeMarch,
          ),
        ]);
      });

      test('given a pendingDelete row missing from the remote list, '
          'when refreshFromRemote runs, '
          'then hard deletes it without an event', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.fetchForCar('car-1')).thenAnswer(
          (_) async => const MaintenancesListResponse(maintenances: []),
        );
        when(() => mockLocal.getAllWithStates('car-1')).thenAnswer(
          (_) async => [
            (
              maintenance: oilChangeMarch,
              syncState: SyncStateEnum.pendingDelete,
            ),
          ],
        );
        when(() => mockLocal.upsertAll(any())).thenAnswer((_) async {});
        when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

        // when
        final events = await repo.refreshFromRemote('car-1');

        // then
        verify(() => mockLocal.hardDelete('1')).called(1);
        expect(events, isEmpty);
      });

      test('given a pendingDelete row still present remotely, '
          'when refreshFromRemote runs, '
          'then it is not reconciled and nothing is deleted', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.fetchForCar('car-1')).thenAnswer(
          (_) async => MaintenancesListResponse(
            maintenances: [MaintenanceDto.fromDomain(oilChangeMarch)],
          ),
        );
        when(() => mockLocal.getAllWithStates('car-1')).thenAnswer(
          (_) async => [
            (
              maintenance: oilChangeMarch,
              syncState: SyncStateEnum.pendingDelete,
            ),
          ],
        );
        when(() => mockLocal.upsertAll(any())).thenAnswer((_) async {});
        when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

        // when
        final events = await repo.refreshFromRemote('car-1');

        // then
        verifyNever(() => mockLocal.hardDelete(any()));
        expect(events, isEmpty);
      });

      test('given a pendingCreate row missing from the remote list, '
          'when refreshFromRemote runs, '
          'then it is left intact and no event is emitted', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.fetchForCar('car-1')).thenAnswer(
          (_) async => const MaintenancesListResponse(maintenances: []),
        );
        when(() => mockLocal.getAllWithStates('car-1')).thenAnswer(
          (_) async => [
            (
              maintenance: brakesPending,
              syncState: SyncStateEnum.pendingCreate,
            ),
          ],
        );
        when(() => mockLocal.upsertAll(any())).thenAnswer((_) async {});
        when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

        // when
        final events = await repo.refreshFromRemote('car-1');

        // then
        verifyNever(() => mockLocal.hardDelete(any()));
        expect(events, isEmpty);
      });
    });

    group('create', () {
      test(
        'given device is online, '
        'when create is called with a new maintenance, '
        'then inserts as pending, pushes to remote, and marks synced',
        () async {
          // given
          const newMaintenance = coolantFlushJune;
          when(
            () => mockConnectivity.isConnected(),
          ).thenAnswer((_) async => true);
          when(() => mockLocal.insertPending(any())).thenAnswer((_) async {});
          when(() => mockRemote.create(any(), any())).thenAnswer((_) async {});
          when(() => mockLocal.markSynced(any())).thenAnswer((_) async {});

          // when
          await repo.create(newMaintenance);

          // then
          verify(() => mockLocal.insertPending(newMaintenance)).called(1);
          verify(
            () => mockRemote.create(
              'car-1',
              MaintenanceDto.fromDomain(newMaintenance),
            ),
          ).called(1);
          verify(() => mockLocal.markSynced('n1')).called(1);
        },
      );

      test('given device is offline, '
          'when create is called, '
          'then inserts as pendingCreate and does not call remote', () async {
        // given
        const newMaintenance = coolantFlushJune;
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => false);
        when(() => mockLocal.insertPending(any())).thenAnswer((_) async {});

        // when
        await repo.create(newMaintenance);

        // then
        verify(() => mockLocal.insertPending(newMaintenance)).called(1);
        verifyNever(() => mockRemote.create(any(), any()));
        verifyNever(() => mockLocal.markSynced(any()));
      });

      test('given device is online but api throws, '
          'when create is called, '
          'then throws Failure and row stays pending', () async {
        // given
        const newMaintenance = coolantFlushJune;
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockLocal.insertPending(any())).thenAnswer((_) async {});
        when(
          () => mockRemote.create(any(), any()),
        ).thenThrow(Exception('server error'));

        // when / then
        await expectLater(
          () => repo.create(newMaintenance),
          throwsA(isA<NetworkFailure>()),
        );
        verify(() => mockLocal.insertPending(newMaintenance)).called(1);
        verifyNever(() => mockLocal.markSynced(any()));
      });

      test('given api throws a connectionTimeout DioException, '
          'when create is called, '
          'then throws NetworkFailure and row stays pending', () async {
        // given
        const newMaintenance = coolantFlushJune;
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockLocal.insertPending(any())).thenAnswer((_) async {});
        when(() => mockRemote.create(any(), any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars/car-1/maintenances'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        // when / then
        await expectLater(
          () => repo.create(newMaintenance),
          throwsA(isA<NetworkFailure>()),
        );
        verifyNever(() => mockLocal.markSynced(any()));
      });

      test('given remote create returns 409, '
          'when create is called, '
          'then settles via markSynced and does not throw', () async {
        // given
        const newMaintenance = coolantFlushJune;
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockLocal.insertPending(any())).thenAnswer((_) async {});
        when(() => mockRemote.create(any(), any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars/car-1/maintenances'),
            response: Response(
              statusCode: 409,
              requestOptions: RequestOptions(path: '/cars/car-1/maintenances'),
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        when(() => mockLocal.markSynced(any())).thenAnswer((_) async {});

        // when
        await repo.create(newMaintenance);

        // then
        verify(() => mockLocal.markSynced('n1')).called(1);
      });
    });

    group('update', () {
      test(
        'given device is online, '
        'when update is called, '
        'then upserts as pendingUpdate, pushes to remote, and marks synced',
        () async {
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
          when(
            () => mockRemote.update(any(), any(), any()),
          ).thenAnswer((_) async {});
          when(() => mockLocal.markSynced(any())).thenAnswer((_) async {});

          // when
          await repo.update(oilChangeMarch);

          // then
          verify(
            () => mockLocal.upsertPending(
              oilChangeMarch,
              syncState: SyncStateEnum.pendingUpdate,
            ),
          ).called(1);
          verify(
            () => mockRemote.update(
              'car-1',
              '1',
              MaintenanceDto.fromDomain(oilChangeMarch),
            ),
          ).called(1);
          verify(() => mockLocal.markSynced('1')).called(1);
        },
      );

      test('given device is offline, '
          'when update is called, '
          'then upserts as pendingUpdate and does not call remote', () async {
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
        await repo.update(oilChangeMarch);

        // then
        verify(
          () => mockLocal.upsertPending(
            oilChangeMarch,
            syncState: SyncStateEnum.pendingUpdate,
          ),
        ).called(1);
        verifyNever(() => mockRemote.update(any(), any(), any()));
        verifyNever(() => mockLocal.markSynced(any()));
      });

      test('given remote update returns 404, '
          'when update push runs, '
          'then hard-deletes locally and does not throw', () async {
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
        when(() => mockRemote.update(any(), any(), any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars/car-1/maintenances/1'),
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(
                path: '/cars/car-1/maintenances/1',
              ),
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

        // when
        await repo.update(oilChangeMarch);

        // then
        verify(() => mockLocal.hardDelete('1')).called(1);
        verifyNever(() => mockLocal.markSynced(any()));
      });

      test('given remote update returns a server error, '
          'when update is called, '
          'then throws ServerFailure and row stays pending', () async {
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
        when(() => mockRemote.update(any(), any(), any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars/car-1/maintenances/1'),
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(
                path: '/cars/car-1/maintenances/1',
              ),
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        // when / then
        await expectLater(
          () => repo.update(oilChangeMarch),
          throwsA(isA<ServerFailure>()),
        );
        verifyNever(() => mockLocal.markSynced(any()));
      });
    });

    group('delete', () {
      test(
        'given device is online and row is synced, '
        'when delete is called, '
        'then marks pending delete, pushes to remote and hard deletes',
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
          when(() => mockRemote.delete(any(), any())).thenAnswer((_) async {});
          when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

          // when
          await repo.delete(oilChangeMarch);

          // then
          verify(() => mockLocal.markPendingDelete('1')).called(1);
          verify(() => mockRemote.delete('car-1', '1')).called(1);
          verify(() => mockLocal.hardDelete('1')).called(1);
        },
      );

      test('given row is pendingCreate, '
          'when delete is called, '
          'then hard deletes locally and never calls remote', () async {
        // given
        when(
          () => mockLocal.syncStateOf('pend1'),
        ).thenAnswer((_) async => SyncStateEnum.pendingCreate);
        when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

        // when
        await repo.delete(brakesPending);

        // then
        verify(() => mockLocal.hardDelete('pend1')).called(1);
        verifyNever(() => mockRemote.delete(any(), any()));
        verifyNever(() => mockLocal.markPendingDelete(any()));
      });

      test('given a pendingCreate row whose push is awaiting connectivity, '
          'when delete of the same row runs, '
          'then throws CacheFailure and does not hard delete', () async {
        // given
        final gate = Completer<void>();
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) => gate.future.then((_) => true));
        when(() => mockLocal.insertPending(any())).thenAnswer((_) async {});
        when(
          () => mockLocal.syncStateOf(brakesPending.id),
        ).thenAnswer((_) async => SyncStateEnum.pendingCreate);
        when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});
        when(() => mockRemote.create(any(), any())).thenAnswer((_) async {});
        when(() => mockLocal.markSynced(any())).thenAnswer((_) async {});
        final createFuture = repo.create(brakesPending);
        await pumpEventQueue();

        // when / then
        await expectLater(
          () => repo.delete(brakesPending),
          throwsA(isA<CacheFailure>()),
        );
        verifyNever(() => mockLocal.hardDelete(any()));

        // when — complete the in-flight push so no future leaks
        gate.complete();
        await createFuture;
      });

      test('given device is offline and row is synced, '
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
        await repo.delete(oilChangeMarch);

        // then
        verify(() => mockLocal.markPendingDelete('1')).called(1);
        verifyNever(() => mockRemote.delete(any(), any()));
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
        when(() => mockRemote.delete(any(), any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars/car-1/maintenances/1'),
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(
                path: '/cars/car-1/maintenances/1',
              ),
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

        // when
        await repo.delete(oilChangeMarch);

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
        when(() => mockRemote.delete(any(), any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars/car-1/maintenances/1'),
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(
                path: '/cars/car-1/maintenances/1',
              ),
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        // when / then
        await expectLater(
          () => repo.delete(oilChangeMarch),
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
        when(() => mockRemote.delete(any(), any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars/car-1/maintenances/1'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        // when / then
        await expectLater(
          () => repo.delete(oilChangeMarch),
          throwsA(isA<NetworkFailure>()),
        );
        verifyNever(() => mockLocal.hardDelete(any()));
        verify(() => mockLocal.markPendingDelete('1')).called(1);
      });
    });

    group('hasPending', () {
      test('given pending rows exist, '
          'when hasPending runs, '
          'then returns true', () async {
        // given
        when(() => mockLocal.countPending('car-1')).thenAnswer((_) async => 2);

        // when
        final pending = await repo.hasPending('car-1');

        // then
        expect(pending, isTrue);
      });

      test('given no pending rows, '
          'when hasPending runs, '
          'then returns false', () async {
        // given
        when(() => mockLocal.countPending('car-1')).thenAnswer((_) async => 0);

        // when
        final pending = await repo.hasPending('car-1');

        // then
        expect(pending, isFalse);
      });

      test('given the local data source throws, '
          'when hasPending runs, '
          'then maps the error to a CacheFailure', () async {
        // given
        when(
          () => mockLocal.countPending('car-1'),
        ).thenThrow(StateError('database unavailable'));

        // when / then
        await expectLater(
          () => repo.hasPending('car-1'),
          throwsA(isA<CacheFailure>()),
        );
      });
    });

    group('pendingDeleteIds', () {
      test('given the local data source returns ids, '
          'when pendingDeleteIds is called, '
          'then returns the same set', () async {
        // given
        when(
          () => mockLocal.pendingDeleteIds('car-1'),
        ).thenAnswer((_) async => {'a', 'b'});

        // when
        final ids = await repo.pendingDeleteIds('car-1');

        // then
        expect(ids, {'a', 'b'});
      });

      test('given the local data source throws, '
          'when pendingDeleteIds is called, '
          'then maps the error to a CacheFailure', () async {
        // given
        when(
          () => mockLocal.pendingDeleteIds('car-1'),
        ).thenThrow(StateError('database unavailable'));

        // when / then
        await expectLater(
          () => repo.pendingDeleteIds('car-1'),
          throwsA(isA<CacheFailure>()),
        );
      });
    });

    group('syncPending', () {
      test('given one pendingCreate row and device is online, '
          'when syncPending is called, '
          'then pushes to api and marks synced', () async {
        // given
        when(() => mockLocal.getPending()).thenAnswer(
          (_) async => [
            (
              maintenance: brakesPending,
              syncState: SyncStateEnum.pendingCreate,
            ),
          ],
        );
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.create(any(), any())).thenAnswer((_) async {});
        when(() => mockLocal.markSynced(any())).thenAnswer((_) async {});

        // when
        await repo.syncPending();

        // then
        verify(() => mockRemote.create(any(), any())).called(1);
        verify(() => mockLocal.markSynced('pend1')).called(1);
      });

      test('given 2 pending rows and the second fails, '
          'when syncPending is called, '
          'then first is synced and second stays pending', () async {
        // given
        when(() => mockLocal.getPending()).thenAnswer(
          (_) async => [
            (
              maintenance: brakesPending,
              syncState: SyncStateEnum.pendingCreate,
            ),
            (
              maintenance: batteryPending,
              syncState: SyncStateEnum.pendingCreate,
            ),
          ],
        );
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        var callCount = 0;
        when(() => mockRemote.create(any(), any())).thenAnswer((_) async {
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

      test('given all create pushes fail, '
          'when syncPending is called, '
          'then all pending rows stay pending', () async {
        // given
        when(() => mockLocal.getPending()).thenAnswer(
          (_) async => [
            (
              maintenance: brakesPending,
              syncState: SyncStateEnum.pendingCreate,
            ),
          ],
        );
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRemote.create(any(), any()),
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

      test('given one pendingUpdate row and device is online, '
          'when syncPending is called, '
          'then calls remote update and marks synced', () async {
        // given
        when(() => mockLocal.getPending()).thenAnswer(
          (_) async => [
            (
              maintenance: brakesPending,
              syncState: SyncStateEnum.pendingUpdate,
            ),
          ],
        );
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRemote.update(any(), any(), any()),
        ).thenAnswer((_) async {});
        when(() => mockLocal.markSynced(any())).thenAnswer((_) async {});

        // when
        await repo.syncPending();

        // then
        verify(() => mockRemote.update('car-1', 'pend1', any())).called(1);
        verifyNever(() => mockRemote.create(any(), any()));
        verify(() => mockLocal.markSynced('pend1')).called(1);
      });

      test('given a pendingUpdate row receives a 404, '
          'when syncPending is called, '
          'then hard-deletes the row and completes without throwing', () async {
        // given
        when(() => mockLocal.getPending()).thenAnswer(
          (_) async => [
            (
              maintenance: brakesPending,
              syncState: SyncStateEnum.pendingUpdate,
            ),
          ],
        );
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.update(any(), any(), any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/cars/car-1/maintenances/pend1',
            ),
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(
                path: '/cars/car-1/maintenances/pend1',
              ),
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

        // when
        await repo.syncPending();

        // then
        verify(() => mockLocal.hardDelete('pend1')).called(1);
        verifyNever(() => mockLocal.markSynced(any()));
      });

      test('given a pendingDelete row and device is online, '
          'when syncPending is called, '
          'then calls remote delete and hard deletes', () async {
        // given
        when(() => mockLocal.getPending()).thenAnswer(
          (_) async => [
            (
              maintenance: brakesPending,
              syncState: SyncStateEnum.pendingDelete,
            ),
          ],
        );
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.delete(any(), any())).thenAnswer((_) async {});
        when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

        // when
        await repo.syncPending();

        // then
        verify(() => mockRemote.delete('car-1', 'pend1')).called(1);
        verify(() => mockLocal.hardDelete('pend1')).called(1);
      });

      test('given a pendingDelete row receives a 404, '
          'when syncPending is called, '
          'then hard deletes without throwing', () async {
        // given
        when(() => mockLocal.getPending()).thenAnswer(
          (_) async => [
            (
              maintenance: brakesPending,
              syncState: SyncStateEnum.pendingDelete,
            ),
          ],
        );
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.delete(any(), any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/cars/car-1/maintenances/pend1',
            ),
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(
                path: '/cars/car-1/maintenances/pend1',
              ),
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
          (_) async => [
            (
              maintenance: brakesPending,
              syncState: SyncStateEnum.pendingDelete,
            ),
          ],
        );
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.delete(any(), any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/cars/car-1/maintenances/pend1',
            ),
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(
                path: '/cars/car-1/maintenances/pend1',
              ),
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        // when
        await repo.syncPending();

        // then
        verifyNever(() => mockLocal.hardDelete(any()));
      });

      test('given remote create returns 409 during the flush, '
          'when syncPending is called, '
          'then marks synced to stop retrying', () async {
        // given
        when(() => mockLocal.getPending()).thenAnswer(
          (_) async => [
            (
              maintenance: brakesPending,
              syncState: SyncStateEnum.pendingCreate,
            ),
          ],
        );
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.create(any(), any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars/car-1/maintenances'),
            response: Response(
              statusCode: 409,
              requestOptions: RequestOptions(path: '/cars/car-1/maintenances'),
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

      test('given a mixed queue of pendingCreate and pendingDelete, '
          'when syncPending is called, '
          'then both are processed in order and one failure does not abort '
          'the other', () async {
        // given
        when(() => mockLocal.getPending()).thenAnswer(
          (_) async => [
            (
              maintenance: brakesPending,
              syncState: SyncStateEnum.pendingCreate,
            ),
            (
              maintenance: batteryPending,
              syncState: SyncStateEnum.pendingDelete,
            ),
          ],
        );
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => true);
        when(() => mockRemote.create(any(), any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars/car-1/maintenances'),
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(path: '/cars/car-1/maintenances'),
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        when(() => mockRemote.delete(any(), any())).thenAnswer((_) async {});
        when(() => mockLocal.hardDelete(any())).thenAnswer((_) async {});

        // when
        await repo.syncPending();

        // then
        verify(() => mockRemote.delete('car-1', 'pend2')).called(1);
        verify(() => mockLocal.hardDelete('pend2')).called(1);
      });
    });
  });
}

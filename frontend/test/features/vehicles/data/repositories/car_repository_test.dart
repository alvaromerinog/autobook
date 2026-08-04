import 'package:autobook/core/error/failures.dart';
import 'package:autobook/core/network/connectivity_service.dart';
import 'package:autobook/features/vehicles/data/datasources/local/app_database.dart';
import 'package:autobook/features/vehicles/data/datasources/local/car_local_datasource.dart';
import 'package:autobook/features/vehicles/data/datasources/remote/car_remote_datasource.dart';
import 'package:autobook/features/vehicles/data/models/car_dto.dart';
import 'package:autobook/features/vehicles/data/repositories/car_repository.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
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
        when(() => mockLocal.upsertAll(any())).thenAnswer((_) async {});

        // when
        await repo.refreshFromRemote();

        // then
        verify(() => mockLocal.upsertAll([])).called(1);
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
        when(() => mockLocal.upsertAll(any())).thenAnswer((_) async {});

        // when
        await repo.refreshFromRemote();

        // then
        final captured = verify(
          () => mockLocal.upsertAll(captureAny()),
        ).captured;
        final upserted = captured.first as List<Car>;
        expect(upserted, hasLength(2));
        expect(upserted[0].id, '1');
        expect(upserted[1].id, '2');
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
          'then skips remote call', () async {
        // given
        when(
          () => mockConnectivity.isConnected(),
        ).thenAnswer((_) async => false);

        // when
        await repo.refreshFromRemote();

        // then
        verifyNever(() => mockRemote.fetchAll());
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
    });
  });
}

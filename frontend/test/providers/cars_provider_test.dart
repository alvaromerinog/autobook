import 'dart:convert';

import 'package:autobook/exceptions/create_car_exception.dart';
import 'package:autobook/exceptions/get_cars_exception.dart';
import 'package:autobook/models/car.dart';
import 'package:autobook/providers/cars_provider.dart';
import 'package:autobook/services/api_service.dart';
import 'package:autobook/services/connectivity_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiService extends Mock implements ApiService {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late MockApiService mockApi;
  late MockConnectivityService mockConnectivity;

  setUpAll(() {
    registerFallbackValue(
      const Car(id: '', brand: '', model: '', year: 0, licensePlate: ''),
    );
  });

  setUp(() {
    mockApi = MockApiService();
    mockConnectivity = MockConnectivityService();
    when(() => mockConnectivity.connectivityChanges)
        .thenAnswer((_) => const Stream.empty());
  });

  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [
        apiServiceProvider.overrideWithValue(mockApi),
        connectivityServiceProvider.overrideWithValue(mockConnectivity),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('Cars', () {
    group('build', () {
      test(
        'given api returns empty list, '
        'when build runs, '
        'then cars is empty and syncError is null',
        () async {
          // given
          SharedPreferences.setMockInitialValues({});
          when(() => mockConnectivity.isConnected())
              .thenAnswer((_) async => true);
          when(() => mockApi.getCars()).thenAnswer((_) async => []);

          // when
          final container = buildContainer();
          final state = await container.read(carsProvider.future);

          // then
          expect(state.cars, isEmpty);
          expect(state.syncError, isNull);
          expect(state.hasPendingSync, isFalse);
          verify(() => mockApi.getCars()).called(1);
        },
      );

      test(
        'given api returns two cars, '
        'when build runs, '
        'then state has those cars and they are persisted',
        () async {
          // given
          SharedPreferences.setMockInitialValues({});
          const car1 = Car(
            id: '1',
            brand: 'Toyota',
            model: 'Corolla',
            year: 2020,
            licensePlate: '1234 ABC',
          );
          const car2 = Car(
            id: '2',
            brand: 'Ford',
            model: 'Focus',
            year: 2019,
            licensePlate: '5678 DEF',
          );
          when(() => mockConnectivity.isConnected())
              .thenAnswer((_) async => true);
          when(() => mockApi.getCars()).thenAnswer((_) async => [car1, car2]);

          // when
          final container = buildContainer();
          final state = await container.read(carsProvider.future);

          // then
          expect(state.cars, hasLength(2));
          expect(state.cars[0].id, '1');
          expect(state.cars[1].id, '2');
          expect(state.syncError, isNull);
          expect(state.hasPendingSync, isFalse);
          verify(() => mockApi.getCars()).called(1);
          final prefs = await SharedPreferences.getInstance();
          final stored = jsonDecode(prefs.getString('cars')!) as List;
          expect(stored, hasLength(2));
        },
      );

      test(
        'given api throws, '
        'when build runs, '
        'then state contains cached cars and the sync error',
        () async {
          // given
          const cached = Car(
            id: 'c1',
            brand: 'BMW',
            model: 'Serie 3',
            year: 2021,
            licensePlate: '9999 ZZZ',
          );
          SharedPreferences.setMockInitialValues({
            'cars': jsonEncode([cached.toJson()]),
          });
          when(() => mockConnectivity.isConnected())
              .thenAnswer((_) async => true);
          when(() => mockApi.getCars()).thenThrow(const GetCarsException(503));

          // when
          final container = buildContainer();
          final state = await container.read(carsProvider.future);

          // then
          expect(state.cars, hasLength(1));
          expect(state.cars[0].id, 'c1');
          expect(state.syncError, isA<GetCarsException>());
          expect(state.hasPendingSync, isFalse);
          verify(() => mockApi.getCars()).called(1);
        },
      );

      test(
        'given device is offline, '
        'when build runs, '
        'then state contains cached cars with no syncError and api is not called',
        () async {
          // given
          const cached = Car(
            id: 'off1',
            brand: 'Honda',
            model: 'Civic',
            year: 2020,
            licensePlate: '4321 XYZ',
          );
          SharedPreferences.setMockInitialValues({
            'cars': jsonEncode([cached.toJson()]),
          });
          when(() => mockConnectivity.isConnected())
              .thenAnswer((_) async => false);

          // when
          final container = buildContainer();
          final state = await container.read(carsProvider.future);

          // then
          expect(state.cars, hasLength(1));
          expect(state.cars[0].id, 'off1');
          expect(state.syncError, isNull);
          expect(state.hasPendingSync, isFalse);
          verifyNever(() => mockApi.getCars());
        },
      );
    });

    group('add', () {
      test(
        'given device is online, '
        'when add is called with a new car, '
        'then state includes the new car and it is persisted',
        () async {
          // given
          SharedPreferences.setMockInitialValues({});
          const existing = Car(
            id: 'e1',
            brand: 'Seat',
            model: 'Ibiza',
            year: 2018,
            licensePlate: '0000 AAA',
          );
          const newCar = Car(
            id: 'n1',
            brand: 'Renault',
            model: 'Megane',
            year: 2022,
            licensePlate: '1111 BBB',
          );
          when(() => mockConnectivity.isConnected())
              .thenAnswer((_) async => true);
          when(() => mockApi.getCars()).thenAnswer((_) async => [existing]);
          when(() => mockApi.createCar(any())).thenAnswer((_) async {});
          final container = buildContainer();
          await container.read(carsProvider.future);

          // when
          await container.read(carsProvider.notifier).add(newCar);
          final state = await container.read(carsProvider.future);

          // then
          expect(state.cars, hasLength(2));
          expect(state.cars.last.id, 'n1');
          expect(state.syncError, isNull);
          expect(state.hasPendingSync, isFalse);
          final prefs = await SharedPreferences.getInstance();
          final stored = jsonDecode(prefs.getString('cars')!) as List;
          expect(stored, hasLength(2));
        },
      );

      test(
        'given device is offline, '
        'when add is called with a new car, '
        'then car is queued as pending and hasPendingSync is true',
        () async {
          // given
          SharedPreferences.setMockInitialValues({});
          const newCar = Car(
            id: 'p1',
            brand: 'Peugeot',
            model: '208',
            year: 2021,
            licensePlate: '2222 CCC',
          );
          when(() => mockConnectivity.isConnected())
              .thenAnswer((_) async => false);
          final container = buildContainer();
          await container.read(carsProvider.future);

          // when
          await container.read(carsProvider.notifier).add(newCar);
          final state = await container.read(carsProvider.future);

          // then
          expect(state.cars, hasLength(1));
          expect(state.cars[0].id, 'p1');
          expect(state.hasPendingSync, isTrue);
          expect(state.syncError, isNull);
          verifyNever(() => mockApi.createCar(any()));
          final prefs = await SharedPreferences.getInstance();
          final pending = jsonDecode(prefs.getString('pending_cars')!) as List;
          expect(pending, hasLength(1));
        },
      );

      test(
        'given device is online but api throws on create, '
        'when add is called, '
        'then car is queued as pending, hasPendingSync is true, and error is rethrown',
        () async {
          // given
          SharedPreferences.setMockInitialValues({});
          const newCar = Car(
            id: 'f1',
            brand: 'Volkswagen',
            model: 'Golf',
            year: 2023,
            licensePlate: '3333 DDD',
          );
          when(() => mockConnectivity.isConnected())
              .thenAnswer((_) async => true);
          when(() => mockApi.getCars()).thenAnswer((_) async => []);
          when(() => mockApi.createCar(any()))
              .thenThrow(const CreateCarException(500));
          final container = buildContainer();
          await container.read(carsProvider.future);

          // when
          await expectLater(
            () => container.read(carsProvider.notifier).add(newCar),
            throwsA(isA<CreateCarException>()),
          );

          // then
          final state = await container.read(carsProvider.future);
          expect(state.cars, hasLength(1));
          expect(state.cars[0].id, 'f1');
          expect(state.hasPendingSync, isTrue);
          final prefs = await SharedPreferences.getInstance();
          final pending = jsonDecode(prefs.getString('pending_cars')!) as List;
          expect(pending, hasLength(1));
        },
      );
    });

    group('syncPendingCars', () {
      test(
        'given device was offline with pending cars and is now online, '
        'when syncPendingCars is called, '
        'then pending cars are sent to api and hasPendingSync is false',
        () async {
          // given
          const pendingCar = Car(
            id: 'pend1',
            brand: 'Fiat',
            model: '500',
            year: 2019,
            licensePlate: '4444 EEE',
          );
          SharedPreferences.setMockInitialValues({
            'cars': jsonEncode([pendingCar.toJson()]),
            'pending_cars': jsonEncode([pendingCar.toJson()]),
          });
          when(() => mockConnectivity.isConnected())
              .thenAnswer((_) async => false);
          final container = buildContainer();
          await container.read(carsProvider.future);
          when(() => mockApi.createCar(any())).thenAnswer((_) async {});

          // when
          await container.read(carsProvider.notifier).syncPendingCars();
          final state = await container.read(carsProvider.future);

          // then
          expect(state.hasPendingSync, isFalse);
          verify(() => mockApi.createCar(any())).called(1);
        },
      );

      test(
        'given 2 pending cars and the second fails to sync, '
        'when syncPendingCars is called, '
        'then only the failed car remains pending and hasPendingSync is true',
        () async {
          // given
          const car1 = Car(
            id: 'pend1',
            brand: 'Fiat',
            model: '500',
            year: 2019,
            licensePlate: '4444 EEE',
          );
          const car2 = Car(
            id: 'pend2',
            brand: 'Alfa',
            model: 'Giulia',
            year: 2020,
            licensePlate: '5555 FFF',
          );
          SharedPreferences.setMockInitialValues({
            'cars': jsonEncode([car1.toJson(), car2.toJson()]),
            'pending_cars': jsonEncode([car1.toJson(), car2.toJson()]),
          });
          when(() => mockConnectivity.isConnected())
              .thenAnswer((_) async => false);
          final container = buildContainer();
          await container.read(carsProvider.future);
          var callCount = 0;
          when(() => mockApi.createCar(any())).thenAnswer((_) async {
            callCount++;
            if (callCount == 2) throw const CreateCarException(500);
          });

          // when
          await container.read(carsProvider.notifier).syncPendingCars();
          final state = await container.read(carsProvider.future);

          // then
          expect(state.hasPendingSync, isTrue);
          final prefs = await SharedPreferences.getInstance();
          final pending = jsonDecode(prefs.getString('pending_cars')!) as List;
          expect(pending, hasLength(1));
          expect(pending[0]['id'], 'pend2');
        },
      );

      test(
        'given all createCar calls fail, '
        'when syncPendingCars is called, '
        'then pending cars remain unchanged and hasPendingSync stays true',
        () async {
          // given
          const pendingCar = Car(
            id: 'pend1',
            brand: 'Fiat',
            model: '500',
            year: 2019,
            licensePlate: '4444 EEE',
          );
          SharedPreferences.setMockInitialValues({
            'cars': jsonEncode([pendingCar.toJson()]),
            'pending_cars': jsonEncode([pendingCar.toJson()]),
          });
          when(() => mockConnectivity.isConnected())
              .thenAnswer((_) async => false);
          final container = buildContainer();
          await container.read(carsProvider.future);
          when(() => mockApi.createCar(any()))
              .thenThrow(const CreateCarException(500));

          // when
          await container.read(carsProvider.notifier).syncPendingCars();
          final state = await container.read(carsProvider.future);

          // then
          expect(state.hasPendingSync, isTrue);
          final prefs = await SharedPreferences.getInstance();
          final pending = jsonDecode(prefs.getString('pending_cars')!) as List;
          expect(pending, hasLength(1));
        },
      );
    });
  });
}

import 'package:autobook/core/error/failures.dart';
import 'package:autobook/core/id/id_generator.dart';
import 'package:autobook/core/sync/sync_coordinator.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/domain/entities/remote_sync_event.dart';
import 'package:autobook/features/vehicles/domain/usecases/create_car_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/delete_car_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/get_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/has_pending_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/pending_delete_ids_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/refresh_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/sync_pending_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/update_car_usecase.dart';
import 'package:autobook/features/vehicles/presentation/providers/usecase_providers.dart';
import 'package:autobook/features/vehicles/presentation/widgets/garage_list_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../app/localization_test_harness.dart';
import '../../fixtures/car_fixtures.dart';
import '../../helpers/car_mocks.dart';

class MockIdGenerator extends Mock implements IdGenerator {}

Future<void> pumpGarageList(
  WidgetTester tester,
  MockCarRepository mockRepo, {
  Locale locale = const Locale('es'),
}) async {
  final mockIds = MockIdGenerator();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        syncCoordinatorProvider.overrideWithValue(SyncCoordinator()),
        getCarsUseCaseProvider.overrideWithValue(GetCarsUseCase(mockRepo)),
        hasPendingCarsUseCaseProvider.overrideWithValue(
          HasPendingCarsUseCase(mockRepo),
        ),
        pendingDeleteIdsUseCaseProvider.overrideWithValue(
          PendingDeleteIdsUseCase(mockRepo),
        ),
        refreshCarsUseCaseProvider.overrideWithValue(
          RefreshCarsUseCase(mockRepo),
        ),
        syncPendingCarsUseCaseProvider.overrideWithValue(
          SyncPendingCarsUseCase(mockRepo),
        ),
        createCarUseCaseProvider.overrideWithValue(
          CreateCarUseCase(mockRepo, mockIds),
        ),
        updateCarUseCaseProvider.overrideWithValue(UpdateCarUseCase(mockRepo)),
        deleteCarUseCaseProvider.overrideWithValue(DeleteCarUseCase(mockRepo)),
      ],
      child: localizedTestApp(
        locale: locale,
        home: const Scaffold(body: GarageListContent()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void stubDefaults(MockCarRepository mockRepo, {List<Car> cars = oneCarList}) {
  when(
    () => mockRepo.refreshFromRemote(),
  ).thenAnswer((_) async => <RemoteSyncEvent>[]);
  when(() => mockRepo.syncPending()).thenAnswer((_) async {});
  when(() => mockRepo.getAll()).thenAnswer((_) async => cars);
  when(() => mockRepo.hasPending()).thenAnswer((_) async => false);
  when(() => mockRepo.pendingDeleteIds()).thenAnswer((_) async => <String>{});
}

void main() {
  late MockCarRepository mockRepo;

  setUpAll(() {
    registerCarFallbacks();
  });

  setUp(() {
    mockRepo = MockCarRepository();
  });

  group('GarageListContent', () {
    testWidgets('given one car, when pumped, then the car card is shown', (
      tester,
    ) async {
      stubDefaults(mockRepo);

      await pumpGarageList(tester, mockRepo);

      expect(find.text('Toyota Corolla'), findsOneWidget);
    });

    testWidgets('given an empty garage, when pumped, then the empty state '
        'is shown', (tester) async {
      stubDefaults(mockRepo, cars: const []);

      await pumpGarageList(tester, mockRepo);

      expect(find.text('Tu garaje está vacío'), findsOneWidget);
      expect(
        find.text(
          'Añade tu primer vehículo para empezar a llevar el registro de sus '
          'mantenimientos.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('given an empty garage in English, then the English empty '
        'state is shown', (tester) async {
      stubDefaults(mockRepo, cars: const []);

      await pumpGarageList(tester, mockRepo, locale: const Locale('en'));

      expect(find.text('Your garage is empty'), findsOneWidget);
      expect(
        find.text('Add your first vehicle to start tracking its maintenance.'),
        findsOneWidget,
      );
    });

    testWidgets('given a remote deletion event, when the list settles, '
        'then the snackbar is shown', (tester) async {
      stubDefaults(mockRepo);
      when(() => mockRepo.refreshFromRemote()).thenAnswer(
        (_) async => [const RemoteSyncEvent.remoteDeleted(toyotaCorolla)],
      );

      await pumpGarageList(tester, mockRepo);

      expect(find.text('Coche Toyota Corolla eliminado'), findsOneWidget);
    });

    testWidgets('given a remote deletion event in English, then the English '
        'snackbar is shown', (tester) async {
      stubDefaults(mockRepo);
      when(() => mockRepo.refreshFromRemote()).thenAnswer(
        (_) async => [const RemoteSyncEvent.remoteDeleted(toyotaCorolla)],
      );

      await pumpGarageList(tester, mockRepo, locale: const Locale('en'));

      expect(find.text('Car Toyota Corolla deleted'), findsOneWidget);
    });

    testWidgets('given a remote deletion with pending update, then the '
        'discarded edit message is shown', (tester) async {
      stubDefaults(mockRepo);
      when(() => mockRepo.refreshFromRemote()).thenAnswer(
        (_) async => [
          const RemoteSyncEvent.remoteDeletedWithPendingUpdate(toyotaCorolla),
        ],
      );

      await pumpGarageList(tester, mockRepo);

      expect(
        find.text('Coche Toyota Corolla eliminado, edición descartada'),
        findsOneWidget,
      );
    });

    testWidgets('given a remote deletion with pending update in English, '
        'then the English discarded edit message is shown', (tester) async {
      stubDefaults(mockRepo);
      when(() => mockRepo.refreshFromRemote()).thenAnswer(
        (_) async => [
          const RemoteSyncEvent.remoteDeletedWithPendingUpdate(toyotaCorolla),
        ],
      );

      await pumpGarageList(tester, mockRepo, locale: const Locale('en'));

      expect(
        find.text('Car Toyota Corolla deleted, edits discarded'),
        findsOneWidget,
      );
    });

    testWidgets('given a car pending delete, then the pending delete label is '
        'shown', (tester) async {
      stubDefaults(mockRepo);
      when(() => mockRepo.pendingDeleteIds()).thenAnswer((_) async => {'1'});

      await pumpGarageList(tester, mockRepo);

      expect(find.text('Pendiente de borrado'), findsOneWidget);
    });

    testWidgets('given a car pending delete in English, then the English '
        'pending delete label is shown', (tester) async {
      stubDefaults(mockRepo);
      when(() => mockRepo.pendingDeleteIds()).thenAnswer((_) async => {'1'});

      await pumpGarageList(tester, mockRepo, locale: const Locale('en'));

      expect(find.text('Pending deletion'), findsOneWidget);
    });

    testWidgets('given pending vehicles, then the pending sync banner with a '
        'localized action is shown', (tester) async {
      stubDefaults(mockRepo);
      when(() => mockRepo.hasPending()).thenAnswer((_) async => true);

      await pumpGarageList(tester, mockRepo, locale: const Locale('en'));

      expect(find.text('Vehicles pending synchronization'), findsOneWidget);
      expect(find.text('Sync'), findsOneWidget);
    });

    testWidgets('given a sync failure, then the friendly error banner with a '
        'retry action is shown', (tester) async {
      stubDefaults(mockRepo);
      when(
        () => mockRepo.refreshFromRemote(),
      ).thenThrow(const NetworkFailure());

      await pumpGarageList(tester, mockRepo, locale: const Locale('en'));

      expect(find.text('Could not connect to the server.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('given a sync failure with pending vehicles, then one combined '
        'message is shown', (tester) async {
      stubDefaults(mockRepo);
      when(() => mockRepo.hasPending()).thenAnswer((_) async => true);
      when(
        () => mockRepo.refreshFromRemote(),
      ).thenThrow(const ServerFailure(500));

      await pumpGarageList(tester, mockRepo);

      expect(
        find.text(
          'No se pudieron cargar los vehículos. Inténtalo de nuevo. Hay '
          'vehículos pendientes de sincronización.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('given an unexpected load error, then the localized details '
        'are shown', (tester) async {
      stubDefaults(mockRepo);
      when(() => mockRepo.getAll()).thenThrow(StateError('boom'));

      await pumpGarageList(tester, mockRepo);

      expect(
        find.text('Error cargando vehículos: Bad state: boom'),
        findsOneWidget,
      );
      expect(find.text('Reintentar'), findsOneWidget);
    });
  });
}

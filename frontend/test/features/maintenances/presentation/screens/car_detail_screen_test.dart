import 'package:autobook/core/id/id_generator.dart';
import 'package:autobook/core/sync/sync_coordinator.dart';
import 'package:autobook/features/maintenances/data/repositories/maintenance_repository.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_remote_sync_event.dart';
import 'package:autobook/features/maintenances/domain/repositories/maintenance_repository.dart';
import 'package:autobook/features/maintenances/presentation/screens/car_detail_screen.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../vehicles/fixtures/car_fixtures.dart';
import '../../../vehicles/helpers/car_mocks.dart';
import '../../fixtures/maintenance_fixtures.dart';

class MockIdGenerator extends Mock implements IdGenerator {}

class MockMaintenanceRepository extends Mock
    implements IMaintenanceRepository {}

Future<void> pumpCarDetailScreen(
  WidgetTester tester,
  MockCarRepository mockCarRepo,
  MockMaintenanceRepository mockMaintRepo, {
  String carId = '1',
}) async {
  final mockIds = MockIdGenerator();
  final router = GoRouter(
    initialLocation: '/cars/$carId',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(body: Text('home')),
        routes: [
          GoRoute(
            path: 'cars/:carId',
            builder: (_, state) =>
                CarDetailScreen(carId: state.pathParameters['carId']!),
          ),
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        syncCoordinatorProvider.overrideWithValue(SyncCoordinator()),
        getCarsUseCaseProvider.overrideWithValue(GetCarsUseCase(mockCarRepo)),
        hasPendingCarsUseCaseProvider.overrideWithValue(
          HasPendingCarsUseCase(mockCarRepo),
        ),
        pendingDeleteIdsUseCaseProvider.overrideWithValue(
          PendingDeleteIdsUseCase(mockCarRepo),
        ),
        refreshCarsUseCaseProvider.overrideWithValue(
          RefreshCarsUseCase(mockCarRepo),
        ),
        syncPendingCarsUseCaseProvider.overrideWithValue(
          SyncPendingCarsUseCase(mockCarRepo),
        ),
        createCarUseCaseProvider.overrideWithValue(
          CreateCarUseCase(mockCarRepo, mockIds),
        ),
        updateCarUseCaseProvider.overrideWithValue(
          UpdateCarUseCase(mockCarRepo),
        ),
        deleteCarUseCaseProvider.overrideWithValue(
          DeleteCarUseCase(mockCarRepo),
        ),
        maintenanceRepositoryProvider.overrideWithValue(mockMaintRepo),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void stubCarDefaults(
  MockCarRepository mockRepo, {
  List<Car> cars = oneCarList,
}) {
  when(
    () => mockRepo.refreshFromRemote(),
  ).thenAnswer((_) async => <RemoteSyncEvent>[]);
  when(() => mockRepo.syncPending()).thenAnswer((_) async {});
  when(() => mockRepo.getAll()).thenAnswer((_) async => cars);
  when(() => mockRepo.hasPending()).thenAnswer((_) async => false);
  when(() => mockRepo.pendingDeleteIds()).thenAnswer((_) async => <String>{});
}

void stubMaintDefaults(MockMaintenanceRepository mockMaintRepo) {
  when(
    () => mockMaintRepo.getAll(any()),
  ).thenAnswer((_) async => <Maintenance>[]);
  when(() => mockMaintRepo.hasPending(any())).thenAnswer((_) async => false);
  when(
    () => mockMaintRepo.pendingDeleteIds(any()),
  ).thenAnswer((_) async => <String>{});
  when(
    () => mockMaintRepo.refreshFromRemote(any()),
  ).thenAnswer((_) async => <MaintenanceRemoteSyncEvent>[]);
  when(() => mockMaintRepo.syncPending()).thenAnswer((_) async {});
}

void main() {
  late MockCarRepository mockCarRepo;
  late MockMaintenanceRepository mockMaintRepo;

  setUpAll(() {
    registerCarFallbacks();
  });

  setUp(() {
    mockCarRepo = MockCarRepository();
    mockMaintRepo = MockMaintenanceRepository();
  });

  group('CarDetailScreen', () {
    group('encabezado del historial', () {
      testWidgets('given one maintenance, '
          'when pumped, '
          'then the count says "1 entrada"', (tester) async {
        // given
        stubCarDefaults(mockCarRepo);
        stubMaintDefaults(mockMaintRepo);
        when(() => mockMaintRepo.getAll('1')).thenAnswer(
          (_) async => [
            buildMaintenance(id: 'm1', carId: '1', date: '2026-03-12'),
          ],
        );

        // when
        await pumpCarDetailScreen(tester, mockCarRepo, mockMaintRepo);

        // then
        expect(find.text('1 entrada'), findsOneWidget);
        expect(find.text('1 entradas'), findsNothing);
      });

      testWidgets('given two maintenances, '
          'when pumped, '
          'then the count says "2 entradas"', (tester) async {
        // given
        stubCarDefaults(mockCarRepo);
        stubMaintDefaults(mockMaintRepo);
        when(() => mockMaintRepo.getAll('1')).thenAnswer(
          (_) async => [
            buildMaintenance(id: 'm1', carId: '1', date: '2026-03-12'),
            buildMaintenance(id: 'm2', carId: '1', date: '2026-01-05'),
          ],
        );

        // when
        await pumpCarDetailScreen(tester, mockCarRepo, mockMaintRepo);

        // then
        expect(find.text('2 entradas'), findsOneWidget);
      });
    });

    group('edit vehicle', () {
      testWidgets('given a car, when the edit icon is tapped, then the edit '
          'dialog opens pre-filled', (tester) async {
        // given
        stubCarDefaults(mockCarRepo);
        stubMaintDefaults(mockMaintRepo);

        // when
        await pumpCarDetailScreen(tester, mockCarRepo, mockMaintRepo);
        await tester.tap(find.byTooltip('Editar vehículo'));
        await tester.pumpAndSettle();

        // then — edit dialog is shown (edit-mode submit label + subtitle
        // are unique to the editing variant of showCarDialog)
        expect(find.text('Guardar cambios'), findsOneWidget);
        expect(find.text('Datos del vehículo'), findsOneWidget);
      });

      testWidgets('given the edit dialog, when Guardar cambios is tapped, '
          'then repo.update is called once', (tester) async {
        // given
        stubCarDefaults(mockCarRepo);
        stubMaintDefaults(mockMaintRepo);
        when(() => mockCarRepo.update(any())).thenAnswer((_) async {});

        // when
        await pumpCarDetailScreen(tester, mockCarRepo, mockMaintRepo);
        await tester.tap(find.byTooltip('Editar vehículo'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Guardar cambios'));
        await tester.pumpAndSettle();

        // then
        verify(() => mockCarRepo.update(any())).called(1);
      });
    });

    group('delete vehicle', () {
      testWidgets('given a car, when the delete menu is opened and Cancelar '
          'is chosen, then the dialog closes and delete is never called', (
        tester,
      ) async {
        // given
        stubCarDefaults(mockCarRepo);
        stubMaintDefaults(mockMaintRepo);

        // when — open the AppBar popup menu and tap the delete entry
        await pumpCarDetailScreen(tester, mockCarRepo, mockMaintRepo);
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar vehículo'));
        await tester.pumpAndSettle();

        // then — confirm dialog is shown
        expect(
          find.text('¿Seguro que quieres eliminar Toyota Corolla?'),
          findsOneWidget,
        );

        // when — cancel
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        // then
        expect(
          find.text('¿Seguro que quieres eliminar Toyota Corolla?'),
          findsNothing,
        );
        verifyNever(() => mockCarRepo.delete(any()));
      });

      testWidgets('given a car, when the delete menu is opened and Eliminar '
          'is chosen, then repo.delete is called once', (tester) async {
        // given
        stubCarDefaults(mockCarRepo);
        stubMaintDefaults(mockMaintRepo);
        when(() => mockCarRepo.delete(any())).thenAnswer((_) async {});

        // when
        await pumpCarDetailScreen(tester, mockCarRepo, mockMaintRepo);
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar vehículo'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        // then
        verify(() => mockCarRepo.delete(any())).called(1);
      });
    });
  });
}

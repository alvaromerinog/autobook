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
  Size? size,
}) async {
  final mockIds = MockIdGenerator();
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  final router = GoRouter(
    initialLocation: '/cars/$carId',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(body: Text('home')),
      ),
      GoRoute(
        path: '/cars/:carId',
        builder: (_, state) =>
            CarDetailScreen(carId: state.pathParameters['carId']!),
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
    registerFallbackValue(buildMaintenance());
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
        stubCarDefaults(mockCarRepo);
        stubMaintDefaults(mockMaintRepo);
        when(() => mockMaintRepo.getAll('1')).thenAnswer(
          (_) async => [
            buildMaintenance(id: 'm1', carId: '1', date: '2026-03-12'),
          ],
        );

        await pumpCarDetailScreen(tester, mockCarRepo, mockMaintRepo);

        expect(find.text('1 entrada'), findsOneWidget);
        expect(find.text('1 entradas'), findsNothing);
      });

      testWidgets('given two maintenances, '
          'when pumped, '
          'then the count says "2 entradas"', (tester) async {
        stubCarDefaults(mockCarRepo);
        stubMaintDefaults(mockMaintRepo);
        when(() => mockMaintRepo.getAll('1')).thenAnswer(
          (_) async => [
            buildMaintenance(id: 'm1', carId: '1', date: '2026-03-12'),
            buildMaintenance(id: 'm2', carId: '1', date: '2026-01-05'),
          ],
        );

        await pumpCarDetailScreen(tester, mockCarRepo, mockMaintRepo);

        expect(find.text('2 entradas'), findsOneWidget);
      });
    });

    group('zona superior sólida', () {
      testWidgets('given the detail screen, '
          'when pumped, '
          'then the upper zone sits on an opaque surface of the page '
          'background colour', (tester) async {
        stubCarDefaults(mockCarRepo);
        stubMaintDefaults(mockMaintRepo);

        await pumpCarDetailScreen(tester, mockCarRepo, mockMaintRepo);

        final heading = find.text('Historial de mantenimientos');
        final solidZone = tester.widget<ColoredBox>(
          find.ancestor(of: heading, matching: find.byType(ColoredBox)).first,
        );
        final cs = Theme.of(tester.element(heading)).colorScheme;
        expect(solidZone.color, cs.surface);
        expect(
          find.ancestor(
            of: find.byKey(const Key('stat-strip-card')),
            matching: find.byType(ColoredBox),
          ),
          findsWidgets,
        );
      });
    });

    group('FAB añadir mantenimiento', () {
      testWidgets('given the detail screen, '
          'when the FAB is tapped and the dialog is saved, '
          'then repo.create is called with a MaintenanceDraft', (tester) async {
        stubCarDefaults(mockCarRepo);
        stubMaintDefaults(mockMaintRepo);
        when(() => mockMaintRepo.getAll('1')).thenAnswer((_) async => []);
        when(() => mockMaintRepo.create(any())).thenAnswer((_) async {});

        await pumpCarDetailScreen(
          tester,
          mockCarRepo,
          mockMaintRepo,
          size: const Size(1080, 2400),
        );
        await tester.tap(find.text('Añadir mantenimiento'));
        await tester.pumpAndSettle();
        expect(find.text('Nuevo mantenimiento'), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Kilómetros'),
          '5000',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Coste'),
          '40',
        );
        await tester.pump();
        await tester.tap(find.text('Guardar'));
        await tester.pumpAndSettle();

        verify(() => mockMaintRepo.create(any())).called(1);
      });
    });

    group('edit vehicle', () {
      testWidgets('given a car, when the edit icon is tapped, then the edit '
          'dialog opens pre-filled', (tester) async {
        stubCarDefaults(mockCarRepo);
        stubMaintDefaults(mockMaintRepo);

        await pumpCarDetailScreen(tester, mockCarRepo, mockMaintRepo);
        await tester.tap(find.byTooltip('Editar vehículo'));
        await tester.pumpAndSettle();

        expect(find.text('Guardar cambios'), findsOneWidget);
        expect(find.text('Datos del vehículo'), findsOneWidget);
      });

      testWidgets('given the edit dialog, when Guardar cambios is tapped, '
          'then repo.update is called once', (tester) async {
        stubCarDefaults(mockCarRepo);
        stubMaintDefaults(mockMaintRepo);
        when(() => mockCarRepo.update(any())).thenAnswer((_) async {});

        await pumpCarDetailScreen(tester, mockCarRepo, mockMaintRepo);
        await tester.tap(find.byTooltip('Editar vehículo'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Guardar cambios'));
        await tester.pumpAndSettle();

        verify(() => mockCarRepo.update(any())).called(1);
      });
    });

    group('delete vehicle', () {
      testWidgets('given a car, when the delete button is tapped and Cancelar '
          'is chosen, then the dialog closes and delete is never called', (
        tester,
      ) async {
        stubCarDefaults(mockCarRepo);
        stubMaintDefaults(mockMaintRepo);

        await pumpCarDetailScreen(tester, mockCarRepo, mockMaintRepo);

        expect(find.byIcon(Icons.more_vert), findsNothing);
        expect(find.byType(PopupMenuButton<String>), findsNothing);
        expect(find.byTooltip('Editar vehículo'), findsOneWidget);
        expect(find.byTooltip('Eliminar vehículo'), findsOneWidget);

        await tester.tap(find.byTooltip('Eliminar vehículo'));
        await tester.pumpAndSettle();

        expect(
          find.text('¿Seguro que quieres eliminar Toyota Corolla?'),
          findsOneWidget,
        );

        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        expect(
          find.text('¿Seguro que quieres eliminar Toyota Corolla?'),
          findsNothing,
        );
        verifyNever(() => mockCarRepo.delete(any()));
      });

      testWidgets('given a car, when the delete button is tapped and Eliminar '
          'is chosen, then repo.delete is called once', (tester) async {
        stubCarDefaults(mockCarRepo);
        stubMaintDefaults(mockMaintRepo);
        when(() => mockCarRepo.delete(any())).thenAnswer((_) async {});

        await pumpCarDetailScreen(tester, mockCarRepo, mockMaintRepo);
        await tester.tap(find.byTooltip('Eliminar vehículo'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        verify(() => mockCarRepo.delete(any())).called(1);
      });
    });

    group('acciones sobre la ficha de estadísticas', () {
      testWidgets('given a car, when pumped, then the edit and delete buttons '
          'straddle the stat card bottom edge', (tester) async {
        stubCarDefaults(mockCarRepo);
        stubMaintDefaults(mockMaintRepo);

        await pumpCarDetailScreen(tester, mockCarRepo, mockMaintRepo);
        final cardRect = tester.getRect(
          find.byKey(const Key('stat-strip-card')),
        );
        final editCenter = tester.getCenter(find.byTooltip('Editar vehículo'));
        final deleteCenter = tester.getCenter(
          find.byTooltip('Eliminar vehículo'),
        );

        expect(find.byKey(const Key('stat-strip-card')), findsOneWidget);
        expect((editCenter.dy - cardRect.bottom).abs(), lessThan(1.0));
        expect((deleteCenter.dy - cardRect.bottom).abs(), lessThan(1.0));
        expect(editCenter.dx, lessThan(deleteCenter.dx));

        final cs = Theme.of(
          tester.element(find.byTooltip('Editar vehículo')),
        ).colorScheme;
        final editDisc = tester.widget<Container>(
          find
              .ancestor(
                of: find.byTooltip('Editar vehículo'),
                matching: find.byType(Container),
              )
              .first,
        );
        expect((editDisc.decoration! as BoxDecoration).color, cs.primary);

        final historialTop = tester
            .getTopLeft(find.text('Historial de mantenimientos'))
            .dy;
        expect(historialTop, greaterThan(deleteCenter.dy + 24.0));
      });
    });

    group('responsive embedded', () {
      testWidgets('given an expanded surface, when pumped, then no back '
          'button is shown', (tester) async {
        stubCarDefaults(mockCarRepo);
        stubMaintDefaults(mockMaintRepo);

        await pumpCarDetailScreen(
          tester,
          mockCarRepo,
          mockMaintRepo,
          size: const Size(1200, 900),
        );

        expect(find.byType(BackButton), findsNothing);
        expect(find.byTooltip('Back'), findsNothing);
      });

      testWidgets('given a compact surface, when pumped, then the back '
          'button is shown', (tester) async {
        stubCarDefaults(mockCarRepo);
        stubMaintDefaults(mockMaintRepo);

        await pumpCarDetailScreen(
          tester,
          mockCarRepo,
          mockMaintRepo,
          size: const Size(400, 900),
        );

        expect(find.byType(BackButton), findsOneWidget);
      });
    });

    group('navegación atrás', () {
      testWidgets('given a compact surface with a single-page stack, '
          'when the back button is tapped, '
          'then it navigates to /', (tester) async {
        stubCarDefaults(mockCarRepo);
        stubMaintDefaults(mockMaintRepo);

        await pumpCarDetailScreen(
          tester,
          mockCarRepo,
          mockMaintRepo,
          size: const Size(400, 900),
        );
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        expect(find.text('home'), findsOneWidget);
      });
    });

    group('vehículo no encontrado', () {
      testWidgets('given a non-existent carId, when pumped, then the not '
          'found message is shown', (tester) async {
        stubCarDefaults(mockCarRepo);
        stubMaintDefaults(mockMaintRepo);

        await pumpCarDetailScreen(
          tester,
          mockCarRepo,
          mockMaintRepo,
          carId: 'no-existe',
        );

        expect(find.text('Vehículo no encontrado'), findsOneWidget);
        expect(find.byTooltip('Editar vehículo'), findsNothing);
        expect(find.byTooltip('Eliminar vehículo'), findsNothing);
      });
    });
  });
}

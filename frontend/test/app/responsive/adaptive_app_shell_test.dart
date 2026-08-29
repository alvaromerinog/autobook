import 'dart:async';

import 'package:autobook/app/responsive/app_sidebar.dart';
import 'package:autobook/app/router/app_router.dart';
import 'package:autobook/core/id/id_generator.dart';
import 'package:autobook/core/sync/sync_coordinator.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_remote_sync_event.dart';
import 'package:autobook/features/maintenances/domain/repositories/maintenance_repository.dart';
import 'package:autobook/features/maintenances/domain/usecases/get_maintenances_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/has_pending_maintenances_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/pending_delete_ids_usecase.dart'
    as maint_pending;
import 'package:autobook/features/maintenances/domain/usecases/refresh_maintenances_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/sync_pending_maintenances_usecase.dart';
import 'package:autobook/features/maintenances/presentation/providers/usecase_providers.dart'
    as maint_usecases;
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/domain/entities/remote_sync_event.dart';
import 'package:autobook/features/vehicles/domain/usecases/create_car_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/delete_car_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/get_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/has_pending_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/pending_delete_ids_usecase.dart'
    as vehicle_pending;
import 'package:autobook/features/vehicles/domain/usecases/refresh_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/sync_pending_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/update_car_usecase.dart';
import 'package:autobook/features/vehicles/presentation/providers/usecase_providers.dart'
    as vehicle_usecases;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../features/maintenances/fixtures/maintenance_fixtures.dart';
import '../../features/vehicles/fixtures/car_fixtures.dart';
import '../../features/vehicles/helpers/car_mocks.dart';

class _MockIdGenerator extends Mock implements IdGenerator {}

/// No-op repo handed to fake use cases whose `call` is overridden.
class _UnusedMaintenanceRepo extends Mock implements IMaintenanceRepository {}

class _StubGetCars extends GetCarsUseCase {
  _StubGetCars(this.cars) : super(MockCarRepository());

  final List<Car> cars;

  @override
  Future<List<Car>> call() async => cars;
}

class _StubGetMaintenances extends GetMaintenancesUseCase {
  _StubGetMaintenances(this.maintenances) : super(_UnusedMaintenanceRepo());

  final List<Maintenance> maintenances;

  @override
  Future<List<Maintenance>> call(String carId) async => maintenances;
}

class _StubHasPendingMaintenances extends HasPendingMaintenancesUseCase {
  _StubHasPendingMaintenances() : super(_UnusedMaintenanceRepo());

  @override
  Future<bool> call(String carId) async => false;
}

class _StubPendingDeleteIds extends maint_pending.PendingDeleteIdsUseCase {
  _StubPendingDeleteIds() : super(_UnusedMaintenanceRepo());

  @override
  Future<Set<String>> call(String carId) async => <String>{};
}

class _StubRefreshMaintenances extends RefreshMaintenancesUseCase {
  _StubRefreshMaintenances() : super(_UnusedMaintenanceRepo());

  @override
  Future<List<MaintenanceRemoteSyncEvent>> call(String carId) async =>
      const <MaintenanceRemoteSyncEvent>[];
}

class _StubSyncPendingMaintenances extends SyncPendingMaintenancesUseCase {
  _StubSyncPendingMaintenances() : super(_UnusedMaintenanceRepo());

  @override
  Future<void> call() async {}
}

Future<(GoRouter, MockCarRepository)> pumpApp(
  WidgetTester tester, {
  required Size size,
  String initial = '/',
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  // given: cold provider graph whose data layer yields one car
  final mockCarRepo = MockCarRepository();
  when(
    () => mockCarRepo.refreshFromRemote(),
  ).thenAnswer((_) async => <RemoteSyncEvent>[]);
  when(() => mockCarRepo.getAll()).thenAnswer((_) async => oneCarList);
  when(() => mockCarRepo.hasPending()).thenAnswer((_) async => false);
  when(
    () => mockCarRepo.pendingDeleteIds(),
  ).thenAnswer((_) async => <String>{});
  when(() => mockCarRepo.syncPending()).thenAnswer((_) async {});
  when(() => mockCarRepo.create(any())).thenAnswer((_) async {});
  when(() => mockCarRepo.update(any())).thenAnswer((_) async {});
  when(() => mockCarRepo.delete(any())).thenAnswer((_) async {});
  final container = ProviderContainer(
    overrides: [
      syncCoordinatorProvider.overrideWithValue(SyncCoordinator()),
      vehicle_usecases.getCarsUseCaseProvider.overrideWithValue(
        _StubGetCars(oneCarList),
      ),
      vehicle_usecases.hasPendingCarsUseCaseProvider.overrideWithValue(
        HasPendingCarsUseCase(mockCarRepo),
      ),
      vehicle_usecases.pendingDeleteIdsUseCaseProvider.overrideWithValue(
        vehicle_pending.PendingDeleteIdsUseCase(mockCarRepo),
      ),
      vehicle_usecases.refreshCarsUseCaseProvider.overrideWithValue(
        RefreshCarsUseCase(mockCarRepo),
      ),
      vehicle_usecases.syncPendingCarsUseCaseProvider.overrideWithValue(
        SyncPendingCarsUseCase(mockCarRepo),
      ),
      vehicle_usecases.createCarUseCaseProvider.overrideWithValue(
        CreateCarUseCase(mockCarRepo, _MockIdGenerator()),
      ),
      vehicle_usecases.updateCarUseCaseProvider.overrideWithValue(
        UpdateCarUseCase(mockCarRepo),
      ),
      vehicle_usecases.deleteCarUseCaseProvider.overrideWithValue(
        DeleteCarUseCase(mockCarRepo),
      ),
      maint_usecases.getMaintenancesUseCaseProvider.overrideWithValue(
        _StubGetMaintenances([buildMaintenance(carId: 'car-1')]),
      ),
      maint_usecases.hasPendingMaintenancesUseCaseProvider.overrideWithValue(
        _StubHasPendingMaintenances(),
      ),
      maint_usecases.pendingDeleteIdsUseCaseProvider.overrideWithValue(
        _StubPendingDeleteIds(),
      ),
      maint_usecases.refreshMaintenancesUseCaseProvider.overrideWithValue(
        _StubRefreshMaintenances(),
      ),
      maint_usecases.syncPendingMaintenancesUseCaseProvider.overrideWithValue(
        _StubSyncPendingMaintenances(),
      ),
    ],
  );
  addTearDown(container.dispose);
  final router = GoRouter(initialLocation: initial, routes: buildAppRoutes());
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return (router, mockCarRepo);
}

void main() {
  setUpAll(() {
    registerCarFallbacks();
    registerFallbackValue(buildMaintenance());
  });

  group('AdaptiveAppShell', () {
    group('expanded', () {
      testWidgets('given an expanded surface at /, when pumped, then the '
          'sidebar, the list and the placeholder are shown in order without '
          'a back button', (tester) async {
        // when
        await pumpApp(tester, size: const Size(1200, 900));

        // then — three columns in order: sidebar, list, placeholder
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Toyota Corolla'), findsOneWidget);
        expect(find.text('Selecciona un vehículo'), findsOneWidget);
        expect(find.byType(BackButton), findsNothing);

        final row = tester.widget<Row>(
          find
              .ancestor(
                of: find.text('Selecciona un vehículo'),
                matching: find.byType(Row),
              )
              .first,
        );
        expect(row.children[0], isA<AppSidebar>());
        expect(row.children[1], isA<VerticalDivider>());
        expect(row.children[2], isA<Expanded>());
        expect(row.children[3], isA<VerticalDivider>());
        expect(row.children[4], isA<Expanded>());
      });
    });

    group('expanded selection', () {
      testWidgets('given an expanded surface at /, when a car card is '
          'tapped, then the URL goes to /cars/1 and the detail fills the '
          'third column without a back button', (tester) async {
        // when
        final (router, _) = await pumpApp(tester, size: const Size(1200, 900));
        await tester.tap(find.text('Toyota Corolla'));
        await tester.pumpAndSettle();

        // then — URL updated and detail rendered embedded
        expect(router.routeInformationProvider.value.uri.path, '/cars/1');
        expect(find.text('Historial de mantenimientos'), findsOneWidget);
        expect(find.byType(BackButton), findsNothing);
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Toyota Corolla'), findsOneWidget);
      });

      testWidgets('given an expanded surface deep-linked to an unknown '
          'car, then the third column shows the not found message', (
        tester,
      ) async {
        // when
        await pumpApp(
          tester,
          size: const Size(1200, 900),
          initial: '/cars/no-existe',
        );

        // then
        expect(find.text('Vehículo no encontrado'), findsOneWidget);
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Toyota Corolla'), findsOneWidget);
      });
    });

    group('resize across breakpoints', () {
      testWidgets('given an expanded surface at /cars/1, when resized to '
          'compact, then the detail fills the screen with a back button, '
          'and back to expanded restores the three columns', (tester) async {
        // given
        final (router, _) = await pumpApp(
          tester,
          size: const Size(1200, 900),
          initial: '/cars/1',
        );
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(BackButton), findsNothing);

        // when — shrink to compact
        tester.view.physicalSize = const Size(400, 900);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpAndSettle();

        // then — full-screen detail with a back button
        expect(find.byType(BackButton), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);

        // when — grow back to expanded
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpAndSettle();

        // then — three columns with the same car still selected
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Historial de mantenimientos'), findsOneWidget);
        expect(router.routeInformationProvider.value.uri.path, '/cars/1');
      });

      testWidgets('given a car selected in expanded, when resized to '
          'medium and the back button is tapped, then the list is shown '
          'again', (tester) async {
        // given — select the car in expanded (go replaces the stack)
        final (router, _) = await pumpApp(
          tester,
          size: const Size(1200, 900),
        );
        await tester.tap(find.text('Toyota Corolla'));
        await tester.pumpAndSettle();
        expect(router.routeInformationProvider.value.uri.path, '/cars/1');

        // when — resize to medium (tablet vertical) and tap back
        tester.view.physicalSize = const Size(720, 900);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpAndSettle();
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // then — back at / with the rail and the car list visible
        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Toyota Corolla'), findsOneWidget);
      });
    });

    group('maintenance push covers shell', () {
      testWidgets('given an expanded surface at /cars/1, when a timeline '
          'entry is opened, then the maintenance detail covers the three '
          'columns and pop returns to the shell', (tester) async {
        // given
        final (router, _) = await pumpApp(
          tester,
          size: const Size(1200, 900),
          initial: '/cars/1',
        );

        // when — tap the timeline entry (maintenance id m1)
        await tester.tap(find.text('Cambio de aceite'));
        await tester.pumpAndSettle();

        // then — full-screen detail, shell columns hidden
        expect(find.byType(BackButton), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.text('Añadir coche'), findsNothing);

        // when — pop back
        router.pop();
        await tester.pumpAndSettle();

        // then — three-column shell is back at /cars/1
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Historial de mantenimientos'), findsOneWidget);
      });
    });

    group('expanded delete selected', () {
      testWidgets('given an expanded surface at /cars/1, when the car is '
          'deleted, then the URL goes back to / and the placeholder is '
          'shown', (tester) async {
        // given
        final (router, mockCarRepo) = await pumpApp(
          tester,
          size: const Size(1200, 900),
          initial: '/cars/1',
        );
        expect(find.text('Historial de mantenimientos'), findsOneWidget);

        // when — open the delete flow from the AppBar menu
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar vehículo'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        // then — delete called once, URL back to /, placeholder restored
        verify(() => mockCarRepo.delete(any())).called(1);
        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(find.text('Selecciona un vehículo'), findsOneWidget);
        expect(find.byType(NavigationRail), findsOneWidget);
      });
    });

    group('medium', () {
      testWidgets('given a medium surface at /, when pumped, then the rail '
          'and the car list are shown without the FAB', (tester) async {
        // when
        await pumpApp(tester, size: const Size(720, 900));

        // then
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Toyota Corolla'), findsOneWidget);
        expect(find.text('Añadir vehículo'), findsNothing);
        expect(find.byTooltip('Añadir coche'), findsOneWidget);
      });

      testWidgets('given a medium surface at /cars/1, when pushed, then the '
          'car detail fills the screen with a back button and no rail', (
        tester,
      ) async {
        // when
        final (router, _) = await pumpApp(tester, size: const Size(720, 900));
        unawaited(router.push('/cars/1'));
        await tester.pumpAndSettle();

        // then
        expect(find.byType(BackButton), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
      });
    });

    group('compact', () {
      testWidgets('given a compact surface at /, when pumped, then the full '
          'home scaffold is shown without a NavigationRail', (tester) async {
        // when
        await pumpApp(tester, size: const Size(400, 900));

        // then
        expect(find.text('Autobook'), findsOneWidget);
        expect(find.text('Añadir vehículo'), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.text('Toyota Corolla'), findsOneWidget);
      });

      testWidgets('given a compact surface at /cars/1, when pushed, then the '
          'car detail is shown with a back button', (tester) async {
        // when
        final (router, _) = await pumpApp(tester, size: const Size(400, 900));
        unawaited(router.push('/cars/1'));
        await tester.pumpAndSettle();

        // then
        expect(find.byType(BackButton), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
        // the detail pane is reachable through the back stack
        expect(router.canPop(), isTrue);
      });
    });
  });
}

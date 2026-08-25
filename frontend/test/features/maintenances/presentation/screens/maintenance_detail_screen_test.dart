import 'package:autobook/core/id/id_generator.dart';
import 'package:autobook/core/sync/sync_coordinator.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_remote_sync_event.dart';
import 'package:autobook/features/maintenances/domain/repositories/maintenance_repository.dart';
import 'package:autobook/features/maintenances/domain/usecases/create_maintenance_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/get_maintenances_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/has_pending_maintenances_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/pending_delete_ids_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/refresh_maintenances_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/sync_pending_maintenances_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/update_maintenance_usecase.dart';
import 'package:autobook/features/maintenances/presentation/providers/usecase_providers.dart'
    as maint_usecases;
import 'package:autobook/features/maintenances/presentation/screens/maintenance_detail_screen.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/domain/entities/remote_sync_event.dart';
import 'package:autobook/features/vehicles/domain/usecases/create_car_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/delete_car_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/get_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/has_pending_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/pending_delete_ids_usecase.dart'
    as vehicle_usecases;
import 'package:autobook/features/vehicles/domain/usecases/refresh_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/sync_pending_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/update_car_usecase.dart';
import 'package:autobook/features/vehicles/presentation/providers/usecase_providers.dart';
import 'package:autobook/features/vehicles/presentation/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../vehicles/fixtures/car_fixtures.dart';
import '../../../vehicles/helpers/car_mocks.dart';
import '../../fixtures/maintenance_fixtures.dart';

class _MockIdGenerator extends Mock implements IdGenerator {}

/// No-op repo handed to fake use cases whose `call` is overridden.
class _UnusedMaintenanceRepo extends Mock implements IMaintenanceRepository {}

class _StubGetMaintenances extends GetMaintenancesUseCase {
  _StubGetMaintenances(this.maintenances) : super(_UnusedMaintenanceRepo());

  final List<Maintenance> maintenances;

  @override
  Future<List<Maintenance>> call(String carId) async => maintenances;
}

class _StubHasPending extends HasPendingMaintenancesUseCase {
  _StubHasPending() : super(_UnusedMaintenanceRepo());

  @override
  Future<bool> call(String carId) async => false;
}

class _StubPendingDeleteIds extends PendingDeleteIdsUseCase {
  _StubPendingDeleteIds() : super(_UnusedMaintenanceRepo());

  @override
  Future<Set<String>> call(String carId) async => <String>{};
}

class _StubRefresh extends RefreshMaintenancesUseCase {
  _StubRefresh() : super(_UnusedMaintenanceRepo());

  @override
  Future<List<MaintenanceRemoteSyncEvent>> call(String carId) async =>
      const <MaintenanceRemoteSyncEvent>[];
}

class _StubSyncPending extends SyncPendingMaintenancesUseCase {
  _StubSyncPending() : super(_UnusedMaintenanceRepo());

  @override
  Future<void> call() async {}
}

class _RecordingUpdate extends UpdateMaintenanceUseCase {
  _RecordingUpdate(this.calls) : super(_UnusedMaintenanceRepo());

  final List<(MaintenanceDraft, Maintenance)> calls;

  @override
  Future<Maintenance> call(MaintenanceDraft draft, Maintenance existing) async {
    calls.add((draft, existing));
    return existing;
  }
}

Future<void> pumpDetailScreen(
  WidgetTester tester, {
  required MockCarRepository mockCarRepo,
  required List<(MaintenanceDraft, Maintenance)> updateCalls,
}) async {
  final router = GoRouter(
    initialLocation: '/cars/car-1/maintenances/m1',
    routes: [
      GoRoute(
        path: '/cars/:carId',
        builder: (_, _) => const Scaffold(body: Text('car detail')),
      ),
      GoRoute(
        path: '/cars/:carId/maintenances/:id',
        builder: (_, state) => MaintenanceDetailScreen(
          carId: state.pathParameters['carId']!,
          maintenanceId: state.pathParameters['id']!,
        ),
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
          vehicle_usecases.PendingDeleteIdsUseCase(mockCarRepo),
        ),
        refreshCarsUseCaseProvider.overrideWithValue(
          RefreshCarsUseCase(mockCarRepo),
        ),
        syncPendingCarsUseCaseProvider.overrideWithValue(
          SyncPendingCarsUseCase(mockCarRepo),
        ),
        createCarUseCaseProvider.overrideWithValue(
          CreateCarUseCase(mockCarRepo, _MockIdGenerator()),
        ),
        updateCarUseCaseProvider.overrideWithValue(
          UpdateCarUseCase(mockCarRepo),
        ),
        deleteCarUseCaseProvider.overrideWithValue(
          DeleteCarUseCase(mockCarRepo),
        ),
        maint_usecases.getMaintenancesUseCaseProvider.overrideWithValue(
          _StubGetMaintenances([buildMaintenance(carId: 'car-1')]),
        ),
        maint_usecases.hasPendingMaintenancesUseCaseProvider.overrideWithValue(
          _StubHasPending(),
        ),
        maint_usecases.pendingDeleteIdsUseCaseProvider.overrideWithValue(
          _StubPendingDeleteIds(),
        ),
        maint_usecases.refreshMaintenancesUseCaseProvider.overrideWithValue(
          _StubRefresh(),
        ),
        maint_usecases.syncPendingMaintenancesUseCaseProvider.overrideWithValue(
          _StubSyncPending(),
        ),
        maint_usecases.updateMaintenanceUseCaseProvider.overrideWithValue(
          _RecordingUpdate(updateCalls),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void stubCarDefaults(MockCarRepository mockRepo, {List<Car>? cars}) {
  when(
    () => mockRepo.refreshFromRemote(),
  ).thenAnswer((_) async => <RemoteSyncEvent>[]);
  when(() => mockRepo.syncPending()).thenAnswer((_) async {});
  when(() => mockRepo.getAll()).thenAnswer((_) async => cars ?? oneCarList);
  when(() => mockRepo.hasPending()).thenAnswer((_) async => false);
  when(() => mockRepo.pendingDeleteIds()).thenAnswer((_) async => <String>{});
}

void main() {
  group('MaintenanceDetailScreen', () {
    group('edit maintenance', () {
      testWidgets('given edit saved in the maintenance dialog flow, '
          'when the draft is saved, '
          'then the update use case is invoked once with it', (tester) async {
        // given
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        final existing = buildMaintenance(carId: 'car-1');
        final calledWith = <(MaintenanceDraft, Maintenance)>[];
        final mockCarRepo = MockCarRepository();
        stubCarDefaults(mockCarRepo);

        await pumpDetailScreen(
          tester,
          mockCarRepo: mockCarRepo,
          updateCalls: calledWith,
        );

        // when — Editar abre el diálogo precargado; guardar cambios
        await tester.tap(find.byTooltip('Editar'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(CustomFormField, 'Coste'),
          '99.9',
        );
        await tester.pump();
        await tester.tap(find.text('Guardar cambios'));
        await tester.pumpAndSettle();

        // then
        expect(calledWith, hasLength(1));
        expect(calledWith.first.$1.cost, 99.9);
        expect(calledWith.first.$2.id, existing.id);
      });
    });
  });
}

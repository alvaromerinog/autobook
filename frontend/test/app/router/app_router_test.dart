import 'dart:async';

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

void main() {
  group('appRouter edit route', () {
    late ProviderContainer container;
    late GoRouter router;

    setUp(() {
      // given: cold provider graph whose data layer yields empty state
      final mockCarRepo = MockCarRepository();
      when(
        () => mockCarRepo.refreshFromRemote(),
      ).thenAnswer((_) async => <RemoteSyncEvent>[]);
      when(() => mockCarRepo.getAll()).thenAnswer((_) async => <Car>[]);
      container = ProviderContainer(
        overrides: [
          syncCoordinatorProvider.overrideWithValue(SyncCoordinator()),
          vehicle_usecases.getCarsUseCaseProvider.overrideWithValue(
            _StubGetCars(const <Car>[]),
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
            _StubGetMaintenances(const <Maintenance>[]),
          ),
          maint_usecases.hasPendingMaintenancesUseCaseProvider
              .overrideWithValue(_StubHasPendingMaintenances()),
          maint_usecases.pendingDeleteIdsUseCaseProvider.overrideWithValue(
            _StubPendingDeleteIds(),
          ),
          maint_usecases.refreshMaintenancesUseCaseProvider.overrideWithValue(
            _StubRefreshMaintenances(),
          ),
          maint_usecases.syncPendingMaintenancesUseCaseProvider
              .overrideWithValue(_StubSyncPendingMaintenances()),
        ],
      );
      addTearDown(container.dispose);
      router = container.read(appRouterProvider);
    });

    Future<void> pumpRouter(WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('given extra carries the matching maintenance, '
        'when the edit route builds cold, '
        'then the screen opens in edit mode', (tester) async {
      await pumpRouter(tester);
      final existing = buildMaintenance();

      // when
      unawaited(
        router.push<Object?>(
          '/cars/${existing.carId}/maintenances/${existing.id}/edit',
          extra: existing,
        ),
      );
      await tester.pumpAndSettle();

      // then
      expect(find.text('Editar mantenimiento'), findsOneWidget);
    });

    testWidgets('given neither extra nor cached entry, '
        'when the edit route builds, '
        'then it shows a not-found screen instead of crashing', (tester) async {
      await pumpRouter(tester);

      // when
      unawaited(router.push<Object?>('/cars/c1/maintenances/nope/edit'));
      await tester.pumpAndSettle();

      // then
      expect(find.text('Registro no encontrado'), findsOneWidget);
    });

    testWidgets('given a cold deep link to a missing record, '
        'when the not-found back button is pressed, '
        'then no error is thrown and it falls back to the car screen', (
      tester,
    ) async {
      await pumpRouter(tester);

      // when: go() leaves only the edit page on the stack (nothing to pop)
      router.go('/cars/c1/maintenances/nope/edit');
      await tester.pumpAndSettle();
      expect(find.text('Registro no encontrado'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // then
      expect(find.text('Vehículo no encontrado'), findsOneWidget);
    });
  });
}

import 'dart:async';

import 'package:autobook/core/error/failures.dart';
import 'package:autobook/core/sync/sync_coordinator.dart';
import 'package:autobook/features/maintenances/data/repositories/maintenance_repository.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_remote_sync_event.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/features/maintenances/domain/repositories/maintenance_repository.dart';
import 'package:autobook/features/maintenances/domain/usecases/create_maintenance_usecase.dart';
import 'package:autobook/features/maintenances/presentation/providers/maintenance_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements IMaintenanceRepository {}

class _FakeMaintenance extends Fake implements Maintenance {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(_FakeMaintenance());
  });

  group('MaintenanceList', () {
    late _MockRepo repo;
    late ProviderContainer container;

    setUp(() {
      repo = _MockRepo();
      container = ProviderContainer(
        overrides: [
          syncCoordinatorProvider.overrideWithValue(SyncCoordinator()),
          maintenanceRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
    });

    test('build emits cached maintenances from local', () async {
      // given
      const carId = 'car-1';
      final cached = [
        const Maintenance(
          id: 'm1',
          carId: carId,
          type: MaintenanceType.oil,
          date: '2026-03-12',
          mileage: 1,
          cost: 1,
        ),
      ];
      when(() => repo.getAll(carId)).thenAnswer((_) async => cached);
      when(() => repo.hasPending(carId)).thenAnswer((_) async => false);
      when(
        () => repo.pendingDeleteIds(carId),
      ).thenAnswer((_) async => <String>{});
      when(
        () => repo.refreshFromRemote(carId),
      ).thenAnswer((_) async => <MaintenanceRemoteSyncEvent>[]);
      when(() => repo.syncPending()).thenAnswer((_) async {});
      container.listen(maintenanceListProvider(carId), (_, _) {});
      container.read(syncCoordinatorProvider); // ensure coordinator exists

      // when
      await container.read(maintenanceListProvider(carId).future);

      // then
      final state = container.read(maintenanceListProvider(carId));
      expect(state.value!.maintenances, cached);
      expect(state.value!.hasPendingSync, false);
    });

    test('add delegates to repo.create via the create use case', () async {
      // given
      const carId = 'car-1';
      when(() => repo.getAll(carId)).thenAnswer((_) async => <Maintenance>[]);
      when(() => repo.hasPending(carId)).thenAnswer((_) async => false);
      when(
        () => repo.pendingDeleteIds(carId),
      ).thenAnswer((_) async => <String>{});
      when(
        () => repo.refreshFromRemote(carId),
      ).thenAnswer((_) async => <MaintenanceRemoteSyncEvent>[]);
      when(() => repo.syncPending()).thenAnswer((_) async {});
      when(() => repo.create(any())).thenAnswer((_) async {});
      container.listen(maintenanceListProvider(carId), (_, _) {});
      container.read(syncCoordinatorProvider);
      await container.read(maintenanceListProvider(carId).future);

      const MaintenanceDraft draft = (
        type: MaintenanceType.oil,
        date: '2026-03-12',
        mileage: 1,
        cost: 1,
        garage: null,
        notes: null,
      );

      // when
      await container.read(maintenanceListProvider(carId).notifier).add(draft);

      // then
      verify(() => repo.create(any())).called(1);
    });

    test('given provider disposed mid-mutation, '
        'when the mutation completes, '
        'then no error escapes', () async {
      // given
      const carId = 'car-1';
      const maintenance = Maintenance(
        id: 'm1',
        carId: carId,
        type: MaintenanceType.oil,
        date: '2026-03-12',
        mileage: 1,
        cost: 1,
      );
      final deleteGate = Completer<void>();
      when(() => repo.getAll(carId)).thenAnswer((_) async => [maintenance]);
      when(() => repo.hasPending(carId)).thenAnswer((_) async => false);
      when(
        () => repo.pendingDeleteIds(carId),
      ).thenAnswer((_) async => <String>{});
      when(
        () => repo.refreshFromRemote(carId),
      ).thenAnswer((_) async => <MaintenanceRemoteSyncEvent>[]);
      when(() => repo.syncPending()).thenAnswer((_) async {});
      when(() => repo.delete(any())).thenAnswer((_) => deleteGate.future);

      final midFlightContainer = ProviderContainer(
        overrides: [
          syncCoordinatorProvider.overrideWithValue(SyncCoordinator()),
          maintenanceRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(midFlightContainer.dispose);
      midFlightContainer.listen(maintenanceListProvider(carId), (_, _) {});
      await midFlightContainer.read(maintenanceListProvider(carId).future);

      // when
      final mutation = midFlightContainer
          .read(maintenanceListProvider(carId).notifier)
          .deleteMaint(maintenance);
      midFlightContainer.dispose();
      deleteGate.complete();

      // then
      await expectLater(mutation, completes);
    });

    test('given provider disposed while post-mutation reads are in flight, '
        'when the reads complete, '
        'then no error escapes', () async {
      // given
      const carId = 'car-1';
      const maintenance = Maintenance(
        id: 'm1',
        carId: carId,
        type: MaintenanceType.oil,
        date: '2026-03-12',
        mileage: 1,
        cost: 1,
      );
      when(() => repo.getAll(carId)).thenAnswer((_) async => [maintenance]);
      when(() => repo.hasPending(carId)).thenAnswer((_) async => false);
      when(
        () => repo.pendingDeleteIds(carId),
      ).thenAnswer((_) async => <String>{});
      when(
        () => repo.refreshFromRemote(carId),
      ).thenAnswer((_) async => <MaintenanceRemoteSyncEvent>[]);
      when(() => repo.syncPending()).thenAnswer((_) async {});
      when(() => repo.delete(any())).thenAnswer((_) async {});

      final midFlightContainer = ProviderContainer(
        overrides: [
          syncCoordinatorProvider.overrideWithValue(SyncCoordinator()),
          maintenanceRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(midFlightContainer.dispose);
      midFlightContainer.listen(maintenanceListProvider(carId), (_, _) {});
      await midFlightContainer.read(maintenanceListProvider(carId).future);

      final readGate = Completer<List<Maintenance>>();
      when(() => repo.getAll(carId)).thenAnswer((_) => readGate.future);

      // when
      final mutation = midFlightContainer
          .read(maintenanceListProvider(carId).notifier)
          .deleteMaint(maintenance);
      await untilCalled(() => repo.getAll(carId));
      midFlightContainer.dispose();
      readGate.complete([maintenance]);

      // then
      await expectLater(mutation, completes);
    });

    test('deleteMaint rethrows ServerFailure as Failure', () async {
      // given
      const carId = 'car-1';
      const maintenance = Maintenance(
        id: 'm1',
        carId: carId,
        type: MaintenanceType.oil,
        date: '2026-03-12',
        mileage: 1,
        cost: 1,
      );
      when(() => repo.getAll(carId)).thenAnswer((_) async => [maintenance]);
      when(() => repo.hasPending(carId)).thenAnswer((_) async => false);
      when(
        () => repo.pendingDeleteIds(carId),
      ).thenAnswer((_) async => <String>{});
      when(
        () => repo.refreshFromRemote(carId),
      ).thenAnswer((_) async => <MaintenanceRemoteSyncEvent>[]);
      when(() => repo.syncPending()).thenAnswer((_) async {});
      when(() => repo.delete(any())).thenThrow(const ServerFailure(500));
      container.listen(maintenanceListProvider(carId), (_, _) {});
      container.read(syncCoordinatorProvider);
      await container.read(maintenanceListProvider(carId).future);

      // when / then
      await expectLater(
        container
            .read(maintenanceListProvider(carId).notifier)
            .deleteMaint(maintenance),
        throwsA(isA<ServerFailure>()),
      );
    });
  });
}

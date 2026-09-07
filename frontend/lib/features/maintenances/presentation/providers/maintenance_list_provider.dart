import 'dart:async';

import 'package:autobook/core/error/failures.dart';
import 'package:autobook/core/sync/sync_coordinator.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_remote_sync_event.dart';
import 'package:autobook/features/maintenances/domain/usecases/create_maintenance_usecase.dart';
import 'package:autobook/features/maintenances/presentation/providers/usecase_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'maintenance_list_provider.g.dart';

typedef MaintenanceListState = ({
  List<Maintenance> maintenances,
  Failure? syncError,
  bool hasPendingSync,
  Set<String> pendingDeleteIds,
  List<MaintenanceRemoteSyncEvent> remoteSyncEvents,
});

@riverpod
class MaintenanceList extends _$MaintenanceList {
  late final String _carId;

  @override
  Future<MaintenanceListState> build(String carId) async {
    _carId = carId;
    final coordinator = ref.read(syncCoordinatorProvider);
    final unregister = coordinator.register(syncPending);
    ref.onDispose(unregister);

    Failure? syncError;
    var cachedMaintenances = <Maintenance>[];
    var hasPendingSync = false;
    var pendingDeleteIds = <String>{};
    try {
      (cachedMaintenances, hasPendingSync, pendingDeleteIds) =
          await _readWithPending();
    } on Failure catch (f) {
      syncError = f;
    }

    _syncInBackground(existingError: syncError);

    return (
      maintenances: cachedMaintenances,
      syncError: syncError,
      hasPendingSync: hasPendingSync,
      pendingDeleteIds: pendingDeleteIds,
      remoteSyncEvents: const <MaintenanceRemoteSyncEvent>[],
    );
  }

  Future<(List<Maintenance>, bool, Set<String>)> _readWithPending() async {
    final getMaintenances = ref.read(getMaintenancesUseCaseProvider);
    final hasPending = ref.read(hasPendingMaintenancesUseCaseProvider);
    final pendingDeleteIds = ref.read(pendingDeleteIdsUseCaseProvider);
    final (maintenances, pending, pendingIds) = await (
      getMaintenances.call(_carId),
      hasPending.call(_carId),
      pendingDeleteIds.call(_carId),
    ).wait;
    return (maintenances, pending, pendingIds);
  }

  Future<void> _emitAfter(
    Future<void> Function() mutation, {
    bool rethrowError = true,
  }) async {
    var cancelled = false;
    ref.onDispose(() => cancelled = true);

    Failure? syncError;
    try {
      await mutation();
    } on Failure catch (f) {
      syncError = f;
    }

    if (!cancelled) {
      var maintenances = <Maintenance>[];
      var hasPendingSync = false;
      var pendingDeleteIds = <String>{};
      try {
        (maintenances, hasPendingSync, pendingDeleteIds) =
            await _readWithPending();
      } on Failure catch (f) {
        syncError ??= f;
      }

      if (cancelled) return;

      state = AsyncData((
        maintenances: maintenances,
        syncError: syncError,
        hasPendingSync: hasPendingSync,
        pendingDeleteIds: pendingDeleteIds,
        remoteSyncEvents: const [],
      ));
    }

    if (rethrowError && syncError != null) throw syncError;
  }

  void _syncInBackground({Failure? existingError}) {
    var cancelled = false;
    ref.onDispose(() => cancelled = true);
    final refresh = ref.read(refreshMaintenancesUseCaseProvider);
    final syncPending = ref.read(syncPendingMaintenancesUseCaseProvider);
    unawaited(
      _refreshAndSync(
        existingError: existingError,
        isCancelled: () => cancelled,
        refresh: () => refresh.call(_carId),
        syncPending: () => syncPending.call(),
      ),
    );
  }

  Future<void> _refreshAndSync({
    Failure? existingError,
    required bool Function() isCancelled,
    required Future<List<MaintenanceRemoteSyncEvent>> Function() refresh,
    required Future<void> Function() syncPending,
  }) async {
    Failure? syncError = existingError;
    var remoteSyncEvents = <MaintenanceRemoteSyncEvent>[];
    try {
      remoteSyncEvents = await refresh();
    } on Failure catch (f) {
      syncError = f;
    }

    if (isCancelled()) return;

    try {
      await syncPending();
    } on Failure catch (f) {
      syncError ??= f;
    }

    if (isCancelled()) return;

    var refreshedMaintenances = <Maintenance>[];
    var hasPendingSync = false;
    var pendingDeleteIds = <String>{};
    try {
      (refreshedMaintenances, hasPendingSync, pendingDeleteIds) =
          await _readWithPending();
    } on Failure catch (f) {
      syncError ??= f;
    }

    if (isCancelled()) return;

    state = AsyncData((
      maintenances: refreshedMaintenances,
      syncError: syncError,
      hasPendingSync: hasPendingSync,
      pendingDeleteIds: pendingDeleteIds,
      remoteSyncEvents: remoteSyncEvents,
    ));
  }

  Future<void> add(MaintenanceDraft draft) => _emitAfter(
    () => ref.read(createMaintenanceUseCaseProvider).call(draft, _carId),
  );

  Future<void> updateMaint(MaintenanceDraft draft, Maintenance existing) =>
      _emitAfter(
        () => ref.read(updateMaintenanceUseCaseProvider).call(draft, existing),
      );

  Future<void> deleteMaint(Maintenance maintenance) => _emitAfter(
    () => ref.read(deleteMaintenanceUseCaseProvider).call(maintenance),
  );

  void clearRemoteChangeBanner() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData((
      maintenances: current.maintenances,
      syncError: current.syncError,
      hasPendingSync: current.hasPendingSync,
      pendingDeleteIds: current.pendingDeleteIds,
      remoteSyncEvents: const [],
    ));
  }

  Future<void> syncPending() => _emitAfter(
    () => ref.read(syncPendingMaintenancesUseCaseProvider).call(),
    rethrowError: false,
  );
}

import 'package:autobook/core/di/uuid_id_generator.dart';
import 'package:autobook/features/maintenances/data/repositories/maintenance_repository.dart';
import 'package:autobook/features/maintenances/domain/usecases/create_maintenance_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/delete_maintenance_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/get_maintenances_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/has_pending_maintenances_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/pending_delete_ids_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/refresh_maintenances_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/sync_pending_maintenances_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/update_maintenance_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'usecase_providers.g.dart';

@riverpod
GetMaintenancesUseCase getMaintenancesUseCase(Ref ref) =>
    GetMaintenancesUseCase(ref.watch(maintenanceRepositoryProvider));

@riverpod
CreateMaintenanceUseCase createMaintenanceUseCase(Ref ref) =>
    CreateMaintenanceUseCase(
      ref.watch(maintenanceRepositoryProvider),
      ref.watch(idGeneratorProvider),
    );

@riverpod
UpdateMaintenanceUseCase updateMaintenanceUseCase(Ref ref) =>
    UpdateMaintenanceUseCase(ref.watch(maintenanceRepositoryProvider));

@riverpod
DeleteMaintenanceUseCase deleteMaintenanceUseCase(Ref ref) =>
    DeleteMaintenanceUseCase(ref.watch(maintenanceRepositoryProvider));

@riverpod
RefreshMaintenancesUseCase refreshMaintenancesUseCase(Ref ref) =>
    RefreshMaintenancesUseCase(ref.watch(maintenanceRepositoryProvider));

@riverpod
SyncPendingMaintenancesUseCase syncPendingMaintenancesUseCase(Ref ref) =>
    SyncPendingMaintenancesUseCase(ref.watch(maintenanceRepositoryProvider));

@riverpod
HasPendingMaintenancesUseCase hasPendingMaintenancesUseCase(Ref ref) =>
    HasPendingMaintenancesUseCase(ref.watch(maintenanceRepositoryProvider));

@riverpod
PendingDeleteIdsUseCase pendingDeleteIdsUseCase(Ref ref) =>
    PendingDeleteIdsUseCase(ref.watch(maintenanceRepositoryProvider));

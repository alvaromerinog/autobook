import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_remote_sync_event.dart';

abstract class IMaintenanceRepository {
  Future<List<Maintenance>> getAll(String carId);
  Future<Maintenance?> getOne(String carId, String id);
  Future<List<MaintenanceRemoteSyncEvent>> refreshFromRemote(String carId);
  Future<void> create(Maintenance maintenance);
  Future<void> update(Maintenance maintenance);
  Future<void> delete(Maintenance maintenance);
  Future<Set<String>> pendingDeleteIds(String carId);
  Future<void> syncPending();
  Future<bool> hasPending(String carId);
}
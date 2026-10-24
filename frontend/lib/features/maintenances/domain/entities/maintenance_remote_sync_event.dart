import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'maintenance_remote_sync_event.freezed.dart';

@freezed
sealed class MaintenanceRemoteSyncEvent with _$MaintenanceRemoteSyncEvent {
  const factory MaintenanceRemoteSyncEvent.remoteDeleted(
    Maintenance maintenance,
  ) = RemoteDeletedM;

  const factory MaintenanceRemoteSyncEvent.remoteDeletedWithPendingUpdate(
    Maintenance maintenance,
  ) = RemoteDeletedWithPendingUpdateM;
}

import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_sync_event.freezed.dart';

@freezed
sealed class RemoteSyncEvent with _$RemoteSyncEvent {
  const factory RemoteSyncEvent.remoteDeleted(Car car) = RemoteDeleted;

  const factory RemoteSyncEvent.remoteDeletedWithPendingUpdate(Car car) =
      RemoteDeletedWithPendingUpdate;
}

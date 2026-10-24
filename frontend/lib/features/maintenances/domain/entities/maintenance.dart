import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'maintenance.freezed.dart';

@freezed
abstract class Maintenance with _$Maintenance {
  const Maintenance._();

  const factory Maintenance({
    required String id,
    required String carId,
    required MaintenanceType type,
    required String date,
    required int mileage,
    required double cost,
    String? garage,
    String? notes,
  }) = _Maintenance;
}

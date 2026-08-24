import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'maintenance_dto.freezed.dart';
part 'maintenance_dto.g.dart';

@freezed
abstract class MaintenanceDto with _$MaintenanceDto {
  const MaintenanceDto._();

  const factory MaintenanceDto({
    required String id,
    required String carId,
    required String type,
    required String date,
    required int mileage,
    required double cost,
    String? garage,
    String? notes,
  }) = _MaintenanceDto;

  factory MaintenanceDto.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceDtoFromJson(json);

  factory MaintenanceDto.fromDomain(Maintenance m) => MaintenanceDto(
    id: m.id,
    carId: m.carId,
    type: m.type.name,
    date: m.date,
    mileage: m.mileage,
    cost: m.cost,
    garage: m.garage,
    notes: m.notes,
  );

  Maintenance toDomain() => Maintenance(
    id: id,
    carId: carId,
    type: MaintenanceType.fromString(type),
    date: date,
    mileage: mileage,
    cost: cost,
    garage: garage,
    notes: notes,
  );
}

@freezed
abstract class MaintenancesListResponse with _$MaintenancesListResponse {
  const factory MaintenancesListResponse({
    required List<MaintenanceDto> maintenances,
  }) = _MaintenancesListResponse;

  factory MaintenancesListResponse.fromJson(Map<String, dynamic> json) =>
      _$MaintenancesListResponseFromJson(json);
}

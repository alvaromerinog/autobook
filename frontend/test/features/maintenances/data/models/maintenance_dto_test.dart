import 'package:autobook/features/maintenances/data/models/maintenance_dto.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MaintenanceDto', () {
    const maintenance = Maintenance(
      id: 'm1',
      carId: 'car-1',
      type: MaintenanceType.oil,
      date: '2026-03-12',
      mileage: 42850,
      cost: 145.2,
      garage: 'Taller Marín',
      notes: 'Aceite 5W-30',
    );

    test('fromDomain then toDomain round-trips all fields', () {
      // given -- maintenance above

      // when
      final dto = MaintenanceDto.fromDomain(maintenance);
      final back = dto.toDomain();

      // then
      expect(back, maintenance);
    });

    test('toJson then fromJson round-trips all fields', () {
      // given
      final dto = MaintenanceDto.fromDomain(maintenance);

      // when
      final json = dto.toJson();
      final back = MaintenanceDto.fromJson(json).toDomain();

      // then
      expect(back, maintenance);
    });
  });
}

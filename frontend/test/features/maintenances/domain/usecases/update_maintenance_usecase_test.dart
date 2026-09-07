import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/features/maintenances/domain/repositories/maintenance_repository.dart';
import 'package:autobook/features/maintenances/domain/usecases/update_maintenance_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements IMaintenanceRepository {}

class _FakeMaintenance extends Fake implements Maintenance {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeMaintenance());
  });

  group('UpdateMaintenanceUseCase', () {
    late _MockRepo repo;
    late UpdateMaintenanceUseCase usecase;

    setUp(() {
      repo = _MockRepo();
      usecase = UpdateMaintenanceUseCase(repo);
    });

    test('returns a Maintenance copying id and carId from existing', () async {
      // given
      const existing = Maintenance(
        id: 'm-1',
        carId: 'car-1',
        type: MaintenanceType.oil,
        date: '2026-01-01',
        mileage: 1000,
        cost: 50,
        garage: null,
        notes: null,
      );
      const draft = (
        type: MaintenanceType.tires,
        date: '2026-02-04',
        mileage: 41200,
        cost: 540.0,
        garage: 'Norauto',
        notes: '4 Michelin',
      );
      when(() => repo.update(any())).thenAnswer((_) async {});

      // when
      final result = await usecase(draft, existing);

      // then
      expect(result.id, existing.id);
      expect(result.carId, existing.carId);
      expect(result.type, MaintenanceType.tires);
      expect(result.garage, 'Norauto');
      verify(() => repo.update(any())).called(1);
    });
  });
}

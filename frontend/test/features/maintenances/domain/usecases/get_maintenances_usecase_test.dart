import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/features/maintenances/domain/repositories/maintenance_repository.dart';
import 'package:autobook/features/maintenances/domain/usecases/get_maintenances_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements IMaintenanceRepository {}

void main() {
  group('GetMaintenancesUseCase', () {
    late _MockRepo repo;
    late GetMaintenancesUseCase usecase;

    setUp(() {
      repo = _MockRepo();
      usecase = GetMaintenancesUseCase(repo);
    });

    test('delegates to repo.getAll with the carId', () async {
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

      // when
      final result = await usecase(carId);

      // then
      expect(result, cached);
      verify(() => repo.getAll(carId)).called(1);
    });
  });
}

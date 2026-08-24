import 'package:autobook/core/id/id_generator.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/features/maintenances/domain/repositories/maintenance_repository.dart';
import 'package:autobook/features/maintenances/domain/usecases/create_maintenance_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements IMaintenanceRepository {}

class _MockIds extends Mock implements IdGenerator {}

class _FakeMaintenance extends Fake implements Maintenance {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(_FakeMaintenance());
  });

  group('CreateMaintenanceUseCase', () {
    late _MockRepo repo;
    late _MockIds ids;
    late CreateMaintenanceUseCase usecase;

    setUp(() {
      repo = _MockRepo();
      ids = _MockIds();
      usecase = CreateMaintenanceUseCase(repo, ids);
    });

    test(
      'returns a Maintenance with the generated id and given fields',
      () async {
        // given
        const carId = 'car-1';
        const newId = 'new-m-1';
        const draft = (
          type: MaintenanceType.oil,
          date: '2026-03-12',
          mileage: 42850,
          cost: 145.2,
          garage: 'Taller Marín',
          notes: 'Aceite 5W-30',
        );
        when(() => ids.newId()).thenReturn(newId);
        when(() => repo.create(any())).thenAnswer((_) async {});

        // when
        final result = await usecase(draft, carId);

        // then
        expect(result.id, newId);
        expect(result.carId, carId);
        expect(result.type, MaintenanceType.oil);
        expect(result.mileage, 42850);
        verify(() => repo.create(any())).called(1);
      },
    );
  });
}

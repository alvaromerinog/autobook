import 'package:autobook/core/error/failures.dart';
import 'package:autobook/core/id/id_generator.dart';
import 'package:autobook/core/sync/sync_coordinator.dart';
import 'package:autobook/features/vehicles/domain/entities/remote_sync_event.dart';
import 'package:autobook/features/vehicles/domain/usecases/create_car_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/delete_car_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/get_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/has_pending_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/pending_delete_ids_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/refresh_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/sync_pending_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/update_car_usecase.dart';
import 'package:autobook/features/vehicles/presentation/providers/usecase_providers.dart';
import 'package:autobook/features/vehicles/presentation/widgets/add_car_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/car_fixtures.dart';
import '../../helpers/car_mocks.dart';

class MockIdGenerator extends Mock implements IdGenerator {}

/// Harness that exposes [addCar] behind a button so the helper can be
/// exercised with a real BuildContext and WidgetRef.
class _AddCarHarness extends ConsumerWidget {
  const _AddCarHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => addCar(context, ref),
          child: const Text('Abrir añadir'),
        ),
      ),
    );
  }
}

Future<void> pumpHarness(
  WidgetTester tester,
  MockCarRepository mockRepo,
  MockIdGenerator mockIds,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        syncCoordinatorProvider.overrideWithValue(SyncCoordinator()),
        getCarsUseCaseProvider.overrideWithValue(GetCarsUseCase(mockRepo)),
        hasPendingCarsUseCaseProvider.overrideWithValue(
          HasPendingCarsUseCase(mockRepo),
        ),
        pendingDeleteIdsUseCaseProvider.overrideWithValue(
          PendingDeleteIdsUseCase(mockRepo),
        ),
        refreshCarsUseCaseProvider.overrideWithValue(
          RefreshCarsUseCase(mockRepo),
        ),
        syncPendingCarsUseCaseProvider.overrideWithValue(
          SyncPendingCarsUseCase(mockRepo),
        ),
        createCarUseCaseProvider.overrideWithValue(
          CreateCarUseCase(mockRepo, mockIds),
        ),
        updateCarUseCaseProvider.overrideWithValue(UpdateCarUseCase(mockRepo)),
        deleteCarUseCaseProvider.overrideWithValue(DeleteCarUseCase(mockRepo)),
      ],
      child: const MaterialApp(home: _AddCarHarness()),
    ),
  );
  await tester.pumpAndSettle();
}

void stubDefaults(MockCarRepository mockRepo) {
  when(
    () => mockRepo.refreshFromRemote(),
  ).thenAnswer((_) async => <RemoteSyncEvent>[]);
  when(() => mockRepo.syncPending()).thenAnswer((_) async {});
  when(() => mockRepo.getAll()).thenAnswer((_) async => oneCarList);
  when(() => mockRepo.hasPending()).thenAnswer((_) async => false);
  when(() => mockRepo.pendingDeleteIds()).thenAnswer((_) async => <String>{});
}

Future<void> fillAndSave(WidgetTester tester) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'Marca'), 'Toyota');
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Modelo'),
    'Corolla',
  );
  await tester.enterText(find.widgetWithText(TextFormField, 'Año'), '2021');
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Matrícula'),
    '9999 XXX',
  );
  await tester.pump();
  await tester.tap(find.text('Guardar vehículo'));
  await tester.pumpAndSettle();
}

void main() {
  late MockCarRepository mockRepo;

  setUpAll(() {
    registerCarFallbacks();
  });

  setUp(() {
    mockRepo = MockCarRepository();
  });

  group('addCar', () {
    testWidgets('given a filled dialog, when saved, then repo.create is '
        'invoked once', (tester) async {
      // given
      stubDefaults(mockRepo);
      when(() => mockRepo.create(any())).thenAnswer((_) async {});
      final mockIds = MockIdGenerator();
      when(() => mockIds.newId()).thenReturn('new-1');

      // when — open dialog and save
      await pumpHarness(tester, mockRepo, mockIds);
      await tester.tap(find.text('Abrir añadir'));
      await tester.pumpAndSettle();
      expect(find.text('Datos del vehículo'), findsOneWidget);
      await fillAndSave(tester);

      // then
      verify(() => mockRepo.create(any())).called(1);
    });

    testWidgets('given repo.create throws a ServerFailure, then a snackbar '
        'with Reintentar is shown', (tester) async {
      // given
      stubDefaults(mockRepo);
      when(() => mockRepo.create(any())).thenThrow(const ServerFailure(500));
      final mockIds = MockIdGenerator();
      when(() => mockIds.newId()).thenReturn('new-1');

      // when — open dialog and save
      await pumpHarness(tester, mockRepo, mockIds);
      await tester.tap(find.text('Abrir añadir'));
      await tester.pumpAndSettle();
      await fillAndSave(tester);

      // then
      expect(find.text('Error al crear el vehículo'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });
  });
}

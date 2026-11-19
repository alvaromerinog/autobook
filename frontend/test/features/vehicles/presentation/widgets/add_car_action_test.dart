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
import 'package:autobook/features/vehicles/presentation/screens/add_car_screen.dart'
    show showCarDialog;
import 'package:autobook/features/vehicles/presentation/widgets/add_car_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../app/localization_test_harness.dart';
import '../../fixtures/car_fixtures.dart';
import '../../helpers/car_mocks.dart';

class MockIdGenerator extends Mock implements IdGenerator {}

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

class _EditCarHarness extends StatelessWidget {
  const _EditCarHarness();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => showCarDialog(context, initial: corollaDraft),
          child: const Text('Abrir editar'),
        ),
      ),
    );
  }
}

Future<void> pumpHarness(
  WidgetTester tester,
  MockCarRepository mockRepo,
  MockIdGenerator mockIds, {
  Locale locale = const Locale('es'),
}) async {
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
      child: localizedTestApp(locale: locale, home: const _AddCarHarness()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> pumpEditHarness(
  WidgetTester tester, {
  Locale locale = const Locale('es'),
}) async {
  await tester.pumpWidget(
    localizedTestApp(locale: locale, home: const _EditCarHarness()),
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

Future<void> fillAndSave(
  WidgetTester tester, {
  String brandLabel = 'Marca',
  String modelLabel = 'Modelo',
  String yearLabel = 'Año',
  String plateLabel = 'Matrícula',
  String submitLabel = 'Guardar vehículo',
}) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, brandLabel),
    'Toyota',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, modelLabel),
    'Corolla',
  );
  await tester.enterText(find.widgetWithText(TextFormField, yearLabel), '2021');
  await tester.enterText(
    find.widgetWithText(TextFormField, plateLabel),
    '9999 XXX',
  );
  await tester.pump();
  await tester.tap(find.text(submitLabel));
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
      stubDefaults(mockRepo);
      when(() => mockRepo.create(any())).thenAnswer((_) async {});
      final mockIds = MockIdGenerator();
      when(() => mockIds.newId()).thenReturn('new-1');

      await pumpHarness(tester, mockRepo, mockIds);
      await tester.tap(find.text('Abrir añadir'));
      await tester.pumpAndSettle();
      expect(find.text('Datos del vehículo'), findsOneWidget);
      await fillAndSave(tester);

      verify(() => mockRepo.create(any())).called(1);
    });

    testWidgets('given the dialog in English, then the form is translated', (
      tester,
    ) async {
      stubDefaults(mockRepo);
      final mockIds = MockIdGenerator();

      await pumpHarness(tester, mockRepo, mockIds, locale: const Locale('en'));
      await tester.tap(find.text('Abrir añadir'));
      await tester.pumpAndSettle();

      expect(find.text('Add vehicle'), findsOneWidget);
      expect(find.text('Vehicle details'), findsOneWidget);
      expect(find.text('Brand'), findsOneWidget);
      expect(find.text('Model'), findsOneWidget);
      expect(find.text('Year'), findsOneWidget);
      expect(find.text('License plate'), findsOneWidget);
      expect(find.text('Additional information (optional)'), findsOneWidget);
      expect(find.text('Save vehicle'), findsOneWidget);
      expect(find.byTooltip('Close'), findsOneWidget);
    });

    testWidgets('given an empty form in English, then the English required '
        'messages are shown', (tester) async {
      stubDefaults(mockRepo);
      final mockIds = MockIdGenerator();

      await pumpHarness(tester, mockRepo, mockIds, locale: const Locale('en'));
      await tester.tap(find.text('Abrir añadir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save vehicle'));
      await tester.pumpAndSettle();

      expect(find.text('Brand is required'), findsOneWidget);
      expect(find.text('Model is required'), findsOneWidget);
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('License plate is required'), findsOneWidget);
    });

    testWidgets('given an out-of-range year in English, then the range '
        'message is shown', (tester) async {
      stubDefaults(mockRepo);
      final mockIds = MockIdGenerator();

      await pumpHarness(tester, mockRepo, mockIds, locale: const Locale('en'));
      await tester.tap(find.text('Abrir añadir'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Year'),
        '1700',
      );
      await tester.tap(find.text('Save vehicle'));
      await tester.pumpAndSettle();

      expect(find.text('Out of range'), findsOneWidget);
    });

    testWidgets('given a filled dialog in English, when saved, then '
        'repo.create is invoked once', (tester) async {
      stubDefaults(mockRepo);
      when(() => mockRepo.create(any())).thenAnswer((_) async {});
      final mockIds = MockIdGenerator();
      when(() => mockIds.newId()).thenReturn('new-1');

      await pumpHarness(tester, mockRepo, mockIds, locale: const Locale('en'));
      await tester.tap(find.text('Abrir añadir'));
      await tester.pumpAndSettle();
      await fillAndSave(
        tester,
        brandLabel: 'Brand',
        modelLabel: 'Model',
        yearLabel: 'Year',
        plateLabel: 'License plate',
        submitLabel: 'Save vehicle',
      );

      verify(() => mockRepo.create(any())).called(1);
    });

    testWidgets('given repo.create throws a ServerFailure, then a snackbar '
        'with Reintentar is shown', (tester) async {
      stubDefaults(mockRepo);
      when(() => mockRepo.create(any())).thenThrow(const ServerFailure(500));
      final mockIds = MockIdGenerator();
      when(() => mockIds.newId()).thenReturn('new-1');

      await pumpHarness(tester, mockRepo, mockIds);
      await tester.tap(find.text('Abrir añadir'));
      await tester.pumpAndSettle();
      await fillAndSave(tester);

      expect(find.text('Error al crear el vehículo'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('given repo.create throws a ServerFailure in English, then '
        'the English snackbar with Retry is shown', (tester) async {
      stubDefaults(mockRepo);
      when(() => mockRepo.create(any())).thenThrow(const ServerFailure(500));
      final mockIds = MockIdGenerator();
      when(() => mockIds.newId()).thenReturn('new-1');

      await pumpHarness(tester, mockRepo, mockIds, locale: const Locale('en'));
      await tester.tap(find.text('Abrir añadir'));
      await tester.pumpAndSettle();
      await fillAndSave(
        tester,
        brandLabel: 'Brand',
        modelLabel: 'Model',
        yearLabel: 'Year',
        plateLabel: 'License plate',
        submitLabel: 'Save vehicle',
      );

      expect(find.text('Could not create the vehicle'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('showCarDialog', () {
    testWidgets('given an initial draft, then the edit dialog is shown in '
        'Spanish', (tester) async {
      await pumpEditHarness(tester);
      await tester.tap(find.text('Abrir editar'));
      await tester.pumpAndSettle();

      expect(find.text('Editar vehículo'), findsOneWidget);
      expect(find.text('Guardar cambios'), findsOneWidget);
    });

    testWidgets('given an initial draft in English, then the English edit '
        'dialog is shown', (tester) async {
      await pumpEditHarness(tester, locale: const Locale('en'));
      await tester.tap(find.text('Abrir editar'));
      await tester.pumpAndSettle();

      expect(find.text('Edit vehicle'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
      expect(find.text('Brand'), findsOneWidget);
    });
  });
}

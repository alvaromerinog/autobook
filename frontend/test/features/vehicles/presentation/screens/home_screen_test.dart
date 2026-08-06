import 'package:autobook/core/id/id_generator.dart';
import 'package:autobook/core/sync/sync_coordinator.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
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
import 'package:autobook/features/vehicles/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/car_fixtures.dart';
import '../../helpers/car_mocks.dart';

class MockIdGenerator extends Mock implements IdGenerator {}

Future<void> pumpHomeScreen(
  WidgetTester tester,
  MockCarRepository mockRepo,
) async {
  final mockIds = MockIdGenerator();
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
      child: const MaterialApp(home: HomeScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void stubSyncDefaults(
  MockCarRepository mockRepo, {
  List<Car> cars = oneCarList,
}) {
  when(
    () => mockRepo.refreshFromRemote(),
  ).thenAnswer((_) async => <RemoteSyncEvent>[]);
  when(() => mockRepo.syncPending()).thenAnswer((_) async {});
  when(() => mockRepo.getAll()).thenAnswer((_) async => cars);
  when(() => mockRepo.hasPending()).thenAnswer((_) async => false);
  when(() => mockRepo.pendingDeleteIds()).thenAnswer((_) async => <String>{});
}

void main() {
  late MockCarRepository mockRepo;

  setUpAll(() {
    registerCarFallbacks();
  });

  setUp(() {
    mockRepo = MockCarRepository();
  });

  group('HomeScreen', () {
    group('delete confirmation dialog', () {
      testWidgets('given a car, when the delete icon is tapped and Cancelar '
          'is chosen, then the dialog closes and delete is never called', (
        tester,
      ) async {
        // given
        stubSyncDefaults(mockRepo);

        // when
        await pumpHomeScreen(tester, mockRepo);
        await tester.tap(find.byTooltip('Eliminar'));
        await tester.pumpAndSettle();

        // then — confirm dialog is shown
        expect(find.text('Eliminar vehículo'), findsOneWidget);
        expect(
          find.text('¿Seguro que quieres eliminar Toyota Corolla?'),
          findsOneWidget,
        );

        // when — cancel
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        // then
        expect(find.text('Eliminar vehículo'), findsNothing);
        verifyNever(() => mockRepo.delete(any()));
      });

      testWidgets('given a car, when the delete icon is tapped and Eliminar '
          'is chosen, then repo.delete is called once', (tester) async {
        // given
        stubSyncDefaults(mockRepo);
        when(() => mockRepo.delete(any())).thenAnswer((_) async {});
        when(() => mockRepo.hasPending()).thenAnswer((_) async => true);

        // when
        await pumpHomeScreen(tester, mockRepo);
        await tester.tap(find.byTooltip('Eliminar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        // then
        verify(() => mockRepo.delete(toyotaCorolla)).called(1);
      });
    });

    group('pending delete row', () {
      testWidgets('given a car pending delete, then the row is translucent and '
          'shows the pending label', (tester) async {
        // given
        stubSyncDefaults(mockRepo);
        when(() => mockRepo.pendingDeleteIds()).thenAnswer((_) async => {'1'});

        // when
        await pumpHomeScreen(tester, mockRepo);

        // then
        expect(find.text('Pendiente de borrado'), findsOneWidget);
        final opacity = tester.widget<Opacity>(
          find.ancestor(of: find.byType(Card), matching: find.byType(Opacity)),
        );
        expect(opacity.opacity, lessThan(1.0));
      });
    });

    group('ephemeral remote change banner', () {
      testWidgets('given a remote deletion event, then a snackbar is shown and '
          'the banner is cleared', (tester) async {
        // given
        stubSyncDefaults(mockRepo);
        when(() => mockRepo.refreshFromRemote()).thenAnswer(
          (_) async => [const RemoteSyncEvent.remoteDeleted(toyotaCorolla)],
        );

        // when
        await pumpHomeScreen(tester, mockRepo);

        // then — snackbar shown with the event text
        expect(find.text('Coche Toyota Corolla eliminado'), findsOneWidget);

        // when — let the snackbar auto-dismiss
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();

        // then — snackbar gone
        expect(find.text('Coche Toyota Corolla eliminado'), findsNothing);
      });
    });
  });
}

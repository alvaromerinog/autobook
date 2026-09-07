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
import 'package:autobook/features/vehicles/presentation/widgets/garage_list_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/car_fixtures.dart';
import '../../helpers/car_mocks.dart';

class MockIdGenerator extends Mock implements IdGenerator {}

Future<void> pumpGarageList(
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
      child: const MaterialApp(home: Scaffold(body: GarageListContent())),
    ),
  );
  await tester.pumpAndSettle();
}

void stubDefaults(MockCarRepository mockRepo, {List<Car> cars = oneCarList}) {
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

  group('GarageListContent', () {
    testWidgets('given one car, when pumped, then the car card is shown', (
      tester,
    ) async {
      // given
      stubDefaults(mockRepo);

      // when
      await pumpGarageList(tester, mockRepo);

      // then
      expect(find.text('Toyota Corolla'), findsOneWidget);
    });

    testWidgets('given an empty garage, when pumped, then the empty state '
        'is shown', (tester) async {
      // given
      stubDefaults(mockRepo, cars: const []);

      // when
      await pumpGarageList(tester, mockRepo);

      // then
      expect(find.text('Tu garaje está vacío'), findsOneWidget);
    });

    testWidgets('given a remote deletion event, when the list settles, '
        'then the snackbar is shown', (tester) async {
      // given
      stubDefaults(mockRepo);
      when(() => mockRepo.refreshFromRemote()).thenAnswer(
        (_) async => [const RemoteSyncEvent.remoteDeleted(toyotaCorolla)],
      );

      // when
      await pumpGarageList(tester, mockRepo);

      // then — snackbar shown with the event text
      expect(find.text('Coche Toyota Corolla eliminado'), findsOneWidget);
    });
  });
}

import 'package:autobook/core/error/failures.dart';
import 'package:autobook/core/id/id_generator.dart';
import 'package:autobook/core/sync/sync_coordinator.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_remote_sync_event.dart';
import 'package:autobook/features/maintenances/domain/entities/maintenance_type.dart';
import 'package:autobook/features/maintenances/domain/repositories/maintenance_repository.dart';
import 'package:autobook/features/maintenances/domain/usecases/create_maintenance_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/delete_maintenance_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/get_maintenances_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/has_pending_maintenances_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/pending_delete_ids_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/refresh_maintenances_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/sync_pending_maintenances_usecase.dart';
import 'package:autobook/features/maintenances/domain/usecases/update_maintenance_usecase.dart';
import 'package:autobook/features/maintenances/presentation/providers/usecase_providers.dart'
    as maint_usecases;
import 'package:autobook/features/maintenances/presentation/screens/maintenance_detail_screen.dart';
import 'package:autobook/features/maintenances/presentation/theme/maint_tints.dart';
import 'package:autobook/features/maintenances/presentation/theme/maint_type_icons.dart';
import 'package:autobook/features/vehicles/domain/entities/car.dart';
import 'package:autobook/features/vehicles/domain/entities/remote_sync_event.dart';
import 'package:autobook/features/vehicles/domain/usecases/create_car_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/delete_car_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/get_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/has_pending_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/pending_delete_ids_usecase.dart'
    as vehicle_usecases;
import 'package:autobook/features/vehicles/domain/usecases/refresh_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/sync_pending_cars_usecase.dart';
import 'package:autobook/features/vehicles/domain/usecases/update_car_usecase.dart';
import 'package:autobook/features/vehicles/presentation/providers/usecase_providers.dart';
import 'package:autobook/l10n/app_localizations.dart';
import 'package:autobook/features/vehicles/presentation/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../vehicles/fixtures/car_fixtures.dart';
import '../../../vehicles/helpers/car_mocks.dart';
import '../../fixtures/maintenance_fixtures.dart';

class _MockIdGenerator extends Mock implements IdGenerator {}

class _UnusedMaintenanceRepo extends Mock implements IMaintenanceRepository {}

class _StubGetMaintenances extends GetMaintenancesUseCase {
  _StubGetMaintenances(this.maintenances) : super(_UnusedMaintenanceRepo());

  final List<Maintenance> maintenances;

  @override
  Future<List<Maintenance>> call(String carId) async => maintenances;
}

class _StubHasPending extends HasPendingMaintenancesUseCase {
  _StubHasPending() : super(_UnusedMaintenanceRepo());

  @override
  Future<bool> call(String carId) async => false;
}

class _StubPendingDeleteIds extends PendingDeleteIdsUseCase {
  _StubPendingDeleteIds() : super(_UnusedMaintenanceRepo());

  @override
  Future<Set<String>> call(String carId) async => <String>{};
}

class _StubRefresh extends RefreshMaintenancesUseCase {
  _StubRefresh() : super(_UnusedMaintenanceRepo());

  @override
  Future<List<MaintenanceRemoteSyncEvent>> call(String carId) async =>
      const <MaintenanceRemoteSyncEvent>[];
}

class _StubSyncPending extends SyncPendingMaintenancesUseCase {
  _StubSyncPending() : super(_UnusedMaintenanceRepo());

  @override
  Future<void> call() async {}
}

class _RecordingUpdate extends UpdateMaintenanceUseCase {
  _RecordingUpdate(this.calls) : super(_UnusedMaintenanceRepo());

  final List<(MaintenanceDraft, Maintenance)> calls;

  @override
  Future<Maintenance> call(MaintenanceDraft draft, Maintenance existing) async {
    calls.add((draft, existing));
    return existing;
  }
}

class _FailingUpdate extends UpdateMaintenanceUseCase {
  _FailingUpdate() : super(_UnusedMaintenanceRepo());

  @override
  Future<Maintenance> call(MaintenanceDraft draft, Maintenance existing) async {
    throw const ServerFailure(500);
  }
}

class _StubDelete extends DeleteMaintenanceUseCase {
  _StubDelete(this.calls) : super(_UnusedMaintenanceRepo());

  final List<Maintenance> calls;

  @override
  Future<void> call(Maintenance maintenance) async {
    calls.add(maintenance);
  }
}

class _FailingDelete extends DeleteMaintenanceUseCase {
  _FailingDelete() : super(_UnusedMaintenanceRepo());

  @override
  Future<void> call(Maintenance maintenance) async {
    throw const ServerFailure(500);
  }
}

Future<void> pumpDetailScreen(
  WidgetTester tester, {
  required MockCarRepository mockCarRepo,
  required List<(MaintenanceDraft, Maintenance)> updateCalls,
  List<Maintenance>? maintenances,
  UpdateMaintenanceUseCase? updateUseCase,
  DeleteMaintenanceUseCase? deleteUseCase,
  Locale locale = const Locale('es'),
}) async {
  final router = GoRouter(
    initialLocation: '/cars/car-1/maintenances/m1',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('home')),
      ),
      GoRoute(
        path: '/cars/:carId',
        builder: (_, _) => const Scaffold(body: Text('car detail')),
      ),
      GoRoute(
        path: '/cars/:carId/maintenances/:id',
        builder: (_, state) => MaintenanceDetailScreen(
          carId: state.pathParameters['carId']!,
          maintenanceId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        syncCoordinatorProvider.overrideWithValue(SyncCoordinator()),
        getCarsUseCaseProvider.overrideWithValue(GetCarsUseCase(mockCarRepo)),
        hasPendingCarsUseCaseProvider.overrideWithValue(
          HasPendingCarsUseCase(mockCarRepo),
        ),
        pendingDeleteIdsUseCaseProvider.overrideWithValue(
          vehicle_usecases.PendingDeleteIdsUseCase(mockCarRepo),
        ),
        refreshCarsUseCaseProvider.overrideWithValue(
          RefreshCarsUseCase(mockCarRepo),
        ),
        syncPendingCarsUseCaseProvider.overrideWithValue(
          SyncPendingCarsUseCase(mockCarRepo),
        ),
        createCarUseCaseProvider.overrideWithValue(
          CreateCarUseCase(mockCarRepo, _MockIdGenerator()),
        ),
        updateCarUseCaseProvider.overrideWithValue(
          UpdateCarUseCase(mockCarRepo),
        ),
        deleteCarUseCaseProvider.overrideWithValue(
          DeleteCarUseCase(mockCarRepo),
        ),
        maint_usecases.getMaintenancesUseCaseProvider.overrideWithValue(
          _StubGetMaintenances(
            maintenances ?? [buildMaintenance(carId: 'car-1')],
          ),
        ),
        maint_usecases.hasPendingMaintenancesUseCaseProvider.overrideWithValue(
          _StubHasPending(),
        ),
        maint_usecases.pendingDeleteIdsUseCaseProvider.overrideWithValue(
          _StubPendingDeleteIds(),
        ),
        maint_usecases.refreshMaintenancesUseCaseProvider.overrideWithValue(
          _StubRefresh(),
        ),
        maint_usecases.syncPendingMaintenancesUseCaseProvider.overrideWithValue(
          _StubSyncPending(),
        ),
        maint_usecases.updateMaintenanceUseCaseProvider.overrideWithValue(
          updateUseCase ?? _RecordingUpdate(updateCalls),
        ),
        maint_usecases.deleteMaintenanceUseCaseProvider.overrideWithValue(
          deleteUseCase ?? _StubDelete(<Maintenance>[]),
        ),
      ],
      child: MaterialApp.router(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void stubCarDefaults(MockCarRepository mockRepo, {List<Car>? cars}) {
  when(
    () => mockRepo.refreshFromRemote(),
  ).thenAnswer((_) async => <RemoteSyncEvent>[]);
  when(() => mockRepo.syncPending()).thenAnswer((_) async {});
  when(() => mockRepo.getAll()).thenAnswer((_) async => cars ?? oneCarList);
  when(() => mockRepo.hasPending()).thenAnswer((_) async => false);
  when(() => mockRepo.pendingDeleteIds()).thenAnswer((_) async => <String>{});
}

void main() {
  group('MaintenanceDetailScreen', () {
    group('edit maintenance', () {
      testWidgets('given edit saved in the maintenance dialog flow, '
          'when the draft is saved, '
          'then the update use case is invoked once with it', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        final existing = buildMaintenance(carId: 'car-1');
        final calledWith = <(MaintenanceDraft, Maintenance)>[];
        final mockCarRepo = MockCarRepository();
        stubCarDefaults(mockCarRepo);

        await pumpDetailScreen(
          tester,
          mockCarRepo: mockCarRepo,
          updateCalls: calledWith,
        );

        await tester.tap(find.byTooltip('Editar'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(CustomFormField, 'Coste'),
          '99.9',
        );
        await tester.pump();
        await tester.tap(find.text('Guardar cambios'));
        await tester.pumpAndSettle();

        expect(calledWith, hasLength(1));
        expect(calledWith.first.$1.cost, 99.9);
        expect(calledWith.first.$2.id, existing.id);
      });
    });

    group('estilo de tarjetas', () {
      testWidgets('dado un mantenimiento encontrado, cuando se bombea, '
          'entonces el encabezado es tarjeta neutra con margen 20 px, esquinas '
          'redondeadas y el tinte solo en la caja del icono', (tester) async {
        final mockCarRepo = MockCarRepository();
        stubCarDefaults(mockCarRepo);

        await pumpDetailScreen(
          tester,
          mockCarRepo: mockCarRepo,
          updateCalls: <(MaintenanceDraft, Maintenance)>[],
        );

        final headerCard = find.byType(Card).first;
        final card = tester.widget<Card>(headerCard);
        final element = tester.element(headerCard);
        final theme = Theme.of(element);
        final tint = getTint(MaintenanceType.oil, theme.brightness);

        expect(card.color, theme.colorScheme.surfaceContainerLow);
        expect(card.color, isNot(tint.bg));

        expect(tester.getTopLeft(headerCard).dx, 20.0);
        expect(tester.getTopLeft(find.byType(Card).last).dx, 20.0);

        final material = tester.widget<Material>(
          find
              .descendant(of: headerCard, matching: find.byType(Material))
              .first,
        );
        final shape = material.shape! as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(12));

        final iconBox = tester.widget<Container>(
          find
              .ancestor(
                of: find.byIcon(maintTypeIcon(MaintenanceType.oil)),
                matching: find.byType(Container),
              )
              .first,
        );
        final decoration = iconBox.decoration! as BoxDecoration;
        expect(decoration.color, tint.bg);
        expect(decoration.borderRadius, BorderRadius.circular(20));
      });

      testWidgets('dado un mantenimiento encontrado, cuando se bombea, '
          'entonces no queda ningún Divider a sangre', (tester) async {
        final mockCarRepo = MockCarRepository();
        stubCarDefaults(mockCarRepo);

        await pumpDetailScreen(
          tester,
          mockCarRepo: mockCarRepo,
          updateCalls: <(MaintenanceDraft, Maintenance)>[],
        );

        expect(find.byType(Divider), findsNothing);
      });
    });

    group('acciones sobre la ficha de estadísticas', () {
      testWidgets('given a maintenance, when pumped, then the edit and delete '
          'buttons straddle the stats card bottom edge', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        final mockCarRepo = MockCarRepository();
        stubCarDefaults(mockCarRepo);

        await pumpDetailScreen(
          tester,
          mockCarRepo: mockCarRepo,
          updateCalls: <(MaintenanceDraft, Maintenance)>[],
        );
        const cardKey = Key('maintenance-stats-card');
        final cardRect = tester.getRect(find.byKey(cardKey));
        final editCenter = tester.getCenter(find.byTooltip('Editar'));
        final deleteCenter = tester.getCenter(find.byTooltip('Eliminar'));

        expect(find.byKey(cardKey), findsOneWidget);
        expect((editCenter.dy - cardRect.bottom).abs(), lessThan(1.0));
        expect((deleteCenter.dy - cardRect.bottom).abs(), lessThan(1.0));
        expect(editCenter.dx, lessThan(deleteCenter.dx));
        expect(tester.widget<Card>(find.byKey(cardKey)).elevation, 1);
        expect(find.text('COSTE'), findsOneWidget);
        expect(find.text('KILÓMETROS'), findsOneWidget);
        expect(find.text('FECHA'), findsOneWidget);

        final cs = Theme.of(
          tester.element(find.byTooltip('Editar')),
        ).colorScheme;
        final editDisc = tester.widget<Container>(
          find
              .ancestor(
                of: find.byTooltip('Editar'),
                matching: find.byType(Container),
              )
              .first,
        );
        expect((editDisc.decoration! as BoxDecoration).color, cs.primary);
      });
    });

    group('delete maintenance', () {
      testWidgets('given a maintenance, when the delete button is tapped and '
          'Cancelar is chosen, then the confirmation dialog is shown and '
          'closes without deleting', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        final mockCarRepo = MockCarRepository();
        stubCarDefaults(mockCarRepo);

        await pumpDetailScreen(
          tester,
          mockCarRepo: mockCarRepo,
          updateCalls: <(MaintenanceDraft, Maintenance)>[],
        );

        expect(find.byTooltip('Editar'), findsOneWidget);
        expect(find.byTooltip('Eliminar'), findsOneWidget);
        expect(find.byIcon(Icons.more_vert), findsNothing);
        expect(find.byType(PopupMenuButton<String>), findsNothing);

        await tester.tap(find.byTooltip('Eliminar'));
        await tester.pumpAndSettle();

        expect(find.text('Eliminar mantenimiento'), findsOneWidget);

        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        expect(find.text('Eliminar mantenimiento'), findsNothing);
      });
    });

    group('English copy', () {
      testWidgets('given a maintenance with notes and a garage, when pumped in '
          'English, then the headings, stats, tooltips and notes are '
          'translated', (tester) async {
        final mockCarRepo = MockCarRepository();
        stubCarDefaults(mockCarRepo);

        await pumpDetailScreen(
          tester,
          mockCarRepo: mockCarRepo,
          updateCalls: <(MaintenanceDraft, Maintenance)>[],
          locale: const Locale('en'),
          maintenances: [
            buildMaintenance(
              carId: 'car-1',
              garage: 'Marín Workshop',
              notes: 'New pads',
            ),
          ],
        );

        expect(find.text('Oil change'), findsOneWidget);
        expect(find.text('COST'), findsOneWidget);
        expect(find.text('MILEAGE'), findsOneWidget);
        expect(find.text('DATE'), findsOneWidget);
        expect(find.text('NOTES'), findsOneWidget);
        expect(find.text('New pads'), findsOneWidget);
        expect(find.text('Marín Workshop'), findsOneWidget);
        expect(find.byTooltip('Edit'), findsOneWidget);
        expect(find.byTooltip('Delete'), findsOneWidget);
      });

      testWidgets('given a maintenance with notes, when pumped in Spanish, '
          'then the notes section keeps the Spanish heading', (tester) async {
        final mockCarRepo = MockCarRepository();
        stubCarDefaults(mockCarRepo);

        await pumpDetailScreen(
          tester,
          mockCarRepo: mockCarRepo,
          updateCalls: <(MaintenanceDraft, Maintenance)>[],
          maintenances: [
            buildMaintenance(carId: 'car-1', notes: 'Pastillas nuevas'),
          ],
        );

        expect(find.text('NOTAS'), findsOneWidget);
        expect(find.text('Pastillas nuevas'), findsOneWidget);
      });
    });

    group('formato por idioma', () {
      testWidgets('given a maintenance, when pumped in Spanish, then date, '
          'mileage and cost follow the Spanish formatting', (tester) async {
        final mockCarRepo = MockCarRepository();
        stubCarDefaults(mockCarRepo);

        await pumpDetailScreen(
          tester,
          mockCarRepo: mockCarRepo,
          updateCalls: <(MaintenanceDraft, Maintenance)>[],
          maintenances: [
            buildMaintenance(
              carId: 'car-1',
              date: '2026-03-12',
              mileage: 189000,
              cost: 1234.5,
            ),
          ],
        );

        expect(find.text('12 mar'), findsOneWidget);
        expect(find.text('189.000 km'), findsOneWidget);
        expect(find.text('1.234,50\u00A0€'), findsOneWidget);
      });

      testWidgets('given a maintenance, when pumped in English, then date, '
          'mileage and cost follow the English formatting', (tester) async {
        final mockCarRepo = MockCarRepository();
        stubCarDefaults(mockCarRepo);

        await pumpDetailScreen(
          tester,
          mockCarRepo: mockCarRepo,
          updateCalls: <(MaintenanceDraft, Maintenance)>[],
          locale: const Locale('en'),
          maintenances: [
            buildMaintenance(
              carId: 'car-1',
              date: '2026-03-12',
              mileage: 189000,
              cost: 1234.5,
            ),
          ],
        );

        expect(find.text('12 Mar'), findsOneWidget);
        expect(find.text('189,000 km'), findsOneWidget);
        expect(find.text('€1,234.50'), findsOneWidget);
      });
    });

    group('registro no encontrado', () {
      testWidgets('given no matching maintenance, when pumped in Spanish, then '
          'the not found message is shown', (tester) async {
        final mockCarRepo = MockCarRepository();
        stubCarDefaults(mockCarRepo);

        await pumpDetailScreen(
          tester,
          mockCarRepo: mockCarRepo,
          updateCalls: <(MaintenanceDraft, Maintenance)>[],
          maintenances: const <Maintenance>[],
        );

        expect(find.text('Registro no encontrado'), findsOneWidget);
      });

      testWidgets('given no matching maintenance, when pumped in English, then '
          'the English not found message is shown', (tester) async {
        final mockCarRepo = MockCarRepository();
        stubCarDefaults(mockCarRepo);

        await pumpDetailScreen(
          tester,
          mockCarRepo: mockCarRepo,
          updateCalls: <(MaintenanceDraft, Maintenance)>[],
          maintenances: const <Maintenance>[],
          locale: const Locale('en'),
        );

        expect(find.text('Record not found'), findsOneWidget);
      });
    });

    group('delete snackbars', () {
      testWidgets('given a confirmed deletion, when it succeeds, then the '
          'Spanish snackbar is shown', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        final mockCarRepo = MockCarRepository();
        stubCarDefaults(mockCarRepo);
        final deleteCalls = <Maintenance>[];

        await pumpDetailScreen(
          tester,
          mockCarRepo: mockCarRepo,
          updateCalls: <(MaintenanceDraft, Maintenance)>[],
          deleteUseCase: _StubDelete(deleteCalls),
        );
        await tester.tap(find.byTooltip('Eliminar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        expect(deleteCalls, hasLength(1));
        expect(find.text('Mantenimiento eliminado'), findsOneWidget);
        expect(find.text('home'), findsOneWidget);
      });

      testWidgets('given a confirmed deletion in English, when it succeeds, '
          'then the English snackbar is shown', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        final mockCarRepo = MockCarRepository();
        stubCarDefaults(mockCarRepo);
        final deleteCalls = <Maintenance>[];

        await pumpDetailScreen(
          tester,
          mockCarRepo: mockCarRepo,
          updateCalls: <(MaintenanceDraft, Maintenance)>[],
          deleteUseCase: _StubDelete(deleteCalls),
          locale: const Locale('en'),
        );
        await tester.tap(find.byTooltip('Delete'));
        await tester.pumpAndSettle();
        expect(find.text('Delete maintenance'), findsOneWidget);
        expect(
          find.text('Are you sure you want to delete this record?'),
          findsOneWidget,
        );
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(find.text('Maintenance deleted'), findsOneWidget);
      });

      testWidgets('given a confirmed deletion, when it fails, then the Spanish '
          'error snackbar is shown', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        final mockCarRepo = MockCarRepository();
        stubCarDefaults(mockCarRepo);

        await pumpDetailScreen(
          tester,
          mockCarRepo: mockCarRepo,
          updateCalls: <(MaintenanceDraft, Maintenance)>[],
          deleteUseCase: _FailingDelete(),
        );
        await tester.tap(find.byTooltip('Eliminar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        expect(find.text('Error al eliminar el mantenimiento'), findsOneWidget);
      });

      testWidgets('given a confirmed deletion in English, when it fails, then '
          'the English error snackbar is shown', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        final mockCarRepo = MockCarRepository();
        stubCarDefaults(mockCarRepo);

        await pumpDetailScreen(
          tester,
          mockCarRepo: mockCarRepo,
          updateCalls: <(MaintenanceDraft, Maintenance)>[],
          deleteUseCase: _FailingDelete(),
          locale: const Locale('en'),
        );
        await tester.tap(find.byTooltip('Delete'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(find.text('Could not delete the maintenance'), findsOneWidget);
      });
    });

    group('update snackbars', () {
      testWidgets('given a failed update, when the dialog is saved, then the '
          'Spanish error snackbar is shown', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        final mockCarRepo = MockCarRepository();
        stubCarDefaults(mockCarRepo);

        await pumpDetailScreen(
          tester,
          mockCarRepo: mockCarRepo,
          updateCalls: <(MaintenanceDraft, Maintenance)>[],
          updateUseCase: _FailingUpdate(),
        );
        await tester.tap(find.byTooltip('Editar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Guardar cambios'));
        await tester.pumpAndSettle();

        expect(
          find.text('Error al actualizar el mantenimiento'),
          findsOneWidget,
        );
      });

      testWidgets('given a failed update in English, when the dialog is saved, '
          'then the English error snackbar is shown', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        final mockCarRepo = MockCarRepository();
        stubCarDefaults(mockCarRepo);

        await pumpDetailScreen(
          tester,
          mockCarRepo: mockCarRepo,
          updateCalls: <(MaintenanceDraft, Maintenance)>[],
          updateUseCase: _FailingUpdate(),
          locale: const Locale('en'),
        );
        await tester.tap(find.byTooltip('Edit'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save changes'));
        await tester.pumpAndSettle();

        expect(find.text('Could not update the maintenance'), findsOneWidget);
      });
    });
  });
}

import 'dart:async';

import 'package:autobook/app/responsive/app_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:autobook/features/vehicles/presentation/widgets/garage_list_content.dart';

import '../../features/maintenances/fixtures/maintenance_fixtures.dart';
import '../../features/vehicles/fixtures/car_fixtures.dart';
import '../app_test_harness.dart';

void main() {
  setUpAll(() {
    registerAppHarnessFallbacks();
  });

  group('AdaptiveAppShell', () {
    group('expanded', () {
      testWidgets('given an expanded surface at /, when pumped, then the '
          'sidebar, the list and the placeholder are shown in order without '
          'a back button', (tester) async {
        await pumpApp(tester, size: const Size(1200, 900));

        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Toyota Corolla'), findsOneWidget);
        expect(find.text('Selecciona un vehículo'), findsOneWidget);
        expect(find.byType(BackButton), findsNothing);

        final row = tester.widget<Row>(
          find
              .ancestor(
                of: find.text('Selecciona un vehículo'),
                matching: find.byType(Row),
              )
              .first,
        );
        expect(row.children[0], isA<AppSidebar>());
        expect(row.children[1], isA<VerticalDivider>());
        expect(row.children[2], isA<Expanded>());
        expect(row.children[3], isA<VerticalDivider>());
        expect(row.children[4], isA<Expanded>());
      });
    });

    group('expanded selection', () {
      testWidgets('given an expanded surface at /, when a car card is '
          'tapped, then the URL goes to /cars/1 and the detail fills the '
          'third column without a back button', (tester) async {
        final (router, _) = await pumpApp(tester, size: const Size(1200, 900));
        await tester.tap(find.text('Toyota Corolla'));
        await tester.pumpAndSettle();

        expect(router.routeInformationProvider.value.uri.path, '/cars/1');
        expect(find.text('Historial de mantenimientos'), findsOneWidget);
        expect(find.byType(BackButton), findsNothing);
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Toyota Corolla'), findsOneWidget);
      });

      testWidgets('given an expanded surface deep-linked to an unknown '
          'car, then the third column shows the not found message', (
        tester,
      ) async {
        await pumpApp(
          tester,
          size: const Size(1200, 900),
          initial: '/cars/no-existe',
        );

        expect(find.text('Vehículo no encontrado'), findsOneWidget);
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Toyota Corolla'), findsOneWidget);
      });

      testWidgets('given an expanded surface with two cars, when one is '
          'selected, then its card is highlighted and the other is not', (
        tester,
      ) async {
        final (router, _) = await pumpApp(
          tester,
          size: const Size(1200, 900),
          cars: [toyotaCorolla, fordFocus],
        );
        await tester.tap(find.text('Ford Focus'));
        await tester.pumpAndSettle();

        final selected = tester.widget<Card>(
          find.ancestor(
            of: find.text('Ford Focus'),
            matching: find.byType(Card),
          ),
        );
        final unselected = tester.widget<Card>(
          find.ancestor(
            of: find.text('Toyota Corolla'),
            matching: find.byType(Card),
          ),
        );
        final colorScheme = Theme.of(
          tester.element(find.text('Ford Focus')),
        ).colorScheme;
        expect(selected.color, colorScheme.secondaryContainer);
        expect(unselected.color, isNull);
        expect(router.routeInformationProvider.value.uri.path, '/cars/2');
      });
    });

    group('resize across breakpoints', () {
      testWidgets('given an expanded surface at /cars/1, when resized to '
          'compact, then the detail fills the screen with a back button, '
          'and back to expanded restores the three columns', (tester) async {
        final (router, _) = await pumpApp(
          tester,
          size: const Size(1200, 900),
          initial: '/cars/1',
        );
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(BackButton), findsNothing);

        tester.view.physicalSize = const Size(400, 900);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpAndSettle();

        expect(find.byType(BackButton), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);

        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Historial de mantenimientos'), findsOneWidget);
        expect(router.routeInformationProvider.value.uri.path, '/cars/1');
      });

      testWidgets('given a car selected in expanded, when resized to '
          'medium and the back button is tapped, then the list is shown '
          'again', (tester) async {
        final (router, _) = await pumpApp(tester, size: const Size(1200, 900));
        await tester.tap(find.text('Toyota Corolla'));
        await tester.pumpAndSettle();
        expect(router.routeInformationProvider.value.uri.path, '/cars/1');

        tester.view.physicalSize = const Size(720, 900);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpAndSettle();

        expect(router.canPop(), isFalse);
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Toyota Corolla'), findsOneWidget);
      });

      testWidgets('given a car pushed in medium, when the back button is '
          'tapped, then pop returns to the list', (tester) async {
        final (router, _) = await pumpApp(tester, size: const Size(720, 900));
        unawaited(router.push('/cars/1'));
        await tester.pumpAndSettle();
        expect(find.byType(BackButton), findsOneWidget);

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Toyota Corolla'), findsOneWidget);
      });
    });

    group('breakpoint boundaries through the shell', () {
      testWidgets('given widths around the 600 and 840 thresholds, when the '
          'surface is resized, then the shell swaps compact/medium/expanded', (
        tester,
      ) async {
        await pumpApp(tester, size: const Size(599, 900));
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.text('Añadir vehículo'), findsOneWidget);

        tester.view.physicalSize = const Size(600, 900);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Añadir vehículo'), findsNothing);
        expect(find.byTooltip('Añadir coche'), findsOneWidget);

        tester.view.physicalSize = const Size(839, 900);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Selecciona un vehículo'), findsNothing);

        tester.view.physicalSize = const Size(840, 900);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Selecciona un vehículo'), findsOneWidget);
      });
    });

    group('maintenance detail placement', () {
      testWidgets(
        'given an expanded surface at /cars/1, when a timeline entry is '
        'opened, then the detail occupies the third column and the rail and '
        'garage list remain visible',
        (tester) async {
          final (router, _) = await pumpApp(
            tester,
            size: const Size(1200, 900),
            initial: '/cars/1',
            maintenance: buildMaintenance(id: 'm1', carId: '1'),
          );

          await tester.tap(find.text('Cambio de aceite'));
          await tester.pumpAndSettle();

          expect(find.text('Cambio de aceite'), findsOneWidget);
          expect(
            router.routeInformationProvider.value.uri.path,
            '/cars/1/maintenances/m1',
          );
          expect(find.byType(AppSidebar), findsOneWidget);
          expect(find.byType(GarageListContent), findsOneWidget);
          expect(find.byType(NavigationRail), findsOneWidget);
          expect(find.text('Historial de mantenimientos'), findsNothing);
          expect(find.text('Cambio de aceite'), findsOneWidget);

          final shellRow = find
              .byWidgetPredicate(
                (widget) =>
                    widget is Row &&
                    widget.children.any((child) => child is AppSidebar),
              )
              .first;
          final thirdColumn = find
              .descendant(
                of: shellRow,
                matching: find.byWidgetPredicate(
                  (widget) => widget is Expanded && widget.flex == 3,
                ),
              )
              .first;
          final detailRect = tester.getRect(find.text('Cambio de aceite'));
          final thirdRect = tester.getRect(thirdColumn);
          expect(detailRect.left, greaterThanOrEqualTo(thirdRect.left));
          expect(detailRect.right, lessThanOrEqualTo(thirdRect.right));

          final garageColumn = find.descendant(
            of: find.byType(GarageListContent),
            matching: find.text('Toyota Corolla'),
          );
          final selectedCar = tester.widget<Card>(
            find.ancestor(of: garageColumn, matching: find.byType(Card)),
          );
          final colorScheme = Theme.of(
            tester.element(garageColumn),
          ).colorScheme;
          expect(selectedCar.color, colorScheme.secondaryContainer);
        },
      );

      testWidgets(
        'given a medium surface at /cars/1, when a timeline entry is opened, '
        'then the detail fills the content column and the rail remains '
        'visible',
        (tester) async {
          final (router, _) = await pumpApp(
            tester,
            size: const Size(720, 900),
            initial: '/cars/1',
            maintenance: buildMaintenance(id: 'm1', carId: '1'),
          );

          await tester.tap(find.text('Cambio de aceite'));
          await tester.pumpAndSettle();

          expect(
            router.routeInformationProvider.value.uri.path,
            '/cars/1/maintenances/m1',
          );
          expect(find.byType(AppSidebar), findsOneWidget);
          expect(find.byType(NavigationRail), findsOneWidget);
          expect(find.byType(GarageListContent), findsNothing);
          expect(find.text('Historial de mantenimientos'), findsNothing);
          expect(find.text('Cambio de aceite'), findsOneWidget);
        },
      );

      testWidgets(
        'given a compact surface at /cars/1, when a timeline entry is opened, '
        'then the detail is full-screen and no rail is visible',
        (tester) async {
          final (router, _) = await pumpApp(
            tester,
            size: const Size(400, 900),
            initial: '/cars/1',
            maintenance: buildMaintenance(id: 'm1', carId: '1'),
          );

          await tester.tap(find.text('Cambio de aceite'));
          await tester.pumpAndSettle();

          expect(
            router.routeInformationProvider.value.uri.path,
            '/cars/1/maintenances/m1',
          );
          expect(find.byType(BackButton), findsOneWidget);
          expect(find.byType(NavigationRail), findsNothing);
          expect(find.byType(AppSidebar), findsNothing);
          expect(find.byType(GarageListContent), findsNothing);
          expect(find.text('Cambio de aceite'), findsOneWidget);
        },
      );

      testWidgets(
        'given an embedded maintenance detail reached from the history, when '
        'the back button is tapped, then /cars/1 and the history are restored',
        (tester) async {
          final (router, _) = await pumpApp(
            tester,
            size: const Size(1200, 900),
            initial: '/cars/1',
            maintenance: buildMaintenance(id: 'm1', carId: '1'),
          );
          await tester.tap(find.text('Cambio de aceite'));
          await tester.pumpAndSettle();

          await tester.tap(find.byType(BackButton));
          await tester.pumpAndSettle();

          expect(router.routeInformationProvider.value.uri.path, '/cars/1');
          expect(find.byType(NavigationRail), findsOneWidget);
          expect(find.byType(GarageListContent), findsOneWidget);
          expect(find.text('Historial de mantenimientos'), findsOneWidget);
        },
      );

      testWidgets(
        'given an embedded maintenance detail reached from the history, when '
        'system back is invoked, then /cars/1 and the shell chrome are '
        'restored',
        (tester) async {
          final (router, _) = await pumpApp(
            tester,
            size: const Size(1200, 900),
            initial: '/cars/1',
            maintenance: buildMaintenance(id: 'm1', carId: '1'),
          );
          await tester.tap(find.text('Cambio de aceite'));
          await tester.pumpAndSettle();

          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();

          expect(router.routeInformationProvider.value.uri.path, '/cars/1');
          expect(find.byType(NavigationRail), findsOneWidget);
          expect(find.byType(GarageListContent), findsOneWidget);
          expect(find.text('Historial de mantenimientos'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'given a cold maintenance deep link, when the back button is tapped, '
        'then the URL is /cars/1 and the shell chrome remains when applicable',
        (tester) async {
          final (router, _) = await pumpApp(
            tester,
            size: const Size(1200, 900),
            initial: '/cars/1/maintenances/m1',
            maintenance: buildMaintenance(id: 'm1', carId: '1'),
          );

          await tester.tap(find.byType(BackButton));
          await tester.pumpAndSettle();

          expect(router.routeInformationProvider.value.uri.path, '/cars/1');
          expect(find.byType(NavigationRail), findsOneWidget);
          expect(find.byType(GarageListContent), findsOneWidget);
        },
      );
    });

    group('expanded delete selected', () {
      testWidgets('given an expanded surface at /cars/1, when the car is '
          'deleted, then the URL goes back to / and the placeholder is '
          'shown', (tester) async {
        final (router, mockCarRepo) = await pumpApp(
          tester,
          size: const Size(1200, 900),
          initial: '/cars/1',
        );
        expect(find.text('Historial de mantenimientos'), findsOneWidget);

        await tester.tap(find.byTooltip('Eliminar vehículo'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        verify(() => mockCarRepo.delete(any())).called(1);
        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(find.text('Selecciona un vehículo'), findsOneWidget);
        expect(find.byType(NavigationRail), findsOneWidget);
      });
    });

    group('medium', () {
      testWidgets('given a medium surface at /, when pumped, then the rail '
          'and the car list are shown without the FAB', (tester) async {
        await pumpApp(tester, size: const Size(720, 900));

        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Toyota Corolla'), findsOneWidget);
        expect(find.text('Añadir vehículo'), findsNothing);
        expect(find.byTooltip('Añadir coche'), findsOneWidget);
      });

      testWidgets('given a medium surface, when a car is pushed, then the '
          'rail stays in place and the detail fills the second column', (
        tester,
      ) async {
        final (router, _) = await pumpApp(tester, size: const Size(720, 900));
        unawaited(router.push('/cars/1'));
        await tester.pumpAndSettle();

        expect(find.byType(BackButton), findsOneWidget);
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Historial de mantenimientos'), findsOneWidget);
      });
    });

    group('scroll preservation on medium', () {
      testWidgets('given a medium surface with a long garage, when the list '
          'is scrolled, a car is pushed and back returns, then the scroll '
          'offset survives the round trip', (tester) async {
        final cars = List.generate(
          30,
          (i) => buildCar(
            id: '$i',
            brand: 'Marca$i',
            model: 'Modelo$i',
            licensePlate: 'PLACA$i',
          ),
        );
        final (router, _) = await pumpApp(
          tester,
          size: const Size(720, 900),
          cars: cars,
        );

        await tester.drag(find.byType(ListView), const Offset(0, -600));
        await tester.pump();
        final scrolled = garageListOffset(tester);
        expect(scrolled, greaterThan(0));

        unawaited(router.push('/cars/5'));
        await tester.pumpAndSettle();
        expect(find.text('Historial de mantenimientos'), findsOneWidget);
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(garageListOffset(tester), closeTo(scrolled, 1));
      });
    });

    group('compact', () {
      testWidgets('given a compact surface at /, when pumped, then the full '
          'home scaffold is shown without a NavigationRail', (tester) async {
        await pumpApp(tester, size: const Size(400, 900));

        expect(find.text('Autobook'), findsOneWidget);
        expect(find.text('Añadir vehículo'), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.text('Toyota Corolla'), findsOneWidget);
      });

      testWidgets('given a compact surface at /cars/1, when pushed, then the '
          'car detail is shown with a back button', (tester) async {
        final (router, _) = await pumpApp(tester, size: const Size(400, 900));
        unawaited(router.push('/cars/1'));
        await tester.pumpAndSettle();

        expect(find.byType(BackButton), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
        expect(router.canPop(), isTrue);
      });

      testWidgets('given a compact surface cold-deep-linked to /cars/1, '
          'when the car is deleted, then the empty-stack fallback goes to /', (
        tester,
      ) async {
        final (router, mockCarRepo) = await pumpApp(
          tester,
          size: const Size(400, 900),
          initial: '/cars/1',
        );
        expect(router.canPop(), isFalse);

        await tester.tap(find.byTooltip('Eliminar vehículo'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        verify(() => mockCarRepo.delete(any())).called(1);
        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(find.text('Añadir vehículo'), findsOneWidget);
      });

      testWidgets('given a compact surface cold-deep-linked to /cars/1, '
          'when the system back is invoked, then the empty-stack fallback '
          'goes to /', (tester) async {
        final (router, _) = await pumpApp(
          tester,
          size: const Size(400, 900),
          initial: '/cars/1',
        );
        expect(router.canPop(), isFalse);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(find.text('Añadir vehículo'), findsOneWidget);
      });
    });

    group('resize while a dialog is open', () {
      testWidgets('given an expanded detail with the delete dialog open, '
          'when the surface shrinks to compact before confirming, then the '
          'delete flow navigates per the new layout', (tester) async {
        final (router, mockCarRepo) = await pumpApp(
          tester,
          size: const Size(1200, 900),
          initial: '/cars/1',
        );

        await tester.tap(find.byTooltip('Eliminar vehículo'));
        await tester.pumpAndSettle();
        expect(
          find.text('¿Seguro que quieres eliminar Toyota Corolla?'),
          findsOneWidget,
        );
        tester.view.physicalSize = const Size(400, 900);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        verify(() => mockCarRepo.delete(any())).called(1);
        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(find.text('Añadir vehículo'), findsOneWidget);
      });
    });

    group('maintenance cold deep link', () {
      testWidgets('given a cold start on a maintenance deep link, when the '
          'back button is tapped, then it pops to the embedded car detail '
          'without throwing', (tester) async {
        final (router, _) = await pumpApp(
          tester,
          size: const Size(400, 900),
          initial: '/cars/1/maintenances/m1',
        );
        expect(find.text('Cambio de aceite'), findsWidgets);

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        expect(router.routeInformationProvider.value.uri.path, '/cars/1');
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.text('Historial de mantenimientos'), findsOneWidget);
      });
    });
  });
}

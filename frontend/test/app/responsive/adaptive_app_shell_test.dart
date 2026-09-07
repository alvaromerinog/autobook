import 'dart:async';

import 'package:autobook/app/responsive/app_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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
        // given — an expanded surface (1200x900) with one car in the garage
        // when — the app is pumped at /
        await pumpApp(tester, size: const Size(1200, 900));

        // then — three columns in order: sidebar, list, placeholder
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
        // given — an expanded surface with one car
        // when — a car card is tapped
        final (router, _) = await pumpApp(tester, size: const Size(1200, 900));
        await tester.tap(find.text('Toyota Corolla'));
        await tester.pumpAndSettle();

        // then — URL updated and detail rendered embedded
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
        // given — an expanded surface cold-started on /cars/no-existe
        // when — the app is pumped
        await pumpApp(
          tester,
          size: const Size(1200, 900),
          initial: '/cars/no-existe',
        );

        // then
        expect(find.text('Vehículo no encontrado'), findsOneWidget);
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Toyota Corolla'), findsOneWidget);
      });

      testWidgets('given an expanded surface with two cars, when one is '
          'selected, then its card is highlighted and the other is not', (
        tester,
      ) async {
        // given — two cars in the garage
        // when — the second car is selected
        final (router, _) = await pumpApp(
          tester,
          size: const Size(1200, 900),
          cars: [toyotaCorolla, fordFocus],
        );
        await tester.tap(find.text('Ford Focus'));
        await tester.pumpAndSettle();

        // then — the selected card is tinted, the other is not
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
        // given — an expanded cold start at /cars/1
        final (router, _) = await pumpApp(
          tester,
          size: const Size(1200, 900),
          initial: '/cars/1',
        );
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(BackButton), findsNothing);

        // when — shrink to compact
        tester.view.physicalSize = const Size(400, 900);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpAndSettle();

        // then — full-screen detail with a back button
        expect(find.byType(BackButton), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);

        // when — grow back to expanded
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpAndSettle();

        // then — three columns with the same car still selected
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Historial de mantenimientos'), findsOneWidget);
        expect(router.routeInformationProvider.value.uri.path, '/cars/1');
      });

      testWidgets('given a car selected in expanded, when resized to '
          'medium and the back button is tapped, then the list is shown '
          'again', (tester) async {
        // given — a car selected in expanded (go replaces the stack)
        final (router, _) = await pumpApp(tester, size: const Size(1200, 900));
        await tester.tap(find.text('Toyota Corolla'));
        await tester.pumpAndSettle();
        expect(router.routeInformationProvider.value.uri.path, '/cars/1');

        // when — resize to medium (tablet vertical) and tap back
        tester.view.physicalSize = const Size(720, 900);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpAndSettle();

        // then — this is the empty-stack fallback path, so back must go to /
        expect(router.canPop(), isFalse);
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // then — back at / with the rail and the car list visible
        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Toyota Corolla'), findsOneWidget);
      });

      testWidgets('given a car pushed in medium, when the back button is '
          'tapped, then pop returns to the list', (tester) async {
        // given — a car detail pushed on a medium surface
        final (router, _) = await pumpApp(tester, size: const Size(720, 900));
        unawaited(router.push('/cars/1'));
        await tester.pumpAndSettle();
        expect(find.byType(BackButton), findsOneWidget);

        // when — the back button is tapped
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // then — popped back to the list
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
        // given — a compact surface (below 600) at /
        await pumpApp(tester, size: const Size(599, 900));
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.text('Añadir vehículo'), findsOneWidget);

        // when — grown to the first medium width
        tester.view.physicalSize = const Size(600, 900);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpAndSettle();

        // then — the rail replaces the FAB
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Añadir vehículo'), findsNothing);
        expect(find.byTooltip('Añadir coche'), findsOneWidget);

        // when — grown to the last medium width
        tester.view.physicalSize = const Size(839, 900);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpAndSettle();

        // then — still the two-column rail + list (no placeholder)
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Selecciona un vehículo'), findsNothing);

        // when — grown to the first expanded width
        tester.view.physicalSize = const Size(840, 900);
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpAndSettle();

        // then — the placeholder column appears
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Selecciona un vehículo'), findsOneWidget);
      });
    });

    group('maintenance push covers shell', () {
      testWidgets('given an expanded surface at /cars/1, when a timeline '
          'entry is opened, then the maintenance detail covers the three '
          'columns and pop returns to the shell', (tester) async {
        // given — an expanded cold start at /cars/1
        final (router, _) = await pumpApp(
          tester,
          size: const Size(1200, 900),
          initial: '/cars/1',
        );

        // when — tap the timeline entry (maintenance id m1)
        await tester.tap(find.text('Cambio de aceite'));
        await tester.pumpAndSettle();

        // then — full-screen detail, shell columns hidden
        expect(find.byType(BackButton), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.text('Añadir coche'), findsNothing);

        // when — pop back
        router.pop();
        await tester.pumpAndSettle();

        // then — three-column shell is back at /cars/1
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Historial de mantenimientos'), findsOneWidget);
      });
    });

    group('expanded delete selected', () {
      testWidgets('given an expanded surface at /cars/1, when the car is '
          'deleted, then the URL goes back to / and the placeholder is '
          'shown', (tester) async {
        // given — an expanded, non-embedded detail at /cars/1
        final (router, mockCarRepo) = await pumpApp(
          tester,
          size: const Size(1200, 900),
          initial: '/cars/1',
        );
        expect(find.text('Historial de mantenimientos'), findsOneWidget);

        // when — open the delete flow from the AppBar menu and confirm
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar vehículo'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        // then — delete called once, URL back to /, placeholder restored
        verify(() => mockCarRepo.delete(any())).called(1);
        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(find.text('Selecciona un vehículo'), findsOneWidget);
        expect(find.byType(NavigationRail), findsOneWidget);
      });
    });

    group('medium', () {
      testWidgets('given a medium surface at /, when pumped, then the rail '
          'and the car list are shown without the FAB', (tester) async {
        // given — a medium surface with one car
        // when — the app is pumped at /
        await pumpApp(tester, size: const Size(720, 900));

        // then
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Toyota Corolla'), findsOneWidget);
        expect(find.text('Añadir vehículo'), findsNothing);
        expect(find.byTooltip('Añadir coche'), findsOneWidget);
      });

      testWidgets('given a medium surface, when a car is pushed, then the '
          'rail stays in place and the detail fills the second column', (
        tester,
      ) async {
        // given — a medium surface with one car
        // when — the car detail is pushed
        final (router, _) = await pumpApp(tester, size: const Size(720, 900));
        unawaited(router.push('/cars/1'));
        await tester.pumpAndSettle();

        // then — the rail persists next to the detail pane
        expect(find.byType(BackButton), findsOneWidget);
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Historial de mantenimientos'), findsOneWidget);
      });
    });

    group('scroll preservation on medium', () {
      testWidgets('given a medium surface with a long garage, when the list '
          'is scrolled, a car is pushed and back returns, then the scroll '
          'offset survives the round trip', (tester) async {
        // given — a garage long enough to scroll on medium
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

        // when — the list is scrolled down
        await tester.drag(find.byType(ListView), const Offset(0, -600));
        await tester.pump();
        final scrolled = garageListOffset(tester);
        expect(scrolled, greaterThan(0));

        // and a car detail is pushed and popped
        unawaited(router.push('/cars/5'));
        await tester.pumpAndSettle();
        expect(find.text('Historial de mantenimientos'), findsOneWidget);
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // then — the same offset is restored
        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(garageListOffset(tester), closeTo(scrolled, 1));
      });
    });

    group('compact', () {
      testWidgets('given a compact surface at /, when pumped, then the full '
          'home scaffold is shown without a NavigationRail', (tester) async {
        // given — a compact surface with one car
        // when — the app is pumped at /
        await pumpApp(tester, size: const Size(400, 900));

        // then
        expect(find.text('Autobook'), findsOneWidget);
        expect(find.text('Añadir vehículo'), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.text('Toyota Corolla'), findsOneWidget);
      });

      testWidgets('given a compact surface at /cars/1, when pushed, then the '
          'car detail is shown with a back button', (tester) async {
        // given — a compact surface with one car
        // when — the car detail is pushed
        final (router, _) = await pumpApp(tester, size: const Size(400, 900));
        unawaited(router.push('/cars/1'));
        await tester.pumpAndSettle();

        // then
        expect(find.byType(BackButton), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
        // the detail pane is reachable through the back stack
        expect(router.canPop(), isTrue);
      });

      testWidgets('given a compact surface cold-deep-linked to /cars/1, '
          'when the car is deleted, then the empty-stack fallback goes to /', (
        tester,
      ) async {
        // given — a compact, single-page stack at /cars/1
        final (router, mockCarRepo) = await pumpApp(
          tester,
          size: const Size(400, 900),
          initial: '/cars/1',
        );
        expect(router.canPop(), isFalse);

        // when — the car is deleted through the AppBar menu
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar vehículo'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        // then — delete was called and the app fell back to /
        verify(() => mockCarRepo.delete(any())).called(1);
        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(find.text('Añadir vehículo'), findsOneWidget);
      });

      testWidgets('given a compact surface cold-deep-linked to /cars/1, '
          'when the system back is invoked, then the empty-stack fallback '
          'goes to /', (tester) async {
        // given — a compact, single-page stack at /cars/1
        final (router, _) = await pumpApp(
          tester,
          size: const Size(400, 900),
          initial: '/cars/1',
        );
        expect(router.canPop(), isFalse);

        // when — the system (hardware/web) back is dispatched
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        // then — the PopScope guard redirected to /
        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(find.text('Añadir vehículo'), findsOneWidget);
      });
    });

    group('resize while a dialog is open', () {
      testWidgets('given an expanded detail with the delete dialog open, '
          'when the surface shrinks to compact before confirming, then the '
          'delete flow navigates per the new layout', (tester) async {
        // given — an expanded, non-embedded detail at /cars/1
        final (router, mockCarRepo) = await pumpApp(
          tester,
          size: const Size(1200, 900),
          initial: '/cars/1',
        );

        // when — the delete dialog is opened and the surface shrinks to
        // compact while it is still open
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar vehículo'));
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

        // then — the size class is re-read after the flow, so on compact the
        // single-page stack falls back to /
        verify(() => mockCarRepo.delete(any())).called(1);
        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(find.text('Añadir vehículo'), findsOneWidget);
      });
    });

    group('maintenance cold deep link', () {
      testWidgets('given a cold start on a maintenance deep link, when the '
          'back button is tapped, then it falls back to / without throwing', (
        tester,
      ) async {
        // given — a compact, single-page stack at a maintenance deep link
        final (router, _) = await pumpApp(
          tester,
          size: const Size(400, 900),
          initial: '/cars/1/maintenances/m1',
        );
        expect(find.text('Cambio de aceite'), findsWidgets);

        // when — the back button is tapped
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // then — no GoError: the guard falls back to /
        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(find.text('Añadir vehículo'), findsOneWidget);
      });
    });
  });
}

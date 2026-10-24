import 'dart:async';

import 'package:autobook/features/vehicles/presentation/widgets/garage_list_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../features/maintenances/fixtures/maintenance_fixtures.dart';
import '../app_test_harness.dart';

void main() {
  setUpAll(() {
    registerAppHarnessFallbacks();
  });

  group('appRouter production routes', () {
    testWidgets(
      'given a cold maintenance deep link at compact, when the production '
      'router is pumped at 400px, then the detail is full-screen without a '
      'rail and the visible back control exists',
      (tester) async {
        final (router, _) = await pumpApp(
          tester,
          size: const Size(400, 900),
          initial: '/cars/1/maintenances/m1',
          maintenance: buildMaintenance(carId: '1'),
        );

        expect(
          router.routeInformationProvider.value.uri.path,
          '/cars/1/maintenances/m1',
        );
        expect(find.text('Cambio de aceite'), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byType(BackButton), findsOneWidget);
      },
    );

    testWidgets(
      'given a cold maintenance deep link at medium, when the production '
      'router is pumped at 720px, then the detail and NavigationRail are '
      'present in the shell',
      (tester) async {
        final (router, _) = await pumpApp(
          tester,
          size: const Size(720, 900),
          initial: '/cars/1/maintenances/m1',
          maintenance: buildMaintenance(carId: '1'),
        );

        expect(
          router.routeInformationProvider.value.uri.path,
          '/cars/1/maintenances/m1',
        );
        expect(find.text('Cambio de aceite'), findsOneWidget);
        expect(find.byType(NavigationRail), findsOneWidget);
      },
    );

    testWidgets(
      'given a cold maintenance deep link at expanded, when the production '
      'router is pumped at 1200px, then the detail and NavigationRail are '
      'present in the shell',
      (tester) async {
        final (router, _) = await pumpApp(
          tester,
          size: const Size(1200, 900),
          initial: '/cars/1/maintenances/m1',
          maintenance: buildMaintenance(carId: '1'),
        );

        expect(
          router.routeInformationProvider.value.uri.path,
          '/cars/1/maintenances/m1',
        );
        expect(find.text('Cambio de aceite'), findsOneWidget);
        expect(find.byType(NavigationRail), findsOneWidget);
      },
    );

    testWidgets(
      'given a cold maintenance deep link with no previous page, when system '
      'back is invoked, then the URL is /cars/1 rather than /',
      (tester) async {
        final (router, _) = await pumpApp(
          tester,
          size: const Size(400, 900),
          initial: '/cars/1/maintenances/m1',
          maintenance: buildMaintenance(carId: '1'),
        );

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(router.routeInformationProvider.value.uri.path, '/cars/1');
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'given the same maintenance URL is loaded again, when the router is '
      'recreated at that location, then carId, maintenanceId, and the same '
      'detail are selected',
      (tester) async {
        final (firstRouter, _) = await pumpApp(
          tester,
          size: const Size(1200, 900),
          initial: '/cars/1/maintenances/m1',
          maintenance: buildMaintenance(carId: '1'),
        );
        firstRouter.dispose();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();

        final (secondRouter, _) = await pumpApp(
          tester,
          size: const Size(1200, 900),
          initial: '/cars/1/maintenances/m1',
          maintenance: buildMaintenance(carId: '1'),
        );

        expect(
          secondRouter.routeInformationProvider.value.uri.path,
          '/cars/1/maintenances/m1',
        );
        expect(find.text('Cambio de aceite'), findsOneWidget);
        expect(find.byType(NavigationRail), findsOneWidget);
      },
    );
  });

  group('settings route', () {
    testWidgets(
      'given a cold settings load at compact, when the production router is '
      'pumped at 400px, then settings fills the screen without a rail or the '
      'garage placeholder and keeps a visible back action',
      (tester) async {
        final (router, _) = await pumpApp(
          tester,
          size: const Size(400, 900),
          initial: '/settings',
        );

        expect(router.routeInformationProvider.value.uri.path, '/settings');
        expect(find.text('Ajustes'), findsOneWidget);
        expect(find.text('Idioma'), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.text('Selecciona un vehículo'), findsNothing);
        expect(find.byType(GarageListContent), findsNothing);
        expect(find.byType(BackButton), findsOneWidget);
      },
    );

    testWidgets(
      'given a cold settings load at medium, when the production router is '
      'pumped at 720px, then the rail shows Settings selected and the garage '
      'list is replaced by settings content',
      (tester) async {
        final (router, _) = await pumpApp(
          tester,
          size: const Size(720, 900),
          initial: '/settings',
        );

        expect(router.routeInformationProvider.value.uri.path, '/settings');
        expect(find.text('Idioma'), findsOneWidget);
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(GarageListContent), findsNothing);
        expect(find.text('Selecciona un vehículo'), findsNothing);
        expect(find.text('Toyota Corolla'), findsNothing);
        final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
        expect(rail.selectedIndex, 1);
      },
    );

    testWidgets(
      'given a cold settings load at expanded, when the production router is '
      'pumped at 1200px, then settings occupies the content area without the '
      'garage list or the select-vehicle placeholder',
      (tester) async {
        final (router, _) = await pumpApp(
          tester,
          size: const Size(1200, 900),
          initial: '/settings',
        );

        expect(router.routeInformationProvider.value.uri.path, '/settings');
        expect(find.text('Idioma'), findsOneWidget);
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(GarageListContent), findsNothing);
        expect(find.text('Selecciona un vehículo'), findsNothing);
        expect(find.text('Toyota Corolla'), findsNothing);
        final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
        expect(rail.selectedIndex, 1);
      },
    );

    testWidgets(
      'given a cold car route at expanded, when pumped, then the garage '
      'destination stays selected instead of Settings',
      (tester) async {
        await pumpApp(tester, size: const Size(1200, 900), initial: '/cars/1');

        final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
        expect(rail.selectedIndex, 0);
      },
    );
  });

  group('settings entry points', () {
    testWidgets(
      'given the compact home, when the localized settings action is tapped, '
      'then settings opens',
      (tester) async {
        final (router, _) = await pumpApp(tester, size: const Size(400, 900));
        expect(find.byIcon(Icons.settings), findsOneWidget);

        await tester.tap(find.byTooltip('Ajustes'));
        await tester.pumpAndSettle();

        expect(router.routeInformationProvider.value.uri.path, '/settings');
        expect(find.text('Idioma'), findsOneWidget);
      },
    );

    testWidgets(
      'given the medium rail, when the settings destination is tapped, then '
      'settings opens',
      (tester) async {
        final (router, _) = await pumpApp(tester, size: const Size(720, 900));

        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();

        expect(router.routeInformationProvider.value.uri.path, '/settings');
        expect(find.text('Idioma'), findsOneWidget);
        expect(find.text('Español'), findsOneWidget);
      },
    );

    testWidgets(
      'given the expanded rail, when the settings destination is tapped, '
      'then settings opens',
      (tester) async {
        final (router, _) = await pumpApp(tester, size: const Size(1200, 900));

        await tester.tap(find.text('Ajustes'));
        await tester.pumpAndSettle();

        expect(router.routeInformationProvider.value.uri.path, '/settings');
        expect(find.text('Idioma'), findsOneWidget);
      },
    );

    testWidgets(
      'given settings at medium, when the garage destination is tapped, then '
      'the garage list returns',
      (tester) async {
        final (router, _) = await pumpApp(
          tester,
          size: const Size(720, 900),
          initial: '/settings',
        );

        await tester.tap(find.byIcon(Icons.garage));
        await tester.pumpAndSettle();

        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(find.byType(GarageListContent), findsOneWidget);
        expect(find.text('Toyota Corolla'), findsOneWidget);
        final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
        expect(rail.selectedIndex, 0);
      },
    );
  });

  group('settings back navigation', () {
    testWidgets(
      'given settings pushed from the garage at compact, when the back action '
      'is tapped, then the previous route is restored',
      (tester) async {
        final (router, _) = await pumpApp(tester, size: const Size(400, 900));
        unawaited(router.push('/settings'));
        await tester.pumpAndSettle();
        expect(router.canPop(), isTrue);
        expect(find.text('Idioma'), findsOneWidget);

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(find.text('Añadir vehículo'), findsOneWidget);
        expect(find.text('Toyota Corolla'), findsOneWidget);
      },
    );

    testWidgets(
      'given a cold settings load at compact with no previous page, when the '
      'back action is tapped, then the empty-stack fallback goes to /',
      (tester) async {
        final (router, _) = await pumpApp(
          tester,
          size: const Size(400, 900),
          initial: '/settings',
        );
        expect(router.canPop(), isFalse);

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(find.text('Añadir vehículo'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'given settings in Spanish at medium, when English is selected, then '
      'the locale switches while the route, rail selection and router state '
      'stay unchanged',
      (tester) async {
        final (router, _) = await pumpApp(
          tester,
          size: const Size(720, 900),
          initial: '/settings',
        );
        final routeInformation = router.routeInformationProvider;

        await tester.tap(find.text('English'));
        await tester.pumpAndSettle();

        expect(find.text('Language'), findsOneWidget);
        expect(find.text('Idioma'), findsNothing);
        expect(router.routeInformationProvider.value.uri.path, '/settings');
        expect(
          identical(router.routeInformationProvider, routeInformation),
          isTrue,
        );
        final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
        expect(rail.selectedIndex, 1);
      },
    );
  });
}

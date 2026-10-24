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
}

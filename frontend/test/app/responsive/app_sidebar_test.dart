import 'package:autobook/app/responsive/app_sidebar.dart';
import 'package:autobook/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Future<GoRouter> pumpSidebar(
  WidgetTester tester, {
  required bool extended,
  String initialLocation = '/',
}) async {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => _sidebarLayout(context, extended),
      ),
      GoRoute(
        path: '/cars/:carId',
        builder: (context, _) => _sidebarLayout(context, extended),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, _) => _sidebarLayout(context, extended),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

Widget _sidebarLayout(BuildContext context, bool extended) {
  final destination = GoRouterState.of(context).uri.path;
  return Scaffold(
    body: Row(
      children: [
        AppSidebar(extended: extended),
        const VerticalDivider(width: 1),
        Expanded(child: Center(child: Text(_pageLabel(destination)))),
      ],
    ),
  );
}

String _pageLabel(String destination) => switch (destination) {
  '/cars/1' => 'detail page',
  '/settings' => 'settings page',
  _ => 'garage page',
};

int? selectedIndex(WidgetTester tester) =>
    tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex;

void main() {
  group('AppSidebar', () {
    for (final extended in [false, true]) {
      group('extended: $extended', () {
        testWidgets('given the sidebar, when pumped, then the logo, the '
            'add-car action and both destinations are visible', (tester) async {
          await pumpSidebar(tester, extended: extended);

          expect(find.byType(NavigationRail), findsOneWidget);
          expect(find.text('Autobook'), findsOneWidget);
          expect(find.byIcon(Icons.directions_car), findsOneWidget);
          if (extended) {
            expect(find.text('Añadir coche'), findsOneWidget);
            expect(find.text('Garaje'), findsOneWidget);
            expect(find.text('Ajustes'), findsOneWidget);
          } else {
            expect(find.byTooltip('Añadir coche'), findsOneWidget);
            expect(find.byIcon(Icons.garage), findsOneWidget);
            expect(find.byIcon(Icons.settings), findsOneWidget);
          }
        });

        testWidgets('given the sidebar, when the add-car button is tapped, '
            'then the car dialog opens', (tester) async {
          await pumpSidebar(tester, extended: extended);
          if (extended) {
            await tester.tap(find.text('Añadir coche'));
          } else {
            await tester.tap(find.byTooltip('Añadir coche'));
          }
          await tester.pumpAndSettle();

          expect(find.text('Datos del vehículo'), findsOneWidget);
        });

        testWidgets('given the sidebar on /cars/x, when the garage '
            'destination is tapped, then the URL goes to /', (tester) async {
          final router = await pumpSidebar(
            tester,
            extended: extended,
            initialLocation: '/cars/1',
          );
          if (extended) {
            await tester.tap(find.text('Garaje'));
          } else {
            await tester.tap(find.byIcon(Icons.garage));
          }
          await tester.pumpAndSettle();

          expect(router.routeInformationProvider.value.uri.path, '/');
        });

        testWidgets('given the sidebar on /, when the settings destination '
            'is tapped, then the URL goes to /settings', (tester) async {
          final router = await pumpSidebar(tester, extended: extended);
          if (extended) {
            await tester.tap(find.text('Ajustes'));
          } else {
            await tester.tap(find.byIcon(Icons.settings));
          }
          await tester.pumpAndSettle();

          expect(router.routeInformationProvider.value.uri.path, '/settings');
        });

        testWidgets('given the sidebar on /settings, when the garage '
            'destination is tapped, then the URL goes to /', (tester) async {
          final router = await pumpSidebar(
            tester,
            extended: extended,
            initialLocation: '/settings',
          );
          if (extended) {
            await tester.tap(find.text('Garaje'));
          } else {
            await tester.tap(find.byIcon(Icons.garage));
          }
          await tester.pumpAndSettle();

          expect(router.routeInformationProvider.value.uri.path, '/');
        });

        testWidgets('given the sidebar on /settings, when pumped, then the '
            'settings destination is selected', (tester) async {
          await pumpSidebar(
            tester,
            extended: extended,
            initialLocation: '/settings',
          );

          expect(selectedIndex(tester), 1);
        });

        for (final location in ['/', '/cars/1']) {
          testWidgets('given the sidebar on $location, when pumped, then the '
              'garage destination is selected', (tester) async {
            await pumpSidebar(
              tester,
              extended: extended,
              initialLocation: location,
            );

            expect(selectedIndex(tester), 0);
          });
        }
      });
    }
  });
}

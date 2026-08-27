import 'package:autobook/app/responsive/app_sidebar.dart';
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
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

/// Renders the sidebar next to a placeholder page so the rail lives inside
/// the Navigator (where an Overlay is available for tooltips).
Widget _sidebarLayout(BuildContext context, bool extended) {
  final destination = GoRouterState.of(context).uri.path;
  return Scaffold(
    body: Row(
      children: [
        AppSidebar(extended: extended),
        const VerticalDivider(width: 1),
        Expanded(
          child: Center(
            child: Text(
              destination == '/cars/1' ? 'detail page' : 'garage page',
            ),
          ),
        ),
      ],
    ),
  );
}

void main() {
  group('AppSidebar', () {
    for (final extended in [false, true]) {
      group('extended: $extended', () {
        testWidgets('given the sidebar, when pumped, then the logo, the '
            'add-car button and the garage destination are visible', (
          tester,
        ) async {
          // when
          await pumpSidebar(tester, extended: extended);

          // then
          expect(find.byType(NavigationRail), findsOneWidget);
          expect(find.text('Autobook'), findsOneWidget);
          expect(find.byIcon(Icons.directions_car), findsOneWidget);
          if (extended) {
            expect(find.text('Añadir coche'), findsOneWidget);
            expect(find.text('Garaje'), findsOneWidget);
          } else {
            expect(find.byTooltip('Añadir coche'), findsOneWidget);
            expect(find.byIcon(Icons.garage), findsOneWidget);
          }
        });

        testWidgets('given the sidebar, when the add-car button is tapped, '
            'then the car dialog opens', (tester) async {
          // when
          await pumpSidebar(tester, extended: extended);
          if (extended) {
            await tester.tap(find.text('Añadir coche'));
          } else {
            await tester.tap(find.byTooltip('Añadir coche'));
          }
          await tester.pumpAndSettle();

          // then
          expect(find.text('Datos del vehículo'), findsOneWidget);
        });

        testWidgets('given the sidebar on /cars/x, when the garage '
            'destination is tapped, then the URL goes to /', (tester) async {
          // when
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

          // then
          expect(
            router.routeInformationProvider.value.uri.path,
            '/',
          );
        });
      });
    }
  });
}
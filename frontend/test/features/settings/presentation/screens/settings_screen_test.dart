import 'package:autobook/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/app_test_harness.dart';

Finder languageRow(String endonym) => find.widgetWithText(ListTile, endonym);

bool rowSelected(WidgetTester tester, String endonym) =>
    tester.widget<ListTile>(languageRow(endonym)).selected;

Finder rowIcon(String endonym, IconData icon) =>
    find.descendant(of: languageRow(endonym), matching: find.byIcon(icon));

Future<GoRouter> pumpSettings(
  WidgetTester tester, {
  Locale? locale = const Locale('es'),
  Map<String, Object> initialPreferences = const {},
}) async {
  final (router, _) = await pumpApp(
    tester,
    size: const Size(400, 900),
    initial: '/settings',
    locale: locale,
    initialPreferences: initialPreferences,
  );
  return router;
}

void main() {
  setUpAll(() {
    registerAppHarnessFallbacks();
  });

  group('SettingsScreen', () {
    group('language choices', () {
      testWidgets(
        'given no saved language, when settings is pumped, then the two '
        'endonyms appear in enum order, Spanish is selected, no system row '
        'is offered and there is no confirmation action',
        (tester) async {
          await pumpSettings(tester);

          expect(find.byType(SettingsScreen), findsOneWidget);
          expect(find.text('Ajustes'), findsOneWidget);
          expect(find.text('Idioma'), findsOneWidget);
          expect(find.text('Español'), findsOneWidget);
          expect(find.text('English'), findsOneWidget);
          expect(find.text('System'), findsNothing);
          expect(find.text('Sistema'), findsNothing);
          expect(find.text('Guardar cambios'), findsNothing);
          expect(find.text('Save changes'), findsNothing);
          expect(
            tester.getTopLeft(find.text('Español')).dy,
            lessThan(tester.getTopLeft(find.text('English')).dy),
          );
          expect(rowSelected(tester, 'Español'), isTrue);
          expect(rowSelected(tester, 'English'), isFalse);
          expect(
            rowIcon('Español', Icons.radio_button_checked),
            findsOneWidget,
          );
          expect(
            rowIcon('English', Icons.radio_button_unchecked),
            findsOneWidget,
          );
        },
      );

      for (final (systemLocale, selected, other) in [
        (const Locale('es'), 'Español', 'English'),
        (const Locale('en'), 'English', 'Español'),
      ]) {
        testWidgets('given no saved language and a system locale of '
            '${systemLocale.languageCode}, when settings is pumped, then the '
            'matching row is the effective selection', (tester) async {
          tester.platformDispatcher.localesTestValue = [systemLocale];
          addTearDown(tester.platformDispatcher.clearLocalesTestValue);

          await pumpSettings(tester, locale: null);

          expect(rowSelected(tester, selected), isTrue);
          expect(rowSelected(tester, other), isFalse);
        });
      }

      testWidgets(
        'given a saved English language, when settings is pumped with a '
        'Spanish default locale, then English is the effective selection and '
        'the labels are English',
        (tester) async {
          await pumpSettings(
            tester,
            initialPreferences: const {'app_language': 'en'},
          );

          expect(find.text('Settings'), findsOneWidget);
          expect(find.text('Language'), findsOneWidget);
          expect(rowSelected(tester, 'English'), isTrue);
          expect(rowSelected(tester, 'Español'), isFalse);
        },
      );
    });

    group('selecting a language', () {
      testWidgets(
        'given Spanish active, when Español is tapped, then Spanish labels '
        'remain, the choice is persisted and the route stays on settings',
        (tester) async {
          final router = await pumpSettings(tester);
          final preferences = await SharedPreferences.getInstance();

          await tester.tap(find.text('Español'));
          await tester.pump();

          expect(find.text('Ajustes'), findsOneWidget);
          expect(find.text('Idioma'), findsOneWidget);
          expect(preferences.getString('app_language'), 'es');
          expect(rowSelected(tester, 'Español'), isTrue);
          expect(router.routeInformationProvider.value.uri.path, '/settings');
        },
      );

      testWidgets(
        'given Spanish active, when English is tapped, then the surrounding '
        'labels switch immediately, the choice is persisted and the route is '
        'unchanged',
        (tester) async {
          final router = await pumpSettings(tester);
          final preferences = await SharedPreferences.getInstance();

          await tester.tap(find.text('English'));
          await tester.pumpAndSettle();

          expect(find.text('Settings'), findsOneWidget);
          expect(find.text('Language'), findsOneWidget);
          expect(find.text('Ajustes'), findsNothing);
          expect(find.text('Idioma'), findsNothing);
          expect(rowSelected(tester, 'English'), isTrue);
          expect(preferences.getString('app_language'), 'en');
          expect(router.routeInformationProvider.value.uri.path, '/settings');
        },
      );

      testWidgets(
        'given English restored from storage, when Español is tapped, then '
        'the labels switch back to Spanish immediately',
        (tester) async {
          await pumpSettings(
            tester,
            initialPreferences: const {'app_language': 'en'},
          );
          final preferences = await SharedPreferences.getInstance();

          await tester.tap(find.text('Español'));
          await tester.pumpAndSettle();

          expect(find.text('Ajustes'), findsOneWidget);
          expect(find.text('Idioma'), findsOneWidget);
          expect(preferences.getString('app_language'), 'es');
          expect(rowSelected(tester, 'Español'), isTrue);
        },
      );
    });

    group('back affordance', () {
      for (final width in [720.0, 1200.0]) {
        testWidgets(
          'given a cold settings load at ${width.toInt()}px, when pumped, '
          'then the rail is present and no leading back button is shown',
          (tester) async {
            await pumpApp(tester, size: Size(width, 900), initial: '/settings');

            expect(find.byType(SettingsScreen), findsOneWidget);
            expect(find.byType(NavigationRail), findsOneWidget);
            expect(find.byType(BackButton), findsNothing);
          },
        );
      }
    });
  });
}

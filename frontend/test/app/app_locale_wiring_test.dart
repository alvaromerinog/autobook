import 'dart:async';

import 'package:autobook/app/localization/app_language.dart';
import 'package:autobook/app/localization/app_locale_provider.dart';
import 'package:autobook/app/router/app_router.dart';
import 'package:autobook/core/di/shared_preferences_provider.dart';
import 'package:autobook/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _LocaleProbe extends StatefulWidget {
  const _LocaleProbe();

  @override
  State<_LocaleProbe> createState() => _LocaleProbeState();
}

class _LocaleProbeState extends State<_LocaleProbe> {
  @override
  Widget build(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return Scaffold(body: Text('probe:$code'));
  }
}

Future<SharedPreferences> mockPreferences(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

Future<(ProviderContainer, GoRouter)> pumpAutobook(
  WidgetTester tester, {
  required Future<SharedPreferences> preferences,
}) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [GoRoute(path: '/', builder: (_, __) => const _LocaleProbe())],
  );
  addTearDown(router.dispose);

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) => preferences),
      appRouterProvider().overrideWithValue(router),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const AutobookApp()),
  );
  return (container, router);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutobookApp locale wiring', () {
    testWidgets(
      'given the initial locale load, when AutobookApp is pumped, then no '
      'router content is rendered until the stored preference resolves',
      (tester) async {
        final preferences = Completer<SharedPreferences>();
        await pumpAutobook(tester, preferences: preferences.future);
        await tester.pump();

        expect(find.byType(_LocaleProbe), findsNothing);
        expect(find.textContaining('probe:'), findsNothing);
        expect(find.byType(Scaffold), findsNothing);

        preferences.complete(await mockPreferences({}));
        await tester.pumpAndSettle();

        expect(find.text('probe:en'), findsOneWidget);
      },
    );

    testWidgets(
      'given a stored Spanish override, when AutobookApp is pumped, then the '
      'router content localizes according to the restored preference',
      (tester) async {
        final preferences = await mockPreferences({'app_language': 'es'});
        await pumpAutobook(tester, preferences: Future.value(preferences));
        await tester.pumpAndSettle();

        expect(find.text('probe:es'), findsOneWidget);
      },
    );

    testWidgets(
      'given a stored Spanish override, when English is selected, then the '
      'locale switches without remounting the route or replacing the router',
      (tester) async {
        final preferences = await mockPreferences({'app_language': 'es'});
        final (container, router) = await pumpAutobook(
          tester,
          preferences: Future.value(preferences),
        );
        await tester.pumpAndSettle();
        final routeState = tester.state<_LocaleProbeState>(
          find.byType(_LocaleProbe),
        );

        await container
            .read(appLocaleProvider.notifier)
            .select(AppLanguage.english);
        await tester.pumpAndSettle();

        expect(find.text('probe:en'), findsOneWidget);
        expect(find.text('probe:es'), findsNothing);
        expect(
          identical(
            tester.state<_LocaleProbeState>(find.byType(_LocaleProbe)),
            routeState,
          ),
          isTrue,
        );
        expect(identical(container.read(appRouterProvider()), router), isTrue);
        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(preferences.getString('app_language'), 'en');
      },
    );
  });
}

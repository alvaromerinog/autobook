import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import '../app_test_harness.dart';

void main() {
  setUpAll(() {
    registerAppHarnessFallbacks();
  });

  group('appRouter production routes', () {
    testWidgets('given a cold start on a maintenance deep link, when '
        'pumped, then the maintenance detail renders from the production '
        'route table', (tester) async {
      // given — the production router started directly on the maintenance route
      // when — the app is pumped
      await pumpApp(tester, initial: '/cars/1/maintenances/m1');

      // then — the maintenance detail is rendered
      expect(find.text('Cambio de aceite'), findsOneWidget);
      expect(find.byTooltip('Editar'), findsOneWidget);
    });

    testWidgets('given a matching maintenance is cached, when the detail '
        'route is pushed, then the maintenance detail screen renders it', (
      tester,
    ) async {
      // given — the production router started at the garage
      final (router, _) = await pumpApp(tester);

      // when — the detail route is pushed
      unawaited(router.push<Object?>('/cars/1/maintenances/m1'));
      await tester.pumpAndSettle();

      // then — the detail renders on top of the shell
      expect(find.text('Cambio de aceite'), findsOneWidget);
      expect(find.byTooltip('Editar'), findsOneWidget);
    });
  });
}

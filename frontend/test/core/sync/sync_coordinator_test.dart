import 'dart:async';

import 'package:autobook/core/sync/sync_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncCoordinator', () {
    group('flush', () {
      test('given 2 registered callbacks and the first throws, '
          'when flush runs, '
          'then both callbacks run and the coordinator resets', () async {
        final coordinator = SyncCoordinator();
        var firstRan = false;
        var secondRan = false;
        coordinator.register(() async {
          firstRan = true;
          throw Exception('first failed');
        });
        coordinator.register(() async {
          secondRan = true;
        });

        await coordinator.flush();

        expect(firstRan, isTrue);
        expect(secondRan, isTrue);
      });

      test('given flush is already running, '
          'when flush is called again, '
          'then the second call is a no-op', () async {
        final coordinator = SyncCoordinator();
        var callCount = 0;
        final completer = Completer<void>();
        coordinator.register(() async {
          callCount++;
          await completer.future;
        });

        final flush1 = coordinator.flush();
        final flush2 = coordinator.flush();
        completer.complete();
        await Future.wait([flush1, flush2]);

        expect(callCount, 1);
      });
    });
  });
}

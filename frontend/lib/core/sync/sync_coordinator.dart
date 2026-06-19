import 'dart:async';
import 'dart:developer';

import 'package:autobook/core/network/connectivity_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_coordinator.g.dart';

@Riverpod(keepAlive: true)
SyncCoordinator syncCoordinator(Ref ref) {
  final coordinator = SyncCoordinator();
  final sub = ref.read(connectivityServiceProvider).connectivityChanges.listen((
    connected,
  ) {
    if (connected) {
      coordinator.flush().catchError((Object e) {
        log('Auto-sync flush failed', error: e);
      });
    }
  });
  ref.onDispose(sub.cancel);
  return coordinator;
}

class SyncCoordinator {
  final _flushCallbacks = <Future<void> Function()>[];
  bool _isFlushing = false;

  /// Registers a callback to be invoked when connectivity is restored.
  /// Returns a function that removes the callback.
  void Function() register(Future<void> Function() callback) {
    _flushCallbacks.add(callback);
    return () => _flushCallbacks.remove(callback);
  }

  Future<void> flush() async {
    if (_isFlushing) return;
    _isFlushing = true;
    try {
      for (final callback in [..._flushCallbacks]) {
        try {
          await callback();
        } catch (e) {
          log('Auto-sync callback failed', error: e);
        }
      }
    } finally {
      _isFlushing = false;
    }
  }
}

import 'dart:async';

import 'package:autobook/core/network/connectivity_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_coordinator.g.dart';

@Riverpod(keepAlive: true)
SyncCoordinator syncCoordinator(Ref ref) {
  final coordinator = SyncCoordinator();
  final sub = ref
      .read(connectivityServiceProvider)
      .connectivityChanges
      .listen((connected) {
    if (connected) coordinator.flush().catchError((_) {});
  });
  ref.onDispose(sub.cancel);
  return coordinator;
}

class SyncCoordinator {
  Future<void> Function()? _flushCallback;
  bool _isFlushing = false;

  void register(Future<void> Function() callback) {
    _flushCallback = callback;
  }

  void unregister() {
    _flushCallback = null;
  }

  Future<void> flush() async {
    if (_isFlushing) return;
    _isFlushing = true;
    try {
      await _flushCallback?.call();
    } finally {
      _isFlushing = false;
    }
  }
}

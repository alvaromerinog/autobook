import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) => ConnectivityService();

class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  Stream<bool> get connectivityChanges =>
      _connectivity.onConnectivityChanged.map(
        (results) => !results.contains(ConnectivityResult.none),
      );
}

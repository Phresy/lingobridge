import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// THIS MUST BE DEFINED for translation_screen.dart
enum ConnectivityStatus { online, offline, checking }

class ConnectivityState {
  final bool isConnected;
  final bool isChecking;

  const ConnectivityState({
    this.isConnected = true,
    this.isChecking = false,
  });

  ConnectivityState copyWith({
    bool? isConnected,
    bool? isChecking,
  }) {
    return ConnectivityState(
      isConnected: isConnected ?? this.isConnected,
      isChecking: isChecking ?? this.isChecking,
    );
  }
}

class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  ConnectivityNotifier() : super(const ConnectivityState(isChecking: true)) {
    _init();
  }

  final Connectivity _connectivity = Connectivity();

  Future<void> _init() async {
    final result = await _connectivity.checkConnectivity();
    _update(result);
    _connectivity.onConnectivityChanged.listen(_update);
  }

  void _update(List<ConnectivityResult> results) {
    final hasConnection = results.any((r) => r != ConnectivityResult.none);
    state = ConnectivityState(
      isConnected: hasConnection,
      isChecking: false,
    );
  }
}

final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityState>(
  (ref) => ConnectivityNotifier(),
);

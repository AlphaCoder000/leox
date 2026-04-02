import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to monitor network connectivity status
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  bool _isConnected = true;
  bool _isChecking = false;
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  
  bool get isConnected => _isConnected;
  bool get isChecking => _isChecking;

  /// Stream of connectivity changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    _isChecking = true;
    
    // Get initial connectivity status
    final initialResults = await _connectivity.checkConnectivity();
    _isConnected = !initialResults.contains(ConnectivityResult.none);
    _isChecking = false;
    
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final wasConnected = _isConnected;
        _isConnected = !results.contains(ConnectivityResult.none);
        
        // Only notify if status actually changed
        if (wasConnected != _isConnected) {
          _connectivityController.add(_isConnected);
        }
      },
    );
  }

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    _isChecking = true;
    try {
      final results = await _connectivity.checkConnectivity();
      _isConnected = !results.contains(ConnectivityResult.none);
      return _isConnected;
    } finally {
      _isChecking = false;
    }
  }

  /// Dispose the connectivity subscription
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }
}

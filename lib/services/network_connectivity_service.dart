import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Network Connectivity Service
/// Monitors network status and connection changes
///
/// Usage:
/// ```dart
/// final isOnline = await NetworkConnectivityService.isConnected();
/// NetworkConnectivityService.connectionStream.listen((isOnline) {
///   debugPrint('Network: ${isOnline ? 'Online' : 'Offline'}');
/// });
/// ```

class NetworkConnectivityService {
  static final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  static bool _isOnline = true;
  static Timer? _checkTimer;

  /// Get current connection status
  static bool get isConnected => _isOnline;

  /// Stream of connection status changes (true = online, false = offline)
  static Stream<bool> get connectionStream => _connectionController.stream;

  /// Initialize network monitoring
  /// Call this once during app startup
  static Future<void> initialize() async {
    // Set initial status (default to true, will be updated by checks)
    _isOnline = true;

    // Run periodic checks every 10 seconds
    _checkTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkConnection();
    });

    // Do an immediate check
    await _checkConnection();
  }

  /// Check current network connection
  static Future<void> _checkConnection() async {
    try {
      // Attempt a simple HTTP request to verify internet connectivity
      // Using Google's DNS server as reliability check
      final uri = Uri.parse('https://www.google.com');
      final request = await HttpClient()
          .headUrl(uri)
          .timeout(const Duration(seconds: 5));
      final response = await request.close();

      final newStatus = response.statusCode == 200;

      if (newStatus != _isOnline) {
        _isOnline = newStatus;
        _connectionController.add(_isOnline);
        debugPrint(
          '[NetworkConnectivity] Status changed: ${_isOnline ? 'Online' : 'Offline'}',
        );
      }
    } catch (e) {
      // If check fails, assume offline
      if (_isOnline) {
        _isOnline = false;
        _connectionController.add(false);
        debugPrint(
          '[NetworkConnectivity] Connection check failed, marking as offline: $e',
        );
      }
    }
  }

  /// Manual check for connection
  static Future<bool> checkConnection() async {
    await _checkConnection();
    return _isOnline;
  }

  /// Clean up resources
  static void dispose() {
    _checkTimer?.cancel();
    _connectionController.close();
  }
}

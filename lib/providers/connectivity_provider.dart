import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';

/// Provider to manage network connectivity state across the app
class ConnectivityProvider extends ChangeNotifier {
  final ConnectivityService _connectivityService = ConnectivityService();
  
  bool _isConnected = true;
  bool _isChecking = false;
  String _connectionStatus = 'Unknown';
  
  bool get isConnected => _isConnected;
  bool get isChecking => _isChecking;
  String get connectionStatus => _connectionStatus;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    _isChecking = true;
    notifyListeners();
    
    await _connectivityService.initialize();
    
    // Get initial status
    _isConnected = _connectivityService.isConnected;
    _updateConnectionStatus();
    
    // Listen to connectivity changes
    _connectivityService.connectivityStream.listen((isConnected) {
      _isConnected = isConnected;
      _updateConnectionStatus();
      notifyListeners();
    });
    
    _isChecking = false;
    notifyListeners();
  }

  /// Manually check connectivity
  Future<void> checkConnectivity() async {
    _isChecking = true;
    notifyListeners();
    
    _isConnected = await _connectivityService.checkConnectivity();
    _updateConnectionStatus();
    
    _isChecking = false;
    notifyListeners();
  }

  /// Update connection status message
  void _updateConnectionStatus() {
    if (_isConnected) {
      _connectionStatus = 'Connected';
    } else {
      _connectionStatus = 'No Internet';
    }
  }

  /// Show connectivity snackbar
  void showConnectivitySnackBar(BuildContext context) {
    if (_isConnected) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Internet connection restored'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 12),
              Text('No internet connection'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }
}

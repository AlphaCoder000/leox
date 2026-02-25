import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  StreamSubscription? _subscription;
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  NotificationProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _init();
      } else {
        _cleanup();
        notifyListeners();
      }
    });
  }

  void refresh() {
    _init();
  }

  void _init() {
    _subscription?.cancel();
    
    _isLoading = true;
    notifyListeners();
    
    _subscription = _notificationService.getNotifications().listen((list) {
      _notifications = list;
      _unreadCount = list.where((n) => !n.isRead).length;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('[NotificationProvider] Error: $e');
      _isLoading = false;
      notifyListeners();
    });
  }

  void _cleanup() {
    _subscription?.cancel();
    _subscription = null;
    _notifications = [];
    _unreadCount = 0;
    _isLoading = false;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> markAsRead(String id) async {
    await _notificationService.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
  }

  Future<void> deleteNotification(String id) async {
    await _notificationService.deleteNotification(id);
  }
}

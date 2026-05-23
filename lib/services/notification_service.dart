import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Send a notification to a specific user
  Future<void> sendNotification({
    required String recipientId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic> data = const {},
  }) async {
    try {
      final docRef = kIsWeb
          ? _firestore.collection('users').doc(recipientId).collection('notifications').doc()
          : _firestore.collection('notifications').doc();
      final notification = NotificationModel(
        id: docRef.id,
        userId: recipientId,
        title: title,
        message: message,
        type: type,
        createdAt: DateTime.now(),
        data: data,
      );

      await docRef.set(notification.toFirestore());
      debugPrint('[NotificationService] Notification successfully sent to recipient: $recipientId (Doc ID: ${docRef.id})');
    } catch (e) {
      debugPrint('[NotificationService] Error sending notification: $e');
    }
  }

  /// Get stream of notifications for current user
  Stream<List<NotificationModel>> getNotifications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    try {
      final query = kIsWeb
          ? _firestore.collection('users').doc(user.uid).collection('notifications')
          : _firestore.collection('notifications').where('userId', isEqualTo: user.uid);

      return query
          .snapshots()
          .map((snapshot) {
            try {
              final list = snapshot.docs
                  .map((doc) => NotificationModel.fromFirestore(doc))
                  .toList();
              // Sort in-memory to avoid index requirement
              list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              return list;
            } catch (e) {
              debugPrint('[NotificationService] Error mapping notifications: $e');
              return <NotificationModel>[];
            }
          })
          .handleError((error) {
            debugPrint('[NotificationService] Error in notifications stream: $error');
            return <NotificationModel>[];
          });
    } catch (e) {
      debugPrint('[NotificationService] Error starting notifications stream: $e');
      return Stream.value([]);
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      final docRef = kIsWeb
          ? _firestore.collection('users').doc(user.uid).collection('notifications').doc(notificationId)
          : _firestore.collection('notifications').doc(notificationId);
      await docRef.update({'isRead': true});
    } catch (e) {
      debugPrint('[NotificationService] Error marking as read: $e');
    }
  }

  /// Mark all notifications as read for current user
  Future<void> markAllAsRead() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final query = kIsWeb
          ? _firestore.collection('users').doc(user.uid).collection('notifications').where('isRead', isEqualTo: false)
          : _firestore.collection('notifications').where('userId', isEqualTo: user.uid).where('isRead', isEqualTo: false);

      final snapshot = await query.get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('[NotificationService] Error marking all as read: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      final docRef = kIsWeb
          ? _firestore.collection('users').doc(user.uid).collection('notifications').doc(notificationId)
          : _firestore.collection('notifications').doc(notificationId);
      await docRef.delete();
    } catch (e) {
      debugPrint('[NotificationService] Error deleting notification: $e');
    }
  }
}

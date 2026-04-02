import 'package:flutter_test/flutter_test.dart';
import 'package:leox/models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('NotificationModel', () {
    test('Constructor should initialize fields', () {
      final now = DateTime.now();
      final notification = NotificationModel(
        id: 'n1',
        userId: 'u1',
        title: 'New Message',
        message: 'You have a message',
        type: 'message',
        createdAt: now,
      );

      expect(notification.isRead, false);
      expect(notification.data, isEmpty);
      expect(notification.id, 'n1');
    });

    test('toFirestore should serialize correctly', () {
      final timestamp = DateTime.utc(2024, 1, 1);
      final notification = NotificationModel(
        id: 'n1',
        userId: 'u1',
        title: 'Hello',
        message: 'World',
        type: 'alert',
        createdAt: timestamp,
        isRead: true,
        data: {'jobId': 'job_123'},
      );

      final map = notification.toFirestore();
      
      expect(map['userId'], 'u1');
      expect(map['title'], 'Hello');
      expect(map['message'], 'World');
      expect(map['type'], 'alert');
      expect(map['isRead'], true);
      expect(map['data'], {'jobId': 'job_123'});
      expect(map['createdAt'], isA<Timestamp>());
    });
  });
}

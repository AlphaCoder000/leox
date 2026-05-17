import 'package:flutter_test/flutter_test.dart';
import 'package:leox/maintenance_contracts/models/mc_review_model.dart';

void main() {
  group('McReviewModel Tests', () {
    test('should initialize with correct values', () {
      final now = DateTime.now();
      final review = McReviewModel(
        id: 'rev_123',
        seekerId: 'seeker_abc',
        providerId: 'provider_xyz',
        serviceId: 'service_789',
        rating: 4.5,
        comment: 'Great service! Plumber arrived right on time.',
        dateTime: now,
        seekerName: 'John Doe',
        serviceTitle: 'Plumbing Repair',
      );

      expect(review.id, 'rev_123');
      expect(review.seekerId, 'seeker_abc');
      expect(review.providerId, 'provider_xyz');
      expect(review.serviceId, 'service_789');
      expect(review.rating, 4.5);
      expect(review.comment, 'Great service! Plumber arrived right on time.');
      expect(review.dateTime, now);
      expect(review.seekerName, 'John Doe');
      expect(review.serviceTitle, 'Plumbing Repair');
    });

    test('should parse correctly from json using fromJson', () {
      final dateTimeStr = '2026-05-17T14:30:00.000Z';
      final json = {
        'seekerId': 'seeker_abc',
        'providerId': 'provider_xyz',
        'serviceId': 'service_789',
        'rating': 5, // Test integer JSON parsing
        'comment': 'Stellar HVAC installation!',
        'dateTime': dateTimeStr,
        'seekerName': 'Jane Smith',
        'serviceTitle': 'HVAC Installation',
      };

      final review = McReviewModel.fromJson(json, 'rev_789');

      expect(review.id, 'rev_789');
      expect(review.seekerId, 'seeker_abc');
      expect(review.providerId, 'provider_xyz');
      expect(review.serviceId, 'service_789');
      expect(review.rating, 5.0);
      expect(review.comment, 'Stellar HVAC installation!');
      expect(review.dateTime, DateTime.parse(dateTimeStr));
      expect(review.seekerName, 'Jane Smith');
      expect(review.serviceTitle, 'HVAC Installation');
    });

    test('should handle missing and null fields in fromJson', () {
      final json = <String, dynamic>{};
      final review = McReviewModel.fromJson(json, 'rev_empty');

      expect(review.id, 'rev_empty');
      expect(review.seekerId, '');
      expect(review.providerId, '');
      expect(review.serviceId, '');
      expect(review.rating, 0.0);
      expect(review.comment, '');
      expect(review.dateTime, isNotNull); // Defaults to DateTime.now()
      expect(review.seekerName, '');
      expect(review.serviceTitle, '');
    });

    test('should serialize correctly to json using toJson', () {
      final now = DateTime.utc(2026, 5, 17, 14, 30, 0);
      final review = McReviewModel(
        id: 'rev_999',
        seekerId: 'seeker_abc',
        providerId: 'provider_xyz',
        serviceId: 'service_789',
        rating: 4.8,
        comment: 'Very professional electrical rewiring.',
        dateTime: now,
        seekerName: 'Bruce Wayne',
        serviceTitle: 'Electrical Rewiring',
      );

      final json = review.toJson();

      expect(json['seekerId'], 'seeker_abc');
      expect(json['providerId'], 'provider_xyz');
      expect(json['serviceId'], 'service_789');
      expect(json['rating'], 4.8);
      expect(json['comment'], 'Very professional electrical rewiring.');
      expect(json['dateTime'], '2026-05-17T14:30:00.000Z');
      expect(json['seekerName'], 'Bruce Wayne');
      expect(json['serviceTitle'], 'Electrical Rewiring');
      expect(json.containsKey('id'), false);
    });
  });
}

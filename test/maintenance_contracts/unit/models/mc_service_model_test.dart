import 'package:flutter_test/flutter_test.dart';
import 'package:leox/maintenance_contracts/models/mc_service_model.dart';

void main() {
  group('McServiceModel Tests', () {
    test('should initialize with correct values', () {
      final service = McServiceModel(
        id: 'srv_123',
        title: 'Monthly AC Cleaning',
        description: 'Complete filter wash and cooling gas top-up',
        category: 'HVAC',
        price: 75.0,
        providerId: 'prov_abc',
        status: 'active',
      );

      expect(service.id, 'srv_123');
      expect(service.title, 'Monthly AC Cleaning');
      expect(service.description, 'Complete filter wash and cooling gas top-up');
      expect(service.category, 'HVAC');
      expect(service.price, 75.0);
      expect(service.providerId, 'prov_abc');
      expect(service.status, 'active');
    });

    test('should fall back to defaults in constructor', () {
      final service = McServiceModel(
        id: 'srv_456',
        title: 'Home Gardening',
        description: 'Lawn trimming and weed control',
        category: 'Gardening',
        price: 50.0,
        providerId: 'prov_xyz',
      );

      expect(service.status, 'active');
    });

    test('should parse correctly from json using fromJson', () {
      final json = {
        'title': 'Deep Cleaning Package',
        'description': 'Kitchen and living area deep cleaning',
        'category': 'Cleaning',
        'price': 150, // Test int handling conversion to double
        'providerId': 'prov_789',
        'status': 'inactive',
      };

      final service = McServiceModel.fromJson(json, 'srv_789');

      expect(service.id, 'srv_789');
      expect(service.title, 'Deep Cleaning Package');
      expect(service.description, 'Kitchen and living area deep cleaning');
      expect(service.category, 'Cleaning');
      expect(service.price, 150.0);
      expect(service.providerId, 'prov_789');
      expect(service.status, 'inactive');
    });

    test('should handle missing and null fields in fromJson', () {
      final json = <String, dynamic>{};
      final service = McServiceModel.fromJson(json, 'srv_empty');

      expect(service.id, 'srv_empty');
      expect(service.title, '');
      expect(service.description, '');
      expect(service.category, '');
      expect(service.price, 0.0);
      expect(service.providerId, '');
      expect(service.status, 'active');
    });

    test('should serialize correctly to json using toJson', () {
      final service = McServiceModel(
        id: 'srv_999',
        title: 'CCTV Installation',
        description: '8-channel camera setup with cloud storage DVR',
        category: 'Security',
        price: 499.99,
        providerId: 'prov_abc',
        status: 'completed',
      );

      final json = service.toJson();

      expect(json['title'], 'CCTV Installation');
      expect(json['description'], '8-channel camera setup with cloud storage DVR');
      expect(json['category'], 'Security');
      expect(json['price'], 499.99);
      expect(json['providerId'], 'prov_abc');
      expect(json['status'], 'completed');
      expect(json.containsKey('id'), false);
    });
  });
}

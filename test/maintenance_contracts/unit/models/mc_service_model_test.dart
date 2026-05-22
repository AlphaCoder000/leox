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
        priceRange: '₹50 - ₹100',
        priceJustification: 'Depends on gas consumption and AC capacity',
        providerId: 'prov_abc',
        status: 'active',
      );

      expect(service.id, 'srv_123');
      expect(service.title, 'Monthly AC Cleaning');
      expect(service.description, 'Complete filter wash and cooling gas top-up');
      expect(service.category, 'HVAC');
      expect(service.price, 75.0);
      expect(service.priceRange, '₹50 - ₹100');
      expect(service.priceJustification, 'Depends on gas consumption and AC capacity');
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
        priceRange: '₹30 - ₹70',
        priceJustification: 'Depends on garden size',
        providerId: 'prov_xyz',
      );

      expect(service.status, 'active');
      expect(service.priceRange, '₹30 - ₹70');
      expect(service.priceJustification, 'Depends on garden size');
    });

    test('should parse correctly from json using fromJson', () {
      final json = {
        'title': 'Deep Cleaning Package',
        'description': 'Kitchen and living area deep cleaning',
        'category': 'Cleaning',
        'price': 150, // Test int handling conversion to double
        'priceRange': '₹100 - ₹200',
        'priceJustification': 'Depends on rooms and dirt level',
        'providerId': 'prov_789',
        'status': 'inactive',
      };

      final service = McServiceModel.fromJson(json, 'srv_789');

      expect(service.id, 'srv_789');
      expect(service.title, 'Deep Cleaning Package');
      expect(service.description, 'Kitchen and living area deep cleaning');
      expect(service.category, 'Cleaning');
      expect(service.price, 150.0);
      expect(service.priceRange, '₹100 - ₹200');
      expect(service.priceJustification, 'Depends on rooms and dirt level');
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
      expect(service.priceRange, '');
      expect(service.priceJustification, '');
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
        priceRange: '₹400 - ₹600',
        priceJustification: 'Depends on the number of cameras and cable length',
        providerId: 'prov_abc',
        status: 'completed',
      );

      final json = service.toJson();

      expect(json['title'], 'CCTV Installation');
      expect(json['description'], '8-channel camera setup with cloud storage DVR');
      expect(json['category'], 'Security');
      expect(json['price'], 499.99);
      expect(json['priceRange'], '₹400 - ₹600');
      expect(json['priceJustification'], 'Depends on the number of cameras and cable length');
      expect(json['providerId'], 'prov_abc');
      expect(json['status'], 'completed');
      expect(json.containsKey('id'), false);
    });
   group('Price Parsing and Fallback Tests', () {
      test('should fall back to parsing legacy double when parsing range', () {
        final json = {
          'title': 'Legacy Service',
          'description': 'Legacy Description',
          'category': 'Legacy',
          'price': 150.0,
          'providerId': 'prov_leg',
        };

        final service = McServiceModel.fromJson(json, 'srv_leg');
        expect(service.price, 150.0);
        expect(service.priceRange, '');
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:leox/maintenance_contracts/models/mc_provider_model.dart';

void main() {
  group('McProviderModel Tests', () {
    test('should initialize with correct values', () {
      final provider = McProviderModel(
        id: 'prov_123',
        companyName: 'Super Plumbers Inc',
        email: 'info@superplumbers.com',
        phone: '+1234567890',
        location: 'New York, NY',
        rating: 4.8,
        profilePicture: 'https://example.com/pic.jpg',
      );

      expect(provider.id, 'prov_123');
      expect(provider.companyName, 'Super Plumbers Inc');
      expect(provider.email, 'info@superplumbers.com');
      expect(provider.phone, '+1234567890');
      expect(provider.location, 'New York, NY');
      expect(provider.rating, 4.8);
      expect(provider.profilePicture, 'https://example.com/pic.jpg');
    });

    test('should fall back to default values in constructor', () {
      final provider = McProviderModel(
        id: 'prov_456',
        companyName: 'AC Techs',
        email: 'ac@techs.com',
        phone: '+987654321',
        location: 'Miami, FL',
      );

      expect(provider.rating, 0.0);
      expect(provider.profilePicture, '');
    });

    test('should parse correctly from json using fromJson', () {
      final json = {
        'companyName': 'Electricians R Us',
        'email': 'contact@eru.com',
        'phone': '+1122334455',
        'location': 'Austin, TX',
        'rating': 4.5,
        'profilePicture': 'https://example.com/elec.png',
      };

      final provider = McProviderModel.fromJson(json, 'prov_789');

      expect(provider.id, 'prov_789');
      expect(provider.companyName, 'Electricians R Us');
      expect(provider.email, 'contact@eru.com');
      expect(provider.phone, '+1122334455');
      expect(provider.location, 'Austin, TX');
      expect(provider.rating, 4.5);
      expect(provider.profilePicture, 'https://example.com/elec.png');
    });

    test('should handle missing and null fields in fromJson', () {
      final json = <String, dynamic>{};
      final provider = McProviderModel.fromJson(json, 'prov_empty');

      expect(provider.id, 'prov_empty');
      expect(provider.companyName, '');
      expect(provider.email, '');
      expect(provider.phone, '');
      expect(provider.location, '');
      expect(provider.rating, 0.0);
      expect(provider.profilePicture, '');
    });

    test('should serialize correctly to json using toJson', () {
      final provider = McProviderModel(
        id: 'prov_999',
        companyName: 'Roofing Pros',
        email: 'roofing@pros.com',
        phone: '+999999999',
        location: 'Los Angeles, CA',
        rating: 4.9,
        profilePicture: 'https://example.com/roof.jpg',
      );

      final json = provider.toJson();

      expect(json['companyName'], 'Roofing Pros');
      expect(json['email'], 'roofing@pros.com');
      expect(json['phone'], '+999999999');
      expect(json['location'], 'Los Angeles, CA');
      expect(json['rating'], 4.9);
      expect(json['profilePicture'], 'https://example.com/roof.jpg');
      // ID should not be in the toJson map, as it's typically stored as the doc ID in Firestore
      expect(json.containsKey('id'), false);
    });
  });
}

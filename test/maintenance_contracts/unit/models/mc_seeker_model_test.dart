import 'package:flutter_test/flutter_test.dart';
import 'package:leox/maintenance_contracts/models/mc_seeker_model.dart';

void main() {
  group('McSeekerModel Tests', () {
    test('should initialize with correct values', () {
      final seeker = McSeekerModel(
        id: 'seeker_123',
        userName: 'Alice Smith',
        email: 'alice@gmail.com',
        phone: '+14155552671',
        address: '456 Main St, San Francisco, CA',
        profilePicture: 'https://example.com/alice.jpg',
      );

      expect(seeker.id, 'seeker_123');
      expect(seeker.userName, 'Alice Smith');
      expect(seeker.email, 'alice@gmail.com');
      expect(seeker.phone, '+14155552671');
      expect(seeker.address, '456 Main St, San Francisco, CA');
      expect(seeker.profilePicture, 'https://example.com/alice.jpg');
    });

    test('should fall back to empty profilePicture in constructor', () {
      final seeker = McSeekerModel(
        id: 'seeker_456',
        userName: 'Bob Jones',
        email: 'bob@gmail.com',
        phone: '+14155550000',
        address: '789 Oak Ave, San Francisco, CA',
      );

      expect(seeker.profilePicture, '');
    });

    test('should parse correctly from json using fromJson', () {
      final json = {
        'userName': 'Charlie Brown',
        'email': 'charlie@gmail.com',
        'phone': '+14155551111',
        'address': '101 Pine Rd, San Francisco, CA',
        'profilePicture': 'https://example.com/charlie.jpg',
      };

      final seeker = McSeekerModel.fromJson(json, 'seeker_789');

      expect(seeker.id, 'seeker_789');
      expect(seeker.userName, 'Charlie Brown');
      expect(seeker.email, 'charlie@gmail.com');
      expect(seeker.phone, '+14155551111');
      expect(seeker.address, '101 Pine Rd, San Francisco, CA');
      expect(seeker.profilePicture, 'https://example.com/charlie.jpg');
    });

    test('should handle missing and null fields in fromJson', () {
      final json = <String, dynamic>{};
      final seeker = McSeekerModel.fromJson(json, 'seeker_empty');

      expect(seeker.id, 'seeker_empty');
      expect(seeker.userName, '');
      expect(seeker.email, '');
      expect(seeker.phone, '');
      expect(seeker.address, '');
      expect(seeker.profilePicture, '');
    });

    test('should serialize correctly to json using toJson', () {
      final seeker = McSeekerModel(
        id: 'seeker_999',
        userName: 'Diana Prince',
        email: 'diana@gmail.com',
        phone: '+14155559999',
        address: '1 Themyscira Way',
        profilePicture: 'https://example.com/diana.jpg',
      );

      final json = seeker.toJson();

      expect(json['userName'], 'Diana Prince');
      expect(json['email'], 'diana@gmail.com');
      expect(json['phone'], '+14155559999');
      expect(json['address'], '1 Themyscira Way');
      expect(json['profilePicture'], 'https://example.com/diana.jpg');
      expect(json.containsKey('id'), false);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:leox/models/employer_profile_model.dart';

void main() {
  group('EmployerProfileModel', () {
    test('Constructor should initialize fields correctly', () {
      final model = EmployerProfileModel(
        name: 'Jane Smith',
        email: 'jane@company.com',
        phone: '1234567890',
        companyName: 'Tech Corp',
        profilePicture: 'pic.jpg',
        contactNumber: '0987654321',
        address: '123 Main St',
        linkedin: 'linkedin.com/in/jane',
      );

      expect(model.name, 'Jane Smith');
      expect(model.email, 'jane@company.com');
      expect(model.phone, '1234567890');
      expect(model.companyName, 'Tech Corp');
      expect(model.profilePicture, 'pic.jpg');
      expect(model.contactNumber, '0987654321');
      expect(model.address, '123 Main St');
      expect(model.linkedin, 'linkedin.com/in/jane');
    });

    test('fromJson() should correctly parse JSON data', () {
      final json = {
        'name': 'Jane Smith',
        'email': 'jane@company.com',
        'phone': '1234567890',
        'companyName': 'Tech Corp',
        'address': '123 Main St', // tests address parsed properly
      };

      final model = EmployerProfileModel.fromJson(json);

      expect(model.name, 'Jane Smith');
      expect(model.email, 'jane@company.com');
      expect(model.companyName, 'Tech Corp');
      expect(model.address, '123 Main St');
      expect(model.profilePicture, isNull);
    });

    test('fromJson() should fall back to location if address is missing', () {
      final json = {
        'name': 'Jane Smith',
        'email': 'jane@company.com',
        'phone': '1234567890',
        'companyName': 'Tech Corp',
        'location': '456 Alternate St', // address is null, location exists
      };

      final model = EmployerProfileModel.fromJson(json);
      expect(model.address, '456 Alternate St');
    });

    test('toJson() should correctly serialize data and ignore nulls', () {
      final model = EmployerProfileModel(
        name: 'Jane Smith',
        email: 'jane@company.com',
        phone: '1234567890',
        companyName: 'Tech Corp',
        address: '123 Main St',
        // other optionals are null
      );

      final json = model.toJson();

      expect(json['name'], 'Jane Smith');
      expect(json['email'], 'jane@company.com');
      expect(json['companyName'], 'Tech Corp');
      expect(json['address'], '123 Main St');
      expect(json.containsKey('profilePicture'), isFalse);
    });
  });
}

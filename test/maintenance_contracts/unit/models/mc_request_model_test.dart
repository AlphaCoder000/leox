import 'package:flutter_test/flutter_test.dart';
import 'package:leox/maintenance_contracts/models/mc_request_model.dart';

void main() {
  group('McRequestModel Tests', () {
    test('should initialize with correct values', () {
      final now = DateTime.now();
      final request = McRequestModel(
        id: 'req_123',
        seekerId: 'seeker_abc',
        providerId: 'provider_xyz',
        serviceId: 'service_789',
        status: 'pending',
        dateTime: now,
        seekerName: 'John Doe',
        seekerPhone: '+1122334455',
        seekerAddress: '123 Elm St',
        message: 'Need help fixing the toilet leak',
      );

      expect(request.id, 'req_123');
      expect(request.seekerId, 'seeker_abc');
      expect(request.providerId, 'provider_xyz');
      expect(request.serviceId, 'service_789');
      expect(request.status, 'pending');
      expect(request.dateTime, now);
      expect(request.seekerName, 'John Doe');
      expect(request.seekerPhone, '+1122334455');
      expect(request.seekerAddress, '123 Elm St');
      expect(request.message, 'Need help fixing the toilet leak');
    });

    test('should fall back to defaults in constructor', () {
      final now = DateTime.now();
      final request = McRequestModel(
        id: 'req_456',
        seekerId: 'seeker_abc',
        providerId: 'provider_xyz',
        serviceId: 'service_789',
        dateTime: now,
      );

      expect(request.status, 'pending');
      expect(request.seekerName, '');
      expect(request.seekerPhone, '');
      expect(request.seekerAddress, '');
      expect(request.message, '');
    });

    test('should parse correctly from json using fromJson', () {
      final dateTimeStr = '2026-05-17T12:00:00.000Z';
      final json = {
        'seekerId': 'seeker_abc',
        'providerId': 'provider_xyz',
        'serviceId': 'service_789',
        'status': 'accepted',
        'dateTime': dateTimeStr,
        'seekerName': 'Jane Smith',
        'seekerPhone': '+3344556677',
        'seekerAddress': '456 Oak Dr',
        'message': 'AC maintenance contract query',
      };

      final request = McRequestModel.fromJson(json, 'req_789');

      expect(request.id, 'req_789');
      expect(request.seekerId, 'seeker_abc');
      expect(request.providerId, 'provider_xyz');
      expect(request.serviceId, 'service_789');
      expect(request.status, 'accepted');
      expect(request.dateTime, DateTime.parse(dateTimeStr));
      expect(request.seekerName, 'Jane Smith');
      expect(request.seekerPhone, '+3344556677');
      expect(request.seekerAddress, '456 Oak Dr');
      expect(request.message, 'AC maintenance contract query');
    });

    test('should handle missing and null fields in fromJson', () {
      final json = <String, dynamic>{};
      final request = McRequestModel.fromJson(json, 'req_empty');

      expect(request.id, 'req_empty');
      expect(request.seekerId, '');
      expect(request.providerId, '');
      expect(request.serviceId, '');
      expect(request.status, 'pending');
      expect(request.dateTime, isNotNull); // Defaults to DateTime.now()
      expect(request.seekerName, '');
      expect(request.seekerPhone, '');
      expect(request.seekerAddress, '');
      expect(request.message, '');
    });

    test('should serialize correctly to json using toJson', () {
      final now = DateTime.utc(2026, 5, 17, 12, 0, 0);
      final request = McRequestModel(
        id: 'req_999',
        seekerId: 'seeker_abc',
        providerId: 'provider_xyz',
        serviceId: 'service_789',
        status: 'completed',
        dateTime: now,
        seekerName: 'Bruce Wayne',
        seekerPhone: '+999888777',
        seekerAddress: '1007 Mountain Drive',
        message: 'Upgrade cave wiring',
      );

      final json = request.toJson();

      expect(json['seekerId'], 'seeker_abc');
      expect(json['providerId'], 'provider_xyz');
      expect(json['serviceId'], 'service_789');
      expect(json['status'], 'completed');
      expect(json['dateTime'], '2026-05-17T12:00:00.000Z');
      expect(json['seekerName'], 'Bruce Wayne');
      expect(json['seekerPhone'], '+999888777');
      expect(json['seekerAddress'], '1007 Mountain Drive');
      expect(json['message'], 'Upgrade cave wiring');
      expect(json.containsKey('id'), false);
    });
  });
}

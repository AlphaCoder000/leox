import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionModel {
  final String userId;
  final String planId;
  final String role;
  final String status;
  final bool trialUsed;
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;
  final DateTime? startDate;
  final DateTime endDate;
  final String? paymentGateway;
  final String? paymentId;
  final bool isComplimentary;

  SubscriptionModel({
    required this.userId,
    required this.planId,
    required this.role,
    required this.status,
    required this.trialUsed,
    this.trialStartDate,
    this.trialEndDate,
    this.startDate,
    required this.endDate,
    this.paymentGateway,
    this.paymentId,
    required this.isComplimentary,
  });

  bool get isActive {
    if (status == 'suspended') return false;
    if (status == 'expired') return false;
    
    final now = DateTime.now();
    
    // Checked if explicitly cancelled but active until endDate
    if (status == 'cancelled') {
      return endDate.isAfter(now);
    }
    
    if (status == 'trial') {
      if (trialEndDate != null) {
        return trialEndDate!.isAfter(now);
      }
      return false;
    }
    
    return status == 'active' && endDate.isAfter(now);
  }

  factory SubscriptionModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? toDateTime(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return SubscriptionModel(
      userId: docId,
      planId: map['planId'] ?? '',
      role: map['role'] ?? '',
      status: map['status'] ?? 'trial',
      trialUsed: map['trialUsed'] ?? false,
      trialStartDate: toDateTime(map['trialStartDate']),
      trialEndDate: toDateTime(map['trialEndDate']),
      startDate: toDateTime(map['startDate']),
      endDate: toDateTime(map['endDate']) ?? DateTime.now(),
      paymentGateway: map['paymentGateway'],
      paymentId: map['paymentId'],
      isComplimentary: map['isComplimentary'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'planId': planId,
      'role': role,
      'status': status,
      'trialUsed': trialUsed,
      'trialStartDate': trialStartDate != null ? Timestamp.fromDate(trialStartDate!) : null,
      'trialEndDate': trialEndDate != null ? Timestamp.fromDate(trialEndDate!) : null,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': Timestamp.fromDate(endDate),
      'paymentGateway': paymentGateway,
      'paymentId': paymentId,
      'isComplimentary': isComplimentary,
    };
  }
}

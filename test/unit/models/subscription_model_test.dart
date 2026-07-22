import 'package:flutter_test/flutter_test.dart';
import 'package:leox/models/subscription_model.dart';

void main() {
  group('SubscriptionModel Unit Tests', () {
    test('should parse correctly from map', () {
      final now = DateTime.now();
      final map = {
        'planId': 'employer_monthly',
        'role': 'employer',
        'status': 'active',
        'trialUsed': true,
        'isComplimentary': false,
        'endDate': now.add(const Duration(days: 30)).toIso8601String(),
        'startDate': now.toIso8601String(),
      };

      final sub = SubscriptionModel.fromMap(map, 'user123_employer');

      expect(sub.userId, 'user123_employer');
      expect(sub.planId, 'employer_monthly');
      expect(sub.role, 'employer');
      expect(sub.status, 'active');
      expect(sub.trialUsed, true);
      expect(sub.isComplimentary, false);
      expect(sub.endDate.isAfter(now), true);
    });

    test('should evaluate active state correctly for active subscriptions', () {
      final now = DateTime.now();
      
      final activeSub = SubscriptionModel(
        userId: 'user123_employer',
        planId: 'employer_monthly',
        role: 'employer',
        status: 'active',
        trialUsed: true,
        endDate: now.add(const Duration(days: 10)),
        isComplimentary: false,
      );

      final expiredSub = SubscriptionModel(
        userId: 'user123_employer',
        planId: 'employer_monthly',
        role: 'employer',
        status: 'active',
        trialUsed: true,
        endDate: now.subtract(const Duration(days: 1)),
        isComplimentary: false,
      );

      expect(activeSub.isActive, true);
      expect(expiredSub.isActive, false);
    });

    test('should evaluate active state correctly for trials', () {
      final now = DateTime.now();
      
      final activeTrial = SubscriptionModel(
        userId: 'user123_employer',
        planId: 'employer_free_trial',
        role: 'employer',
        status: 'trial',
        trialUsed: false,
        trialEndDate: now.add(const Duration(days: 15)),
        endDate: now.add(const Duration(days: 15)),
        isComplimentary: false,
      );

      final expiredTrial = SubscriptionModel(
        userId: 'user123_employer',
        planId: 'employer_free_trial',
        role: 'employer',
        status: 'trial',
        trialUsed: false,
        trialEndDate: now.subtract(const Duration(days: 1)),
        endDate: now.subtract(const Duration(days: 1)),
        isComplimentary: false,
      );

      expect(activeTrial.isActive, true);
      expect(expiredTrial.isActive, false);
    });

    test('should evaluate active state correctly for cancelled subscriptions', () {
      final now = DateTime.now();
      
      // Cancelled but not yet expired
      final cancelledActive = SubscriptionModel(
        userId: 'user123_employer',
        planId: 'employer_monthly',
        role: 'employer',
        status: 'cancelled',
        trialUsed: true,
        endDate: now.add(const Duration(days: 5)),
        isComplimentary: false,
      );

      // Cancelled and past end date
      final cancelledExpired = SubscriptionModel(
        userId: 'user123_employer',
        planId: 'employer_monthly',
        role: 'employer',
        status: 'cancelled',
        trialUsed: true,
        endDate: now.subtract(const Duration(days: 2)),
        isComplimentary: false,
      );

      expect(cancelledActive.isActive, true);
      expect(cancelledExpired.isActive, false);
    });

    test('should return false for suspended or expired statuses', () {
      final now = DateTime.now();
      
      final suspended = SubscriptionModel(
        userId: 'user123_employer',
        planId: 'employer_monthly',
        role: 'employer',
        status: 'suspended',
        trialUsed: true,
        endDate: now.add(const Duration(days: 30)),
        isComplimentary: false,
      );

      final expired = SubscriptionModel(
        userId: 'user123_employer',
        planId: 'employer_monthly',
        role: 'employer',
        status: 'expired',
        trialUsed: true,
        endDate: now.add(const Duration(days: 30)),
        isComplimentary: false,
      );

      expect(suspended.isActive, false);
      expect(expired.isActive, false);
    });
  });
}

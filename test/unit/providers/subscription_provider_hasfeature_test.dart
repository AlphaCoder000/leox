// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter_test/flutter_test.dart';
import 'package:leox/models/subscription_model.dart';
import 'package:leox/models/subscription_plan_model.dart';

// ---------------------------------------------------------------------------
// Lightweight replica of hasFeature logic (pure Dart, no Firebase needed)
// ---------------------------------------------------------------------------
//
// We can't easily instantiate SubscriptionProvider (it requires Firebase),
// so we replicate the exact hasFeature algorithm here and keep it in sync.
// When the provider's logic changes, update this file too.
// ---------------------------------------------------------------------------

bool hasFeatureLogic({
  required SubscriptionModel? currentSubscription,
  required List<SubscriptionPlanModel> plans,
  required String featureKey,
}) {
  if (currentSubscription == null) return false;
  if (!currentSubscription.isActive) return false;

  // Trial → full access
  if (currentSubscription.status == 'trial') return true;

  // Cancelled but within end date → grant access
  if (currentSubscription.status == 'cancelled') {
    return currentSubscription.endDate.isAfter(DateTime.now());
  }

  // Complimentary → full access
  if (currentSubscription.isComplimentary) return true;

  // Find plan
  final activePlan = plans.firstWhere(
    (p) => p.id == currentSubscription.planId,
    orElse: () => SubscriptionPlanModel(
      id: 'fallback',
      name: 'Fallback',
      role: currentSubscription.role,
      description: '',
      monthlyPrice: 0,
      yearlyPrice: 0,
      currency: 'INR',
      trialDurationDays: 30,
      features: {},
      isRecommended: false,
      isActive: false,
    ),
  );

  if (activePlan.id != 'fallback' && activePlan.features.isNotEmpty) {
    final featureValue = activePlan.features[featureKey];
    if (featureValue is bool) return featureValue;
    if (featureValue is num) return featureValue > 0;
    return false;
  }

  // Fallback: plan not in Firestore yet — grant if status is active
  return currentSubscription.status == 'active';
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SubscriptionModel _makeSub({
  String status = 'active',
  String planId = 'employer_monthly',
  bool isComplimentary = false,
  Duration endOffset = const Duration(days: 30),
  Duration? trialEndOffset,
}) {
  final now = DateTime.now();
  return SubscriptionModel(
    userId: 'user123_employer',
    planId: planId,
    role: 'employer',
    status: status,
    trialUsed: status != 'trial',
    trialEndDate: trialEndOffset != null ? now.add(trialEndOffset) : null,
    endDate: now.add(endOffset),
    isComplimentary: isComplimentary,
  );
}

SubscriptionPlanModel _makePlan({
  String id = 'employer_monthly',
  Map<String, dynamic> features = const {'view_jobs': true, 'post_jobs': true},
}) {
  return SubscriptionPlanModel(
    id: id,
    name: 'Monthly Plan',
    role: 'employer',
    description: 'Test plan',
    monthlyPrice: 999,
    yearlyPrice: 9999,
    currency: 'INR',
    trialDurationDays: 30,
    features: features,
    isRecommended: false,
    isActive: true,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('hasFeature — null / no subscription', () {
    test('returns false when subscription is null', () {
      expect(
        hasFeatureLogic(
          currentSubscription: null,
          plans: [],
          featureKey: 'view_jobs',
        ),
        isFalse,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('hasFeature — TRIAL status', () {
    test('returns true for any feature key during active trial', () {
      final sub = _makeSub(
        status: 'trial',
        planId: 'employer_free_trial',
        trialEndOffset: const Duration(days: 15),
      );

      expect(
        hasFeatureLogic(currentSubscription: sub, plans: [], featureKey: 'view_jobs'),
        isTrue,
      );
      expect(
        hasFeatureLogic(currentSubscription: sub, plans: [], featureKey: 'post_jobs'),
        isTrue,
      );
      expect(
        hasFeatureLogic(currentSubscription: sub, plans: [], featureKey: 'any_random_key'),
        isTrue,
      );
    });

    test('returns false when trial has expired', () {
      final sub = _makeSub(
        status: 'trial',
        planId: 'employer_free_trial',
        endOffset: const Duration(days: -1),
        trialEndOffset: const Duration(days: -1),
      );

      expect(
        hasFeatureLogic(currentSubscription: sub, plans: [], featureKey: 'view_jobs'),
        isFalse,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('hasFeature — ACTIVE status', () {
    test('returns true when plan has feature=true', () {
      final sub = _makeSub(status: 'active', planId: 'employer_monthly');
      final plans = [_makePlan(features: {'view_jobs': true})];

      expect(
        hasFeatureLogic(currentSubscription: sub, plans: plans, featureKey: 'view_jobs'),
        isTrue,
      );
    });

    test('returns false when plan has feature=false', () {
      final sub = _makeSub(status: 'active', planId: 'employer_monthly');
      final plans = [_makePlan(features: {'view_jobs': false})];

      expect(
        hasFeatureLogic(currentSubscription: sub, plans: plans, featureKey: 'view_jobs'),
        isFalse,
      );
    });

    test('returns true when plan has numeric feature > 0', () {
      final sub = _makeSub(status: 'active', planId: 'employer_monthly');
      final plans = [_makePlan(features: {'max_jobs': 5})];

      expect(
        hasFeatureLogic(currentSubscription: sub, plans: plans, featureKey: 'max_jobs'),
        isTrue,
      );
    });

    test('returns false when plan has numeric feature == 0', () {
      final sub = _makeSub(status: 'active', planId: 'employer_monthly');
      final plans = [_makePlan(features: {'max_jobs': 0})];

      expect(
        hasFeatureLogic(currentSubscription: sub, plans: plans, featureKey: 'max_jobs'),
        isFalse,
      );
    });

    test('returns false for feature key not in plan', () {
      final sub = _makeSub(status: 'active', planId: 'employer_monthly');
      final plans = [_makePlan(features: {'view_jobs': true})];

      expect(
        hasFeatureLogic(currentSubscription: sub, plans: plans, featureKey: 'ai_matching'),
        isFalse,
      );
    });

    test('grants access via fallback when plan not in Firestore yet', () {
      // Plan list is empty (race condition on load)
      final sub = _makeSub(status: 'active', planId: 'employer_monthly');

      expect(
        hasFeatureLogic(currentSubscription: sub, plans: [], featureKey: 'view_jobs'),
        isTrue, // fallback: active status → grant
      );
    });

    test('returns false when active subscription is past endDate', () {
      final sub = _makeSub(
        status: 'active',
        endOffset: const Duration(days: -2),
      );

      expect(
        hasFeatureLogic(currentSubscription: sub, plans: [], featureKey: 'view_jobs'),
        isFalse,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('hasFeature — CANCELLED status (admin cancellation flow)', () {
    test('returns true when cancelled but endDate is in the future', () {
      // Admin cancelled, user still within billing period
      final sub = _makeSub(
        status: 'cancelled',
        endOffset: const Duration(days: 5),
      );

      expect(
        hasFeatureLogic(currentSubscription: sub, plans: [], featureKey: 'view_jobs'),
        isTrue,
      );
    });

    test('returns false when cancelled AND endDate has passed', () {
      // Admin cancelled AND billing period is over
      final sub = _makeSub(
        status: 'cancelled',
        endOffset: const Duration(days: -1),
      );

      expect(
        hasFeatureLogic(currentSubscription: sub, plans: [], featureKey: 'view_jobs'),
        isFalse,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('hasFeature — SUSPENDED / EXPIRED statuses', () {
    test('returns false when suspended (even with future endDate)', () {
      final sub = _makeSub(status: 'suspended', endOffset: const Duration(days: 30));

      expect(
        hasFeatureLogic(currentSubscription: sub, plans: [], featureKey: 'view_jobs'),
        isFalse,
      );
    });

    test('returns false when expired (even with future endDate)', () {
      final sub = _makeSub(status: 'expired', endOffset: const Duration(days: 30));

      expect(
        hasFeatureLogic(currentSubscription: sub, plans: [], featureKey: 'view_jobs'),
        isFalse,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('hasFeature — COMPLIMENTARY subscriptions', () {
    test('returns true for any feature when isComplimentary=true', () {
      final sub = _makeSub(
        status: 'active',
        isComplimentary: true,
        planId: 'employer_complimentary',
      );

      expect(
        hasFeatureLogic(currentSubscription: sub, plans: [], featureKey: 'view_jobs'),
        isTrue,
      );
      expect(
        hasFeatureLogic(currentSubscription: sub, plans: [], featureKey: 'ai_matching'),
        isTrue,
      );
    });
  });
}

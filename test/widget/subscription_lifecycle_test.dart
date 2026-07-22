// ignore_for_file: invalid_use_of_protected_member

/// Subscription Lifecycle Widget Integration Tests
///
/// These tests simulate the full subscription lifecycle at the widget level:
///   1. Trial → badge shows "FREE 1 MONTH", features are accessible
///   2. Trial expires → badge shows "EXPIRED", gate blocks access
///   3. Active → badge shows "PREMIUM", features are accessible
///   4. Admin cancels subscription (status='cancelled', endDate future)
///        → badge shows "CANCELLED", features still accessible
///   5. Cancellation period ends (endDate past)
///        → badge shows "CANCELLED", gate BLOCKS features
///   6. Suspended → badge shows "SUSPENDED", gate BLOCKS features
///
/// These tests use a FakeSubscriptionProvider to avoid Firebase dependencies.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'package:leox/models/subscription_model.dart';
import 'package:leox/models/subscription_plan_model.dart';
import 'package:leox/providers/subscription_provider.dart';
import 'package:leox/widgets/subscription_status_badge.dart';
import 'package:leox/widgets/subscription_gate.dart';

// ---------------------------------------------------------------------------
// Fake provider – replaces real Firebase-backed provider in tests
// ---------------------------------------------------------------------------

class FakeSubscriptionProvider extends ChangeNotifier
    implements SubscriptionProvider {
  SubscriptionModel? _sub;
  List<SubscriptionPlanModel> _plans = [];

  @override
  SubscriptionModel? get currentSubscription => _sub;

  @override
  bool get isActive => _sub?.isActive ?? false;

  @override
  List<SubscriptionPlanModel> get plans => _plans;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  /// Mirror of the real hasFeature logic – kept in sync with provider.
  @override
  bool hasFeature(String featureKey) {
    if (_sub == null) return false;
    if (!_sub!.isActive) return false;

    if (_sub!.status == 'trial') return true;

    if (_sub!.status == 'cancelled') {
      return _sub!.endDate.isAfter(DateTime.now());
    }

    if (_sub!.isComplimentary) return true;

    final plan = _plans.firstWhere(
      (p) => p.id == _sub!.planId,
      orElse: () => SubscriptionPlanModel(
        id: 'fallback',
        name: 'Fallback',
        role: _sub!.role,
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

    if (plan.id != 'fallback' && plan.features.isNotEmpty) {
      final v = plan.features[featureKey];
      if (v is bool) return v;
      if (v is num) return v > 0;
      return false;
    }

    return _sub!.status == 'active';
  }

  @override
  void listenToSubscription(String uid, String role) {}

  @override
  Future<Map<String, dynamic>?> createCheckoutOrder({
    required String planId,
    required String billingCycle,
    String? couponCode,
    String? gstNumber,
  }) async =>
      null;

  @override
  Future<bool> verifyPaymentSignature({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String planId,
    required String billingCycle,
    String? couponCode,
    String? gstNumber,
  }) async =>
      false;

  // Test helpers
  void setSubscription(SubscriptionModel? sub) {
    _sub = sub;
    notifyListeners();
  }

  void setPlans(List<SubscriptionPlanModel> plans) {
    _plans = plans;
    notifyListeners();
  }
}

// ---------------------------------------------------------------------------
// Helper: wrap widgets in Sizer + Provider
// ---------------------------------------------------------------------------

Widget _wrap(Widget child, FakeSubscriptionProvider provider) {
  return Sizer(
    builder: (ctx, orientation, deviceType) {
      return ChangeNotifierProvider<SubscriptionProvider>.value(
        value: provider,
        child: MaterialApp(
          home: Scaffold(body: child),
        ),
      );
    },
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

// Top-level constants used in SubscriptionGate tests
const kTestFeature = 'view_jobs';
const Widget kProtectedContent = Text('PROTECTED CONTENT');

void main() {
  late FakeSubscriptionProvider provider;

  setUp(() {
    provider = FakeSubscriptionProvider();
  });

  // -------------------------------------------------------------------------
  group('SubscriptionStatusBadge Lifecycle', () {
    testWidgets('1. No subscription → shows NO PLAN', (tester) async {
      provider.setSubscription(null);
      await tester.pumpWidget(_wrap(const SubscriptionStatusBadge(), provider));
      await tester.pumpAndSettle();
      expect(find.text('NO PLAN'), findsOneWidget);
    });

    testWidgets('2. Active trial → shows FREE 1 MONTH', (tester) async {
      provider.setSubscription(SubscriptionModel(
        userId: 'uid_employer',
        planId: 'employer_free_trial',
        role: 'employer',
        status: 'trial',
        trialUsed: false,
        trialEndDate: DateTime.now().add(const Duration(days: 20)),
        endDate: DateTime.now().add(const Duration(days: 20)),
        isComplimentary: false,
      ));

      await tester.pumpWidget(_wrap(const SubscriptionStatusBadge(), provider));
      await tester.pumpAndSettle();
      expect(find.text('FREE 1 MONTH'), findsOneWidget);
    });

    testWidgets('3. Active premium → shows PREMIUM', (tester) async {
      provider.setSubscription(SubscriptionModel(
        userId: 'uid_employer',
        planId: 'employer_monthly',
        role: 'employer',
        status: 'active',
        trialUsed: true,
        endDate: DateTime.now().add(const Duration(days: 30)),
        isComplimentary: false,
      ));

      await tester.pumpWidget(_wrap(const SubscriptionStatusBadge(), provider));
      await tester.pumpAndSettle();
      expect(find.text('PREMIUM'), findsOneWidget);
    });

    testWidgets(
        '4. Admin cancels subscription (future endDate) → shows CANCELLED',
        (tester) async {
      provider.setSubscription(SubscriptionModel(
        userId: 'uid_employer',
        planId: 'employer_monthly',
        role: 'employer',
        status: 'cancelled', // ← admin sets this in Firestore
        trialUsed: true,
        endDate: DateTime.now().add(const Duration(days: 7)), // still active
        isComplimentary: false,
      ));

      await tester.pumpWidget(_wrap(const SubscriptionStatusBadge(), provider));
      await tester.pumpAndSettle();
      expect(find.text('CANCELLED'), findsOneWidget);
    });

    testWidgets('5. Expired → shows EXPIRED', (tester) async {
      provider.setSubscription(SubscriptionModel(
        userId: 'uid_employer',
        planId: 'employer_monthly',
        role: 'employer',
        status: 'active',
        trialUsed: true,
        endDate: DateTime.now().subtract(const Duration(days: 2)),
        isComplimentary: false,
      ));

      await tester.pumpWidget(_wrap(const SubscriptionStatusBadge(), provider));
      await tester.pumpAndSettle();
      expect(find.text('EXPIRED'), findsOneWidget);
    });

    testWidgets('6. Suspended → shows SUSPENDED', (tester) async {
      provider.setSubscription(SubscriptionModel(
        userId: 'uid_employer',
        planId: 'employer_monthly',
        role: 'employer',
        status: 'suspended',
        trialUsed: true,
        endDate: DateTime.now().add(const Duration(days: 30)),
        isComplimentary: false,
      ));

      await tester.pumpWidget(_wrap(const SubscriptionStatusBadge(), provider));
      await tester.pumpAndSettle();
      expect(find.text('SUSPENDED'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  group('SubscriptionGate Lifecycle', () {

    testWidgets('Trial user: gate allows access', (tester) async {
      provider.setSubscription(SubscriptionModel(
        userId: 'uid',
        planId: 'employer_free_trial',
        role: 'employer',
        status: 'trial',
        trialUsed: false,
        trialEndDate: DateTime.now().add(const Duration(days: 20)),
        endDate: DateTime.now().add(const Duration(days: 20)),
        isComplimentary: false,
      ));

      await tester.pumpWidget(
        _wrap(SubscriptionGate(featureKey: kTestFeature, child: kProtectedContent),
            provider),
      );
      await tester.pumpAndSettle();
      expect(find.text('PROTECTED CONTENT'), findsOneWidget);
    });

    testWidgets('Expired trial: gate BLOCKS access', (tester) async {
      provider.setSubscription(SubscriptionModel(
        userId: 'uid',
        planId: 'employer_free_trial',
        role: 'employer',
        status: 'trial',
        trialUsed: false,
        trialEndDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().subtract(const Duration(days: 1)),
        isComplimentary: false,
      ));

      await tester.pumpWidget(
        _wrap(SubscriptionGate(featureKey: kTestFeature, child: kProtectedContent),
            provider),
      );
      await tester.pumpAndSettle();
      // Protected content NOT shown; paywall is shown instead
      expect(find.text('PROTECTED CONTENT'), findsNothing);
      expect(find.text('LEO OPUS Premium Feature'), findsOneWidget);
    });

    testWidgets(
        'Admin cancelled (within endDate): gate still allows access',
        (tester) async {
      // Simulates real-time Firestore update: admin changes status to 'cancelled'
      // but endDate is 7 days in the future → user still gets access
      provider.setSubscription(SubscriptionModel(
        userId: 'uid',
        planId: 'employer_monthly',
        role: 'employer',
        status: 'cancelled',
        trialUsed: true,
        endDate: DateTime.now().add(const Duration(days: 7)),
        isComplimentary: false,
      ));

      await tester.pumpWidget(
        _wrap(SubscriptionGate(featureKey: kTestFeature, child: kProtectedContent),
            provider),
      );
      await tester.pumpAndSettle();
      expect(find.text('PROTECTED CONTENT'), findsOneWidget);
    });

    testWidgets(
        'Admin cancelled (endDate past): gate BLOCKS access',
        (tester) async {
      // Admin cancelled AND billing period over → fully blocked
      provider.setSubscription(SubscriptionModel(
        userId: 'uid',
        planId: 'employer_monthly',
        role: 'employer',
        status: 'cancelled',
        trialUsed: true,
        endDate: DateTime.now().subtract(const Duration(days: 3)),
        isComplimentary: false,
      ));

      await tester.pumpWidget(
        _wrap(SubscriptionGate(featureKey: kTestFeature, child: kProtectedContent),
            provider),
      );
      await tester.pumpAndSettle();
      expect(find.text('PROTECTED CONTENT'), findsNothing);
      expect(find.text('LEO OPUS Premium Feature'), findsOneWidget);
    });

    testWidgets('Suspended subscription: gate BLOCKS access', (tester) async {
      provider.setSubscription(SubscriptionModel(
        userId: 'uid',
        planId: 'employer_monthly',
        role: 'employer',
        status: 'suspended',
        trialUsed: true,
        endDate: DateTime.now().add(const Duration(days: 30)),
        isComplimentary: false,
      ));

      await tester.pumpWidget(
        _wrap(SubscriptionGate(featureKey: kTestFeature, child: kProtectedContent),
            provider),
      );
      await tester.pumpAndSettle();
      expect(find.text('PROTECTED CONTENT'), findsNothing);
      expect(find.text('LEO OPUS Premium Feature'), findsOneWidget);
    });

    testWidgets('Active paid subscription: gate allows access', (tester) async {
      provider.setSubscription(SubscriptionModel(
        userId: 'uid',
        planId: 'employer_monthly',
        role: 'employer',
        status: 'active',
        trialUsed: true,
        endDate: DateTime.now().add(const Duration(days: 30)),
        isComplimentary: false,
      ));
      provider.setPlans([
        SubscriptionPlanModel(
          id: 'employer_monthly',
          name: 'Employer Monthly',
          role: 'employer',
          description: 'Monthly plan',
          monthlyPrice: 999,
          yearlyPrice: 9999,
          currency: 'INR',
          trialDurationDays: 30,
          features: {kTestFeature: true},
          isRecommended: true,
          isActive: true,
        ),
      ]);

      await tester.pumpWidget(
        _wrap(SubscriptionGate(featureKey: kTestFeature, child: kProtectedContent),
            provider),
      );
      await tester.pumpAndSettle();
      expect(find.text('PROTECTED CONTENT'), findsOneWidget);
    });

    testWidgets(
        'Real-time update: provider changes from trial to expired — gate reacts',
        (tester) async {
      // Start with active trial
      provider.setSubscription(SubscriptionModel(
        userId: 'uid',
        planId: 'employer_free_trial',
        role: 'employer',
        status: 'trial',
        trialUsed: false,
        trialEndDate: DateTime.now().add(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        isComplimentary: false,
      ));

      await tester.pumpWidget(
        _wrap(SubscriptionGate(featureKey: kTestFeature, child: kProtectedContent),
            provider),
      );
      await tester.pumpAndSettle();
      expect(find.text('PROTECTED CONTENT'), findsOneWidget);

      // Simulate Firestore real-time update: trial expired
      provider.setSubscription(SubscriptionModel(
        userId: 'uid',
        planId: 'employer_free_trial',
        role: 'employer',
        status: 'trial',
        trialUsed: true,
        trialEndDate: DateTime.now().subtract(const Duration(hours: 1)),
        endDate: DateTime.now().subtract(const Duration(hours: 1)),
        isComplimentary: false,
      ));
      await tester.pumpAndSettle();

      // Gate now blocks
      expect(find.text('PROTECTED CONTENT'), findsNothing);
      expect(find.text('LEO OPUS Premium Feature'), findsOneWidget);
    });

    testWidgets(
        'Real-time update: provider changes from cancelled (future) to cancelled (past) — gate blocks',
        (tester) async {
      // Start: admin cancelled but within billing period
      provider.setSubscription(SubscriptionModel(
        userId: 'uid',
        planId: 'employer_monthly',
        role: 'employer',
        status: 'cancelled',
        trialUsed: true,
        endDate: DateTime.now().add(const Duration(days: 3)),
        isComplimentary: false,
      ));

      await tester.pumpWidget(
        _wrap(SubscriptionGate(featureKey: kTestFeature, child: kProtectedContent),
            provider),
      );
      await tester.pumpAndSettle();
      expect(find.text('PROTECTED CONTENT'), findsOneWidget);

      // Simulate: billing period passed (Firestore document updated by backend CRON)
      provider.setSubscription(SubscriptionModel(
        userId: 'uid',
        planId: 'employer_monthly',
        role: 'employer',
        status: 'cancelled',
        trialUsed: true,
        endDate: DateTime.now().subtract(const Duration(hours: 1)),
        isComplimentary: false,
      ));
      await tester.pumpAndSettle();

      // Gate blocks
      expect(find.text('PROTECTED CONTENT'), findsNothing);
      expect(find.text('LEO OPUS Premium Feature'), findsOneWidget);
    });
  });
}

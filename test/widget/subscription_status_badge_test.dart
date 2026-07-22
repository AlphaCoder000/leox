import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:leox/widgets/subscription_status_badge.dart';
import 'package:leox/providers/subscription_provider.dart';
import 'package:leox/models/subscription_model.dart';
import 'package:leox/models/subscription_plan_model.dart';

class FakeSubscriptionProvider extends ChangeNotifier implements SubscriptionProvider {
  @override
  SubscriptionModel? currentSubscription;

  @override
  bool get isActive => currentSubscription?.isActive ?? false;

  @override
  List<SubscriptionPlanModel> get plans => [];

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  bool hasFeature(String featureKey) => false;

  @override
  void listenToSubscription(String uid, String role) {}

  @override
  Future<Map<String, dynamic>?> createCheckoutOrder({
    required String planId,
    required String billingCycle,
    String? couponCode,
    String? gstNumber,
  }) async {
    return null;
  }

  @override
  Future<bool> verifyPaymentSignature({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String planId,
    required String billingCycle,
    String? couponCode,
    String? gstNumber,
  }) async {
    return false;
  }
}

void main() {
  group('SubscriptionStatusBadge Widget Tests', () {
    late FakeSubscriptionProvider fakeProvider;

    setUp(() {
      fakeProvider = FakeSubscriptionProvider();
    });

    Widget createTestWidget() {
      return Sizer(
        builder: (context, orientation, deviceType) {
          return ChangeNotifierProvider<SubscriptionProvider>.value(
            value: fakeProvider,
            child: const MaterialApp(
              home: Scaffold(
                body: SubscriptionStatusBadge(),
              ),
            ),
          );
        },
      );
    }

    testWidgets('should display NO PLAN when subscription is null', (WidgetTester tester) async {
      fakeProvider.currentSubscription = null;
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('NO PLAN'), findsOneWidget);
    });

    testWidgets('should display CANCELLED when status is cancelled', (WidgetTester tester) async {
      fakeProvider.currentSubscription = SubscriptionModel(
        userId: 'user123',
        planId: 'employer_monthly',
        role: 'employer',
        status: 'cancelled',
        trialUsed: true,
        endDate: DateTime.now().add(const Duration(days: 5)),
        isComplimentary: false,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('CANCELLED'), findsOneWidget);
    });

    testWidgets('should display FREE 1 MONTH when status is trial and it is active', (WidgetTester tester) async {
      fakeProvider.currentSubscription = SubscriptionModel(
        userId: 'user123',
        planId: 'employer_free_trial',
        role: 'employer',
        status: 'trial',
        trialUsed: false,
        trialEndDate: DateTime.now().add(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 15)),
        isComplimentary: false,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('FREE 1 MONTH'), findsOneWidget);
    });

    testWidgets('should display PREMIUM when status is active and it is active', (WidgetTester tester) async {
      fakeProvider.currentSubscription = SubscriptionModel(
        userId: 'user123',
        planId: 'employer_monthly',
        role: 'employer',
        status: 'active',
        trialUsed: true,
        endDate: DateTime.now().add(const Duration(days: 30)),
        isComplimentary: false,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('PREMIUM'), findsOneWidget);
    });

    testWidgets('should display EXPIRED when status is active but it is expired', (WidgetTester tester) async {
      fakeProvider.currentSubscription = SubscriptionModel(
        userId: 'user123',
        planId: 'employer_monthly',
        role: 'employer',
        status: 'active',
        trialUsed: true,
        endDate: DateTime.now().subtract(const Duration(days: 2)),
        isComplimentary: false,
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('EXPIRED'), findsOneWidget);
    });
  });
}

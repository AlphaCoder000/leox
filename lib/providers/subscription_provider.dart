import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/subscription_plan_model.dart';
import '../models/subscription_model.dart';
import '../services/api_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ======== STATE ========
  SubscriptionModel? _currentSubscription;
  SubscriptionModel? get currentSubscription => _currentSubscription;
  bool get isActive => _currentSubscription?.isActive ?? false;

  List<SubscriptionPlanModel> _plans = [];
  List<SubscriptionPlanModel> get plans => _plans;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription<DocumentSnapshot>? _subSubscription;
  StreamSubscription<QuerySnapshot>? _plansSubscription;

  SubscriptionProvider() {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        _stopListeners();
        _currentSubscription = null;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _stopListeners();
    super.dispose();
  }

  // ======== PRIVATE METHODS ========

  void _stopListeners() {
    _subSubscription?.cancel();
    _plansSubscription?.cancel();
    _subSubscription = null;
    _plansSubscription = null;
  }

  // Auto-grants a 30-day free trial on first launch/check if no sub document exists
  Future<void> _autoCreateTrialSubscription(String uid, String role) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final trialEndDate = now.add(const Duration(days: 30));

      final defaultSub = SubscriptionModel(
        userId: uid,
        planId: '${role}_free_trial',
        role: role,
        status: 'trial',
        trialUsed: false,
        trialStartDate: now,
        trialEndDate: trialEndDate,
        startDate: now,
        endDate: trialEndDate,
        isComplimentary: false,
      );

      final docId = '${uid}_$role';
      // Writes safely to Firestore (Permitted by security rules)
      await _firestore.collection('subscriptions').doc(docId).set(defaultSub.toMap());
      debugPrint('[SubscriptionProvider] Initialized 30-day free trial subscription for role=$role under docId=$docId');
    } catch (e) {
      debugPrint('[SubscriptionProvider] Error auto-creating trial subscription: $e');
    }
  }

  // ======== PUBLIC METHODS ========

  /// Dynamic Role-based Subscription Listener
  void listenToSubscription(String uid, String role) {
    _stopListeners();

    // 1. Listen to active user subscription document
    final docId = '${uid}_$role';
    _subSubscription = _firestore
        .collection('subscriptions')
        .doc(docId)
        .snapshots()
        .listen((doc) async {
      if (doc.exists && doc.data() != null) {
        _currentSubscription = SubscriptionModel.fromMap(doc.data()!, doc.id);
        debugPrint('[SubscriptionProvider] Subscription loaded: status=${_currentSubscription!.status}, isActive=${_currentSubscription!.isActive}');
      } else {
        _currentSubscription = null;
        // Document does not exist, let's trigger trial auto-creation
        debugPrint('[SubscriptionProvider] No subscription doc found for role=$role, attempting trial creation');
        await _autoCreateTrialSubscription(uid, role);
      }
      notifyListeners();
    }, onError: (err) {
      debugPrint('[SubscriptionProvider] Error listening to subscription: $err');
    });

    // 2. Listen to active subscription plans
    _plansSubscription = _firestore
        .collection('subscription_plans')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snap) {
      _plans = snap.docs
          .map((doc) => SubscriptionPlanModel.fromMap(doc.data(), doc.id))
          .toList();
      debugPrint('[SubscriptionProvider] Plans updated: ${_plans.length} active plans');
      notifyListeners();
    }, onError: (err) {
      debugPrint('[SubscriptionProvider] Error listening to plans: $err');
    });
  }

  // ======== PUBLIC METHODS ========

  /// Main Feature-Flag Authorization Check
  bool hasFeature(String featureKey) {
    // If no subscription loaded, default to block premium features
    if (_currentSubscription == null) return false;

    // Check if subscription is legally active (handles cancelled, suspended, expired, trial end)
    if (!_currentSubscription!.isActive) return false;

    // --- Trial users get FULL access to all features ---
    // During the free 30-day trial, all premium features are unlocked.
    if (_currentSubscription!.status == 'trial') {
      return true;
    }

    // --- Cancelled but within end date: continue granting access ---
    // Admin cancelled, but user still has access until original period ends.
    if (_currentSubscription!.status == 'cancelled') {
      final now = DateTime.now();
      return _currentSubscription!.endDate.isAfter(now);
    }

    // --- Complimentary subscriptions get full access ---
    if (_currentSubscription!.isComplimentary) {
      return true;
    }

    // Find the corresponding plan definition for active paid subscriptions
    final activePlan = _plans.firstWhere(
      (plan) => plan.id == _currentSubscription!.planId,
      orElse: () => SubscriptionPlanModel(
        id: 'fallback',
        name: 'Fallback',
        role: _currentSubscription!.role,
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

    // If plan was found (not fallback), evaluate the feature flag
    if (activePlan.id != 'fallback' && activePlan.features.isNotEmpty) {
      final featureValue = activePlan.features[featureKey];
      if (featureValue is bool) {
        return featureValue;
      }
      // Numeric value check (like maximum jobs limit)
      if (featureValue is num) {
        return featureValue > 0;
      }
      // Feature key not in plan definition — default deny
      return false;
    }

    // Fallback: plan not found in Firestore yet (loading race condition)
    // Grant access if subscription is active to avoid false locks
    debugPrint('[SubscriptionProvider] Plan "${_currentSubscription!.planId}" not found — defaulting to GRANT for active subscription');
    return _currentSubscription!.status == 'active';
  }

  /// Create checkout order via backend API
  Future<Map<String, dynamic>?> createCheckoutOrder({
    required String planId,
    required String billingCycle,
    String? couponCode,
    String? gstNumber,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final token = await _auth.currentUser?.getIdToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await ApiService.post(
        '/subscription/create-order',
        body: {
          'planId': planId,
          'billingCycle': billingCycle,
          if (couponCode != null) 'couponCode': couponCode,
          if (gstNumber != null) 'gstNumber': gstNumber,
        },
        authToken: token,
      );

      if (response == null || response['success'] != true) {
        throw Exception(response?['error'] ?? 'Failed to generate payment order');
      }

      return Map<String, dynamic>.from(response);

    } catch (e) {
      _setErrorMessage(e.toString().replaceAll('Exception: ', ''));
      debugPrint('[SubscriptionProvider] Error creating payment order: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Verify signature on Node.js server
  Future<bool> verifyPaymentSignature({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String planId,
    required String billingCycle,
    String? couponCode,
    String? gstNumber,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final token = await _auth.currentUser?.getIdToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await ApiService.post(
        '/subscription/verify-payment',
        body: {
          'razorpayOrderId': razorpayOrderId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySignature': razorpaySignature,
          'planId': planId,
          'billingCycle': billingCycle,
          if (couponCode != null) 'couponCode': couponCode,
          if (gstNumber != null) 'gstNumber': gstNumber,
        },
        authToken: token,
      );

      if (response == null || response['success'] != true) {
        throw Exception(response?['error'] ?? 'Payment validation failed');
      }

      return true;

    } catch (e) {
      _setErrorMessage(e.toString().replaceAll('Exception: ', ''));
      debugPrint('[SubscriptionProvider] Signature verification failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ======== HELPER STATE MUTATORS ========
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }
}

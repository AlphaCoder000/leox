import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mc_service_model.dart';
import '../models/mc_request_model.dart';
import '../models/mc_review_model.dart';

class McSeekerDashboardController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<McServiceModel> _allServices = [];
  List<McServiceModel> get allServices => _allServices;

  List<McRequestModel> _myRequests = [];
  List<McRequestModel> get myRequests => _myRequests;

  List<McReviewModel> _myReviews = [];
  List<McReviewModel> get myReviews => _myReviews;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StreamSubscription<QuerySnapshot>? _myRequestsSubscription;
  StreamSubscription<QuerySnapshot>? _servicesSubscription;

  Future<void> fetchAllServices() async {
    _isLoading = true;
    notifyListeners();
    _servicesSubscription?.cancel();

    _servicesSubscription = _firestore
        .collection('mc_services')
        .snapshots()
        .listen((snapshot) {
      _allServices = snapshot.docs
          .map((doc) => McServiceModel.fromJson(doc.data(), doc.id))
          .toList();
      _isLoading = false;
      notifyListeners();
      debugPrint("[McSeekerDashboardController] Real-time all services updated: ${_allServices.length}");
    }, onError: (e) {
      debugPrint("Error in seeker all services stream: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> fetchMyRequests(String seekerId) async {
    _isLoading = true;
    notifyListeners();
    _myRequestsSubscription?.cancel();

    _myRequestsSubscription = _firestore
        .collection('mc_requests')
        .where('seekerId', isEqualTo: seekerId)
        .snapshots()
        .listen((snapshot) {
      _myRequests = snapshot.docs
          .map((doc) => McRequestModel.fromJson(doc.data(), doc.id))
          .toList();
      _isLoading = false;
      notifyListeners();
      debugPrint("[McSeekerDashboardController] Real-time my requests updated: ${_myRequests.length}");
    }, onError: (e) {
      debugPrint("Error in seeker requests stream: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> createRequest(McRequestModel request) async {
    try {
      await _firestore.collection('mc_requests').add(request.toJson());
    } catch (e) {
      debugPrint("Error creating request: $e");
    }
  }

  Future<void> fetchMyReviews(String seekerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('mc_reviews')
          .where('seekerId', isEqualTo: seekerId)
          .get();
      
      _myReviews = snapshot.docs
          .map((doc) => McReviewModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitReview(McReviewModel review) async {
    try {
      await _firestore.collection('mc_reviews').add(review.toJson());
      await fetchMyReviews(review.seekerId);

      // Recalculate provider's average rating dynamically
      if (review.providerId.isNotEmpty) {
        final reviewsSnapshot = await _firestore
            .collection('mc_reviews')
            .where('providerId', isEqualTo: review.providerId)
            .get();

        if (reviewsSnapshot.docs.isNotEmpty) {
          double totalRating = 0.0;
          for (var doc in reviewsSnapshot.docs) {
            final data = doc.data();
            totalRating += (data['rating'] ?? 0.0).toDouble();
          }
          final averageRating = totalRating / reviewsSnapshot.docs.length;
          final roundedRating = double.parse(averageRating.toStringAsFixed(1));

          await _firestore
              .collection('mc_providers')
              .doc(review.providerId)
              .update({'rating': roundedRating});
        }
      }
    } catch (e) {
      debugPrint("Error submitting review: $e");
    }
  }

  @override
  void dispose() {
    _myRequestsSubscription?.cancel();
    _servicesSubscription?.cancel();
    super.dispose();
  }
}

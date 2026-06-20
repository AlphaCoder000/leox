import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mc_service_model.dart';
import '../models/mc_request_model.dart';
import '../models/mc_review_model.dart';

class McProviderDashboardController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<McServiceModel> _services = [];
  List<McServiceModel> get services => _services;

  List<McRequestModel> _requests = [];
  List<McRequestModel> get requests => _requests;

  List<McReviewModel> _providerReviews = [];
  List<McReviewModel> get providerReviews => _providerReviews;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StreamSubscription<QuerySnapshot>? _requestsSubscription;
  StreamSubscription<QuerySnapshot>? _servicesSubscription;

  Future<void> fetchMyServices(String providerId) async {
    _isLoading = true;
    notifyListeners();
    _servicesSubscription?.cancel();

    _servicesSubscription = _firestore
        .collection('mc_services')
        .where('providerId', isEqualTo: providerId)
        .snapshots()
        .listen((snapshot) {
      _services = snapshot.docs
          .map((doc) => McServiceModel.fromJson(doc.data(), doc.id))
          .toList();
      _isLoading = false;
      notifyListeners();
      debugPrint("[McProviderDashboardController] Real-time services updated: ${_services.length}");
    }, onError: (e) {
      debugPrint("Error in services stream: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> fetchIncomingRequests(String providerId) async {
    _isLoading = true;
    notifyListeners();
    _requestsSubscription?.cancel();

    _requestsSubscription = _firestore
        .collection('mc_requests')
        .where('providerId', isEqualTo: providerId)
        .snapshots()
        .listen((snapshot) {
      _requests = snapshot.docs
          .map((doc) => McRequestModel.fromJson(doc.data(), doc.id))
          .toList();
      _isLoading = false;
      notifyListeners();
      debugPrint("[McProviderDashboardController] Real-time requests updated: ${_requests.length}");
    }, onError: (e) {
      debugPrint("Error in requests stream: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> fetchProviderReviews(String providerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('mc_reviews')
          .where('providerId', isEqualTo: providerId)
          .get();
      
      _providerReviews = snapshot.docs
          .map((doc) => McReviewModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint("Error fetching provider reviews: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addService(McServiceModel service) async {
    try {
      await _firestore.collection('mc_services').add(service.toJson());
    } catch (e) {
      debugPrint("Error adding service: $e");
    }
  }

  Future<void> deleteService(String serviceId, String providerId) async {
    try {
      await _firestore.collection('mc_services').doc(serviceId).delete();
    } catch (e) {
      debugPrint("Error deleting service: $e");
    }
  }

  Future<void> updateService(McServiceModel service) async {
    try {
      await _firestore.collection('mc_services').doc(service.id).update(service.toJson());
    } catch (e) {
      debugPrint("Error updating service: $e");
    }
  }
  
  Future<void> updateRequestStatus(String requestId, String newStatus, String providerId) async {
    try {
      await _firestore.collection('mc_requests').doc(requestId).update({'status': newStatus});
    } catch (e) {
      debugPrint("Error updating request status: $e");
    }
  }

  Future<void> updateServiceStatus(String serviceId, String newStatus, String providerId) async {
    try {
      await _firestore.collection('mc_services').doc(serviceId).update({'status': newStatus});
    } catch (e) {
      debugPrint("Error updating service status: $e");
    }
  }

  @override
  void dispose() {
    _requestsSubscription?.cancel();
    _servicesSubscription?.cancel();
    super.dispose();
  }
}

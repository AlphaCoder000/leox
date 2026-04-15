import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mc_service_model.dart';
import '../models/mc_request_model.dart';

class McProviderDashboardController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<McServiceModel> _services = [];
  List<McServiceModel> get services => _services;

  List<McRequestModel> _requests = [];
  List<McRequestModel> get requests => _requests;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchMyServices(String providerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('mc_services')
          .where('providerId', isEqualTo: providerId)
          .get();
      
      _services = snapshot.docs
          .map((doc) => McServiceModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint("Error fetching provider services: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchIncomingRequests(String providerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('mc_requests')
          .where('providerId', isEqualTo: providerId)
          .get();
      
      _requests = snapshot.docs
          .map((doc) => McRequestModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint("Error fetching provider requests: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addService(McServiceModel service) async {
    try {
      await _firestore.collection('mc_services').add(service.toJson());
      await fetchMyServices(service.providerId);
    } catch (e) {
      debugPrint("Error adding service: $e");
    }
  }

  Future<void> deleteService(String serviceId, String providerId) async {
    try {
      await _firestore.collection('mc_services').doc(serviceId).delete();
      await fetchMyServices(providerId);
    } catch (e) {
      debugPrint("Error deleting service: $e");
    }
  }
  
  Future<void> updateRequestStatus(String requestId, String newStatus, String providerId) async {
    try {
      await _firestore.collection('mc_requests').doc(requestId).update({'status': newStatus});
      await fetchIncomingRequests(providerId);
    } catch (e) {
      debugPrint("Error updating request status: $e");
    }
  }
}

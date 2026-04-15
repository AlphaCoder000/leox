import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mc_service_model.dart';
import '../models/mc_request_model.dart';

class McSeekerDashboardController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<McServiceModel> _allServices = [];
  List<McServiceModel> get allServices => _allServices;

  List<McRequestModel> _myRequests = [];
  List<McRequestModel> get myRequests => _myRequests;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchAllServices() async {
    _isLoading = true;
    notifyListeners();
    try {
      QuerySnapshot snapshot = await _firestore.collection('mc_services').get();
      
      _allServices = snapshot.docs
          .map((doc) => McServiceModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint("Error fetching all services: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyRequests(String seekerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('mc_requests')
          .where('seekerId', isEqualTo: seekerId)
          .get();
      
      _myRequests = snapshot.docs
          .map((doc) => McRequestModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint("Error fetching seeker requests: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createRequest(McRequestModel request) async {
    try {
      await _firestore.collection('mc_requests').add(request.toJson());
      await fetchMyRequests(request.seekerId);
    } catch (e) {
      debugPrint("Error creating request: $e");
    }
  }
}

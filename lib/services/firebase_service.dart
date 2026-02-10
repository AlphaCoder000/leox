/// Firebase Service - Firebase Admin SDK Equivalent
/// Equivalent to web app's src/lib/firebaseAdmin.server.ts
/// Provides secure Firebase operations for Flutter app

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ======== AUTHENTICATION ========

  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Get user ID token for API calls
  Future<String?> getIdToken() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      debugPrint('[FirebaseService] Error getting ID token: $e');
      return null;
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Get user claims for role-based access
  Future<Map<String, dynamic>?> getUserClaims() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final idTokenResult = await user.getIdTokenResult();
        return idTokenResult.claims;
      }
      return null;
    } catch (e) {
      debugPrint('[FirebaseService] Error getting user claims: $e');
      return null;
    }
  }

  // ======== FIRESTORE OPERATIONS ========

  /// Create document with server timestamp
  Future<DocumentReference> createDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      final documentData = Map<String, dynamic>.from(data);
      documentData['createdAt'] = FieldValue.serverTimestamp();
      documentData['updatedAt'] = FieldValue.serverTimestamp();

      return await _firestore.collection(collection).add(documentData);
    } catch (e) {
      debugPrint('[FirebaseService] Error creating document: $e');
      rethrow;
    }
  }

  /// Update document with server timestamp
  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      final documentData = Map<String, dynamic>.from(data);
      documentData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection(collection).doc(documentId).update(documentData);
    } catch (e) {
      debugPrint('[FirebaseService] Error updating document: $e');
      rethrow;
    }
  }

  /// Get document with error handling
  Future<DocumentSnapshot?> getDocument(String collection, String documentId) async {
    try {
      return await _firestore.collection(collection).doc(documentId).get();
    } catch (e) {
      debugPrint('[FirebaseService] Error getting document: $e');
      return null;
    }
  }

  /// Query documents with error handling
  Future<QuerySnapshot> queryDocuments(
    String collection,
    String field,
    dynamic value, {
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection).where(field, isEqualTo: value);

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } catch (e) {
      debugPrint('[FirebaseService] Error querying documents: $e');
      rethrow;
    }
  }

  /// Batch operations
  Future<void> batchWrite(List<BatchOperation> operations) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        switch (operation.type) {
          case BatchOperationType.create:
            final docRef = _firestore.collection(operation.collection).doc();
            batch.set(docRef, operation.data);
            break;
          case BatchOperationType.set:
            final docRef = _firestore.collection(operation.collection).doc(operation.documentId);
            batch.set(docRef, operation.data);
            break;
          case BatchOperationType.update:
            final docRef = _firestore.collection(operation.collection).doc(operation.documentId);
            batch.update(docRef, operation.data);
            break;
          case BatchOperationType.delete:
            final docRef = _firestore.collection(operation.collection).doc(operation.documentId);
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
      debugPrint('[FirebaseService] Batch operation completed successfully');
    } catch (e) {
      debugPrint('[FirebaseService] Error in batch operation: $e');
      rethrow;
    }
  }

  /// Transaction operation
  Future<T> runTransaction<T>(
    TransactionHandler<T> transactionHandler,
  ) async {
    try {
      return await _firestore.runTransaction(transactionHandler);
    } catch (e) {
      debugPrint('[FirebaseService] Error in transaction: $e');
      rethrow;
    }
  }

  // ======== STORAGE OPERATIONS ========

  /// Upload file to Firebase Storage
  Future<String> uploadFile({
    required String filePath,
    required File file,
    Map<String, String>? metadata,
  }) async {
    try {
      final ref = _storage.ref().child(filePath);
      
      final uploadTask = ref.putFile(file);
      
      // Add metadata if provided
      if (metadata != null) {
        final metadataObj = SettableMetadata(
          customMetadata: metadata,
        );
        await ref.putFile(file, metadataObj);
      }

      final downloadUrl = await ref.getDownloadURL();
      debugPrint('[FirebaseService] File uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('[FirebaseService] Error uploading file: $e');
      rethrow;
    }
  }

  /// Delete file from Firebase Storage
  Future<void> deleteFile(String filePath) async {
    try {
      await _storage.ref().child(filePath).delete();
      debugPrint('[FirebaseService] File deleted successfully: $filePath');
    } catch (e) {
      debugPrint('[FirebaseService] Error deleting file: $e');
      rethrow;
    }
  }

  /// Get file download URL
  Future<String?> getDownloadUrl(String filePath) async {
    try {
      return await _storage.ref().child(filePath).getDownloadURL();
    } catch (e) {
      debugPrint('[FirebaseService] Error getting download URL: $e');
      return null;
    }
  }

  // ======== SECURITY & VALIDATION ========

  /// Validate user permissions for document access
  Future<bool> canAccessDocument(
    String collection,
    String documentId,
    String requiredPermission,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Get user claims for role-based access
      final claims = await getUserClaims();
      if (claims == null) return false;

      // Check document ownership or role-based permissions
      final doc = await getDocument(collection, documentId);
      if (doc == null || !doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return false;

      // Owner can always access
      if (data['ownerId'] == user.uid) return true;

      // Check role-based permissions
      final userRole = claims['role'] as String?;
      if (userRole == 'admin') return true;

      // Check specific permissions
      switch (requiredPermission) {
        case 'read':
          return data['isPublic'] == true || 
                 data['readers']?.contains(user.uid) == true;
        case 'write':
          return data['writers']?.contains(user.uid) == true;
        case 'delete':
          return data['owners']?.contains(user.uid) == true;
        default:
          return false;
      }
    } catch (e) {
      debugPrint('[FirebaseService] Error checking document access: $e');
      return false;
    }
  }

  /// Create user profile with proper permissions
  Future<void> createUserProfile({
    required String userId,
    required String role, // 'employee' or 'employer'
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final userDoc = _firestore.collection('${role}s').doc(userId);
      
      final userData = Map<String, dynamic>.from(profileData);
      userData.addAll({
        'userId': userId,
        'role': role,
        'isActive': true,
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'permissions': _getDefaultPermissions(role),
      });

      await userDoc.set(userData);
      debugPrint('[FirebaseService] User profile created for $role: $userId');
    } catch (e) {
      debugPrint('[FirebaseService] Error creating user profile: $e');
      rethrow;
    }
  }

  // ======== ANALYTICS & MONITORING ========

  /// Log user activity
  Future<void> logActivity({
    required String userId,
    required String action,
    Map<String, dynamic>? details,
  }) async {
    try {
      await _firestore.collection('activity_logs').add({
        'userId': userId,
        'action': action,
        'details': details ?? {},
        'timestamp': FieldValue.serverTimestamp(),
        'userAgent': 'Flutter App',
      });
    } catch (e) {
      debugPrint('[FirebaseService] Error logging activity: $e');
    }
  }

  /// Get user activity logs
  Future<List<Map<String, dynamic>>> getUserActivityLogs(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('activity_logs')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      debugPrint('[FirebaseService] Error getting activity logs: $e');
      return [];
    }
  }

  // ======== HELPER METHODS ========

  Map<String, bool> _getDefaultPermissions(String role) {
    switch (role) {
      case 'employee':
        return {
          'canApplyJobs': true,
          'canViewJobs': true,
          'canUpdateProfile': true,
          'canUploadResume': true,
        };
      case 'employer':
        return {
          'canPostJobs': true,
          'canViewApplications': true,
          'canUpdateProfile': true,
          'canScheduleInterviews': true,
        };
      default:
        return {};
    }
  }

  /// Check if user has specific permission
  Future<bool> hasPermission(String permission) async {
    try {
      final claims = await getUserClaims();
      if (claims == null) return false;

      final permissions = claims['permissions'] as Map<String, bool>?;
      return permissions?[permission] ?? false;
    } catch (e) {
      debugPrint('[FirebaseService] Error checking permission: $e');
      return false;
    }
  }

  /// Get user role from claims
  Future<String?> getUserRole() async {
    try {
      final claims = await getUserClaims();
      return claims?['role'] as String?;
    } catch (e) {
      debugPrint('[FirebaseService] Error getting user role: $e');
      return null;
    }
  }
}

// ======== SUPPORTING CLASSES ========

enum BatchOperationType { create, set, update, delete }

class BatchOperation {
  final BatchOperationType type;
  final String collection;
  final String? documentId;
  final Map<String, dynamic> data;

  BatchOperation({
    required this.type,
    required this.collection,
    this.documentId,
    required this.data,
  });
}

typedef TransactionHandler<T> = Future<T> Function(Transaction transaction);

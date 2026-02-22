import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload file and return download URL
  Future<String?> uploadFile(XFile file, String path) async {
    try {
      final ref = _storage.ref().child(path);

      UploadTask uploadTask;

      if (kIsWeb) {
        // Web upload
        final bytes = await file.readAsBytes();
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: file.mimeType),
        );
      } else {
        // Mobile upload
        final fileToUpload = File(file.path);
        uploadTask = ref.putFile(
          fileToUpload,
          SettableMetadata(contentType: file.mimeType),
        );
      }

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('[StorageService] Error uploading file: $e');
      return null;
    }
  }

  /// Upload a file selected by `file_picker` (PlatformFile)
  Future<String?> uploadPlatformFile(PlatformFile file, String path) async {
    try {
      final ref = _storage.ref().child(path);

      UploadTask uploadTask;

      final fileName = file.name ?? 'file';
      final contentType = _getContentType(fileName);

      if (kIsWeb) {
        final bytes = file.bytes;
        if (bytes == null) {
          throw Exception('No file bytes available for web upload');
        }
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: contentType),
        );
      } else {
        final filePath = file.path;
        if (filePath == null) throw Exception('File path is null');
        final fileToUpload = File(filePath);
        uploadTask = ref.putFile(
          fileToUpload,
          SettableMetadata(contentType: contentType),
        );
      }

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('[StorageService] Error uploading platform file: $e');
      return null;
    }
  }

  /// Upload file bytes and return download URL
  Future<String?> uploadFileBytes({
    required Uint8List fileBytes,
    required String fileName,
    required String folder,
  }) async {
    try {
      final ref = _storage.ref().child('$folder/$fileName');

      final uploadTask = ref.putData(
        fileBytes,
        SettableMetadata(contentType: _getContentType(fileName)),
      );

      // Add progress tracking and timeout handling
      final snapshot = await uploadTask.timeout(
        Duration(minutes: 5),
        onTimeout: () {
          throw TimeoutException('File upload timed out after 5 minutes');
        },
      );

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('[StorageService] Error uploading file bytes: $e');
      return null;
    }
  }

  /// Get content type based on file extension
  String _getContentType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  /// Delete file from Firebase Storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      debugPrint('[StorageService] File deleted successfully: $fileUrl');
    } catch (e) {
      debugPrint('[StorageService] Error deleting file: $e');
      rethrow;
    }
  }
}

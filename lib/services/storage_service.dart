import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static final _storage = FirebaseStorage.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Uploads a local JPEG file to Firebase Storage.
  /// Returns the public download URL, or null if the upload fails or user is signed out.
  static Future<String?> uploadPhoto({
    required String ownerType,
    required String ownerId,
    required String photoId,
    required String localPath,
  }) async {
    final uid = _uid;
    if (uid == null) return null;
    try {
      final ref = _storage.ref('users/$uid/photos/${ownerType}s/$ownerId/$photoId.jpg');
      await ref.putFile(File(localPath));
      return await ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) debugPrint('StorageService: upload failed for $photoId: $e');
      return null;
    }
  }

  /// Deletes a photo from Firebase Storage. Fails silently.
  static Future<void> deletePhoto({
    required String ownerType,
    required String ownerId,
    required String photoId,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final ref = _storage.ref('users/$uid/photos/${ownerType}s/$ownerId/$photoId.jpg');
      await ref.delete();
    } catch (e) {
      if (kDebugMode) debugPrint('StorageService: delete failed for $photoId: $e');
    }
  }
}

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class StorageService {
  static final _storage = FirebaseStorage.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Uploads a local JPEG file to Firebase Storage, compressed to max 1024px / quality 80.
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
      final compressed = await _compress(localPath);
      await ref.putData(
        compressed,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) debugPrint('StorageService: upload failed for $photoId: $e');
      return null;
    }
  }

  /// Resize to max 1024px on longest edge, encode JPEG at quality 80.
  static Future<Uint8List> _compress(String localPath) async {
    try {
      final bytes = await File(localPath).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return bytes;

      img.Image resized;
      const kMax = 1024;
      if (decoded.width > decoded.height && decoded.width > kMax) {
        resized = img.copyResize(decoded, width: kMax);
      } else if (decoded.height > decoded.width && decoded.height > kMax) {
        resized = img.copyResize(decoded, height: kMax);
      } else if (decoded.width == decoded.height && decoded.width > kMax) {
        resized = img.copyResize(decoded, width: kMax, height: kMax);
      } else {
        resized = decoded;
      }

      return Uint8List.fromList(img.encodeJpg(resized, quality: 80));
    } catch (e) {
      if (kDebugMode) debugPrint('StorageService: compression failed, using original: $e');
      return File(localPath).readAsBytesSync();
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

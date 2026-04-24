import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'error_service.dart';

class StorageService {
  static final _storage = FirebaseStorage.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // Last upload error — readable from the UI for diagnostics.
  static String? lastUploadError;

  /// Uploads a local JPEG file to Firebase Storage, compressed to max 1024px / quality 80.
  /// Returns the public download URL, or null if the upload fails or user is signed out.
  static Future<String?> uploadPhoto({
    required String ownerType,
    required String ownerId,
    required String photoId,
    required String localPath,
  }) async {
    final uid = _uid;
    if (uid == null) {
      lastUploadError = 'uid=null (not signed in)';
      return null;
    }
    File? tmpFile;
    try {
      final storagePath = 'users/$uid/photos/${ownerType}s/$ownerId/$photoId.jpg';
      final ref = _storage.ref(storagePath);
      if (kDebugMode) debugPrint('StorageService: uploading $storagePath');

      // Write compressed bytes to a temp file and upload via putFile —
      // more reliable on iOS than putData (uses NSURLSession background transfer).
      final compressed = await _compress(localPath);
      final tmpDir = await getTemporaryDirectory();
      tmpFile = File(p.join(tmpDir.path, '$photoId.jpg'));
      await tmpFile.writeAsBytes(compressed);

      await ref.putFile(tmpFile, SettableMetadata(contentType: 'image/jpeg'));
      final url = await ref.getDownloadURL();

      lastUploadError = null;
      if (kDebugMode) debugPrint('StorageService: upload OK → $url');
      return url;
    } catch (e, st) {
      lastUploadError = e.toString();
      logError('StorageService upload $ownerType/$ownerId/$photoId', e, st);
      return null;
    } finally {
      try { tmpFile?.deleteSync(); } catch (_) {}
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
    } catch (e, st) {
      logError('StorageService compress', e, st);
      return await File(localPath).readAsBytes();
    }
  }

  /// Deletes all photos for a user from Firebase Storage.
  static Future<void> deleteAllUserPhotos(String uid) async {
    try {
      final ref = _storage.ref('users/$uid/photos');
      final result = await ref.listAll();
      for (final item in result.items) {
        await item.delete();
      }
      for (final prefix in result.prefixes) {
        await _deletePrefix(prefix);
      }
      if (kDebugMode) debugPrint('StorageService: deleted all photos for $uid');
    } catch (e, st) {
      logError('StorageService deleteAllUserPhotos', e, st);
    }
  }

  static Future<void> _deletePrefix(Reference ref) async {
    final result = await ref.listAll();
    for (final item in result.items) {
      await item.delete();
    }
    for (final prefix in result.prefixes) {
      await _deletePrefix(prefix);
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
    } catch (e, st) {
      logError('StorageService delete $photoId', e, st);
    }
  }
}

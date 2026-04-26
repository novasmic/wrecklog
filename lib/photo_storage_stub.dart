// lib/photo_storage_stub.dart
// Safety stub — should never be reached if io/html conditions cover all targets.
// Exported by photo_storage.dart as the fallback.

import 'dart:async';

import 'package:image_picker/image_picker.dart';

import 'photo_storage_model.dart';
export 'photo_storage_model.dart';

class PhotoStorage {
  static Stream<void> get remoteChanges => const Stream<void>.empty();

  static Future<List<AppPhoto>> loadAll() async =>
      throw UnsupportedError('Photo storage not supported on this platform.');

  static Future<List<AppPhoto>> forOwner(
          String ownerType, String ownerId) async =>
      throw UnsupportedError('Photo storage not supported on this platform.');

  static Future<AppPhoto> add({
    required String ownerType,
    required String ownerId,
    required String sourcePath,
  }) async =>
      throw UnsupportedError('Photo storage not supported on this platform.');

  static Future<AppPhoto> addFromXFile({
    required String ownerType,
    required String ownerId,
    required XFile xfile,
  }) async =>
      throw UnsupportedError('Photo storage not supported on this platform.');

  static Future<void> delete(AppPhoto photo) async =>
      throw UnsupportedError('Photo storage not supported on this platform.');

  static Future<void> deleteAllForOwner(
          String ownerType, String ownerId) async =>
      throw UnsupportedError('Photo storage not supported on this platform.');

  static Future<void> wipeAll() async {}

  static Future<void> backfillRemoteUrls() async {}

  static Future<void> cacheRemotePhotos() async {}
}

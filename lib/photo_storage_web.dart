// lib/photo_storage_web.dart
// Flutter Web implementation — stores photos as base64 strings in SharedPrefs.
// No dart:io, no filesystem, no path_provider.
// Never imported directly — used via photo_storage.dart conditional export.

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'photo_constants.dart';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'photo_storage_model.dart';
export 'photo_storage_model.dart';

// Web photos are stored per-owner to keep individual keys small.
// Key format: wrecklog_photos_web_v1:<ownerType>:<ownerId>
String _ownerKey(String ownerType, String ownerId) =>
    'wrecklog_photos_web_v1:$ownerType:$ownerId';

// Global index of all (ownerType, ownerId) pairs that have photos,
// so deleteAllForOwner can work without scanning everything.
const String _kIndexKey = 'wrecklog_photos_web_index_v1';

class PhotoStorage {
  // ── Read ──────────────────────────────────────────────────────────────────
  static Future<List<AppPhoto>> forOwner(
      String ownerType, String ownerId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ownerKey(ownerType, ownerId));
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => AppPhoto.tryFromJson(e as Map<String, dynamic>))
        .whereType<AppPhoto>()
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  // ── Wipe all photos from SharedPreferences (called by Storage.wipeAll) ────
  static Future<void> wipeAll() async {
    final prefs = await SharedPreferences.getInstance();
    final photoKeys = prefs.getKeys()
        .where((k) => k.startsWith('wrecklog_photos_web_v1:') || k == _kIndexKey)
        .toList();
    for (final k in photoKeys) {
      await prefs.remove(k);
    }
  }

  // ── Read all (used by backup) ─────────────────────────────────────────────
  static Future<List<AppPhoto>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kIndexKey);
    if (raw == null) return [];
    final index = (jsonDecode(raw) as List<dynamic>).cast<String>();
    final all = <AppPhoto>[];
    for (final entry in index) {
      final parts = entry.split(':');
      if (parts.length != 2) continue;
      all.addAll(await forOwner(parts[0], parts[1]));
    }
    return all;
  }

  // ── Write ─────────────────────────────────────────────────────────────────
  /// Not used on Web — Web has no filesystem path. Always use addFromXFile.
  static Future<AppPhoto> add({
    required String ownerType,
    required String ownerId,
    required String sourcePath,
  }) async =>
      throw UnsupportedError('Use addFromXFile on Web — no filesystem path available.');

  /// Reads bytes from [xfile] (image_picker XFile), base64-encodes them,
  /// and saves as an AppPhoto record.
  static Future<AppPhoto> addFromXFile({
    required String ownerType,
    required String ownerId,
    required XFile xfile,
  }) async {
    final bytes = await xfile.readAsBytes();
    final b64 = base64Encode(bytes);
    final id = _newId();

    final photo = AppPhoto(
      id:         id,
      ownerType:  ownerType,
      ownerId:    ownerId,
      createdAt:  DateTime.now().millisecondsSinceEpoch,
      pathOrData: b64,
    );

    await _appendPhoto(ownerType, ownerId, photo);
    await _registerInIndex(ownerType, ownerId);
    return photo;
  }

  // ── Delete single ─────────────────────────────────────────────────────────
  static Future<void> delete(AppPhoto photo) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _ownerKey(photo.ownerType, photo.ownerId);
    final raw = prefs.getString(key);
    if (raw == null) return;
    final list = (jsonDecode(raw) as List<dynamic>)
        .map((e) => AppPhoto.tryFromJson(e as Map<String, dynamic>))
        .whereType<AppPhoto>()
        .where((p) => p.id != photo.id)
        .toList();
    if (list.isEmpty) {
      await prefs.remove(key);
      await _removeFromIndex(photo.ownerType, photo.ownerId, prefs);
    } else {
      await prefs.setString(
          key, jsonEncode(list.map((p) => p.toJson()).toList()));
    }
  }

  // ── Delete all for owner ──────────────────────────────────────────────────
  static Future<void> deleteAllForOwner(
      String ownerType, String ownerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ownerKey(ownerType, ownerId));
    await _removeFromIndex(ownerType, ownerId, prefs);
  }

  // ── Internals ─────────────────────────────────────────────────────────────
  static Future<void> _appendPhoto(
      String ownerType, String ownerId, AppPhoto photo) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _ownerKey(ownerType, ownerId);
    final raw = prefs.getString(key);
    final list = raw == null
        ? <AppPhoto>[]
        : (jsonDecode(raw) as List<dynamic>)
            .map((e) => AppPhoto.tryFromJson(e as Map<String, dynamic>))
            .whereType<AppPhoto>()
            .toList();
    // Belt-and-braces: enforce max even if UI check is bypassed
    if (list.length >= kMaxPhotosPerOwner) {
      throw Exception(
          'Photo limit reached — max $kMaxPhotosPerOwner photos per item.');
    }
    list.add(photo);
    await prefs.setString(
        key, jsonEncode(list.map((p) => p.toJson()).toList()));
  }

  static Future<void> _registerInIndex(
      String ownerType, String ownerId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kIndexKey);
    final index =
        raw == null ? <String>[] : (jsonDecode(raw) as List<dynamic>).cast<String>();
    final entry = '$ownerType:$ownerId';
    if (!index.contains(entry)) {
      index.add(entry);
      await prefs.setString(_kIndexKey, jsonEncode(index));
    }
  }

  static Future<void> _removeFromIndex(
      String ownerType, String ownerId, SharedPreferences prefs) async {
    final raw = prefs.getString(_kIndexKey);
    if (raw == null) return;
    final index = (jsonDecode(raw) as List<dynamic>).cast<String>();
    index.remove('$ownerType:$ownerId');
    await prefs.setString(_kIndexKey, jsonEncode(index));
  }

  static String _newId() =>
      'P${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9999)}';
}

/// Web helper — decode base64 back to bytes for display via MemoryImage.
Uint8List decodePhotoBytes(String pathOrData) => base64Decode(pathOrData);

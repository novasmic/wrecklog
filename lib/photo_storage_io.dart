// lib/photo_storage_io.dart
// Android + iOS implementation — stores JPEG files in app documents directory.
// Metadata stored in a JSON file (no SharedPreferences size limits).
// Never imported directly — used via photo_storage.dart conditional export.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'photo_storage_model.dart';
export 'photo_storage_model.dart';

// Legacy SharedPreferences key — only used during one-time migration.
const String _kLegacyPrefsKey = 'wrecklog_photos_v1';

class PhotoStorage {
  // ── Read ──────────────────────────────────────────────────────────────────
  static Future<List<AppPhoto>> forOwner(
      String ownerType, String ownerId) async {
    final all = await _loadAll();
    return all
        .where((ph) => ph.ownerType == ownerType && ph.ownerId == ownerId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  // ── Write ─────────────────────────────────────────────────────────────────
  /// Copies [sourcePath] (temp path from image_picker) into our own folder
  /// and saves the metadata record. Returns the saved AppPhoto.
  static Future<AppPhoto> add({
    required String ownerType,
    required String ownerId,
    required String sourcePath,
  }) async {
    final id = _newId();
    final dir = await _photoDir(ownerType, ownerId);
    await dir.create(recursive: true);
    final dest = p.join(dir.path, '$id.jpg');
    await File(sourcePath).copy(dest);

    final photo = AppPhoto(
      id:         id,
      ownerType:  ownerType,
      ownerId:    ownerId,
      createdAt:  DateTime.now().millisecondsSinceEpoch,
      pathOrData: dest,
    );
    final all = await _loadAll();
    all.add(photo);
    await _saveAll(all);
    return photo;
  }

  /// Convenience wrapper — on iOS/Android XFile always has a valid path.
  static Future<AppPhoto> addFromXFile({
    required String ownerType,
    required String ownerId,
    required XFile xfile,
  }) async {
    return add(
      ownerType:  ownerType,
      ownerId:    ownerId,
      sourcePath: xfile.path,
    );
  }

  // ── Delete single ─────────────────────────────────────────────────────────
  static Future<void> delete(AppPhoto photo) async {
    final all = await _loadAll();
    all.removeWhere((ph) => ph.id == photo.id);
    await _saveAll(all);
    _deleteFile(photo.pathOrData);
  }

  // ── Delete all for owner (vehicle or part deleted) ────────────────────────
  static Future<void> deleteAllForOwner(
      String ownerType, String ownerId) async {
    final all = await _loadAll();
    final gone = all
        .where((ph) => ph.ownerType == ownerType && ph.ownerId == ownerId)
        .toList();
    for (final ph in gone) {
      _deleteFile(ph.pathOrData);
    }
    all.removeWhere(
        (ph) => ph.ownerType == ownerType && ph.ownerId == ownerId);
    await _saveAll(all);
  }

  // ── Public loadAll (used by backup) ──────────────────────────────────────
  static Future<List<AppPhoto>> loadAll() => _loadAll();

  // ── Wipe all photo files and metadata (called by Storage.wipeAll) ─────────
  static Future<void> wipeAll() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'wrecklog', 'photos'));
    if (dir.existsSync()) await dir.delete(recursive: true);
  }

  // ── Internals ─────────────────────────────────────────────────────────────

  /// Path: .../wrecklog/photos/metadata.json
  static Future<File> _metadataFile() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'wrecklog', 'photos'));
    await dir.create(recursive: true);
    return File(p.join(dir.path, 'metadata.json'));
  }

  /// Loads all photo metadata, migrating from SharedPreferences if needed.
  static Future<List<AppPhoto>> _loadAll() async {
    await _migrateFromPrefsIfNeeded();
    final file = await _metadataFile();

    // Recover from a write that was interrupted before rename completed —
    // if .tmp exists but metadata.json doesn't, rename .tmp to recover it.
    final tmp = File('${file.path}.tmp');
    if (!file.existsSync() && tmp.existsSync()) {
      try { await tmp.rename(file.path); } catch (_) {}
    }

    if (!file.existsSync()) return [];
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => AppPhoto.tryFromJson(e as Map<String, dynamic>))
          .whereType<AppPhoto>()
          .toList();
    } catch (e) {
      // Corrupted metadata file — return empty rather than crash.
      if (kDebugMode) debugPrint('PhotoStorage: failed to read metadata: $e');
      return [];
    }
  }

  static Future<void> _saveAll(List<AppPhoto> photos) async {
    final file = await _metadataFile();
    final jsonString = const JsonEncoder.withIndent('  ')
        .convert(photos.map((ph) => ph.toJson()).toList());

    // Atomic write — write to .tmp, delete existing target, then rename.
    // Deleting first avoids rename failures on filesystems where rename
    // won't overwrite an existing file.
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonString);
    try {
      if (file.existsSync()) await file.delete();
      await tmp.rename(file.path);
    } catch (e) {
      // Fallback: copy bytes then clean up tmp
      if (kDebugMode) debugPrint('PhotoStorage: atomic rename failed, using copy fallback: $e');
      try {
        await tmp.copy(file.path);
      } finally {
        if (tmp.existsSync()) await tmp.delete();
      }
    }
  }

  /// One-time migration: moves existing data from SharedPreferences to JSON file.
  /// Safe to call every time — exits immediately once migration is done.
  static Future<void> _migrateFromPrefsIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLegacyPrefsKey);
    if (raw == null) return; // Nothing to migrate

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final photos = list
          .map((e) => AppPhoto.tryFromJson(e as Map<String, dynamic>))
          .whereType<AppPhoto>()
          .toList();

      final file = await _metadataFile();
      if (!file.existsSync()) {
        // Only write if file doesn't exist — never overwrite newer data.
        // Use _saveAll so migration also benefits from atomic write.
        await _saveAll(photos);
      }
    } catch (e) {
      // Migration failed — leave prefs key in place, will retry next launch.
      if (kDebugMode) debugPrint('PhotoStorage: migration from prefs failed: $e');
      return;
    }

    // Clean up legacy key
    await prefs.remove(_kLegacyPrefsKey);
  }

  static void _deleteFile(String path) {
    try {
      final f = File(path);
      if (f.existsSync()) f.deleteSync();
    } catch (e) {
      if (kDebugMode) debugPrint('PhotoStorage: failed to delete file $path: $e');
    }
  }

  static Future<Directory> _photoDir(String ownerType, String ownerId) async {
    final base = await getApplicationDocumentsDirectory();
    return Directory(
        p.join(base.path, 'wrecklog', 'photos', '${ownerType}s', ownerId));
  }

  static String _newId() =>
      'P${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9999)}';
}

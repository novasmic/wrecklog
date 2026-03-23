// lib/photo_storage_io.dart
// Android + iOS implementation — stores JPEG files in app documents directory.
// Metadata stored in a JSON file (no SharedPreferences size limits).
// Never imported directly — used via photo_storage.dart conditional export.
//
// Path storage strategy (v2):
//   Paths are stored RELATIVE to getApplicationDocumentsDirectory(), e.g.
//   "wrecklog/photos/vehicles/abc/P123.jpg".
//   On load, they are resolved to absolute paths for in-memory use.
//   On save, they are converted back to relative paths.
//   Old records with stale absolute paths (from before this change) are
//   automatically rebased to the current documents directory on first load,
//   healing the iOS "broken photos after TestFlight update" issue.

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

    // In-memory photo uses the current absolute path.
    // _saveAll converts to relative before writing to disk.
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
  /// All returned AppPhoto records have current absolute paths.
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
      final photos = list
          .map((e) => AppPhoto.tryFromJson(e as Map<String, dynamic>))
          .whereType<AppPhoto>()
          .toList();

      // Rebase paths to the current documents directory.
      // This fixes stale absolute paths after iOS app container UUID changes
      // (e.g. after a TestFlight update) and resolves relative paths stored
      // by newer versions of the app.
      final base = await getApplicationDocumentsDirectory();
      return photos.map((ph) => _withAbsolutePath(ph, base.path)).toList();
    } catch (e) {
      // Corrupted metadata file — return empty rather than crash.
      if (kDebugMode) debugPrint('PhotoStorage: failed to read metadata: $e');
      return [];
    }
  }

  /// Saves [photos] to disk, converting absolute paths to relative first so
  /// they survive future iOS app container UUID changes.
  static Future<void> _saveAll(List<AppPhoto> photos) async {
    final base = await getApplicationDocumentsDirectory();
    final toStore = photos
        .map((ph) => _withRelativePath(ph, base.path))
        .toList();
    final file = await _metadataFile();
    final jsonString = const JsonEncoder.withIndent('  ')
        .convert(toStore.map((ph) => ph.toJson()).toList());

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

  // ── Path helpers ──────────────────────────────────────────────────────────

  /// Returns [ph] with its pathOrData resolved to a current absolute path.
  ///
  /// Handles two cases:
  /// • Relative path (new format): joined with [basePath].
  /// • Stale absolute path (old format, e.g. after iOS UUID change):
  ///   finds the "Documents/wrecklog" segment and rebases onto [basePath].
  static AppPhoto _withAbsolutePath(AppPhoto ph, String basePath) {
    final path = ph.pathOrData;

    String abs;
    if (!p.isAbsolute(path)) {
      // Relative — just resolve against current documents dir.
      abs = p.join(basePath, path);
    } else {
      // Absolute — may be stale. Find the Documents/wrecklog boundary and
      // rebase everything from "wrecklog" onward onto the current base path.
      final marker = 'Documents${p.separator}wrecklog';
      final idx = path.indexOf(marker);
      if (idx < 0) return ph; // unknown format, leave as-is
      final rel = path.substring(idx + 'Documents${p.separator}'.length);
      abs = p.join(basePath, rel);
    }

    if (abs == path) return ph;
    return AppPhoto(
      id:        ph.id,
      ownerType: ph.ownerType,
      ownerId:   ph.ownerId,
      createdAt: ph.createdAt,
      pathOrData: abs,
      remoteUrl: ph.remoteUrl,
    );
  }

  /// Returns [ph] with its pathOrData converted to a relative path by
  /// stripping the [basePath] prefix.  If the path is already relative or
  /// cannot be stripped, [ph] is returned unchanged.
  static AppPhoto _withRelativePath(AppPhoto ph, String basePath) {
    final path = ph.pathOrData;
    if (!p.isAbsolute(path)) return ph; // already relative
    final prefix = basePath.endsWith(p.separator)
        ? basePath
        : '$basePath${p.separator}';
    if (!path.startsWith(prefix)) return ph; // unknown prefix, leave as-is
    final rel = path.substring(prefix.length);
    if (rel == path) return ph;
    return AppPhoto(
      id:        ph.id,
      ownerType: ph.ownerType,
      ownerId:   ph.ownerId,
      createdAt: ph.createdAt,
      pathOrData: rel,
      remoteUrl: ph.remoteUrl,
    );
  }
}

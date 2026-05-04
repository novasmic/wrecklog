import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../photo_storage_model.dart';
import 'error_service.dart';

/// Firestore structure:
///   users/{uid}/vehicles/{vehicleId}          — vehicle record
///   users/{uid}/vehicles/{vehicleId}/parts/{partId}  — part record (includes listings array)
///
/// All writes are fire-and-forget — local storage is still the source of truth.
/// Failures are logged in debug mode but never surface to the user.

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _vehiclesCol(String uid) =>
      _db.collection('users').doc(uid).collection('vehicles');

  static CollectionReference<Map<String, dynamic>> _partsCol(String uid, String vehicleId) =>
      _vehiclesCol(uid).doc(vehicleId).collection('parts');

  static CollectionReference<Map<String, dynamic>> _interchangeCol(String uid) =>
      _db.collection('users').doc(uid).collection('interchangeGroups');

  // ── Interchange groups ─────────────────────────────────────────────────────

  static Future<void> upsertInterchangeGroup(String uid, Map<String, dynamic> groupJson) async {
    try {
      final id = groupJson['id'] as String;
      final data = Map<String, dynamic>.from(groupJson)
        ..removeWhere((_, v) => v == null)
        ..['syncedAt'] = FieldValue.serverTimestamp();
      await _interchangeCol(uid).doc(id).set(data, SetOptions(merge: true));
    } catch (e, st) {
      logError('Firestore upsertInterchangeGroup', e, st);
    }
  }

  static Future<void> deleteInterchangeGroup(String uid, String groupId) async {
    try {
      await _interchangeCol(uid).doc(groupId).delete();
    } catch (e, st) {
      logError('Firestore deleteInterchangeGroup', e, st);
    }
  }

  static Future<List<Map<String, dynamic>>> loadInterchangeGroups(String uid) async {
    try {
      final snap = await _interchangeCol(uid).get();
      return snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
    } catch (e, st) {
      logError('Firestore loadInterchangeGroups', e, st);
      return [];
    }
  }

  // ── Vehicles ───────────────────────────────────────────────────────────────

  static Future<void> upsertVehicle(String uid, Map<String, dynamic> vehicleJson) async {
    try {
      final id = vehicleJson['id'] as String;
      final data = Map<String, dynamic>.from(vehicleJson)
        ..remove('parts') // parts stored in subcollection
        ..removeWhere((_, v) => v == null) // preserve web-only fields (e.g. VIN, series entered on web)
        ..['syncedAt'] = FieldValue.serverTimestamp();
      await _vehiclesCol(uid).doc(id).set(data, SetOptions(merge: true));
    } catch (e, st) {
      logError('Firestore upsertVehicle', e, st);
    }
  }

  static Future<void> deleteVehicle(String uid, String vehicleId) async {
    try {
      // Delete all parts first
      final parts = await _partsCol(uid, vehicleId).get();
      for (final doc in parts.docs) {
        await doc.reference.delete();
      }
      await _vehiclesCol(uid).doc(vehicleId).delete();
    } catch (e, st) {
      logError('Firestore deleteVehicle', e, st);
    }
  }

  // ── Parts ──────────────────────────────────────────────────────────────────

  static Future<void> upsertPart(String uid, String vehicleId, Map<String, dynamic> partJson) async {
    try {
      final id = partJson['id'] as String;
      final data = Map<String, dynamic>.from(partJson)
        ..removeWhere((_, v) => v == null) // preserve web-only fields; use clearPartSale() to explicitly delete
        ..['syncedAt'] = FieldValue.serverTimestamp();
      await _partsCol(uid, vehicleId).doc(id).set(data, SetOptions(merge: true));
    } catch (e, st) {
      logError('Firestore upsertPart', e, st);
    }
  }

  static Future<void> clearPartSale(String uid, String vehicleId, String partId) async {
    try {
      await _partsCol(uid, vehicleId).doc(partId).update({
        'salePriceCents': FieldValue.delete(),
        'dateSold':       FieldValue.delete(),
      });
    } catch (e, st) {
      logError('Firestore clearPartSale', e, st);
    }
  }

  static Future<void> deletePart(String uid, String vehicleId, String partId) async {
    try {
      await _partsCol(uid, vehicleId).doc(partId).delete();
    } catch (e, st) {
      logError('Firestore deletePart', e, st);
    }
  }

  // ── Pro status ─────────────────────────────────────────────────────────────

  static Future<void> updateUserPro(String uid, bool isPro) async {
    try {
      await _db.collection('users').doc(uid).set({
        'isPro': isPro,
        'proUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e, st) {
      logError('Firestore updateUserPro', e, st);
    }
  }

  // ── Photo metadata ─────────────────────────────────────────────────────────

  static CollectionReference<Map<String, dynamic>> _photoMetaCol(String uid) =>
      _db.collection('users').doc(uid).collection('photoMeta');

  static Future<void> upsertPhotoMeta(String uid, AppPhoto photo) async {
    if (photo.remoteUrl == null) return;
    try {
      await _photoMetaCol(uid).doc(photo.id).set({
        'id':        photo.id,
        'ownerType': photo.ownerType,
        'ownerId':   photo.ownerId,
        'remoteUrl': photo.remoteUrl,
        'createdAt': photo.createdAt,
      }, SetOptions(merge: true));
    } catch (e, st) {
      logError('Firestore upsertPhotoMeta', e, st);
    }
  }

  static Future<void> deletePhotoMeta(String uid, String photoId) async {
    try {
      await _photoMetaCol(uid).doc(photoId).delete();
    } catch (e, st) {
      logError('Firestore deletePhotoMeta', e, st);
    }
  }

  /// Returns the set of photo IDs that exist in Firestore photoMeta, or null
  /// if the fetch failed. Callers must treat null as "unknown" and skip deletion
  /// to avoid wiping local photos when offline or on network error.
  static Future<Set<String>?> getPhotoMetaIds(String uid) async {
    try {
      final snap = await _photoMetaCol(uid).get();
      return snap.docs.map((d) => d.id).toSet();
    } catch (e, st) {
      logError('Firestore getPhotoMetaIds', e, st);
      return null;
    }
  }

  // ── User profile ───────────────────────────────────────────────────────────

  static Future<void> ensureUserProfile(String uid, String email) async {
    try {
      final doc = _db.collection('users').doc(uid);
      await doc.set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e, st) {
      logError('Firestore ensureUserProfile', e, st);
    }
  }

  // ── Migration — upload all existing local data on first sign-in ────────────
  //
  // DANGER: kFirestoreSyncVersion (in main.dart) controls when this runs.
  // Bumping that constant forces a full re-upload for every existing user.
  // This function reads Firestore first so it can never overwrite a non-null
  // cloud value with a local null — but still: do not bump the version number
  // unless you have a concrete reason and have tested the migration path.

  static Future<void> migrateLocalData(
    String uid,
    List<Map<String, dynamic>> vehiclesJson,
  ) async {
    try {
      // Read existing Firestore data first so we can preserve fields that the
      // mobile app doesn't manage (e.g. VIN, bid price, series entered on web).
      // This is defence-in-depth on top of null-stripping: Firestore wins when
      // local is null, local wins when local has an actual value.
      final fsVehicles = <String, Map<String, dynamic>>{};
      final fsParts    = <String, Map<String, dynamic>>{};
      {
        final vSnap = await _vehiclesCol(uid).get();
        for (final vDoc in vSnap.docs) {
          fsVehicles[vDoc.id] = _stripTimestamps(vDoc.data());
          final pSnap = await _partsCol(uid, vDoc.id).get();
          for (final pDoc in pSnap.docs) {
            fsParts['${vDoc.id}/${pDoc.id}'] = _stripTimestamps(pDoc.data());
          }
        }
      }

      var batch = _db.batch();
      int ops = 0;

      Future<void> maybeFlush() async {
        if (ops >= 490) {
          await batch.commit();
          batch = _db.batch();
          ops = 0;
        }
      }

      for (final vJson in vehiclesJson) {
        final vehicleId = vJson['id'] as String;
        final parts = (vJson['parts'] as List<dynamic>?) ?? [];

        final vehicleData = _safeLocalOverFirestore(
          firestore: fsVehicles[vehicleId],
          local: Map<String, dynamic>.from(vJson)..remove('parts'),
        )..['syncedAt'] = FieldValue.serverTimestamp();

        batch.set(
          _vehiclesCol(uid).doc(vehicleId),
          vehicleData,
          SetOptions(merge: true),
        );
        ops++;
        await maybeFlush();

        for (final pJson in parts) {
          final partMap = Map<String, dynamic>.from(pJson as Map<String, dynamic>);
          final partId  = partMap['id'] as String;
          final partData = _safeLocalOverFirestore(
            firestore: fsParts['$vehicleId/$partId'],
            local: partMap,
          )..['syncedAt'] = FieldValue.serverTimestamp();
          batch.set(
            _partsCol(uid, vehicleId).doc(partId),
            partData,
            SetOptions(merge: true),
          );
          ops++;
          await maybeFlush();
        }
      }

      if (ops > 0) await batch.commit();

      await _db.collection('users').doc(uid).set(
        {'migratedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );

      if (kDebugMode) debugPrint('Firestore migration complete for $uid');
    } catch (e, st) {
      logError('Firestore migrateLocalData', e, st);
    }
  }

  // Merges local data over existing Firestore data.
  // Local non-null values win (they reflect actual user edits on device).
  // Firestore non-null values are preserved when local is null or absent.
  static Map<String, dynamic> _safeLocalOverFirestore({
    required Map<String, dynamic>? firestore,
    required Map<String, dynamic> local,
  }) {
    final localNonNull = Map<String, dynamic>.from(local)
      ..removeWhere((_, v) => v == null);
    if (firestore == null) return localNonNull;
    return {...firestore, ...localNonNull};
  }

  /// Returns true if this user has already been migrated.
  static Future<bool> hasMigrated(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data()?['migratedAt'] != null;
    } catch (e) {
      return false;
    }
  }

  // ── Delete all — wipe everything from Firestore for a user ────────────────

  /// Deletes all vehicles, parts, photoMeta, and the user profile document.
  static Future<void> deleteAllUserData(String uid) async {
    try {
      // Delete all vehicles and their parts subcollections.
      final vehicles = await _vehiclesCol(uid).get();
      for (final vDoc in vehicles.docs) {
        final parts = await _partsCol(uid, vDoc.id).get();
        for (final pDoc in parts.docs) {
          await pDoc.reference.delete();
        }
        await vDoc.reference.delete();
      }

      // Delete all photoMeta documents.
      final photoMeta = await _db
          .collection('users')
          .doc(uid)
          .collection('photoMeta')
          .get();
      for (final doc in photoMeta.docs) {
        await doc.reference.delete();
      }

      // Clear migratedAt so a fresh device can re-upload, but preserve
      // isPro and other profile fields so web access isn't lost.
      await _db.collection('users').doc(uid).update(
        {'migratedAt': FieldValue.delete()},
      );

      if (kDebugMode) debugPrint('Firestore: deleted all data for $uid');
    } catch (e, st) {
      logError('Firestore deleteAllUserData', e, st);
      rethrow;
    }
  }

  // ── Restore — pull all cloud data down to a new/wiped device ──────────────

  /// Fetches all vehicles and their parts from Firestore.
  /// Returns a list of vehicle JSON maps (each with a nested 'parts' list),
  /// ready to pass to Vehicle.fromJson(). Returns empty list on failure.
  static Future<List<Map<String, dynamic>>> restoreFromFirestore(String uid) async {
    try {
      final vehiclesSnap = await _vehiclesCol(uid).get();
      if (vehiclesSnap.docs.isEmpty) return [];

      final result = <Map<String, dynamic>>[];
      for (final vDoc in vehiclesSnap.docs) {
        final vehicleData = _stripTimestamps(vDoc.data());
        vehicleData['id'] = vDoc.id;

        final partsSnap = await _partsCol(uid, vDoc.id).get();
        final parts = <Map<String, dynamic>>[];
        for (final pDoc in partsSnap.docs) {
          final partData = _stripTimestamps(pDoc.data());
          partData['id'] = pDoc.id;
          parts.add(partData);
        }
        vehicleData['parts'] = parts;
        result.add(vehicleData);
      }

      if (kDebugMode) debugPrint('Firestore restore: ${result.length} vehicles');
      return result;
    } catch (e, st) {
      logError('Firestore restoreFromFirestore', e, st);
      return [];
    }
  }

  static Map<String, dynamic> _stripTimestamps(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    for (final entry in data.entries) {
      final v = entry.value;
      if (v is Timestamp) continue; // drop server timestamps
      if (v is Map) {
        result[entry.key] = _stripTimestamps(Map<String, dynamic>.from(v));
      } else if (v is List) {
        result[entry.key] = v
            .whereType<Object>()
            .where((e) => e is! Timestamp)
            .map((e) => e is Map ? _stripTimestamps(Map<String, dynamic>.from(e)) : e)
            .toList();
      } else {
        result[entry.key] = v;
      }
    }
    return result;
  }
}

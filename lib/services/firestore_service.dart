import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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

  // ── Vehicles ───────────────────────────────────────────────────────────────

  static Future<void> upsertVehicle(String uid, Map<String, dynamic> vehicleJson) async {
    try {
      final id = vehicleJson['id'] as String;
      final data = Map<String, dynamic>.from(vehicleJson)
        ..remove('parts') // parts stored in subcollection
        ..['syncedAt'] = FieldValue.serverTimestamp();
      await _vehiclesCol(uid).doc(id).set(data, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) debugPrint('Firestore upsertVehicle error: $e');
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
    } catch (e) {
      if (kDebugMode) debugPrint('Firestore deleteVehicle error: $e');
    }
  }

  // ── Parts ──────────────────────────────────────────────────────────────────

  static Future<void> upsertPart(String uid, String vehicleId, Map<String, dynamic> partJson) async {
    try {
      final id = partJson['id'] as String;
      final data = Map<String, dynamic>.from(partJson)
        ..['syncedAt'] = FieldValue.serverTimestamp();
      await _partsCol(uid, vehicleId).doc(id).set(data, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) debugPrint('Firestore upsertPart error: $e');
    }
  }

  static Future<void> deletePart(String uid, String vehicleId, String partId) async {
    try {
      await _partsCol(uid, vehicleId).doc(partId).delete();
    } catch (e) {
      if (kDebugMode) debugPrint('Firestore deletePart error: $e');
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
    } catch (e) {
      if (kDebugMode) debugPrint('Firestore ensureUserProfile error: $e');
    }
  }

  // ── Migration — upload all existing local data on first sign-in ────────────

  static Future<void> migrateLocalData(
    String uid,
    List<Map<String, dynamic>> vehiclesJson,
  ) async {
    try {
      final batch = _db.batch();
      int ops = 0;

      for (final vJson in vehiclesJson) {
        final vehicleId = vJson['id'] as String;
        final parts = (vJson['parts'] as List<dynamic>?) ?? [];

        final vehicleData = Map<String, dynamic>.from(vJson)
          ..remove('parts')
          ..['syncedAt'] = FieldValue.serverTimestamp();

        batch.set(
          _vehiclesCol(uid).doc(vehicleId),
          vehicleData,
          SetOptions(merge: true),
        );
        ops++;

        for (final pJson in parts) {
          final partData = Map<String, dynamic>.from(pJson as Map<String, dynamic>)
            ..['syncedAt'] = FieldValue.serverTimestamp();
          batch.set(
            _partsCol(uid, vehicleId).doc(partData['id'] as String),
            partData,
            SetOptions(merge: true),
          );
          ops++;

          // Firestore batches are limited to 500 operations — commit and start fresh.
          if (ops >= 490) {
            await batch.commit();
            ops = 0;
          }
        }
      }

      if (ops > 0) await batch.commit();

      // Mark migration as done so we don't repeat it.
      await _db.collection('users').doc(uid).set(
        {'migratedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );

      if (kDebugMode) debugPrint('Firestore migration complete for $uid');
    } catch (e) {
      if (kDebugMode) debugPrint('Firestore migrateLocalData error: $e');
    }
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
}

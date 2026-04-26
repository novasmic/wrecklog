import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'error_service.dart';
import '../photo_storage_io.dart';

/// Called when Firestore has changes for a vehicle's parts.
/// [vehicleId]      — which vehicle changed
/// [remoteParts]    — sanitised part JSONs; include [_syncedAtMs] key (ms since epoch)
/// [deletedPartIds] — part IDs deleted from Firestore
typedef FirestoreUpdateCallback = void Function({
  required String vehicleId,
  required List<Map<String, dynamic>> remoteParts,
  required List<String> deletedPartIds,
});

/// Called when a vehicle document is added or modified in Firestore.
typedef FirestoreVehicleCallback = void Function({
  required String vehicleId,
  required Map<String, dynamic> vehicleData,
  required bool isNew,
});

/// Called when a vehicle is deleted from Firestore.
typedef FirestoreVehicleDeleteCallback = void Function(String vehicleId);

/// Listens to Firestore in real-time and calls [callback] when parts change.
/// Start it when the user signs in; stop it when they sign out.
class FirestoreSync {
  static final FirestoreSync instance = FirestoreSync._();
  FirestoreSync._();

  static final _db = FirebaseFirestore.instance;

  /// Set these before calling [start] so updates reach the UI.
  FirestoreUpdateCallback? callback;
  FirestoreVehicleCallback? vehicleCallback;
  FirestoreVehicleDeleteCallback? vehicleDeleteCallback;

  StreamSubscription<QuerySnapshot>? _vehiclesSub;
  StreamSubscription<QuerySnapshot>? _photoMetaSub;
  final Map<String, StreamSubscription<QuerySnapshot>> _partSubs = {};
  bool _active = false;

  // ── Public API ──────────────────────────────────────────────────────────────

  void start(String uid) {
    if (_active) stop();
    _active = true;

    _vehiclesSub = _db
        .collection('users')
        .doc(uid)
        .collection('vehicles')
        .snapshots()
        .listen(
          (snap) => _onVehiclesChanged(uid, snap),
          onError: (e, st) => logError('FirestoreSync vehicles stream', e, st),
        );

    _photoMetaSub = _db
        .collection('users')
        .doc(uid)
        .collection('photoMeta')
        .snapshots()
        .listen(
          _onPhotoMetaChanged,
          onError: (e, st) => logError('FirestoreSync photoMeta stream', e, st),
        );
  }

  void stop() {
    _active = false;
    _vehiclesSub?.cancel();
    _vehiclesSub = null;
    _photoMetaSub?.cancel();
    _photoMetaSub = null;
    for (final sub in _partSubs.values) { sub.cancel(); }
    _partSubs.clear();
  }

  // ── PhotoMeta listener ──────────────────────────────────────────────────────

  void _onPhotoMetaChanged(QuerySnapshot snap) {
    for (final change in snap.docChanges) {
      if (change.type == DocumentChangeType.removed) {
        PhotoStorage.deleteLocalById(change.doc.id);
      }
    }
  }

  // ── Vehicle listener ────────────────────────────────────────────────────────

  void _onVehiclesChanged(String uid, QuerySnapshot snap) {
    for (final change in snap.docChanges) {
      final vehicleId = change.doc.id;

      if (change.type == DocumentChangeType.removed) {
        _partSubs[vehicleId]?.cancel();
        _partSubs.remove(vehicleId);
        vehicleDeleteCallback?.call(vehicleId);
      } else {
        final isNew = change.type == DocumentChangeType.added;
        final data  = _sanitise(change.doc.data() as Map<String, dynamic>);
        data['id']  = vehicleId;
        vehicleCallback?.call(
          vehicleId:   vehicleId,
          vehicleData: data,
          isNew:       isNew,
        );

        // Attach a parts listener for this vehicle if not already watching it.
        _partSubs.putIfAbsent(vehicleId, () {
          return _db
              .collection('users')
              .doc(uid)
              .collection('vehicles')
              .doc(vehicleId)
              .collection('parts')
              .snapshots()
              .listen(
                (partSnap) => _onPartsChanged(vehicleId, partSnap),
                onError: (e, st) => logError('FirestoreSync parts[$vehicleId] stream', e, st),
              );
        });
      }
    }
  }

  // ── Parts listener ──────────────────────────────────────────────────────────

  void _onPartsChanged(String vehicleId, QuerySnapshot snap) {
    if (!_active || callback == null) return;

    final remoteParts   = <Map<String, dynamic>>[];
    final deletedPartIds = <String>[];

    for (final change in snap.docChanges) {
      if (change.type == DocumentChangeType.removed) {
        deletedPartIds.add(change.doc.id);
        continue;
      }

      final raw      = change.doc.data() as Map<String, dynamic>;
      final sanitised = _sanitise(raw);
      sanitised['id'] = change.doc.id;

      // Preserve syncedAt as milliseconds for conflict resolution.
      final syncedAt = raw['syncedAt'];
      if (syncedAt is Timestamp) {
        sanitised['_syncedAtMs'] = syncedAt.millisecondsSinceEpoch;
      }

      remoteParts.add(sanitised);
    }

    if (remoteParts.isEmpty && deletedPartIds.isEmpty) return;

    callback!(
      vehicleId:      vehicleId,
      remoteParts:    remoteParts,
      deletedPartIds: deletedPartIds,
    );
  }

  // ── Sanitise — strip Timestamps, deep-convert JS objects ───────────────────

  static Map<String, dynamic> _sanitise(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    for (final entry in data.entries) {
      final v = entry.value;
      if (v is Timestamp) continue;
      if (v is Map) {
        result[entry.key] = _sanitise(Map<String, dynamic>.from(v));
      } else if (v is List) {
        result[entry.key] = v
            .map((e) {
              if (e is Timestamp) return null;
              if (e is Map) return _sanitise(Map<String, dynamic>.from(e));
              return e;
            })
            .where((e) => e != null)
            .toList();
      } else {
        result[entry.key] = v;
      }
    }
    return result;
  }
}

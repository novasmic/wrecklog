// lib/photo_storage_model.dart
// Platform-agnostic photo model used by all storage implementations.

class AppPhoto {
  final String id;
  final String ownerType;   // "vehicle" or "part"
  final String ownerId;
  final int    createdAt;   // epoch ms
  /// IO:  absolute file path on device
  /// Web: base64-encoded JPEG string
  final String pathOrData;
  final String? remoteUrl;  // reserved for future cloud sync

  AppPhoto({
    required this.id,
    required this.ownerType,
    required this.ownerId,
    required this.createdAt,
    required this.pathOrData,
    this.remoteUrl,
  });

  Map<String, dynamic> toJson() => {
    'id':         id,
    'ownerType':  ownerType,
    'ownerId':    ownerId,
    'createdAt':  createdAt,
    'pathOrData': pathOrData,
    if (remoteUrl != null) 'remoteUrl': remoteUrl,
  };

  /// Returns null if any required field is missing or the wrong type.
  /// Callers should filter nulls so one bad record never crashes the app.
  static AppPhoto? tryFromJson(Map<String, dynamic> j) {
    try {
      final id         = j['id']         as String?;
      final ownerType  = j['ownerType']  as String?;
      final ownerId    = j['ownerId']    as String?;
      final createdAt  = j['createdAt']  as int?;
      final pathOrData = j['pathOrData'] as String?;
      if (id == null || ownerType == null || ownerId == null ||
          createdAt == null || pathOrData == null) return null;
      return AppPhoto(
        id:         id,
        ownerType:  ownerType,
        ownerId:    ownerId,
        createdAt:  createdAt,
        pathOrData: pathOrData,
        remoteUrl:  j['remoteUrl'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  // Keep fromJson for compatibility — throws on bad data (internal use only).
  factory AppPhoto.fromJson(Map<String, dynamic> j) => AppPhoto(
    id:          j['id']         as String,
    ownerType:   j['ownerType']  as String,
    ownerId:     j['ownerId']    as String,
    createdAt:   j['createdAt']  as int,
    pathOrData:  j['pathOrData'] as String,
    remoteUrl:   j['remoteUrl']  as String?,
  );
}

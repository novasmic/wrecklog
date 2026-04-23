import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Logs an error to Crashlytics in production and debugPrint in debug mode.
/// Use this everywhere instead of bare `if (kDebugMode) debugPrint(...)`.
void logError(String context, Object e, [StackTrace? st]) {
  if (kDebugMode) debugPrint('$context: $e');
  FirebaseCrashlytics.instance.recordError(
    e,
    st ?? StackTrace.current,
    reason: context,
    fatal: false,
  );
}

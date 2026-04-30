import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_service.dart';

class RatingService {
  static const _kHasRated = 'has_rated_v1';

  static Future<bool> hasRated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kHasRated) ?? false;
  }

  static Future<void> submitRating(int stars, {String? comment}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHasRated, true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final docId = uid ?? 'anon_${DateTime.now().millisecondsSinceEpoch}';
      await FirebaseFirestore.instance.collection('ratings').doc(docId).set({
        'stars': stars,
        'comment': comment ?? '',
        'uid': uid,
        'platform': defaultTargetPlatform.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (stars > 0) await AnalyticsService.logUserRating(stars);
    } catch (e) {
      if (kDebugMode) debugPrint('RatingService.submitRating error: $e');
    }
  }
}

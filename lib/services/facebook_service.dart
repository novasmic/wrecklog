import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';

class FacebookService {
  static final _fb = FacebookAppEvents();

  static Future<void> init() async {
    try {
      await _fb.setAutoLogAppEventsEnabled(true);
      await _fb.logEvent(name: 'fb_mobile_activate_app');
    } catch (e) {
      if (kDebugMode) debugPrint('FacebookService.init error: $e');
    }
  }

  static Future<void> logPurchase(double amount, String currency) async {
    try {
      await _fb.logPurchase(amount: amount, currency: currency);
    } catch (e) {
      if (kDebugMode) debugPrint('Facebook logPurchase error: $e');
    }
  }
}

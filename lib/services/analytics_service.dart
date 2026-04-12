import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final _analytics = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  static Future<void> logAppOpen() async {
    try {
      await _analytics.logAppOpen();
    } catch (e) {
      if (kDebugMode) debugPrint('Analytics logAppOpen error: $e');
    }
  }

  static Future<void> logSubscriptionStarted(String productId) async {
    try {
      await _analytics.logEvent(
        name: 'subscription_started',
        parameters: {'product_id': productId},
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Analytics logSubscriptionStarted error: $e');
    }
  }

  static Future<void> logSubscriptionCompleted(String productId, double amount, String currency) async {
    try {
      await _analytics.logPurchase(
        currency: currency,
        value: amount,
        items: [AnalyticsEventItem(itemId: productId, itemName: productId)],
      );
      await _analytics.logEvent(
        name: 'subscription_completed',
        parameters: {'product_id': productId},
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Analytics logSubscriptionCompleted error: $e');
    }
  }

  static Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      if (kDebugMode) debugPrint('Analytics logScreenView error: $e');
    }
  }
}

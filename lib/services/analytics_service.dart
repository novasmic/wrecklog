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

  static Future<void> logVehicleCreated(String make, String model, int year) async {
    try {
      await _analytics.logEvent(
        name: 'vehicle_created',
        parameters: {'make': make, 'model': model, 'year': year},
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Analytics logVehicleCreated error: $e');
    }
  }

  static Future<void> logPartAdded(String partName, String? category, String? vehicleMake, String? vehicleModel) async {
    try {
      await _analytics.logEvent(
        name: 'part_added',
        parameters: {
          'part_name': partName,
          if (category != null) 'category': category,
          if (vehicleMake != null) 'vehicle_make': vehicleMake,
          if (vehicleModel != null) 'vehicle_model': vehicleModel,
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Analytics logPartAdded error: $e');
    }
  }

  static Future<void> logPartSold(String partName, int? salePriceCents, String? category) async {
    try {
      await _analytics.logEvent(
        name: 'part_sold',
        parameters: {
          'part_name': partName,
          if (salePriceCents != null) 'sale_price_cents': salePriceCents,
          if (category != null) 'category': category,
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Analytics logPartSold error: $e');
    }
  }

  static Future<void> logListingAdded(String platform) async {
    try {
      await _analytics.logEvent(
        name: 'listing_added',
        parameters: {'platform': platform},
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Analytics logListingAdded error: $e');
    }
  }

  static Future<void> logUpgradeViewed() async {
    try {
      await _analytics.logEvent(name: 'upgrade_viewed');
    } catch (e) {
      if (kDebugMode) debugPrint('Analytics logUpgradeViewed error: $e');
    }
  }

  static Future<void> logUserRating(int stars) async {
    try {
      await _analytics.logEvent(
        name: 'user_rating',
        parameters: {'stars': stars},
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Analytics logUserRating error: $e');
    }
  }
}

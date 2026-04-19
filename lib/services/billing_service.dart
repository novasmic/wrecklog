import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'facebook_service.dart';
import 'analytics_service.dart';

class BillingService extends ChangeNotifier {
  // ── Product IDs ────────────────────────────────────────────────────────────
  static const String kMonthlyId = 'wrecklog_pro_monthly';
  static const String kYearlyId  = 'wrecklog_pro_yearly';
  // Legacy one-time product — honoured so existing buyers keep Pro forever.
  static const String kLegacyId  = 'pro_unlock';

  static const Set<String> _allIds = {kMonthlyId, kYearlyId, kLegacyId};

  // Prefs key — session cache; re-verified with Play on every init.
  static const String _kProKey = 'is_pro';

  // ── State ──────────────────────────────────────────────────────────────────
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  bool isAvailable = false;
  bool isPro       = false;

  ProductDetails? monthlyProduct;
  ProductDetails? yearlyProduct;

  // ── Restore tracking ───────────────────────────────────────────────────────
  // _restoreInProgress: true while restore() is in flight.
  // _foundActive:       at least one active/restored purchase was seen.
  // _sawAnyCallback:    Play delivered at least one callback (even empty).
  //                     Used to distinguish "no active subs" from "no network".
  //
  // Revoke logic (evaluated after timeout):
  //   • Play responded with callbacks but no active sub → revoke
  //   • Play never responded (network issue) → preserve existing status
  bool _restoreInProgress = false;
  bool _foundActive       = false;
  bool _sawAnyCallback    = false;

  // ── Price getters ──────────────────────────────────────────────────────────
  // Return App Store / Play Store localised price when available.
  // Shows 'Loading…' if products haven't loaded yet — avoids showing wrong currency.
  String get monthlyPrice => monthlyProduct?.price ?? 'Loading…';
  String get yearlyPrice  => yearlyProduct?.price  ?? 'Loading…';

  // ── Init ───────────────────────────────────────────────────────────────────
  Future<void> init() async {
    // Load cached value so UI is not blank while we verify with Play.
    final prefs = await SharedPreferences.getInstance();
    isPro = prefs.getBool(_kProKey) ?? false;
    notifyListeners();

    try {
      isAvailable = await _iap.isAvailable();
    } catch (_) {
      isAvailable = false;
    }
    if (!isAvailable) return;

    // Query product details — wrapped so a network failure doesn't crash init.
    try {
      final response = await _iap.queryProductDetails(_allIds);
      for (final p in response.productDetails) {
        if (p.id == kMonthlyId) monthlyProduct = p;
        if (p.id == kYearlyId)  yearlyProduct  = p;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('IAP: failed to query products: $e');
      // Degrade gracefully — prices fall back to hardcoded strings.
    }

    _sub?.cancel();
    _sub = _iap.purchaseStream.listen(_handlePurchases);

    // Re-verify subscription status with Play — fire-and-forget so init()
    // returns immediately. The app shows the cached isPro value at once;
    // if Play revokes it, notifyListeners() updates the UI after the check.
    restore(); // ignore: unawaited_futures
  }

  // ── Purchase ───────────────────────────────────────────────────────────────
  Future<void> buyMonthly() async {
    if (!isAvailable || monthlyProduct == null) {
      throw Exception('Monthly subscription not available. Please check your connection and try again.');
    }
    await AnalyticsService.logCheckoutStarted(kMonthlyId);
    final param = PurchaseParam(productDetails: monthlyProduct!);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> buyYearly() async {
    if (!isAvailable || yearlyProduct == null) {
      throw Exception('Yearly subscription not available. Please check your connection and try again.');
    }
    await AnalyticsService.logCheckoutStarted(kYearlyId);
    final param = PurchaseParam(productDetails: yearlyProduct!);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  // Kept for any legacy call sites — routes to monthly.
  Future<void> buyPro() => buyMonthly();

  // ── Restore ────────────────────────────────────────────────────────────────
  Future<void> restore() async {
    if (!isAvailable) return;

    // Reset flags before every restore attempt.
    _restoreInProgress = true;
    _foundActive       = false;
    _sawAnyCallback    = false;

    await _iap.restorePurchases();

    // restorePurchases() is fire-and-forget — results arrive via purchaseStream.
    // Use an 8-second window (generous for slow networks) before evaluating.
    await Future.delayed(const Duration(seconds: 8));

    // Only revoke if Play actually responded but returned no active entitlement.
    // If _sawAnyCallback is false, Play never responded (network issue) —
    // preserve the user's existing Pro status rather than incorrectly revoking.
    if (_sawAnyCallback && !_foundActive) {
      await _revokePro();
    }

    _restoreInProgress = false;
  }

  // ── Grant / revoke ─────────────────────────────────────────────────────────
  Future<void> _grantPro() async {
    if (isPro) return;
    isPro = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kProKey, true);
    notifyListeners();
  }

  Future<void> _revokePro() async {
    if (!isPro) return;
    isPro = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kProKey, false);
    notifyListeners();
  }

  // ── Purchase stream handler ────────────────────────────────────────────────
  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    // An empty list means Play Store definitively returned "no purchases".
    // Non-empty lists are evaluated per-purchase below.
    if (_restoreInProgress && purchases.isEmpty) _sawAnyCallback = true;

    for (final p in purchases) {
      if (!_allIds.contains(p.productID)) continue;

      switch (p.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Minimal receipt check: ensure Play provided a verification token.
          // Full server-side validation would call your backend here.
          final hasReceipt =
              p.verificationData.serverVerificationData.isNotEmpty;
          if (hasReceipt || kDebugMode) {
            // Purchased/restored = conclusive — Play responded.
            if (_restoreInProgress) {
              _sawAnyCallback = true;
              _foundActive = true;
            }
            // Log purchase event to Facebook (new purchases only, not restores).
            if (p.status == PurchaseStatus.purchased) {
              final product = p.productID == kMonthlyId
                  ? monthlyProduct
                  : p.productID == kYearlyId
                      ? yearlyProduct
                      : null;
              if (product != null) {
                await FacebookService.logPurchase(
                  product.rawPrice,
                  product.currencyCode,
                );
                await AnalyticsService.logPurchaseCompleted(
                  p.productID,
                  product.rawPrice,
                  product.currencyCode,
                );
              }
            }
            await _grantPro();
          } else {
            if (kDebugMode) {
              debugPrint('IAP: skipped grant — empty receipt for ${p.productID}');
            }
          }
          break;
        case PurchaseStatus.error:
          // Error is inconclusive — could be transient network failure.
          // Do NOT set _sawAnyCallback; preserve existing Pro status.
          if (kDebugMode) debugPrint('IAP error: ${p.error}');
          break;
        case PurchaseStatus.canceled:
          // Cancelled = Play responded, but subscription is not active.
          if (_restoreInProgress) _sawAnyCallback = true;
          break;
        case PurchaseStatus.pending:
          break;
      }

      if (p.pendingCompletePurchase) {
        await _iap.completePurchase(p);
      }
    }
  }

  // ── Dispose ────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

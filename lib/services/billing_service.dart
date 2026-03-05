import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  // _sawCallback:       stream fired at least once during this restore.
  // _foundActive:       at least one active/restored purchase was seen.
  //
  // Revoke logic (evaluated after delay):
  //   • Play returned items but none active  → sawCallback=true,  foundActive=false → revoke
  //   • Play returned nothing (empty list)   → sawCallback=false, foundActive=false → revoke
  //   • Play returned an active subscription → sawCallback=true,  foundActive=true  → keep
  bool _restoreInProgress = false;
  bool _sawCallback       = false;
  bool _foundActive       = false;

  // ── Price getters ──────────────────────────────────────────────────────────
  // Return Play Store localised price when available, fall back to AUD strings.
  String get monthlyPrice => monthlyProduct?.price ?? r'$4.99';
  String get yearlyPrice  => yearlyProduct?.price  ?? r'$39.99';

  // ── Init ───────────────────────────────────────────────────────────────────
  Future<void> init() async {
    // Load cached value so UI is not blank while we verify with Play.
    final prefs = await SharedPreferences.getInstance();
    isPro = prefs.getBool(_kProKey) ?? false;
    notifyListeners();

    isAvailable = await _iap.isAvailable();
    if (!isAvailable) return;

    final response = await _iap.queryProductDetails(_allIds);
    for (final p in response.productDetails) {
      if (p.id == kMonthlyId) monthlyProduct = p;
      if (p.id == kYearlyId)  yearlyProduct  = p;
    }

    _sub?.cancel();
    _sub = _iap.purchaseStream.listen(_handlePurchases);

    // Re-verify subscription status with Play on every launch.
    await restore();
  }

  // ── Purchase ───────────────────────────────────────────────────────────────
  Future<void> buyMonthly() async {
    if (!isAvailable || monthlyProduct == null) return;
    final param = PurchaseParam(productDetails: monthlyProduct!);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> buyYearly() async {
    if (!isAvailable || yearlyProduct == null) return;
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
    _sawCallback       = false;
    _foundActive       = false;

    await _iap.restorePurchases();

    // restorePurchases() is fire-and-forget — results arrive via purchaseStream.
    // Wait long enough for Play to deliver all callbacks before we decide.
    await Future.delayed(const Duration(seconds: 4));

    // Now evaluate: if no active entitlement was found, revoke cached Pro.
    // This covers both:
    //   a) Play returned purchase items but none were active (_sawCallback=true, _foundActive=false)
    //   b) Play returned an empty list — no purchases at all (_sawCallback=false, _foundActive=false)
    if (!_foundActive) {
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
    // Mark that Play responded during this restore window.
    if (_restoreInProgress) _sawCallback = true;

    for (final p in purchases) {
      if (!_allIds.contains(p.productID)) continue;

      switch (p.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (_restoreInProgress) _foundActive = true;
          await _grantPro();
          break;
        case PurchaseStatus.error:
          if (kDebugMode) debugPrint('IAP error: ${p.error}');
          break;
        case PurchaseStatus.canceled:
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
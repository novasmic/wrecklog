// lib/main.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'io_file_stub.dart' if (dart.library.io) 'io_file_io.dart';
import 'home_screen.dart';
// Web-only download (safe on Android/iOS via conditional import)
import 'web_download_stub.dart' if (dart.library.html) 'web_download_web.dart';

import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'landing_screen.dart';
import 'app_services.dart';
import 'photo_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:archive/archive_io.dart';

// Web-only download (safe because app is Web-first)

const double kPad = 12;
const double kRadius = 16;

const List<String> kPartCategories = [
  'Engine',
  'Transmission',
  'Driveline',
  'Suspension',
  'Steering',
  'Brakes',
  'Electrical',
  'Lighting',
  'Cooling',
  'Fuel System',
  'Exhaust',
  'Body',
  'Interior',
  'Wheels & Tyres',
  'Accessories',
  'Other',
];

class PartCategoryStorage {
  static const _key = 'part_categories';

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? List.from(kPartCategories);
  }

  static Future<void> save(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, categories);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await billing.init();
  await _loadDebugProFlag();
  await PresetGroupStorage.migrate(); // one-time preset key migration // no-op in release
  runApp(const WreckLogApp());
}

/// ----------------------------
/// App
/// ----------------------------
class WreckLogApp extends StatelessWidget {
  const WreckLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    // WreckLog brand colours
    const brandOrange = Color(0xFFE8700A);
    const bgDark = Color(0xFF0F0D0B);
    const surfaceCard = Color(0xFF211A0E);

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandOrange,
        brightness: Brightness.dark,
        primary: brandOrange,
        onPrimary: Colors.black,
        surface: bgDark,
        onSurface: Colors.white,
      ),
      visualDensity: VisualDensity.standard,
    );

    // Rebuild the app when billing state changes (e.g. after purchasing Pro)
    return AnimatedBuilder(
      animation: billing,
      builder: (context, _) => MaterialApp(
        title: 'WreckLog',
        debugShowCheckedModeBanner: false,
        theme: base.copyWith(
        scaffoldBackgroundColor: bgDark,
        appBarTheme: AppBarTheme(
          backgroundColor: bgDark,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: base.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: Colors.white,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF1A1408),
          indicatorColor: brandOrange.withValues(alpha: 0.2),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: brandOrange);
            }
            return IconThemeData(color: Colors.white.withValues(alpha: 0.5));
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: brandOrange, fontWeight: FontWeight.w700, fontSize: 12);
            }
            return TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12);
          }),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadius),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
        ),
        chipTheme: base.chipTheme.copyWith(
          labelStyle: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceCard,
          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: brandOrange, width: 1.5),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: brandOrange,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: brandOrange,
            side: const BorderSide(color: brandOrange),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: brandOrange,
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: brandOrange,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
        home: const AppShell(),
      ),
    );
  }
}

/// ----------------------------
/// App Shell (Tabs)
/// ----------------------------
class AppShell extends StatefulWidget {
  /// When true, skip the empty→landing redirect in _load().
  /// Set this when navigating here from LandingScreen so we don't
  /// immediately bounce back before the user has added anything.
  final bool allowEmpty;
  const AppShell({super.key, this.allowEmpty = false});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0; // 0=home, 1=vehicles, 2=search, 3=stats, 4=settings;
  bool _loading = true;
  List<Vehicle> _vehicles = [];
  Timer? _saveDebounce;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final v = await Storage.loadVehicles();
    if (!mounted) return;
    setState(() {
      _vehicles = v;
      _loading = false;
    });
    // Only redirect to landing on cold start — not when coming from LandingScreen
    if (v.isEmpty && mounted && !widget.allowEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LandingScreen()),
      );
    }
  }

  // Debounced save — batches rapid successive changes (e.g. adding many parts)
  // into a single disk write 500 ms after the last call.
  Future<void> _persist() async {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      Storage.saveVehicles(_vehicles).catchError((Object e) {
        if (kDebugMode) debugPrint('Storage.saveVehicles failed: $e');
        // Show a snackbar on the next frame if context is still valid.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Save failed — check device storage.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      });
    });
  }

  Future<void> _updateVehicle(Vehicle updated) async {
    setState(() {
      _vehicles = _vehicles.map((x) => x.id == updated.id ? updated : x).toList();
    });
    await _persist();
  }

  Future<void> _addVehicle(Vehicle created) async {
    setState(() => _vehicles = [created, ..._vehicles]);
    await _persist();
  }

  Future<void> _deleteVehicle(String id) async {
    final vehicleIdx = _vehicles.indexWhere((x) => x.id == id);
    if (vehicleIdx < 0) return; // vehicle not found — nothing to delete
    final vehicle = _vehicles[vehicleIdx];
    try {
      await PhotoStorage.deleteAllForOwner('vehicle', id);
      for (final part in vehicle.parts) {
        await PhotoStorage.deleteAllForOwner('part', part.id);
      }
      setState(() => _vehicles.removeWhere((x) => x.id == id));
      await _persist();
      // Last vehicle deleted → go back to landing immediately
      if (_vehicles.isEmpty && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LandingScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delete failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Home screen is the navigation hub — shown without a nav bar.
    if (_tab == 0) {
      return HomeScreen(
        onAddVehicle:   () async {
          final created = await Navigator.of(context).push<Vehicle>(
            MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
          );
          if (created == null || !context.mounted) return;
          await _addVehicle(created);
          if (!context.mounted) return;
          final updated = await Navigator.of(context).push<Vehicle>(
            MaterialPageRoute(builder: (_) => VehicleDetailScreen(vehicle: created, allVehicles: _vehicles)),
          );
          if (updated != null) await _updateVehicle(updated);
        },
        onViewVehicles: () => setState(() => _tab = 1),
        onSearchParts:  () => setState(() => _tab = 2),
        onStats:        () => setState(() => _tab = 3),
        onSettings:     () => setState(() => _tab = 4),
      );
    }

    // IndexedStack keeps all tab widgets alive — state (search query, scroll
    // position, etc.) is preserved when switching between tabs.
    // PopScope intercepts the back gesture to return to the home screen.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _tab = 0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _tab - 1,
          children: [
            VehiclesHome(
              loading: _loading,
              vehicles: _vehicles,
              onReload: _load,
              onAddVehicle: _addVehicle,
              onUpdateVehicle: _updateVehicle,
              onDeleteVehicle: _deleteVehicle,
            ),
          PartsSearchTab(
            vehicles: _vehicles,
            onOpenVehicle: (vehicleId) async {
              final vIdx = _vehicles.indexWhere((x) => x.id == vehicleId);
              if (vIdx < 0) return;
              final v = _vehicles[vIdx];
              final updated = await Navigator.of(context).push<Vehicle>(
                MaterialPageRoute(builder: (_) => VehicleDetailScreen(vehicle: v, allVehicles: _vehicles)),
              );
              if (updated != null) await _updateVehicle(updated);
            },
            onPartEdited: (updatedPart, owningVehicle) async {
              // Splice the updated part back into its vehicle then persist.
              final vIdx = _vehicles.indexWhere((x) => x.id == owningVehicle.id);
              if (vIdx < 0) return;
              final v = _vehicles[vIdx];
              final pIdx = v.parts.indexWhere((p) => p.id == updatedPart.id);
              if (pIdx < 0) return;
              setState(() => v.parts[pIdx] = updatedPart);
              await _persist();
            },
          ),
          StatsTab(
            loading: _loading,
            vehicles: _vehicles,
          ),
          SettingsTab(
            vehicles: _vehicles,
            onRestoreVehicles: (restored) async {
              setState(() => _vehicles = restored);
              await _persist();
            },
            onWipeAll: () async {
              await Storage.wipeAll();
              await _load();
            },
          ),
        ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.directions_car), label: 'Vehicles'),
            NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
            NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
            NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

/// ----------------------------
/// Data Models
/// ----------------------------
enum ItemType { car, motorcycle, boat, tractor, other }

extension ItemTypeX on ItemType {
  String get label {
    switch (this) {
      case ItemType.car:
        return 'Car';
      case ItemType.motorcycle:
        return 'Motorcycle';
      case ItemType.boat:
        return 'Boat';
      case ItemType.tractor:
        return 'Tractor / Machinery';
      case ItemType.other:
        return 'Other';
    }
  }

  /// Safe SharedPreferences key suffix (no spaces or slashes).
  static ItemType fromString(String s) {
    for (final v in ItemType.values) {
      if (v.name == s) return v;
    }
    return ItemType.other;
  }
}

enum VehicleStatus { whole, stripping, shellGone }

extension VehicleStatusX on VehicleStatus {
  String get label {
    switch (this) {
      case VehicleStatus.whole:
        return 'Whole';
      case VehicleStatus.stripping:
        return 'Being Stripped';
      case VehicleStatus.shellGone:
        return 'Shell Gone';
    }
  }

  static VehicleStatus fromString(String s) {
    for (final v in VehicleStatus.values) {
      if (v.name == s) return v;
    }
    return VehicleStatus.whole;
  }
}

enum PartState { removed, listed, sold, scrapped }

extension PartStateX on PartState {
  String get label {
    switch (this) {
      case PartState.removed:
        return 'In stock';
      case PartState.listed:
        return 'Listed';
      case PartState.sold:
        return 'Sold';
      case PartState.scrapped:
        return 'Scrapped';
    }
  }

  static PartState fromString(String s) {
    for (final v in PartState.values) {
      if (v.name == s) return v;
    }
    if (s == 'removed') return PartState.removed;
    if (s == 'sold') return PartState.sold;
    if (s == 'scrapped') return PartState.scrapped;
    return PartState.removed;
  }
}

const List<String> kDefaultPlatforms = ['eBay', 'Facebook', 'Marketplace', 'Gumtree', 'Craigslist'];

class PlatformStorage {
  static const _key = 'listing_platforms';

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? List.from(kDefaultPlatforms);
  }

  static Future<void> save(List<String> platforms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, platforms);
  }
}

/// Returns the best-match platform name from the URL, or empty string if unknown.
String detectPlatformFromUrl(String url) {
  final u = url.toLowerCase().trim();
  if (u.contains('ebay.'))                           return 'eBay';
  if (u.contains('facebook.com') || u.contains('fb.com')) return 'Facebook';
  if (u.contains('marketplace'))                     return 'Marketplace';
  if (u.contains('gumtree.'))                        return 'Gumtree';
  if (u.contains('craigslist.'))                     return 'Craigslist';
  return '';
}


class Listing {
  final String id;
  String platform;
  String url;
  bool isLive;
  int? listedPriceCents;
  DateTime createdAt;

  Listing({
    required this.id,
    required this.platform,
    required this.url,
    required this.isLive,
    required this.createdAt,
    this.listedPriceCents,
  });

  String get displayPlatformName => platform;

  Map<String, dynamic> toJson() => {
        'id': id,
        'platform': platform,
        'url': url,
        'isLive': isLive,
        'listedPriceCents': listedPriceCents,
        'createdAt': createdAt.toIso8601String(),
      };

  static Listing fromJson(Map<String, dynamic> j) {
    // New format: 'platform' string field
    String platform = (j['platform'] as String?) ?? '';
    if (platform.isEmpty) {
      // Migrate from old preset-based format
      final presetStr = (j['preset'] as String?) ?? 'custom';
      final customName = (j['customPlatformName'] as String?);
      switch (presetStr) {
        case 'ebay':     platform = 'eBay'; break;
        case 'facebook': platform = 'Facebook'; break;
        case 'gumtree':  platform = 'Gumtree'; break;
        default:
          platform = (customName?.trim().isNotEmpty == true) ? customName!.trim() : 'Other';
      }
    }
    return Listing(
      id: j['id'] as String,
      platform: platform,
      url: (j['url'] as String?) ?? '',
      isLive: (j['isLive'] as bool?) ?? (j['isActive'] as bool?) ?? true,
      listedPriceCents: (j['listedPriceCents'] as num?)?.toInt(),
      createdAt: DateTime.tryParse((j['createdAt'] as String?) ?? '') ?? DateTime.now(),
    );
  }
}

class Part {
  final String id;
  String name;
  PartState state;

  String? location;
  String? notes;

  // Added fields (safe default + backwards compatible)
  String? partNumber;
  int qty;

  int? askingPriceCents;
  int? salePriceCents;

  List<Listing> listings;
  DateTime createdAt;

  /// WL-XXXXXX stock ID — null for old parts, generated once on creation.
  final String? stockId;

  /// Last-modified timestamp. Null for parts created before v1.2.
  DateTime? updatedAt;

  /// Reserved for future photo support. Empty list for existing parts.
  List<String> photoIds;

  /// User-assigned category. Null for uncategorised / legacy parts.
  String? category;

  // Vehicle snapshot (copied from vehicle at creation, never updated)
  String? vehicleMake;
  String? vehicleModel;
  int? vehicleYear;
  String? vehicleTrim;
  String? vehicleEngine;
  String? vehicleTransmission;
  String? vehicleDrivetrain;
  int? vehicleUsageValue;
  String? vehicleUsageUnit;

  // Part metadata
  String? partCondition;
  String? side; // 'Left' | 'Right' | 'Pair' | null
  DateTime? dateListed;
  DateTime? dateSold;

  Part({
    required this.id,
    required this.name,
    required this.state,
    required this.createdAt,
    this.location,
    this.notes,
    this.partNumber,
    this.qty = 1,
    this.askingPriceCents,
    this.salePriceCents,
    this.stockId,
    this.updatedAt,
    this.category,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleYear,
    this.vehicleTrim,
    this.vehicleEngine,
    this.vehicleTransmission,
    this.vehicleDrivetrain,
    this.vehicleUsageValue,
    this.vehicleUsageUnit,
    this.partCondition,
    this.side,
    this.dateListed,
    this.dateSold,
    List<String>? photoIds,
    List<Listing>? listings,
  }) : photoIds = photoIds ?? [],
       listings = listings ?? [];

  bool get hasLiveListings => listings.any((l) => l.url.trim().isNotEmpty && l.isLive);

  /// Normalized part number for matching/grouping — dashes and spaces removed, uppercased.
  String? get normalizedPartNumber =>
      partNumber == null ? null : normalizePartNumber(partNumber!);

  Set<String> get livePlatformNames => listings
      .where((l) => l.url.trim().isNotEmpty)
      .map((l) => l.displayPlatformName)
      .toSet();

  int get totalLinksCount => listings.where((l) => l.url.trim().isNotEmpty).length;

  int get liveLinksCount => listings.where((l) => l.url.trim().isNotEmpty && l.isLive).length;

  int? get daysToSell {
    if (dateListed == null || dateSold == null) return null;
    final days = dateSold!.difference(dateListed!).inDays;
    return days < 0 ? null : days;
  }

  int daysInStock({DateTime? now}) {
    final n = now ?? DateTime.now();
    final diff = n.difference(createdAt);
    final d = diff.inDays;
    return d < 0 ? 0 : d;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'state': state.name,
        'location': location,
        'notes': notes,
        'partNumber': partNumber,
        'qty': qty,
        'askingPriceCents': askingPriceCents,
        'salePriceCents': salePriceCents,
        'listings': listings.map((l) => l.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'stockId': stockId,
        'photoIds': photoIds,
        'category': category,
        'vehicleMake': vehicleMake,
        'vehicleModel': vehicleModel,
        'vehicleYear': vehicleYear,
        'vehicleTrim': vehicleTrim,
        'vehicleEngine': vehicleEngine,
        'vehicleTransmission': vehicleTransmission,
        'vehicleDrivetrain': vehicleDrivetrain,
        'vehicleUsageValue': vehicleUsageValue,
        'vehicleUsageUnit': vehicleUsageUnit,
        'partCondition': partCondition,
        'side': side,
        'dateListed': dateListed?.toIso8601String(),
        'dateSold': dateSold?.toIso8601String(),
      };

  static Part fromJson(Map<String, dynamic> j) {
    final listingsJson = (j['listings'] as List<dynamic>?) ?? const [];
    return Part(
      id: j['id'] as String,
      name: (j['name'] as String?) ?? '',
      state: PartStateX.fromString((j['state'] as String?) ?? 'removed'),
      location: (j['location'] as String?),
      notes: (j['notes'] as String?),
      partNumber: (j['partNumber'] as String?),
      qty: (((j['qty'] as num?)?.toInt()) ?? 1).clamp(1, 999999),
      askingPriceCents: (j['askingPriceCents'] as num?)?.toInt(),
      salePriceCents: (j['salePriceCents'] as num?)?.toInt(),
      createdAt: DateTime.tryParse((j['createdAt'] as String?) ?? '') ?? DateTime.now(),
      listings: listingsJson.map((e) => Listing.fromJson(e as Map<String, dynamic>)).toList(),
      stockId: j['stockId'] as String?,  // null for old parts — never back-filled
      updatedAt: j['updatedAt'] == null ? null : DateTime.tryParse(j['updatedAt'] as String),
      photoIds: (j['photoIds'] as List<dynamic>?)?.map((e) => e as String).toList(),
      category: j['category'] as String?,
      vehicleMake: j['vehicleMake'] as String?,
      vehicleModel: j['vehicleModel'] as String?,
      vehicleYear: (j['vehicleYear'] as num?)?.toInt(),
      vehicleTrim: j['vehicleTrim'] as String?,
      vehicleEngine: j['vehicleEngine'] as String?,
      vehicleTransmission: j['vehicleTransmission'] as String?,
      vehicleDrivetrain: j['vehicleDrivetrain'] as String?,
      vehicleUsageValue: (j['vehicleUsageValue'] as num?)?.toInt(),
      vehicleUsageUnit: j['vehicleUsageUnit'] as String?,
      partCondition: j['partCondition'] as String?,
      side: j['side'] as String?,
      dateListed: j['dateListed'] == null ? null : DateTime.tryParse(j['dateListed'] as String),
      dateSold: j['dateSold'] == null ? null : DateTime.tryParse(j['dateSold'] as String),
    );
  }
}

class Vehicle {
  final String id;
  String make;
  String model;
  int year;

  ItemType itemType;

  /// Flexible identifier: VIN, rego, serial, hull ID, stock number, etc.
  String? identifier;

  VehicleStatus status;
  int? purchasePriceCents;
  DateTime acquiredAt;
  List<Part> parts;

  /// v1.1 fields — backward compatible (null / defaults for old data)
  int? usageValue;          // e.g. 120000
  String usageUnit;         // "km" | "miles" | "hours"
  String color;             // e.g. "Silver" — empty string if not set

  /// Vehicle-level notes: damage, condition, anything useful.
  String? notes;

  /// v1.2 placeholder fields — reserved for future features, no UI yet.
  DateTime? createdAt;      // when this record was first created in the app
  DateTime? updatedAt;
  List<String> photoIds;    // reserved for photo feature

  /// v1.3 market data fields — optional vehicle spec details.
  String? trim;
  String? engine;
  String? transmission;
  String? drivetrain;

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.itemType,
    required this.status,
    required this.acquiredAt,
    required this.parts,
    this.purchasePriceCents,
    this.identifier,
    this.usageValue,
    this.usageUnit = 'km',
    this.color = '',
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.trim,
    this.engine,
    this.transmission,
    this.drivetrain,
    List<String>? photoIds,
  }) : photoIds = photoIds ?? [];

  int get partsCount => parts.length;

  int get inStockCount => parts.where((p) => p.state == PartState.removed || p.state == PartState.listed).length;

  int get listedLiveCount => parts.where((p) =>
      p.hasLiveListings &&
      p.state != PartState.sold &&
      p.state != PartState.scrapped).length;

  int get soldRevenueCents {
    int sum = 0;
    for (final p in parts) {
      if (p.state == PartState.sold && p.salePriceCents != null) sum += p.salePriceCents!;
    }
    return sum;
  }

  int get profitLossCents {
    final purchase = purchasePriceCents ?? 0;
    return soldRevenueCents - purchase;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'make': make,
        'model': model,
        'year': year,
        'itemType': itemType.name,
        'identifier': identifier,
        'vin': identifier, // legacy support
        'status': status.name,
        'purchasePriceCents': purchasePriceCents,
        'acquiredAt': acquiredAt.toIso8601String(),
        'parts': parts.map((p) => p.toJson()).toList(),
        'usageValue': usageValue,
        'usageUnit': usageUnit,
        'color': color,
        'notes': notes,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'photoIds': photoIds,
        'trim': trim,
        'engine': engine,
        'transmission': transmission,
        'drivetrain': drivetrain,
      };

  static Vehicle fromJson(Map<String, dynamic> j) {
    final partsJson = (j['parts'] as List<dynamic>?) ?? const [];
    return Vehicle(
      id: j['id'] as String,
      make: (j['make'] as String?) ?? '',
      model: (j['model'] as String?) ?? '',
      year: (j['year'] as num?)?.toInt() ?? DateTime.now().year,
      itemType: ItemTypeX.fromString((j['itemType'] as String?) ?? 'other'),
      identifier: (j['identifier'] as String?) ?? (j['vin'] as String?),
      status: VehicleStatusX.fromString((j['status'] as String?) ?? 'whole'),
      purchasePriceCents: (j['purchasePriceCents'] as num?)?.toInt(),
      acquiredAt: DateTime.tryParse((j['acquiredAt'] as String?) ?? '') ?? DateTime.now(),
      parts: partsJson.map((e) => Part.fromJson(e as Map<String, dynamic>)).toList(),
      usageValue: (j['usageValue'] as num?)?.toInt(),
      usageUnit: (j['usageUnit'] as String?) ?? 'km',
      color: (j['color'] as String?) ?? '',
      notes: j['notes'] as String?,
      createdAt: j['createdAt'] == null ? null : DateTime.tryParse(j['createdAt'] as String),
      updatedAt: j['updatedAt'] == null ? null : DateTime.tryParse(j['updatedAt'] as String),
      photoIds: (j['photoIds'] as List<dynamic>?)?.map((e) => e as String).toList(),
      trim: j['trim'] as String?,
      engine: j['engine'] as String?,
      transmission: j['transmission'] as String?,
      drivetrain: j['drivetrain'] as String?,
    );
  }
}

/// ----------------------------
/// Storage
/// ----------------------------
class Storage {
  static const String _vehiclesKey = 'wrecklog_vehicles_v1';

  /// Legacy keys that earlier versions may have written to.
  /// We check these in order if the primary key is empty, migrate data, then
  /// remove the old key so it never runs again.
  static const List<String> _legacyKeys = [
    'wrecklog_vehicles',   // possible bare key from early builds
    'vehicles',            // ChatGPT early scaffold key
  ];

  static Future<List<Vehicle>> loadVehicles() async {
    final prefs = await SharedPreferences.getInstance();

    // Try primary key first
    final raw = prefs.getString(_vehiclesKey);
    if (raw != null && raw.trim().isNotEmpty) {
      return _decode(raw);
    }

    // Fall back to legacy keys — migrate on first find
    for (final legacyKey in _legacyKeys) {
      final legacyRaw = prefs.getString(legacyKey);
      if (legacyRaw != null && legacyRaw.trim().isNotEmpty) {
        final vehicles = _decode(legacyRaw);
        if (vehicles.isNotEmpty) {
          // Migrate: write to new key, remove old key
          await prefs.setString(_vehiclesKey, legacyRaw);
          await prefs.remove(legacyKey);
          return vehicles;
        }
      }
    }

    return [];
  }

  static List<Vehicle> _decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.map((e) => Vehicle.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('Storage: failed to decode vehicles JSON: $e');
      return [];
    }
  }

  static Future<void> saveVehicles(List<Vehicle> vehicles) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(vehicles.map((v) => v.toJson()).toList());
    await prefs.setString(_vehiclesKey, raw);
  }

  static Future<void> wipeAll() async {
    final prefs = await SharedPreferences.getInstance();

    // Vehicle data
    await prefs.remove(_vehiclesKey);
    for (final k in _legacyKeys) {
      await prefs.remove(k);
    }

    // User-customised settings
    await prefs.remove('part_categories');
    await prefs.remove('listing_platforms');
    await prefs.remove(PresetGroupStorage._versionKey);
    for (final type in ItemType.values) {
      await PresetGroupStorage.reset(type);
    }

    // Recent model autocomplete cache
    final recentKeys = prefs.getKeys()
        .where((k) => k.startsWith('recent_models_'))
        .toList();
    for (final k in recentKeys) {
      await prefs.remove(k);
    }

    // Photos (platform-specific implementation)
    await PhotoStorage.wipeAll();
  }
}

/// ----------------------------
/// Helpers
/// ----------------------------
String formatMoneyFromCents(int cents) {
  final sign = cents < 0 ? '-' : '';
  final abs = cents.abs();
  final dollars = abs ~/ 100;
  final rem = abs % 100;
  if (rem == 0) return '$sign\$$dollars';
  return '$sign\$$dollars.${rem.toString().padLeft(2, '0')}';
}

int? parseMoneyToCents(String input) {
  final s = input.trim();
  if (s.isEmpty) return null;
  final cleaned = s.replaceAll('\$', '').replaceAll(',', '').trim();
  final value = double.tryParse(cleaned);
  if (value == null || value.isNaN || value.isInfinite) return null;
  if (value < 0) return null;
  if (value > 99999999) return null; // cap at ~$1,000,000
  return (value * 100).round();
}

String formatDateShort(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

// Counter suffix ensures uniqueness even when called in a tight loop on
// platforms where microsecond clock resolution is coarser than 1 µs.
int _newIdCounter = 0;
String newId() => '${DateTime.now().microsecondsSinceEpoch}_${_newIdCounter++}';

String normalizeIdentifier(String input) => input.trim().toUpperCase();

/// Strips dashes and spaces and uppercases — used for part number matching/grouping.
/// The original value is always preserved for display.
String normalizePartNumber(String pn) =>
    pn.replaceAll(RegExp(r'[-\s]'), '').toUpperCase();

Color profitColor(int plCents) => plCents >= 0 ? Colors.green : Colors.red;

// ─────────────────────────────
// Stock ID Generator (v1.1)
// ─────────────────────────────
// Format: WL-XXXXXX  (6 chars from allowed set, uppercase, no I/O/0/1)
const String _stockIdChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

/// Generate a unique WL-XXXXXX stock ID that doesn't collide with any
/// existing stockId across all vehicles/parts in [allVehicles].
String generateUniqueStockId(List<Vehicle> allVehicles) {
  final existing = <String>{};
  for (final v in allVehicles) {
    for (final p in v.parts) {
      if (p.stockId != null) existing.add(p.stockId!);
    }
  }
  return _generateStockId(existing);
}

String _generateStockId(Set<String> existing) {
  final rng = math.Random.secure();
  while (true) {
    final suffix = List.generate(6, (_) => _stockIdChars[rng.nextInt(_stockIdChars.length)]).join();
    final candidate = 'WL-$suffix';
    if (!existing.contains(candidate)) return candidate;
  }
}

Color ageColor(int days) {
  if (days < 30) return Colors.green;
  if (days < 90) return Colors.orange;
  return Colors.red;
}

Future<void> copyToClipboard(BuildContext context, String text, {String message = 'Copied'}) async {
  final t = text.trim();
  if (t.isEmpty) return;
  await Clipboard.setData(ClipboardData(text: t));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}


// ─────────────────────────────
// Pro gating (Free tier limits)
// ─────────────────────────────
const int kFreeVehicleLimit = 1;
const int kFreePartLimitPerVehicle = 5;

/// Simple keyword → category mapping for part name suggestions.
/// Keys are lowercase. Checked via String.contains so "headlight" matches "headlight assembly".
const Map<String, String> kPartCategorySuggestions = {
  // Engine
  'engine': 'Engine', 'motor': 'Engine', 'long motor': 'Engine', 'short motor': 'Engine',
  'block': 'Engine', 'cylinder head': 'Engine', 'rocker cover': 'Engine',
  'cam': 'Engine', 'camshaft': 'Engine', 'crankshaft': 'Engine', 'piston': 'Engine',
  'timing': 'Engine', 'injector': 'Engine', 'turbo': 'Engine', 'supercharger': 'Engine',
  'oil pump': 'Engine', 'throttle body': 'Engine', 'intake manifold': 'Engine',
  'egr': 'Engine',
  // Transmission
  'gearbox': 'Transmission', 'transmission': 'Transmission', 'clutch': 'Transmission',
  'torque converter': 'Transmission', 'flywheel': 'Transmission',
  'gear selector': 'Transmission', 'mechatronics': 'Transmission', 'valve body': 'Transmission',
  'transmission cooler': 'Transmission',
  // Driveline
  'diff': 'Driveline', 'differential': 'Driveline', 'transfer case': 'Driveline',
  'tailshaft': 'Driveline', 'driveshaft': 'Driveline', 'drive shaft': 'Driveline',
  'cv shaft': 'Driveline', 'cv joint': 'Driveline', 'axle': 'Driveline',
  'prop shaft': 'Driveline', 'wheel hub': 'Driveline',
  // Suspension
  'strut': 'Suspension', 'shock': 'Suspension', 'spring': 'Suspension',
  'control arm': 'Suspension', 'sway bar': 'Suspension', 'leaf spring': 'Suspension',
  'upper arm': 'Suspension', 'lower arm': 'Suspension', 'link': 'Suspension',
  'bush': 'Suspension',
  // Steering
  'steering rack': 'Steering', 'power steering': 'Steering', 'steering column': 'Steering',
  'tie rod': 'Steering', 'steering knuckle': 'Steering', 'steering pump': 'Steering',
  // Brakes
  'brake': 'Brakes', 'caliper': 'Brakes', 'rotor': 'Brakes',
  'disc': 'Brakes', 'pad': 'Brakes', 'drum': 'Brakes', 'abs': 'Brakes',
  'brake booster': 'Brakes', 'master cylinder': 'Brakes', 'handbrake': 'Brakes',
  // Electrical
  'alternator': 'Electrical', 'starter': 'Electrical', 'battery': 'Electrical',
  'ecu': 'Electrical', 'pcm': 'Electrical', 'bcm': 'Electrical',
  'fuse': 'Electrical', 'wiring': 'Electrical', 'sensor': 'Electrical',
  'relay': 'Electrical', 'module': 'Electrical', 'computer': 'Electrical',
  'switch': 'Electrical', 'window motor': 'Electrical', 'instrument cluster': 'Electrical',
  // Lighting
  'headlight': 'Lighting', 'tail light': 'Lighting', 'taillight': 'Lighting',
  'indicator': 'Lighting', 'fog light': 'Lighting', 'foglight': 'Lighting',
  'led bar': 'Lighting', 'light bar': 'Lighting', 'brake light': 'Lighting',
  'interior light': 'Lighting', 'lamp': 'Lighting',
  // Cooling
  'radiator': 'Cooling', 'intercooler': 'Cooling', 'thermostat': 'Cooling',
  'water pump': 'Cooling', 'cooling fan': 'Cooling', 'thermo fan': 'Cooling',
  'overflow bottle': 'Cooling', 'heater core': 'Cooling', 'condenser': 'Cooling',
  // Fuel System
  'fuel pump': 'Fuel System', 'fuel tank': 'Fuel System', 'fuel rail': 'Fuel System',
  'fuel line': 'Fuel System', 'lift pump': 'Fuel System',
  'carburetor': 'Fuel System', 'carby': 'Fuel System',
  // Exhaust
  'exhaust': 'Exhaust', 'muffler': 'Exhaust', 'catalytic': 'Exhaust',
  'exhaust manifold': 'Exhaust', 'downpipe': 'Exhaust', 'dpf': 'Exhaust',
  // Body
  'door': 'Body', 'bonnet': 'Body', 'hood': 'Body', 'fender': 'Body',
  'bumper': 'Body', 'guard': 'Body', 'tailgate': 'Body', 'grille': 'Body',
  'mirror': 'Body', 'glass': 'Body', 'windscreen': 'Body', 'window glass': 'Body',
  'roof': 'Body',
  // Interior
  'seat': 'Interior', 'dash': 'Interior', 'dashboard': 'Interior',
  'carpet': 'Interior', 'console': 'Interior', 'door trim': 'Interior',
  'seatbelt': 'Interior', 'steering wheel': 'Interior', 'infotainment': 'Interior',
  'centre console': 'Interior',
  // Wheels & Tyres
  'wheel': 'Wheels & Tyres', 'rim': 'Wheels & Tyres', 'tyre': 'Wheels & Tyres',
  'tire': 'Wheels & Tyres', 'spare wheel': 'Wheels & Tyres', 'wheel nut': 'Wheels & Tyres',
  // Accessories
  'bullbar': 'Accessories', 'bull bar': 'Accessories', 'tow bar': 'Accessories',
  'towbar': 'Accessories', 'snorkel': 'Accessories', 'side step': 'Accessories',
  'roof rack': 'Accessories', 'canopy': 'Accessories', 'tray': 'Accessories',
  'spotlight': 'Accessories', 'uhf': 'Accessories', 'brake controller': 'Accessories',
};

// Debug-only Pro override — compiled out in release builds.
// Persisted so it survives hot restarts during a session.
const String _kDebugProKey = 'debug_pro_enabled';
bool _debugProOverride = false; // in-memory mirror; loaded once at startup

/// True if billing says Pro OR the local testing override is on.
bool get isPro {
  if (_debugProOverride) return true;
  return billing.isPro;
}

Future<void> _loadDebugProFlag() async {
  final prefs = await SharedPreferences.getInstance();
  _debugProOverride = prefs.getBool(_kDebugProKey) ?? false;
}

Future<void> _saveDebugProFlag(bool value) async {
  _debugProOverride = value;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kDebugProKey, value);
}

Future<void> showProPaywall(BuildContext context, {required String title, required String message}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => _ProPaywallDialog(title: title, message: message),
  );
}

class _ProPaywallDialog extends StatefulWidget {
  final String title;
  final String message;
  const _ProPaywallDialog({required this.title, required this.message});

  @override
  State<_ProPaywallDialog> createState() => _ProPaywallDialogState();
}

class _ProPaywallDialogState extends State<_ProPaywallDialog> {
  bool _loading = false;

  Future<void> _buy(Future<void> Function() purchase) async {
    // Show spinner inside dialog while purchase is in progress.
    // Only pop once the async work is done so setState is never called
    // on a disposed widget.
    if (!mounted) return;
    setState(() => _loading = true);
    // Capture the scaffold messenger before any async gap.
    final messenger = ScaffoldMessenger.of(context);
    try {
      await purchase();
      if (mounted) Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Welcome to Pro! 🎉')),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        messenger.showSnackBar(
          SnackBar(content: Text('Purchase failed: $e')),
        );
      }
    }
    // No finally setState — if we succeeded we already popped (disposed).
    // If we failed we already called setState above while still mounted.
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.lock_open, color: Color(0xFFE8700A)),
          const SizedBox(width: 8),
          Expanded(child: Text(widget.title)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 20),

          // ── Yearly plan (highlighted) ────────────────────────────────
          _PlanTile(
            label: 'Yearly',
            price: '${billing.yearlyPrice} / year',
            badge: '2 months free',
            highlight: true,
            loading: _loading,
            onTap: () => _buy(billing.buyYearly),
          ),
          const SizedBox(height: 10),

          // ── Monthly plan ─────────────────────────────────────────────
          _PlanTile(
            label: 'Monthly',
            price: '${billing.monthlyPrice} / month',
            badge: null,
            highlight: false,
            loading: _loading,
            onTap: () => _buy(billing.buyMonthly),
          ),

          const SizedBox(height: 12),
          const Text(
            'Cancel any time. Existing data is always yours.',
            style: TextStyle(color: Colors.white38, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Not now'),
        ),
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  final String label;
  final String price;
  final String? badge;
  final bool highlight;
  final bool loading;
  final VoidCallback onTap;

  const _PlanTile({
    required this.label,
    required this.price,
    required this.badge,
    required this.highlight,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: highlight
              ? const Color(0xFFE8700A).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: highlight
                ? const Color(0xFFE8700A)
                : Colors.white.withValues(alpha: 0.15),
            width: highlight ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(label,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: highlight
                                ? const Color(0xFFE8700A)
                                : Colors.white,
                          )),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8700A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(badge!,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(price,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            if (loading)
              const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: highlight
                    ? const Color(0xFFE8700A)
                    : Colors.white38,
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> showRestoreDialog(BuildContext context) async {
  try {
    await billing.restore();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restore complete')));
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
    }
  }
}



/// Format a usage number with thousands separator: 120000 → "120,000"
String _formatUsage(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}


/// Returns the "From: year • usage" tertiary line for a part row.
/// [vehicle] may be null if the source wasn't found.
String _partSourceLine(Vehicle? vehicle) {
  if (vehicle == null) return 'From: (vehicle missing)';
  final yearStr = vehicle.year > 0 ? vehicle.year.toString() : 'Unknown';
  if (vehicle.usageValue == null || vehicle.usageValue! <= 0) {
    return 'From: $yearStr';
  }
  return 'From: $yearStr • ${_formatUsage(vehicle.usageValue!)} ${vehicle.usageUnit}';
}

/// "WL-XXXXXX • PN123 • Left" secondary line — omits missing parts gracefully.
String _partSecondaryLine(Part p) {
  final sid  = (p.stockId ?? '').trim();
  final pn   = (p.partNumber ?? '').trim();
  final side = (p.side ?? '').trim();
  final parts = [
    if (sid.isNotEmpty) sid,
    if (pn.isNotEmpty) pn,
    if (side.isNotEmpty) side,
  ];
  return parts.join(' • ');
}

String _titleOrFallback(Vehicle v) {
  final make = v.make.trim();
  final model = v.model.trim();
  if (make.isEmpty && model.isEmpty) return '${v.year} Item';
  return '${v.year} $make $model'.trim();
}

void normalizePartStateFromListings(Part p) {
  if (p.state == PartState.sold || p.state == PartState.scrapped) return;
  p.state = p.hasLiveListings ? PartState.listed : PartState.removed;
  if (p.state != PartState.sold) {
    p.salePriceCents = null;
  }
}

Uri? _safeParseUrl(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  final hasScheme = s.startsWith('http://') || s.startsWith('https://');
  final candidate = hasScheme ? s : 'https://$s';
  // Only allow http/https — block javascript:, data:, file:, etc.
  if (!candidate.startsWith('http://') && !candidate.startsWith('https://')) {
    return null;
  }
  return Uri.tryParse(candidate);
}

Future<void> openUrlEasy(BuildContext context, String url) async {
  final uri = _safeParseUrl(url);
  if (uri == null) return;

  try {
    final ok = await launchUrl(
      uri,
      mode: LaunchMode.platformDefault,
      webOnlyWindowName: '_blank',
    );
    if (!ok && context.mounted) {
      await copyToClipboard(context, url, message: 'Could not open - link copied');
    }
  } catch (_) {
    if (context.mounted) {
      await copyToClipboard(context, url, message: 'Could not open - link copied');
    }
  }
}

Future<void> showLinksSheet(BuildContext context, Part part) async {
  final links = part.listings.where((l) => l.url.trim().isNotEmpty).toList();
  if (links.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No links to open')));
    return;
  }

  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Links (${links.length})',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  part.name,
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(ctx).textTheme.bodyMedium?.color?.withValues(alpha: 0.75),
                      ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: links.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final l = links[i];
                      final live = l.isLive;
                      final liveColor = live ? Colors.green : Colors.grey;

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      l.displayPlatformName,
                                      style: Theme.of(ctx).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                  WLBadge(
                                    text: live ? 'Live' : 'Not live',
                                    color: liveColor,
                                    icon: live ? Icons.circle : Icons.circle_outlined,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => openUrlEasy(ctx, l.url),
                                child: Text(
                                  l.url,
                                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w700,
                                      ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => copyToClipboard(ctx, l.url, message: 'Link copied'),
                                      icon: const Icon(Icons.copy),
                                      label: const Text('Copy'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () => openUrlEasy(ctx, l.url),
                                      icon: const Icon(Icons.open_in_new),
                                      label: const Text('Open'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Web export helpers
// Backup format version — increment if the data model changes in a
// way that would make old backups incompatible.
const int _kBackupFormatVersion = 2;

Future<String> vehiclesToPrettyJson(List<Vehicle> vehicles) async {
  final categories = await PartCategoryStorage.load();
  final platforms = await PlatformStorage.load();
  final presets = <String, dynamic>{};
  for (final type in ItemType.values) {
    presets[type.name] = await PresetGroupStorage.load(type);
  }
  final obj = {
    'wrecklog_backup': true,
    'format_version': _kBackupFormatVersion,
    'exported_at': DateTime.now().toIso8601String(),
    'vehicles': vehicles.map((v) => v.toJson()).toList(),
    'part_categories': categories,
    'listing_platforms': platforms,
    'preset_groups': presets,
  };
  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(obj);
}

String vehiclesToCsv(List<Vehicle> vehicles) {
  // Flat, practical export for quick sorting/filtering
  final rows = <List<String>>[];
  rows.add([
    'vehicle_id',
    'vehicle_year',
    'vehicle_make',
    'vehicle_model',
    'vehicle_trim',
    'vehicle_engine',
    'vehicle_transmission',
    'vehicle_drivetrain',
    'vehicle_usage',
    'vehicle_identifier',
    'vehicle_status',
    'item_type',
    'part_id',
    'part_name',
    'part_number',
    'part_category',
    'part_condition',
    'part_side',
    'part_state',
    'part_location',
    'qty',
    'asking_price',
    'sale_price',
    'date_listed',
    'date_sold',
    'days_to_sell',
    'links_total',
    'links_live',
  ]);

  for (final v in vehicles) {
    final usageStr = v.usageValue != null ? '${v.usageValue} ${v.usageUnit}' : '';
    for (final p in v.parts) {
      final dts = p.daysToSell;
      rows.add([
        v.id,
        v.year.toString(),
        v.make,
        v.model,
        v.trim ?? '',
        v.engine ?? '',
        v.transmission ?? '',
        v.drivetrain ?? '',
        usageStr,
        v.identifier ?? '',
        v.status.name,
        v.itemType.name,
        p.id,
        p.name,
        p.partNumber ?? '',
        p.category ?? '',
        p.partCondition ?? '',
        p.side ?? '',
        p.state.name,
        p.location ?? '',
        p.qty.toString(),
        p.askingPriceCents == null ? '' : formatMoneyFromCents(p.askingPriceCents!),
        p.salePriceCents == null ? '' : formatMoneyFromCents(p.salePriceCents!),
        p.dateListed == null ? '' : p.dateListed!.toIso8601String().substring(0, 10),
        p.dateSold == null ? '' : p.dateSold!.toIso8601String().substring(0, 10),
        dts == null ? '' : dts.toString(),
        p.totalLinksCount.toString(),
        p.liveLinksCount.toString(),
      ]);
    }
  }

  String esc(String s) {
    final needs = s.contains(',') || s.contains('"') || s.contains('\n') || s.contains('\r');
    if (!needs) return s;
    return '"${s.replaceAll('"', '""')}"';
  }

  return rows.map((r) => r.map(esc).join(',')).join('\n');
}

void downloadTextFileWeb({required String filename, required String content}) {
  if (!kIsWeb) return;
  webDownloadTextFile(filename: filename, content: content);
}

/// ----------------------------
/// Presets
/// ----------------------------
// ─────────────────────────────────────────────────────────────────────────────
// Grouped Preset Parts  (v1.2)
// Map<groupName, List<partName>> per ItemType
// ─────────────────────────────────────────────────────────────────────────────

/// Default grouped presets — used when no prefs key exists or on reset.
Map<ItemType, Map<String, List<String>>> defaultGroupedPresets = {
  ItemType.car: {
    'Engine': [
      'Engine complete', 'Long motor', 'Short motor', 'Turbo',
      'Injectors', 'Fuel pump (high pressure)', 'Intake manifold',
      'Throttle body', 'EGR valve', 'Oil pump', 'Rocker cover',
      'Cylinder head', 'Timing components',
    ],
    'Transmission': [
      'Gearbox', 'Torque converter', 'Clutch kit', 'Flywheel',
      'Gear selector', 'Transmission cooler', 'Mechatronics / valve body',
    ],
    'Driveline': [
      'Differential (front)', 'Differential (rear)', 'Transfer case',
      'Tailshaft', 'CV shafts', 'Drive shafts', 'Axles',
      'Wheel hubs', 'Prop shaft',
    ],
    'Suspension': [
      'Control arms', 'Shocks / struts', 'Springs', 'Sway bar',
      'Links / bushes', 'Leaf springs', 'Upper arms', 'Lower arms',
    ],
    'Steering': [
      'Steering rack', 'Power steering pump', 'Steering column',
      'Tie rods', 'Steering knuckle',
    ],
    'Brakes': [
      'Brake calipers', 'Brake discs / rotors', 'Brake pads',
      'ABS module', 'Brake booster', 'Master cylinder', 'Handbrake components',
    ],
    'Electrical': [
      'Alternator', 'Starter motor', 'Wiring loom', 'ECU / PCM', 'BCM',
      'Sensors', 'Relays', 'Fuse box', 'Instrument cluster',
      'Window motors', 'Switches',
    ],
    'Lighting': [
      'Headlights', 'Tail lights', 'Indicators', 'Fog lights',
      'LED light bars', 'Interior lights', 'Brake lights',
    ],
    'Cooling': [
      'Radiator', 'Intercooler', 'Cooling fan', 'Thermostat housing',
      'Overflow bottle', 'Heater core', 'Condenser',
    ],
    'Fuel System': [
      'Fuel tank', 'Lift pump', 'Fuel lines', 'Fuel rail', 'Injectors',
    ],
    'Exhaust': [
      'Exhaust system', 'Muffler', 'DPF', 'Catalytic converter', 'Exhaust manifold',
    ],
    'Body': [
      'Doors', 'Bonnet', 'Guards / fenders', 'Tailgate', 'Bumper',
      'Grille', 'Mirrors', 'Window glass',
    ],
    'Interior': [
      'Seats', 'Dash', 'Centre console', 'Door trims', 'Carpet',
      'Seatbelts', 'Steering wheel', 'Infotainment screen', 'Interior switches',
    ],
    'Wheels & Tyres': [
      'Wheels / rims', 'Tyres', 'Spare wheel', 'Wheel nuts',
    ],
    'Accessories': [
      'Bullbar', 'Tow bar', 'Snorkel', 'Side steps', 'Roof rack',
      'Canopy', 'Tray', 'Spotlights', 'UHF radios', 'Brake controller',
      'Aftermarket add-ons',
    ],
    'Other': ['Misc parts'],
  },
  ItemType.motorcycle: {
    'Engine': ['Engine', 'Gearbox', 'Exhaust', 'Starter motor', 'Alternator'],
    'Frame': ['Frame', 'Swingarm', 'Front forks', 'Rear shock', 'Triple clamp'],
    'Electrical': ['ECU', 'Instrument cluster', 'Headlight', 'Tail light', 'Wiring loom'],
    'Controls': ['Handlebar', 'Throttle body', 'Brake caliper (F)', 'Brake caliper (R)', 'Footpegs'],
    'Bodywork': ['Fairings (set)', 'Fuel tank', 'Seat', 'Front guard', 'Rear guard'],
    'Other': ['Front wheel', 'Rear wheel', 'Chain & sprockets', 'Battery'],
  },
  ItemType.boat: {
    'Outboard': ['Outboard', 'Propeller', 'Lower unit', 'Powerhead', 'Tilt & trim'],
    'Electrical': ['Battery', 'Wiring loom', 'Gauges', 'Bilge pump', 'Navigation lights'],
    'Fuel': ['Fuel tank', 'Fuel lines', 'Fuel pump'],
    'Steering': ['Steering wheel', 'Steering cable', 'Helm pump'],
    'Pumps': ['Bilge pump', 'Livebait pump', 'Wash-down pump'],
    'Trailer': ['Trailer frame', 'Trailer axle', 'Trailer wheels', 'Winch'],
    'Other': ['Anchor', 'Hatch lids', 'Rod holders', 'Seats'],
  },
  ItemType.tractor: {
    'Engine': ['Engine', 'Radiator', 'Starter motor', 'Alternator', 'Turbo', 'Injectors'],
    'Hydraulics': ['Hydraulic pump', 'Hydraulic cylinder', 'Control valve', 'PTO assembly'],
    'Electrical': ['ECU', 'Instrument cluster', 'Wiring loom', 'Battery'],
    'Cooling': ['Radiator', 'Overflow bottle', 'Thermo fan', 'Water pump'],
    'Running Gear': ['Transmission', 'Tyres (set)', 'Rim (set)', 'Axle shaft'],
    'Controls': ['Steering wheel', 'Joystick controller', 'Cab parts', 'Seat'],
    'Other': ['Three-point linkage', 'Draw bar', 'Front weights'],
  },
  ItemType.other: {
    'General': ['Main assembly', 'Control module', 'Panels', 'Fasteners / misc'],
    'Electrical': ['Wiring', 'Lights', 'Battery', 'Control board'],
    'Hardware': ['Bolts / nuts', 'Bearings', 'Seals', 'Gaskets'],
    'Other': ['Misc parts'],
  },
};

// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// Canonical prefs key for grouped presets — ONE function, used everywhere.
// Strips slashes, spaces and surrounding whitespace so
// "Tractor / Machinery" → "preset_groups_TractorMachinery"
// ─────────────────────────────────────────────────────────────────────────────
String prefsKeyForType(String type) {
  final normalized = type
      .toLowerCase()
      .replaceAll('/', '')
      .replaceAll(' ', '')
      .trim();
  return 'preset_groups_$normalized';
}

// PresetGroupStorage — load/save grouped presets per ItemType
// ─────────────────────────────────────────────────────────────────────────────
class PresetGroupStorage {
  static String _key(ItemType t) => prefsKeyForType(t.label);

  // Bump this when defaultGroupedPresets changes in a breaking way.
  // On first load after an upgrade, old per-type prefs are wiped and replaced
  // with fresh defaults — protecting against stale data from old builds.
  static const String _versionKey = 'preset_groups_schema_v';
  static const int _currentVersion = 3;

  /// One-time migration for the old broken-key-generation bug.
  ///
  /// The old bug caused string interpolation to be written literally, producing
  /// the key `preset_groups_\$normalized` (dollar sign included) instead of
  /// the correct per-type keys. All five types collided under that one key.
  ///
  /// Fix: remove only the known broken collision key. Valid per-type keys
  /// (preset_groups_car, preset_groups_motorcycle, etc.) are left untouched
  /// unless we can positively detect that a per-type key holds cross-type
  /// content (i.e. it was written when all types collided).
  static Future<void> migrate() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(_versionKey) ?? 0;
    if (stored >= _currentVersion) return;

    // 1. Remove the literal broken collision key if it exists.
    const brokenKey = r'preset_groups_$normalized';
    await prefs.remove(brokenKey);

    // 2. For each valid per-type key, check if it looks like cross-type
    //    contamination: if a motorcycle/boat/tractor key contains car-only
    //    part names (e.g. "Tailgate") it was written under the old collision
    //    bug. Wipe it so it falls back to the correct type defaults.
    // Terms that are unambiguously car-specific and would never appear in a
    // legitimate motorcycle/boat/tractor preset list. Borderline terms like
    // "dashboard" and "centre console" are excluded to avoid false positives.
    const carOnlyTerms = {'tailgate', 'bonnet', 'front bar', 'rear bar', 'carpet set'};
    const contaminationThreshold = 2; // require 2+ matches before wiping
    final typesToCheck = {
      ItemType.motorcycle, ItemType.boat, ItemType.tractor, ItemType.other,
    };
    for (final type in typesToCheck) {
      final key = _key(type);
      final raw = prefs.getString(key);
      if (raw == null) continue;
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final allParts = <String>{};
        for (final v in decoded.values) {
          allParts.addAll((v as List).map((e) => (e as String).toLowerCase()));
        }
        final matchCount = carOnlyTerms.where((t) => allParts.contains(t)).length;
        if (matchCount >= contaminationThreshold) await prefs.remove(key);
      } catch (_) {
        await prefs.remove(key); // corrupt data — safe to wipe
      }
    }

    await prefs.setInt(_versionKey, _currentVersion);
  }

  static Future<Map<String, List<String>>> load(ItemType type) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(type));
    if (raw == null || raw.trim().isEmpty) {
      return _deepCopy(defaultGroupedPresets[type] ?? defaultGroupedPresets[ItemType.other]!);
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, List<String>.from(v as List)));
    } catch (_) {
      return _deepCopy(defaultGroupedPresets[type] ?? defaultGroupedPresets[ItemType.other]!);
    }
  }

  static Future<void> save(ItemType type, Map<String, List<String>> groups) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(type), jsonEncode(groups));
  }

  static Future<void> reset(ItemType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(type));
  }

  static Map<String, List<String>> _deepCopy(Map<String, List<String>> src) =>
      {for (final e in src.entries) e.key: List<String>.from(e.value)};
}

/// Normalize a part name for duplicate detection: trim + collapse spaces + lowercase.
String _normalizePartName(String s) =>
    s.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

/// Legacy flat list — kept so nothing else in the file breaks.
/// Now derived from default grouped presets (flattened).
Map<ItemType, List<String>> get presetPartsByType => {
  for (final entry in defaultGroupedPresets.entries)
    entry.key: [
      for (final parts in entry.value.values) ...parts,
    ],
};

/// ----------------------------
/// UI Building Blocks
/// ----------------------------
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: t.bodySmall?.copyWith(color: t.bodySmall?.color?.withValues(alpha: 0.75))),
              ]
            ]),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class WLBadge extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Color color;
  final VoidCallback? onTap;

  const WLBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              height: 1.0,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: child,
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: padding, child: child));
  }
}


/// ----------------------------
/// Vehicles Home
/// ----------------------------
class VehiclesHome extends StatefulWidget {
  final bool loading;
  final List<Vehicle> vehicles;
  final Future<void> Function() onReload;
  final Future<void> Function(Vehicle created) onAddVehicle;
  final Future<void> Function(Vehicle updated) onUpdateVehicle;
  final Future<void> Function(String id) onDeleteVehicle;

  const VehiclesHome({
    super.key,
    required this.loading,
    required this.vehicles,
    required this.onReload,
    required this.onAddVehicle,
    required this.onUpdateVehicle,
    required this.onDeleteVehicle,
  });

  @override
  State<VehiclesHome> createState() => _VehiclesHomeState();
}

enum _VehicleSort { newest, oldest, mostParts, biggestProfit }

class _VehiclesHomeState extends State<VehiclesHome> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  _VehicleSort _sort = _VehicleSort.newest;
  // Cached painter — never recreated on setState, avoids object churn.
  final _grainPainter = LeatherGrainPainter();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Vehicle> _filtered() {
    final q = _query.trim().toLowerCase();
    var list = widget.vehicles.where((v) {
      if (q.isEmpty) return true;
      return _titleOrFallback(v).toLowerCase().contains(q) ||
          (v.identifier ?? '').toLowerCase().contains(q) ||
          (v.notes ?? '').toLowerCase().contains(q) ||
          v.color.toLowerCase().contains(q);
    }).toList();

    switch (_sort) {
      case _VehicleSort.newest:
        list.sort((a, b) => b.acquiredAt.compareTo(a.acquiredAt));
      case _VehicleSort.oldest:
        list.sort((a, b) => a.acquiredAt.compareTo(b.acquiredAt));
      case _VehicleSort.mostParts:
        list.sort((a, b) => b.partsCount.compareTo(a.partsCount));
      case _VehicleSort.biggestProfit:
        list.sort((a, b) => b.profitLossCents.compareTo(a.profitLossCents));
    }
    // Always push completed (shell gone) vehicles to the bottom.
    list.sort((a, b) {
      final aComp = a.status == VehicleStatus.shellGone ? 1 : 0;
      final bComp = b.status == VehicleStatus.shellGone ? 1 : 0;
      return aComp.compareTo(bComp);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = widget.vehicles;
    final onReload = widget.onReload;
    final onAddVehicle = widget.onAddVehicle;
    final onUpdateVehicle = widget.onUpdateVehicle;
    final onDeleteVehicle = widget.onDeleteVehicle;
    final loading = widget.loading;

    final totalPurchase = vehicles.fold<int>(0, (s, v) => s + (v.purchasePriceCents ?? 0));
    final totalRevenue = vehicles.fold<int>(0, (s, v) => s + v.soldRevenueCents);
    final totalPL = totalRevenue - totalPurchase;
    final plColor = profitColor(totalPL);

    final filtered = _filtered();

    return Scaffold(
      appBar: AppBar(
        title: const Text('WreckLog'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: onReload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!isPro && vehicles.length >= kFreeVehicleLimit) {
            await showProPaywall(
              context,
              title: 'Free limit reached',
              message: 'Free WreckLog is limited to $kFreeVehicleLimit vehicle. Upgrade to Pro for unlimited vehicles and parts.',
            );
            return;
          }
          final created = await Navigator.of(context).push<Vehicle>(
            MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
          );
          if (created == null || !context.mounted) return;
          await onAddVehicle(created);
          if (!context.mounted) return;
          final updated = await Navigator.of(context).push<Vehicle>(
            MaterialPageRoute(builder: (_) => VehicleDetailScreen(vehicle: created, allVehicles: widget.vehicles)),
          );
          if (updated != null) await onUpdateVehicle(updated);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle'),
      ),
      body: Stack(
        children: [
          // Leather grain background — painter cached in state, never recreated.
          SizedBox.expand(
            child: CustomPaint(painter: _grainPainter),
          ),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else
            RefreshIndicator(
              onRefresh: onReload,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(kPad, kPad, kPad, 96),
                children: [
                  // ── Pro banner (compact) ──────────────────────────────
                  if (!isPro) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFE8700A).withValues(alpha: 0.10),
                        border: Border.all(color: const Color(0xFFE8700A).withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.workspace_premium, color: Color(0xFFE8700A), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Free tier: $kFreeVehicleLimit vehicle · $kFreePartLimitPerVehicle parts each',
                              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.65)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => showProPaywall(
                              context,
                              title: 'Upgrade to Pro',
                              message: 'Unlock unlimited vehicles and parts.',
                            ),
                            child: const Text(
                              'Go Pro',
                              style: TextStyle(color: Color(0xFFE8700A), fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // ── Search + sort bar ─────────────────────────────────
                  if (vehicles.isNotEmpty) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (v) => setState(() => _query = v),
                            decoration: InputDecoration(
                              hintText: 'Search make, model, rego, notes…',
                              prefixIcon: const Icon(Icons.search, size: 18),
                              suffixIcon: _query.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 16),
                                      onPressed: () => setState(() {
                                        _query = '';
                                        _searchCtrl.clear();
                                      }),
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<_VehicleSort>(
                          tooltip: 'Sort',
                          icon: const Icon(Icons.sort, color: Color(0xFFE8700A)),
                          initialValue: _sort,
                          onSelected: (s) => setState(() => _sort = s),
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: _VehicleSort.newest,       child: Text('Newest first')),
                            PopupMenuItem(value: _VehicleSort.oldest,       child: Text('Oldest first')),
                            PopupMenuItem(value: _VehicleSort.mostParts,    child: Text('Most parts')),
                            PopupMenuItem(value: _VehicleSort.biggestProfit,child: Text('Biggest profit')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                  // ── Slim stats strip ──────────────────────────────────
                  if (vehicles.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: [
                          Icon(Icons.directions_car_outlined, size: 14, color: Colors.white.withValues(alpha: 0.35)),
                          const SizedBox(width: 5),
                          Text(
                            '${vehicles.length} vehicle${vehicles.length == 1 ? '' : 's'}',
                            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.trending_up, size: 14, color: plColor.withValues(alpha: 0.7)),
                          const SizedBox(width: 5),
                          Text(
                            'P/L ${formatMoneyFromCents(totalPL)}',
                            style: TextStyle(fontSize: 12, color: plColor.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (vehicles.isEmpty)
                    _EmptyVehiclesState(
                      onAddVehicle: () async {
                        final created = await Navigator.of(context).push<Vehicle>(
                          MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
                        );
                        if (created == null || !context.mounted) return;
                        await onAddVehicle(created);
                        if (!context.mounted) return;
                        final updated = await Navigator.of(context).push<Vehicle>(
                          MaterialPageRoute(builder: (_) => VehicleDetailScreen(vehicle: created, allVehicles: widget.vehicles)),
                        );
                        if (updated != null) await onUpdateVehicle(updated);
                      },
                    )
                  else if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No vehicles match "$_query"',
                          style: const TextStyle(color: Colors.white38),
                        ),
                      ),
                    )
                  else
                    ...filtered.map(
                      (v) => Padding(
                        key: ValueKey(v.id),
                        padding: const EdgeInsets.only(bottom: 10),
                        child: VehicleCard(
                          vehicle: v,
                          onOpen: () async {
                            final updated = await Navigator.of(context).push<Vehicle>(
                              MaterialPageRoute(builder: (_) => VehicleDetailScreen(vehicle: v, allVehicles: vehicles)),
                            );
                            if (updated != null) await onUpdateVehicle(updated);
                          },
                          onDelete: () async {
                            final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete vehicle?'),
                                    content: Text('Delete "${_titleOrFallback(v)}" and all its parts?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                                    ],
                                  ),
                                ) ??
                                false;
                            if (!ok) return;
                            await onDeleteVehicle(v.id);
                          },
                          onMarkCompleted: () async {
                            final isCompleted = v.status == VehicleStatus.shellGone;
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(isCompleted ? 'Mark Active?' : 'Mark Completed?'),
                                content: Text(isCompleted
                                    ? 'Move "${_titleOrFallback(v)}" back to active stripping?'
                                    : 'Mark "${_titleOrFallback(v)}" as completed (shell gone)?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(isCompleted ? 'Mark Active' : 'Mark Completed')),
                                ],
                              ),
                            ) ?? false;
                            if (!ok) return;
                            v.status = isCompleted ? VehicleStatus.stripping : VehicleStatus.shellGone;
                            await onUpdateVehicle(v);
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyVehiclesState extends StatelessWidget {
  final VoidCallback onAddVehicle;
  const _EmptyVehiclesState({required this.onAddVehicle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hero empty state card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadius),
            border: Border.all(color: const Color(0xFFE8700A).withValues(alpha: 0.3)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFE8700A).withValues(alpha: 0.08),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8700A).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8700A).withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.directions_car, size: 42, color: Color(0xFFE8700A)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add your first vehicle',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Start by adding the vehicle you\'re currently dismantling. You can track every part, where it\'s stored, and what it\'s listed for.',
                style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.55), height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onAddVehicle,
                  icon: const Icon(Icons.add),
                  label: const Text('Add your first vehicle'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE8700A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // How it works steps
        const AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HOW IT WORKS',
                style: TextStyle(
                  color: Color(0xFFE8700A),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 16),
              _OnboardingStep(
                number: '1',
                title: 'Add a vehicle',
                description: 'Enter the year, make and model of the car you\'re pulling apart.',
                icon: Icons.directions_car_outlined,
              ),
              SizedBox(height: 14),
              _OnboardingStep(
                number: '2',
                title: 'Log each part as you pull it',
                description: 'Record the part name, location in your yard, part number and asking price.',
                icon: Icons.inventory_2_outlined,
              ),
              SizedBox(height: 14),
              _OnboardingStep(
                number: '3',
                title: 'Track your listings',
                description: 'Add eBay or Facebook links to each part so you know what\'s live and what\'s not.',
                icon: Icons.storefront_outlined,
              ),
              SizedBox(height: 14),
              _OnboardingStep(
                number: '4',
                title: 'Mark parts as sold',
                description: 'Tap the three-dot menu on any part to mark it sold and record the sale price.',
                icon: Icons.check_circle_outline,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Free tier info
        AppCard(
          child: Row(
            children: [
              const Icon(Icons.lock_open_outlined, color: Color(0xFFE8700A), size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Free to get started',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      'No account required. Add your first vehicle and up to 5 parts for free.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final IconData icon;

  const _OnboardingStep({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFE8700A).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE8700A).withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFFE8700A),
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5), height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void _showVehicleDetailsSheet(BuildContext context, Vehicle vehicle) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _VehicleDetailsSheet(vehicle: vehicle),
  );
}

class _VehicleDetailsSheet extends StatelessWidget {
  final Vehicle vehicle;
  const _VehicleDetailsSheet({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    if (vehicle.color.isNotEmpty) {
      rows.add(_DetailRow(icon: Icons.palette_outlined, label: 'Colour', value: vehicle.color));
    }
    if (vehicle.usageValue != null) {
      final unitLabel = vehicle.usageUnit == 'hours' ? 'Hours' : vehicle.usageUnit == 'miles' ? 'Miles' : 'Kilometres';
      rows.add(_DetailRow(icon: Icons.speed_outlined, label: unitLabel,
          value: '${_formatUsage(vehicle.usageValue!)} ${vehicle.usageUnit}'));
    }
    if (vehicle.purchasePriceCents != null) {
      rows.add(_DetailRow(icon: Icons.attach_money, label: 'Purchase price',
          value: formatMoneyFromCents(vehicle.purchasePriceCents!)));
    }
    rows.add(_DetailRow(icon: Icons.flag_outlined, label: 'Status',
        value: vehicle.status.label));
    rows.add(_DetailRow(icon: Icons.calendar_today_outlined, label: 'Acquired',
        value: '${vehicle.acquiredAt.day}/${vehicle.acquiredAt.month}/${vehicle.acquiredAt.year}'));
    if ((vehicle.identifier ?? '').isNotEmpty) {
      rows.add(_DetailRow(icon: Icons.tag, label: 'VIN / Rego / ID', value: vehicle.identifier!));
    }
    if ((vehicle.notes ?? '').trim().isNotEmpty) {
      rows.add(_DetailRow(icon: Icons.notes_outlined, label: 'Notes', value: vehicle.notes!.trim()));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${vehicle.year} ${vehicle.make} ${vehicle.model}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            '${vehicle.partsCount} parts  ·  ${vehicle.inStockCount} in stock',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
          ),
          const SizedBox(height: 16),
          // Vehicle photos
          PhotoStrip(
            ownerType: 'vehicle',
            ownerId: vehicle.id,
            maxCount: kMaxVehiclePhotos,
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('No extra details recorded.', style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
            )
          else
            ...rows,
        ],
      ),
    );
  }
}

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final VoidCallback? onMarkCompleted;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onOpen,
    required this.onDelete,
    this.onMarkCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final pl = vehicle.profitLossCents;
    final plColor = profitColor(pl);
    final isCompleted = vehicle.status == VehicleStatus.shellGone;

    final typeIcon = switch (vehicle.itemType) {
      ItemType.car        => Icons.directions_car,
      ItemType.motorcycle => Icons.two_wheeler,
      ItemType.boat       => Icons.directions_boat,
      ItemType.tractor    => Icons.agriculture,
      ItemType.other      => Icons.category,
    };

    // Stat line: kms (most important) · parts · in stock · P/L
    final statParts = <String>[];
    if (vehicle.usageValue != null) {
      statParts.add('${_formatUsage(vehicle.usageValue!)} ${vehicle.usageUnit}');
    }
    statParts.add('${vehicle.partsCount} parts');
    if (vehicle.inStockCount > 0) {
      statParts.add('${vehicle.inStockCount} in stock');
    }
    if (vehicle.listedLiveCount > 0) {
      statParts.add('${vehicle.listedLiveCount} listed');
    }
    // Only show P/L when there are parts — no parts means $0 is meaningless.
    final showPL = vehicle.partsCount > 0;
    final plStr = formatMoneyFromCents(pl);
    // Prefix is everything before P/L, joined with separators.
    final statPrefix = statParts.isEmpty ? '' : '${statParts.join('  ·  ')}${showPL ? '  ·  ' : ''}';

    return Opacity(
      opacity: isCompleted ? 0.45 : 1.0,
      child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF252525), Color(0xFF1A1A1A)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Accent bar — grey when completed, orange otherwise
              Container(
                width: 4,
                height: 76,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                  gradient: isCompleted
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.grey, Color(0xFF555555)],
                        )
                      : const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFE8700A), Color(0xFFC45A06)],
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Type icon in circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8700A).withValues(alpha: 0.12),
                ),
                child: Icon(typeIcon, size: 24, color: const Color(0xFFE8700A)),
              ),
              const SizedBox(width: 14),
              // Title + stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _titleOrFallback(vehicle),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCompleted) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.4)),
                            ),
                            child: const Text(
                              'Shell Gone',
                              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 12),
                        children: [
                          TextSpan(
                            text: statPrefix,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
                          ),
                          if (showPL)
                            TextSpan(
                              text: 'P/L $plStr',
                              style: TextStyle(color: plColor, fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((vehicle.notes ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        vehicle.notes!,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Info button — opens vehicle details sheet
              IconButton(
                onPressed: () => _showVehicleDetailsSheet(context, vehicle),
                icon: const Icon(Icons.info_outline, color: Colors.green, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
              // 3-dot menu
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'delete') onDelete();
                  if (v == 'complete' && onMarkCompleted != null) onMarkCompleted!();
                },
                itemBuilder: (_) => [
                  if (onMarkCompleted != null)
                    PopupMenuItem(
                      value: 'complete',
                      child: ListTile(
                        leading: Icon(isCompleted ? Icons.refresh : Icons.check_circle_outline, color: isCompleted ? Colors.orange : Colors.grey),
                        title: Text(isCompleted ? 'Mark Active' : 'Mark Completed'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                padding: EdgeInsets.zero,
                iconSize: 20,
                icon: Icon(Icons.more_vert, color: Colors.white.withValues(alpha: 0.3), size: 20),
              ),
            ],
          ),
        ),
      ),
      ), // Opacity
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Default model suggestions per vehicle type — shown when recents list is empty.
// These are fallback hints only; user can always type freely.
// ─────────────────────────────────────────────────────────────────────────────
List<String> defaultModelsForType(ItemType type) {
  switch (type) {
    case ItemType.car:
      return ['Ranger', 'Hilux', 'Navara', 'Triton', 'D-Max', 'BT-50', 'LandCruiser'];
    case ItemType.motorcycle:
      return ['MT-07', 'Ninja 400', 'CRF250', 'YZF-R3', 'KLR650', 'GSX-R', 'Duke 390'];
    case ItemType.boat:
      return ['510 Cruiseabout', '550 Centre Console', '460 Renegade', '580 Fisherman'];
    case ItemType.tractor:
      return ['3CX', 'D6', '308E', 'S70', 'KX057', 'PC200'];
    case ItemType.other:
      return [];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Make suggestions per vehicle type  (v1.2)
// ─────────────────────────────────────────────────────────────────────────────
List<String> defaultMakesForType(ItemType type) {
  switch (type) {
    case ItemType.car:
      return [
        'Ford', 'Toyota', 'Holden', 'Mazda', 'Mitsubishi', 'Nissan', 'Hyundai',
        'Kia', 'Subaru', 'Honda', 'Volkswagen', 'BMW', 'Mercedes-Benz', 'Audi',
        'Lexus', 'Jeep', 'Land Rover', 'Isuzu', 'Suzuki', 'Renault', 'Peugeot',
        'Volvo', 'Skoda', 'Ssangyong', 'GWM', 'BYD', 'LDV',
      ];
    case ItemType.motorcycle:
      return [
        'Honda', 'Yamaha', 'Kawasaki', 'Suzuki', 'KTM', 'Harley-Davidson',
        'Triumph', 'Ducati', 'BMW', 'Aprilia', 'Husqvarna', 'Royal Enfield',
        'MV Agusta', 'Benelli', 'Indian', 'Vespa', 'Piaggio', 'Beta', 'Sherco',
      ];
    case ItemType.boat:
      return [
        // Hull brands
        'Quintrex', 'Stacer', 'Ally Craft', 'Haines Hunter', 'Caribbean',
        'Savage', 'Seafarer', 'Bar Crusher', 'Yellowfin', 'Clark', 'Stejcraft',
        'Horizon', 'Polycraft', 'Bluefin', 'Streaker',
        // Outboard brands
        'Yamaha', 'Mercury', 'Suzuki', 'Honda', 'Evinrude', 'Johnson', 'Tohatsu',
      ];
    case ItemType.tractor:
      return [
        'John Deere', 'Kubota', 'Caterpillar', 'Komatsu', 'Case', 'New Holland',
        'JCB', 'Bobcat', 'Hitachi', 'Volvo', 'Massey Ferguson', 'Deutz-Fahr',
        'Takeuchi', 'Yanmar', 'IHI', 'Doosan', 'Liebherr', 'AGCO', 'Fendt',
      ];
    case ItemType.other:
      return [];
  }
}

/// ----------------------------
/// Add / Edit Vehicle
/// ----------------------------
// ─────────────────────────────────────────────────────────────────────────────
// Recent Model storage  (v1.2)
// Key: recent_models_<typeNormalized>_<makeNormalized>
// Stores up to 20 models per type+make, newest first, de-duped.
// ─────────────────────────────────────────────────────────────────────────────
String _recentModelsKey(ItemType type, String make) {
  final t = type.label.toLowerCase().replaceAll('/', '').replaceAll(' ', '').trim();
  final m = make.toLowerCase().replaceAll(' ', '').trim();
  return 'recent_models_${t}_$m';
}

class RecentModelStorage {
  static const int _maxItems = 20;

  static Future<List<String>> load(ItemType type, String make) async {
    if (make.trim().isEmpty) return [];
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recentModelsKey(type, make));
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      return List<String>.from(jsonDecode(raw) as List);
    } catch (_) {
      return [];
    }
  }

  static Future<void> add(ItemType type, String make, String model) async {
    if (make.trim().isEmpty || model.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final existing = await load(type, make);
    final norm = model.trim().toLowerCase();
    existing.removeWhere((m) => m.trim().toLowerCase() == norm);
    existing.insert(0, model.trim());
    if (existing.length > _maxItems) existing.removeRange(_maxItems, existing.length);
    await prefs.setString(_recentModelsKey(type, make), jsonEncode(existing));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Model autocomplete field  (v1.2)
// Shows recent models for the current type+make; always allows free text.
// ─────────────────────────────────────────────────────────────────────────────
class _ModelAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final ItemType itemType;
  final String make;
  final String? Function(String?)? validator;

  const _ModelAutocompleteField({
    super.key,
    required this.controller,
    required this.itemType,
    required this.make,
    this.validator,
  });

  @override
  State<_ModelAutocompleteField> createState() => _ModelAutocompleteFieldState();
}

class _ModelAutocompleteFieldState extends State<_ModelAutocompleteField> {
  List<String> _recents = [];
  String _lastKey = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_ModelAutocompleteField old) {
    super.didUpdateWidget(old);
    final key = '${widget.itemType.name}_${widget.make}';
    if (key != _lastKey) _load();
  }

  Future<void> _load() async {
    _lastKey = '${widget.itemType.name}_${widget.make}';
    final recents = await RecentModelStorage.load(widget.itemType, widget.make);
    if (mounted) setState(() => _recents = recents);
  }

  @override
  Widget build(BuildContext context) {
    // ── Type-aware icon + hint ─────────────────────────────────────────
    IconData modelIcon;
    String modelHint;
    switch (widget.itemType) {
      case ItemType.car:
        modelIcon = Icons.directions_car_outlined;
        modelHint = 'Ranger / Hilux / Navara';
      case ItemType.motorcycle:
        modelIcon = Icons.two_wheeler_outlined;
        modelHint = 'MT-07 / Ninja 400 / CRF250';
      case ItemType.boat:
        modelIcon = Icons.directions_boat_outlined;
        modelHint = '510 Cruiseabout / 550 Centre Console';
      case ItemType.tractor:
        modelIcon = Icons.agriculture_outlined;
        modelHint = '3CX / D6 / 308E';
      case ItemType.other:
        modelIcon = Icons.inventory_2_outlined;
        modelHint = 'Enter model';
    }

    // Build the options list:
    //   1. Recents (make was entered, user has saved vehicles) — highest priority
    //   2. Type defaults — shown even before make is entered so user sees examples
    //   3. Nothing (ItemType.other with no recents) — plain field fallback
    final defaults = defaultModelsForType(widget.itemType);
    final hasMake = widget.make.trim().isNotEmpty;
    final options = _recents.isNotEmpty
        ? _recents          // recents always win when available
        : defaults;         // fall back to type defaults (empty when Other)

    // No options at all → plain field with appropriate hint
    if (options.isEmpty) {
      return TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          labelText: 'Model',
          hintText: hasMake ? modelHint : 'Enter model',
          prefixIcon: Icon(modelIcon),
        ),
        validator: widget.validator,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        inputFormatters: [LengthLimitingTextInputFormatter(60)],
      );
    }

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: widget.controller.text),
      optionsBuilder: (tv) {
        final q = tv.text.trim().toLowerCase();
        if (q.isEmpty) return options;
        return options.where((m) => m.toLowerCase().contains(q));
      },
      fieldViewBuilder: (ctx, fieldCtrl, focusNode, onFieldSubmitted) {
        fieldCtrl.addListener(() {
          if (widget.controller.text != fieldCtrl.text) {
            widget.controller.text = fieldCtrl.text;
          }
        });
        return TextFormField(
          controller: fieldCtrl,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Model',
            hintText: modelHint,
            prefixIcon: Icon(modelIcon),
          ),
          validator: widget.validator,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          inputFormatters: [LengthLimitingTextInputFormatter(60)],
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder: (ctx, onSelected, opts) {
        final list = opts.toList();
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(kRadius),
            color: const Color(0xFF211A0E),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220, maxWidth: 320),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (_, i) => InkWell(
                  onTap: () => onSelected(list[i]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    child: Text(list[i], style: const TextStyle(fontSize: 14)),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      onSelected: (value) => widget.controller.text = value,
    );
  }
}

/// Context-aware Make field with inline suggestions.
/// Filters the preset list as the user types; still allows free text.
class _MakeAutocompleteField extends StatelessWidget {
  final TextEditingController controller;
  final ItemType itemType;
  final String? Function(String?)? validator;
  final void Function(String)? onMakeChanged;

  const _MakeAutocompleteField({
    super.key,
    required this.controller,
    required this.itemType,
    this.validator,
    this.onMakeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = defaultMakesForType(itemType);

    // If no preset list for this type, fall back to a plain field
    if (options.isEmpty) {
      return TextFormField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Make',
          hintText: 'Enter make',
          prefixIcon: Icon(Icons.business_outlined),
        ),
        onChanged: onMakeChanged,
        validator: validator,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        inputFormatters: [LengthLimitingTextInputFormatter(60)],
      );
    }

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: controller.text),
      optionsBuilder: (textEditingValue) {
        final q = textEditingValue.text.trim().toLowerCase();
        if (q.isEmpty) return options;
        return options.where((o) => o.toLowerCase().contains(q));
      },
      fieldViewBuilder: (ctx, fieldCtrl, focusNode, onFieldSubmitted) {
        // Keep the external controller in sync
        fieldCtrl.addListener(() {
          if (controller.text != fieldCtrl.text) {
            controller.text = fieldCtrl.text;
            onMakeChanged?.call(fieldCtrl.text);
          }
        });
        return TextFormField(
          controller: fieldCtrl,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Make',
            hintText: options.isNotEmpty ? options.first : 'Enter make',
            prefixIcon: const Icon(Icons.business_outlined),
          ),
          validator: validator,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          inputFormatters: [LengthLimitingTextInputFormatter(60)],
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder: (ctx, onSelected, opts) {
        final list = opts.toList();
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(kRadius),
            color: const Color(0xFF211A0E),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220, maxWidth: 320),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (_, i) => InkWell(
                  onTap: () => onSelected(list[i]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    child: Text(
                      list[i],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      onSelected: (value) {
        controller.text = value;
        onMakeChanged?.call(value);
      },
    );
  }
}

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  final _makeCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController(text: DateTime.now().year.toString());
  final _purchaseCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _usageCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _trimCtrl = TextEditingController();
  final _engineCtrl = TextEditingController();
  final _transmissionCtrl = TextEditingController();
  final _drivetrainCtrl = TextEditingController();

  ItemType _itemType = ItemType.car;
  DateTime _acquiredAt = DateTime.now();
  String _usageUnit = 'km';
  String _makeValue = ''; // mirrors _makeCtrl; drives model suggestions

  @override
  void dispose() {
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _purchaseCtrl.dispose();
    _idCtrl.dispose();
    _colorCtrl.dispose();
    _usageCtrl.dispose();
    _notesCtrl.dispose();
    _trimCtrl.dispose();
    _engineCtrl.dispose();
    _transmissionCtrl.dispose();
    _drivetrainCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
      initialDate: _acquiredAt,
    );
    if (picked == null) return;
    setState(() => _acquiredAt = picked);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final year = int.tryParse(_yearCtrl.text.trim()) ?? DateTime.now().year;
    final purchaseCents = parseMoneyToCents(_purchaseCtrl.text);
    final ident = normalizeIdentifier(_idCtrl.text);
    final usageValue = int.tryParse(_usageCtrl.text.trim());
    final notes = _notesCtrl.text.trim();

    final v = Vehicle(
      id: newId(),
      make: _makeCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      year: year,
      itemType: _itemType,
      status: VehicleStatus.whole,
      acquiredAt: _acquiredAt,
      purchasePriceCents: purchaseCents,
      identifier: ident.isEmpty ? null : ident,
      parts: [],
      usageValue: usageValue,
      usageUnit: _usageUnit,
      color: _colorCtrl.text.trim(),
      notes: notes.isEmpty ? null : notes,
      trim: _trimCtrl.text.trim().isEmpty ? null : _trimCtrl.text.trim(),
      engine: _engineCtrl.text.trim().isEmpty ? null : _engineCtrl.text.trim(),
      transmission: _transmissionCtrl.text.trim().isEmpty ? null : _transmissionCtrl.text.trim(),
      drivetrain: _drivetrainCtrl.text.trim().isEmpty ? null : _drivetrainCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    await RecentModelStorage.add(_itemType, v.make, v.model);
    if (mounted) Navigator.of(context).pop(v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vehicle'),
        actions: [
          FilledButton(onPressed: _save, child: const Text('Save')),
          const SizedBox(width: 10),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(kPad),
        children: [
          AppCard(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<ItemType>(
                    initialValue: _itemType,
                    decoration: const InputDecoration(labelText: 'Item type'),
                    items: ItemType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                    onChanged: (v) {
                      setState(() {
                        _itemType = v ?? ItemType.other;
                        _makeCtrl.clear();
                        _modelCtrl.clear();
                        _makeValue = '';
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _MakeAutocompleteField(
                    key: ValueKey('make_$_itemType'), // force rebuild on type change
                    controller: _makeCtrl,
                    itemType: _itemType,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    onMakeChanged: (m) => setState(() {
                      _makeValue = m;
                      _modelCtrl.clear();
                    }),
                  ),
                  const SizedBox(height: 10),
                  _ModelAutocompleteField(
                    key: ValueKey('model_$_itemType'),
                    controller: _modelCtrl,
                    itemType: _itemType,
                    make: _makeValue,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _yearCtrl,
                    decoration: const InputDecoration(labelText: 'Year'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final year = int.tryParse((v ?? '').trim());
                      if (year == null) return 'Enter a year';
                      if (year < 1900 || year > DateTime.now().year + 1) return 'Year looks wrong';
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _trimCtrl,
                    decoration: const InputDecoration(labelText: 'Trim (optional)', hintText: 'e.g. SR5 / Sport / Limited'),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _engineCtrl,
                    decoration: const InputDecoration(labelText: 'Engine (optional)', hintText: 'e.g. 2.0L 4cyl / 3.5L V6 / 2JZ-GE'),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _transmissionCtrl,
                    decoration: const InputDecoration(labelText: 'Transmission (optional)', hintText: 'e.g. Auto / Manual / CVT'),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _drivetrainCtrl,
                    decoration: const InputDecoration(labelText: 'Drivetrain (optional)', hintText: 'e.g. FWD / RWD / AWD / 4WD'),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _idCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Identifier (optional)',
                      hintText: 'VIN / rego / serial / stock #',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [LengthLimitingTextInputFormatter(50)],
                    onChanged: (v) {
                      final upper = v.toUpperCase();
                      if (v != upper) {
                        _idCtrl.value = _idCtrl.value.copyWith(
                          text: upper,
                          selection: TextSelection.collapsed(offset: upper.length),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _colorCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Colour (optional)',
                      hintText: 'e.g. Silver, Gunmetal Grey',
                      prefixIcon: Icon(Icons.palette_outlined),
                    ),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _usageCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Usage reading (optional)',
                            hintText: 'e.g. 120000',
                            prefixIcon: Icon(Icons.speed_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: _usageUnit,
                          decoration: const InputDecoration(labelText: 'Unit'),
                          items: const [
                            DropdownMenuItem(value: 'km', child: Text('km')),
                            DropdownMenuItem(value: 'miles', child: Text('miles')),
                            DropdownMenuItem(value: 'hours', child: Text('hours')),
                          ],
                          onChanged: (v) => setState(() => _usageUnit = v ?? 'km'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vehicle details are copied into parts added under this vehicle. Accurate information helps keep part records reliable.',
                    style: TextStyle(fontSize: 11, color: Colors.white38),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _purchaseCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Purchase price (optional)',
                      hintText: 'e.g. 2500 or 2500.00',
                      prefixText: '\$',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _notesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Notes / Damage (optional)',
                      hintText: 'e.g. front hit, flood, engine knocks, rolled',
                      prefixIcon: Icon(Icons.warning_amber_outlined),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    maxLength: 2000,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text('Acquired: ${formatDateShort(_acquiredAt)}'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditVehicleScreen extends StatefulWidget {
  final Vehicle vehicle;

  const EditVehicleScreen({super.key, required this.vehicle});

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _makeCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _purchaseCtrl;
  late final TextEditingController _idCtrl;
  late final TextEditingController _colorCtrl;
  late final TextEditingController _usageCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _trimCtrl;
  late final TextEditingController _engineCtrl;
  late final TextEditingController _transmissionCtrl;
  late final TextEditingController _drivetrainCtrl;

  late ItemType _itemType;
  late DateTime _acquiredAt;
  late String _usageUnit;
  late String _makeValue;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _makeCtrl = TextEditingController(text: v.make);
    _modelCtrl = TextEditingController(text: v.model);
    _makeValue = v.make;
    _yearCtrl = TextEditingController(text: v.year.toString());
    _purchaseCtrl = TextEditingController(
      text: v.purchasePriceCents == null ? '' : (v.purchasePriceCents! / 100).toStringAsFixed(2),
    );
    _idCtrl = TextEditingController(text: v.identifier ?? '');
    _colorCtrl = TextEditingController(text: v.color);
    _usageCtrl = TextEditingController(
      text: v.usageValue != null ? v.usageValue.toString() : '',
    );
    _notesCtrl = TextEditingController(text: v.notes ?? '');
    _trimCtrl = TextEditingController(text: v.trim ?? '');
    _engineCtrl = TextEditingController(text: v.engine ?? '');
    _transmissionCtrl = TextEditingController(text: v.transmission ?? '');
    _drivetrainCtrl = TextEditingController(text: v.drivetrain ?? '');
    _itemType = v.itemType;
    _acquiredAt = v.acquiredAt;
    _usageUnit = v.usageUnit;
  }

  @override
  void dispose() {
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _purchaseCtrl.dispose();
    _idCtrl.dispose();
    _colorCtrl.dispose();
    _usageCtrl.dispose();
    _notesCtrl.dispose();
    _trimCtrl.dispose();
    _engineCtrl.dispose();
    _transmissionCtrl.dispose();
    _drivetrainCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
      initialDate: _acquiredAt,
    );
    if (picked == null) return;
    setState(() => _acquiredAt = picked);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final year = int.tryParse(_yearCtrl.text.trim()) ?? widget.vehicle.year;
    final purchaseCents = parseMoneyToCents(_purchaseCtrl.text);
    final ident = normalizeIdentifier(_idCtrl.text);
    final usageValue = int.tryParse(_usageCtrl.text.trim());
    final notes = _notesCtrl.text.trim();

    final updated = Vehicle(
      id: widget.vehicle.id,
      make: _makeCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      year: year,
      itemType: _itemType,
      status: widget.vehicle.status, // preserved from existing data
      acquiredAt: _acquiredAt,
      purchasePriceCents: purchaseCents,
      identifier: ident.isEmpty ? null : ident,
      parts: widget.vehicle.parts,
      usageValue: usageValue,
      usageUnit: _usageUnit,
      color: _colorCtrl.text.trim(),
      notes: notes.isEmpty ? null : notes,
      trim: _trimCtrl.text.trim().isEmpty ? null : _trimCtrl.text.trim(),
      engine: _engineCtrl.text.trim().isEmpty ? null : _engineCtrl.text.trim(),
      transmission: _transmissionCtrl.text.trim().isEmpty ? null : _transmissionCtrl.text.trim(),
      drivetrain: _drivetrainCtrl.text.trim().isEmpty ? null : _drivetrainCtrl.text.trim(),
      createdAt: widget.vehicle.createdAt, // preserve original creation time
      updatedAt: DateTime.now(),
    );

    await RecentModelStorage.add(_itemType, updated.make, updated.model);
    if (mounted) Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Vehicle'),
        actions: [
          FilledButton(onPressed: () => _save(), child: const Text('Save')),
          const SizedBox(width: 10),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(kPad),
        children: [
          AppCard(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<ItemType>(
                    initialValue: _itemType,
                    decoration: const InputDecoration(labelText: 'Item type'),
                    items: ItemType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                    onChanged: (v) {
                      setState(() {
                        _itemType = v ?? ItemType.other;
                        _makeCtrl.clear();
                        _modelCtrl.clear();
                        _makeValue = '';
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _MakeAutocompleteField(
                    key: ValueKey('make_$_itemType'),
                    controller: _makeCtrl,
                    itemType: _itemType,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    onMakeChanged: (m) => setState(() {
                      _makeValue = m;
                      _modelCtrl.clear();
                    }),
                  ),
                  const SizedBox(height: 10),
                  _ModelAutocompleteField(
                    key: ValueKey('model_$_itemType'),
                    controller: _modelCtrl,
                    itemType: _itemType,
                    make: _makeValue,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _yearCtrl,
                    decoration: const InputDecoration(labelText: 'Year'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final year = int.tryParse((v ?? '').trim());
                      if (year == null) return 'Enter a year';
                      if (year < 1900 || year > DateTime.now().year + 1) return 'Year looks wrong';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _trimCtrl,
                    decoration: const InputDecoration(labelText: 'Trim (optional)', hintText: 'e.g. SR5 / Sport / Limited'),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _engineCtrl,
                    decoration: const InputDecoration(labelText: 'Engine (optional)', hintText: 'e.g. 2.0L 4cyl / 3.5L V6 / 2JZ-GE'),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _transmissionCtrl,
                    decoration: const InputDecoration(labelText: 'Transmission (optional)', hintText: 'e.g. Auto / Manual / CVT'),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _drivetrainCtrl,
                    decoration: const InputDecoration(labelText: 'Drivetrain (optional)', hintText: 'e.g. FWD / RWD / AWD / 4WD'),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _idCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Identifier (optional)',
                      hintText: 'VIN / rego / serial / stock #',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (v) {
                      final upper = v.toUpperCase();
                      if (v != upper) {
                        _idCtrl.value = _idCtrl.value.copyWith(
                          text: upper,
                          selection: TextSelection.collapsed(offset: upper.length),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _colorCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Colour (optional)',
                      hintText: 'e.g. Silver, Gunmetal Grey',
                      prefixIcon: Icon(Icons.palette_outlined),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _usageCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Usage reading (optional)',
                            hintText: 'e.g. 120000',
                            prefixIcon: Icon(Icons.speed_outlined),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: _usageUnit,
                          decoration: const InputDecoration(labelText: 'Unit'),
                          items: const [
                            DropdownMenuItem(value: 'km', child: Text('km')),
                            DropdownMenuItem(value: 'miles', child: Text('miles')),
                            DropdownMenuItem(value: 'hours', child: Text('hours')),
                          ],
                          onChanged: (v) => setState(() => _usageUnit = v ?? 'km'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vehicle details are copied into parts added under this vehicle. Accurate information helps keep part records reliable.',
                    style: TextStyle(fontSize: 11, color: Colors.white38),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _purchaseCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Purchase price (optional)',
                      prefixText: '\$',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _notesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Notes / Damage (optional)',
                      hintText: 'e.g. front hit, flood, engine knocks, rolled',
                      prefixIcon: Icon(Icons.warning_amber_outlined),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    maxLength: 2000,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text('Acquired: ${formatDateShort(_acquiredAt)}'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ----------------------------
/// Vehicle Detail (Parts) + Filters
/// ----------------------------
enum _PartsViewFilter { all, listed, notListed }

class VehicleDetailScreen extends StatefulWidget {
  final Vehicle vehicle;
  /// All vehicles — used to generate globally-unique stock IDs.
  final List<Vehicle> allVehicles;

  const VehicleDetailScreen({
    super.key,
    required this.vehicle,
    required this.allVehicles,
  });

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  late Vehicle _v;
  _PartsViewFilter _filter = _PartsViewFilter.all;
  String? _sideFilter;
  bool _selectMode = false;
  final Set<String> _selectedPartIds = {};
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  List<String> _categories = List.from(kPartCategories);

  @override
  void initState() {
    super.initState();
    _v = Vehicle.fromJson(widget.vehicle.toJson());
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
    });
    PartCategoryStorage.load().then((cats) {
      if (mounted) setState(() => _categories = cats);
    }).catchError((Object e) { if (kDebugMode) debugPrint('PartCategoryStorage.load failed: $e'); });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _editVehicle() async {
    final updated = await Navigator.of(context).push<Vehicle>(
      MaterialPageRoute(builder: (_) => EditVehicleScreen(vehicle: _v)),
    );
    if (updated == null) return;
    setState(() => _v = updated);
  }

  Future<void> _addPart() async {
    if (!isPro && _v.parts.length >= kFreePartLimitPerVehicle) {
      await showProPaywall(
        context,
        title: 'Free parts limit reached',
        message: 'Free WreckLog allows $kFreePartLimitPerVehicle parts per vehicle. Upgrade to Pro for unlimited parts.',
      );
      if (!mounted) return;
    }
    final created = await Navigator.of(context).push<Part>(
      MaterialPageRoute(builder: (_) => AddPartScreen(allVehicles: _allVehiclesWithCurrent(), vehicle: _v)),
    );
    if (!mounted || created == null) return;
    setState(() {
      normalizePartStateFromListings(created);
      _v.parts.insert(0, created);
    });
  }

  Future<void> _quickAddPresets() async {
    final groups = await PresetGroupStorage.load(_v.itemType);
    if (!mounted) return;
    final selected = await Navigator.of(context).push<Set<String>>(
      MaterialPageRoute(
        builder: (_) => GroupedPresetsPickerScreen(
          itemType: _v.itemType,
          groups: groups,
          allVehicles: _allVehiclesWithCurrent(),
          existingParts: _v.parts,
        ),
        fullscreenDialog: true,
      ),
    );
    if (selected == null || selected.isEmpty) return;
    if (!mounted) return;

    if (!isPro) {
      final remaining = kFreePartLimitPerVehicle - _v.parts.length;
      if (remaining <= 0) {
        await showProPaywall(
          context,
          title: 'Free parts limit reached',
          message: 'Free WreckLog allows $kFreePartLimitPerVehicle parts per vehicle. Upgrade to Pro for unlimited parts.',
        );
        return;
      }
      if (selected.length > remaining) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Free tier allows $remaining more part(s) on this vehicle. Please select fewer or upgrade to Pro.')),
        );
        return;
      }
    }

    setState(() {
      // Build a running set of existing stock IDs so each preset gets a unique one
      final existingIds = <String>{};
      for (final v in _allVehiclesWithCurrent()) {
        for (final p in v.parts) {
          if (p.stockId != null) existingIds.add(p.stockId!);
        }
      }

      for (final name in selected) {
        final stockId = _generateStockId(existingIds);
        existingIds.add(stockId); // reserve for the next iteration
        _v.parts.insert(
          0,
          Part(
            id: newId(),
            name: name,
            state: PartState.removed,
            createdAt: DateTime.now(),
            qty: 1,
            stockId: stockId,
            vehicleMake: _v.make,
            vehicleModel: _v.model,
            vehicleYear: _v.year,
            vehicleTrim: _v.trim,
            vehicleEngine: _v.engine,
            vehicleTransmission: _v.transmission,
            vehicleDrivetrain: _v.drivetrain,
            vehicleUsageValue: _v.usageValue,
            vehicleUsageUnit: _v.usageUnit,
          ),
        );
      }
    });
  }

  void _saveAndExit() => Navigator.of(context).pop(_v);

  /// Returns allVehicles from parent with current vehicle replaced by latest _v.
  /// Used for globally-unique stock ID generation.
  List<Vehicle> _allVehiclesWithCurrent() {
    return widget.allVehicles
        .map((v) => v.id == _v.id ? _v : v)
        .toList();
  }

  Future<void> _deletePart(Part p) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete part?'),
            content: Text('Delete "${p.name}" from this item?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
            ],
          ),
        ) ??
        false;
    if (!ok) return;

    // Clean up photos for this part
    await PhotoStorage.deleteAllForOwner('part', p.id);
    setState(() => _v.parts.removeWhere((x) => x.id == p.id));
  }

  Future<void> _editPart(Part p) async {
    final updated = await showDialog<Part>(
      context: context,
      builder: (_) => EditPartDialog(part: p),
    );
    if (updated == null) return;
    setState(() {
      final idx = _v.parts.indexWhere((x) => x.id == p.id);
      if (idx >= 0) {
        normalizePartStateFromListings(updated);
        _v.parts[idx] = updated;
      }
    });
  }

  /// Opens PartDetailScreen for [p]. If the user edits and saves, the
  /// returned Part is spliced back into _v automatically.
  Future<void> _openPartDetail(Part p) async {
    final updated = await Navigator.of(context).push<Part>(
      MaterialPageRoute(
        builder: (_) => PartDetailScreen(
          part: p,
          vehicle: _v,
          // onPartEdited not needed here — we use the push return value.
        ),
      ),
    );
    if (updated == null) return;
    setState(() {
      final idx = _v.parts.indexWhere((x) => x.id == updated.id);
      if (idx >= 0) _v.parts[idx] = updated;
    });
  }

  Future<void> _setSold(Part p) async {
    final ctrl = TextEditingController(
      text: p.salePriceCents == null ? '' : (p.salePriceCents! / 100).toStringAsFixed(2),
    );

    final cents = await showDialog<int?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as sold'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Sold price',
            hintText: 'e.g. 100 or 100.00',
            prefixText: '\$',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final c = parseMoneyToCents(ctrl.text) ?? 0;
              Navigator.pop(ctx, c);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    ctrl.dispose();
    if (cents == null) return;

    setState(() {
      p.state = PartState.sold;
      p.salePriceCents = cents;
      p.dateSold ??= DateTime.now();
      for (final l in p.listings) {
        l.isLive = false;
      }
    });
  }

  void _setScrapped(Part p) {
    setState(() {
      p.state = PartState.scrapped;
      p.salePriceCents = null;
      for (final l in p.listings) {
        l.isLive = false;
      }
    });
  }

  void _setInStock(Part p) {
    setState(() {
      p.state = p.hasLiveListings ? PartState.listed : PartState.removed;
      p.salePriceCents = null;
    });
  }

  void _duplicatePart(Part source) {
    final copy = Part(
      id: newId(),
      name: source.name,
      state: PartState.removed,
      createdAt: DateTime.now(),
      category: source.category,
      partCondition: source.partCondition,
      side: source.side,
      partNumber: source.partNumber,
      notes: source.notes,
      location: source.location,
      qty: source.qty,
      stockId: generateUniqueStockId(_allVehiclesWithCurrent()),
      vehicleMake: source.vehicleMake,
      vehicleModel: source.vehicleModel,
      vehicleYear: source.vehicleYear,
      vehicleTrim: source.vehicleTrim,
      vehicleEngine: source.vehicleEngine,
      vehicleTransmission: source.vehicleTransmission,
      vehicleDrivetrain: source.vehicleDrivetrain,
      vehicleUsageValue: source.vehicleUsageValue,
      vehicleUsageUnit: source.vehicleUsageUnit,
      // askingPriceCents intentionally copied — useful default
      askingPriceCents: source.askingPriceCents,
      // sale price, dateSold, listings NOT copied
    );
    setState(() => _v.parts.add(copy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Duplicated "${source.name}"')));
  }

  Future<void> _deleteSoldPartPhotos() async {
    final soldParts = _v.parts.where((p) => p.state == PartState.sold).toList();
    if (soldParts.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No sold parts with photos to clean up.')));
      }
      return;
    }

    // Count photos first so confirmation dialog is meaningful
    int photoCount = 0;
    for (final part in soldParts) {
      final photos = await PhotoStorage.forOwner('part', part.id);
      photoCount += photos.length;
    }

    if (photoCount == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sold parts have no photos to delete.')));
      }
      return;
    }

    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete photos of sold parts?'),
        content: Text(
          'This will permanently delete $photoCount photo${photoCount == 1 ? '' : 's'} '
          'from ${soldParts.length} sold part${soldParts.length == 1 ? '' : 's'} '
          'in this vehicle.\n\nThis cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete photos'),
          ),
        ],
      ),
    ) ?? false;

    if (!ok || !mounted) return;

    for (final part in soldParts) {
      await PhotoStorage.deleteAllForOwner('part', part.id);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted $photoCount photo${photoCount == 1 ? '' : 's'} from sold parts.'),
          backgroundColor: Colors.green,
        ));
    }
  }


  Future<void> _bulkMarkSold() async {
    if (_selectedPartIds.isEmpty) return;
    final ctrl = TextEditingController();
    final cents = await showDialog<int?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Mark ${_selectedPartIds.length} part${_selectedPartIds.length == 1 ? '' : 's'} as sold'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Sold price each',
            hintText: 'e.g. 100.00',
            prefixText: '\$',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final c = parseMoneyToCents(ctrl.text) ?? 0;
              Navigator.pop(ctx, c);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (cents == null || !mounted) return;
    setState(() {
      for (final p in _v.parts) {
        if (_selectedPartIds.contains(p.id)) {
          p.state = PartState.sold;
          p.salePriceCents = cents;
          p.dateSold ??= DateTime.now();
          for (final l in p.listings) { l.isLive = false; }
        }
      }
      _selectMode = false;
      _selectedPartIds.clear();
    });
  }

  void _bulkMarkScrapped() {
    setState(() {
      for (final p in _v.parts) {
        if (_selectedPartIds.contains(p.id)) {
          p.state = PartState.scrapped;
          p.salePriceCents = null;
          for (final l in p.listings) { l.isLive = false; }
        }
      }
      _selectMode = false;
      _selectedPartIds.clear();
    });
  }

  Future<void> _bulkDelete() async {
    if (_selectedPartIds.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${_selectedPartIds.length} part${_selectedPartIds.length == 1 ? '' : 's'}?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
    if (!ok || !mounted) return;
    for (final id in _selectedPartIds) {
      await PhotoStorage.deleteAllForOwner('part', id);
    }
    setState(() {
      _v.parts.removeWhere((p) => _selectedPartIds.contains(p.id));
      _selectMode = false;
      _selectedPartIds.clear();
    });
  }

  List<Widget> _buildGroupedParts(List<Part> parts, BuildContext context) {
    // Group parts by category
    final Map<String, List<Part>> groups = {};
    for (final p in parts) {
      final key = (p.category?.trim().isNotEmpty == true) ? p.category! : 'Uncategorised';
      groups.putIfAbsent(key, () => []).add(p);
    }

    // Order: user-defined categories first (in their order), custom next, Uncategorised last
    final ordered = [
      ..._categories.where(groups.containsKey),
      ...groups.keys.where((k) => !_categories.contains(k) && k != 'Uncategorised'),
      if (groups.containsKey('Uncategorised')) 'Uncategorised',
    ];

    return ordered.map((cat) {
      final catParts = groups[cat]!;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: true,
              tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              backgroundColor: Colors.white.withValues(alpha: 0.03),
              collapsedBackgroundColor: Colors.white.withValues(alpha: 0.03),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
              title: Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8700A),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    cat,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${catParts.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
              children: catParts.map((p) => Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                child: GestureDetector(
                  onTap: _selectMode
                      ? () => setState(() {
                          if (_selectedPartIds.contains(p.id)) { _selectedPartIds.remove(p.id); }
                          else { _selectedPartIds.add(p.id); }
                        })
                      : () => _openPartDetail(p),
                  onLongPress: () {
                    if (!_selectMode) {
                      setState(() {
                        _selectMode = true;
                        _selectedPartIds.add(p.id);
                      });
                    }
                  },
                  child: Stack(
                    children: [
                      PartCard(
                        part: p,
                        onEdit: () => _editPart(p),
                        onDelete: () => _deletePart(p),
                        onMarkSold: () => _setSold(p),
                        onMarkScrapped: () => _setScrapped(p),
                        onMarkInStock: () => _setInStock(p),
                        onOpenLinks: () => showLinksSheet(context, p),
                        onDuplicate: () => _duplicatePart(p),
                        onAddToCommonParts: () => showAddToCommonPartsSheet(
                          context,
                          partName: p.name,
                          itemType: _v.itemType,
                        ),
                      ),
                      if (_selectMode)
                        Positioned(
                          top: 8, right: 8,
                          child: Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _selectedPartIds.contains(p.id) ? const Color(0xFFE8700A) : Colors.white24,
                              border: Border.all(color: Colors.white54, width: 1.5),
                            ),
                            child: _selectedPartIds.contains(p.id)
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Part> _filteredParts() {
    var parts = _v.parts;

    // Apply state filter
    switch (_filter) {
      case _PartsViewFilter.all:
        break;
      case _PartsViewFilter.listed:
        parts = parts.where((p) => p.hasLiveListings).toList();
        break;
      case _PartsViewFilter.notListed:
        parts = parts.where((p) {
          final inStock = p.state == PartState.removed || p.state == PartState.listed;
          return inStock && !p.hasLiveListings;
        }).toList();
        break;
    }

    // Apply side filter
    if (_sideFilter != null) {
      parts = parts.where((p) => p.side == _sideFilter).toList();
    }

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      parts = parts.where((p) {
        final q = _searchQuery;
        if (p.name.toLowerCase().contains(q)) return true;
        if ((p.location ?? '').toLowerCase().contains(q)) return true;
        if ((p.partNumber ?? '').toLowerCase().contains(q)) return true;
        if (normalizePartNumber(p.partNumber ?? '').toLowerCase().contains(normalizePartNumber(q).toLowerCase())) return true;
        if ((p.notes ?? '').toLowerCase().contains(q)) return true;
        if ((p.stockId ?? '').toLowerCase().contains(q)) return true;
        return false;
      }).toList();
    }

    return parts;
  }

  @override
  Widget build(BuildContext context) {
    final pl = _v.profitLossCents;
    final plColor = profitColor(pl);

    final notListed = _v.inStockCount - _v.listedLiveCount;
    final shownParts = _filteredParts();

    final infoParts = <String>[];
    if ((_v.identifier ?? '').trim().isNotEmpty) infoParts.add(_v.identifier!.trim());
    if (_v.color.trim().isNotEmpty) infoParts.add(_v.color.trim());
    if (_v.usageValue != null) infoParts.add('${_formatUsage(_v.usageValue!)} ${_v.usageUnit}');
    final infoLine = infoParts.join('  ·  ');

    Widget statBox(String value, String label, Color color, {bool active = false, VoidCallback? onTap}) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: active ? color.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: active ? color.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.07),
              ),
            ),
            child: Column(
              children: [
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
                const SizedBox(height: 2),
                Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.45))),
              ],
            ),
          ),
        ),
      );
    }

    Widget filterPill(String label, _PartsViewFilter f) {
      final active = _filter == f;
      return GestureDetector(
        onTap: () => setState(() => _filter = f),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: active ? const Color(0xFFE8700A) : Colors.white.withValues(alpha: 0.07),
            border: Border.all(
              color: active ? const Color(0xFFE8700A) : Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ),
      );
    }

    Widget sideChip(String label, String? value) {
      final active = _sideFilter == value;
      return GestureDetector(
        onTap: () => setState(() => _sideFilter = active ? null : value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: active ? Colors.blue.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: active ? Colors.blue.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? Colors.blue[200] : Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    // PopScope ensures the latest vehicle state is always returned to the
    // parent (and thus persisted) even when the user navigates back via
    // system gesture or hardware button, not just the explicit back arrow.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _saveAndExit();
      },
      child: Scaffold(
      appBar: _selectMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() { _selectMode = false; _selectedPartIds.clear(); }),
              ),
              title: Text('${_selectedPartIds.length} selected'),
            )
          : AppBar(
        title: Text(_titleOrFallback(_v)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _saveAndExit),
        actions: [
          IconButton(
            tooltip: 'Edit vehicle',
            onPressed: _editVehicle,
            icon: const Icon(Icons.edit_outlined),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More options',
            onSelected: (value) async {
              if (value == 'quick_add') await _quickAddPresets();
              if (value == 'delete_sold_photos') await _deleteSoldPartPhotos();
              if (value == 'toggle_completed') {
                setState(() {
                  _v.status = _v.status == VehicleStatus.shellGone
                      ? VehicleStatus.stripping
                      : VehicleStatus.shellGone;
                });
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'quick_add', child: ListTile(
                leading: Icon(Icons.playlist_add),
                title: Text('Add common parts'),
                contentPadding: EdgeInsets.zero,
              )),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'toggle_completed', child: ListTile(
                leading: Icon(_v.status == VehicleStatus.shellGone ? Icons.refresh : Icons.check_circle_outline),
                title: Text(_v.status == VehicleStatus.shellGone ? 'Mark Active' : 'Mark Completed'),
                contentPadding: EdgeInsets.zero,
              )),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'delete_sold_photos', child: ListTile(
                leading: Icon(Icons.delete_sweep_outlined),
                title: Text('Delete photos of sold parts'),
                contentPadding: EdgeInsets.zero,
              )),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'fab_common_parts',
            onPressed: _quickAddPresets,
            tooltip: 'Add common parts',
            child: const Icon(Icons.playlist_add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'fab_add_part',
            onPressed: _addPart,
            icon: const Icon(Icons.add),
            label: const Text('Add Part'),
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: CustomPaint(painter: LeatherGrainPainter()),
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(kPad, kPad, kPad, 96),
            children: [
              // ── Vehicle info line ────────────────────────────────────────
          if (infoLine.isNotEmpty) ...[
            Text(
              infoLine,
              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
          ],
          if ((_v.notes ?? '').trim().isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.warning_amber_outlined, size: 14, color: Colors.orange.withValues(alpha: 0.8)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _v.notes!,
                    style: TextStyle(fontSize: 12, color: Colors.orange.withValues(alpha: 0.75)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          // ── 4 stat boxes ─────────────────────────────────────────────
          Row(
            children: [
              statBox('${_v.partsCount}', 'Parts', Colors.white60,
                active: _filter == _PartsViewFilter.all,
                onTap: () => setState(() => _filter = _PartsViewFilter.all)),
              const SizedBox(width: 8),
              statBox('${_v.inStockCount}', 'In Stock', const Color(0xFFE8700A)),
              const SizedBox(width: 8),
              statBox('${_v.listedLiveCount}', 'Listed', Colors.green,
                active: _filter == _PartsViewFilter.listed,
                onTap: () => setState(() => _filter = _PartsViewFilter.listed)),
              const SizedBox(width: 8),
              statBox(formatMoneyFromCents(pl), 'P&L', plColor),
            ],
          ),
          const SizedBox(height: 14),

          // ── Filter pills + part count ────────────────────────────────
          Row(
            children: [
              filterPill('All', _PartsViewFilter.all),
              const SizedBox(width: 8),
              filterPill('Listed', _PartsViewFilter.listed),
              const SizedBox(width: 8),
              filterPill('Unlisted ($notListed)', _PartsViewFilter.notListed),
              const Spacer(),
              Text(
                '${shownParts.length} part${shownParts.length == 1 ? '' : 's'}',
                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.3)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              sideChip('All sides', null),
              const SizedBox(width: 6),
              sideChip('Left', 'Left'),
              const SizedBox(width: 6),
              sideChip('Right', 'Right'),
              const SizedBox(width: 6),
              sideChip('Pair', 'Pair'),
            ]),
          ),
          const SizedBox(height: 12),

          // ── Search bar ───────────────────────────────────────────────
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search parts...',
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),

          // ── Vehicle photos ───────────────────────────────────────────────
          AppCard(
            child: PhotoStrip(
              ownerType: 'vehicle',
              ownerId:   _v.id,
              maxCount:  kMaxVehiclePhotos,
            ),
          ),
          const SizedBox(height: 12),

          if (shownParts.isEmpty)
            AppCard(
              child: Column(
                children: [
                  const Icon(Icons.inventory_2, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    _filter == _PartsViewFilter.all ? 'No parts yet' : 'No parts in this filter',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _filter == _PartsViewFilter.all
                        ? 'Add parts as you dismantle. Use "Add common parts" to speed it up.'
                        : 'Clear filter to see everything again.',
                  ),
                ],
              ),
            )
          else ..._buildGroupedParts(shownParts, context),
            ],
          ),
          if (_selectMode)
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: SafeArea(
                child: Container(
                  color: const Color(0xFF1A1A1A),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => setState(() { _selectMode = false; _selectedPartIds.clear(); }),
                        child: const Text('Cancel'),
                      ),
                      const Spacer(),
                      Text('${_selectedPartIds.length} selected', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                      const Spacer(),
                      TextButton(
                        onPressed: _selectedPartIds.isEmpty ? null : _bulkMarkScrapped,
                        child: const Text('Scrap', style: TextStyle(color: Colors.orange)),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _selectedPartIds.isEmpty ? null : _bulkDelete,
                        style: FilledButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _selectedPartIds.isEmpty ? null : _bulkMarkSold,
                        style: FilledButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Mark Sold'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    ), // Scaffold
    ); // PopScope
  }
}

/// ----------------------------
/// Part Card
/// ----------------------------

// ═════════════════════════════════════════════════════════════════════════════
// PartListRow  (v1.2)
// 3-line compact row used in search results and drill-down screens.
// Shows: partName / stockId • partNumber / From: year • usage
// ═════════════════════════════════════════════════════════════════════════════
class PartListRow extends StatelessWidget {
  final Part part;
  final Vehicle? vehicle; // null = not found / legacy
  final VoidCallback onTap;

  const PartListRow({
    super.key,
    required this.part,
    required this.vehicle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final secondary = _partSecondaryLine(part);
    final source    = _partSourceLine(vehicle);
    final state     = part.state;
    final stateColor = state == PartState.sold
        ? Colors.green
        : state == PartState.scrapped
            ? Colors.grey
            : state == PartState.listed
                ? Colors.blue
                : Colors.white54;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Line 1: part name
                    Text(
                      part.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    // Line 2: stockId • partNumber
                    if (secondary.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        secondary,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Color(0xFFE8700A),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                    // Line 3: From: year • usage
                    const SizedBox(height: 3),
                    Text(
                      source,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: stateColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: stateColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      state.label,
                      style: TextStyle(
                        color: stateColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18, color: Colors.white24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PartDetailScreen  (v1.2)
// Full-screen read-only view of a part with stock ID + source vehicle info.
// ═════════════════════════════════════════════════════════════════════════════
class PartDetailScreen extends StatefulWidget {
  final Part part;
  final Vehicle? vehicle;
  /// Called after a successful edit so the caller can persist the change.
  /// Receives the updated [Part]. May be null (read-only contexts).
  final void Function(Part updated)? onPartEdited;

  const PartDetailScreen({
    super.key,
    required this.part,
    required this.vehicle,
    this.onPartEdited,
  });

  @override
  State<PartDetailScreen> createState() => _PartDetailScreenState();
}

class _PartDetailScreenState extends State<PartDetailScreen> {
  late Part _part;

  @override
  void initState() {
    super.initState();
    _part = widget.part;
  }

  Future<void> _edit() async {
    final updated = await showDialog<Part>(
      context: context,
      builder: (_) => EditPartDialog(part: _part),
    );
    if (updated == null) return;
    normalizePartStateFromListings(updated);
    setState(() => _part = updated);
    // Notify via callback (search flow) AND pop result (vehicle flow).
    widget.onPartEdited?.call(updated);
    // Pop with the updated part so any awaiting caller (e.g. VehicleDetailScreen)
    // can splice it back in without needing a callback.
    if (mounted) Navigator.of(context).pop(updated);
  }

  Future<void> _markSold() async {
    if (_part.state == PartState.sold || _part.state == PartState.scrapped) return;
    final ctrl = TextEditingController(
      text: _part.salePriceCents == null ? '' : (_part.salePriceCents! / 100).toStringAsFixed(2),
    );
    final cents = await showDialog<int?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as sold'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Sold price',
            hintText: 'e.g. 100.00',
            prefixText: '\$',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final c = parseMoneyToCents(ctrl.text) ?? 0;
              Navigator.pop(ctx, c);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (cents == null || !mounted) return;
    setState(() {
      _part.state = PartState.sold;
      _part.salePriceCents = cents;
      _part.dateSold ??= DateTime.now();
      for (final l in _part.listings) { l.isLive = false; }
    });
    widget.onPartEdited?.call(_part);
    if (mounted) Navigator.of(context).pop(_part);
  }

  @override
  Widget build(BuildContext context) {
    // Use live _part (may have been updated by _edit())
    final part = _part;
    final vehicle = widget.vehicle;
    final usageStr = (vehicle?.usageValue != null && vehicle!.usageValue! > 0)
        ? '${_formatUsage(vehicle.usageValue!)} ${vehicle.usageUnit}'
        : null;
    final colorStr = (vehicle?.color ?? '').trim().isEmpty ? null : vehicle!.color;

    final canMarkSold = part.state != PartState.sold && part.state != PartState.scrapped;

    return Scaffold(
      appBar: AppBar(
        title: Text(part.name),
        actions: [
          // Edit is always available — no null-gate.
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit part',
            onPressed: _edit,
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: canMarkSold
          ? FloatingActionButton.extended(
              heroTag: 'fab_mark_sold',
              onPressed: _markSold,
              backgroundColor: Colors.green,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Mark Sold'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(kPad),
        children: [
          // ── Part photos ─────────────────────────────────────────────────
          AppCard(
            child: PhotoStrip(
              ownerType: 'part',
              ownerId:   part.id,
              maxCount:  kMaxPartPhotos,
            ),
          ),
          const SizedBox(height: kPad),

          // ── Identification ──────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(title: 'Part identification'),

                // Stock ID — prominent
                if ((part.stockId ?? '').trim().isNotEmpty)
                  _DetailRow(
                    icon: Icons.qr_code_outlined,
                    label: 'Stock ID',
                    value: part.stockId!,
                    valueStyle: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE8700A),
                      letterSpacing: 1,
                    ),
                  ),

                _DetailRow(
                  icon: Icons.label_outline,
                  label: 'Part name',
                  value: part.name,
                ),

                if ((part.partNumber ?? '').trim().isNotEmpty)
                  _DetailRow(
                    icon: Icons.confirmation_number_outlined,
                    label: 'Part number',
                    value: part.partNumber!,
                    valueStyle: const TextStyle(fontFamily: 'monospace'),
                  ),

                if ((part.location ?? '').trim().isNotEmpty)
                  _DetailRow(
                    icon: Icons.place_outlined,
                    label: 'Location',
                    value: part.location!,
                  ),

                if (part.qty > 1)
                  _DetailRow(
                    icon: Icons.numbers,
                    label: 'Quantity',
                    value: part.qty.toString(),
                  ),

                if ((part.partCondition ?? '').trim().isNotEmpty)
                  _DetailRow(
                    icon: Icons.stars_outlined,
                    label: 'Condition',
                    value: part.partCondition!,
                  ),

                if (part.side != null)
                  _DetailRow(
                    icon: Icons.swap_horiz_outlined,
                    label: 'Side',
                    value: part.side!,
                  ),

                _DetailRow(
                  icon: Icons.info_outline,
                  label: 'Status',
                  value: part.state.label,
                ),
              ],
            ),
          ),

          const SizedBox(height: kPad),

          // ── Source vehicle ──────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(title: 'Source vehicle'),

                if (vehicle != null) ...[
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Year',
                    value: vehicle.year.toString(),
                  ),
                  if (vehicle.make.trim().isNotEmpty)
                    _DetailRow(
                      icon: Icons.directions_car_outlined,
                      label: 'Make',
                      value: vehicle.make,
                    ),
                  if (vehicle.model.trim().isNotEmpty)
                    _DetailRow(
                      icon: Icons.commute_outlined,
                      label: 'Model',
                      value: vehicle.model,
                    ),
                ] else
                  const _DetailRow(
                    icon: Icons.directions_car_outlined,
                    label: 'Vehicle',
                    value: '(vehicle missing)',
                  ),

                if (usageStr != null)
                  _DetailRow(
                    icon: Icons.speed_outlined,
                    label: 'KMs / Usage',
                    value: usageStr,
                  ),

                if (colorStr != null)
                  _DetailRow(
                    icon: Icons.palette_outlined,
                    label: 'Colour',
                    value: colorStr,
                  ),

                if (vehicle?.identifier != null && vehicle!.identifier!.isNotEmpty)
                  _DetailRow(
                    icon: Icons.badge_outlined,
                    label: 'Identifier',
                    value: vehicle.identifier!,
                  ),
              ],
            ),
          ),

          // ── Pricing ─────────────────────────────────────────────────────
          if (part.askingPriceCents != null || part.salePriceCents != null ||
              part.dateListed != null || part.dateSold != null) ...[
            const SizedBox(height: kPad),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(title: 'Pricing'),
                  if (part.askingPriceCents != null)
                    _DetailRow(
                      icon: Icons.sell_outlined,
                      label: 'Asking price',
                      value: formatMoneyFromCents(part.askingPriceCents!),
                    ),
                  if (part.salePriceCents != null)
                    _DetailRow(
                      icon: Icons.check_circle_outline,
                      label: 'Sale price',
                      value: formatMoneyFromCents(part.salePriceCents!),
                    ),
                  if (part.dateListed != null)
                    _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date listed',
                      value: formatDateShort(part.dateListed!),
                    ),
                  if (part.dateSold != null)
                    _DetailRow(
                      icon: Icons.event_available_outlined,
                      label: 'Date sold',
                      value: formatDateShort(part.dateSold!),
                    ),
                  if (part.daysToSell != null)
                    _DetailRow(
                      icon: Icons.timer_outlined,
                      label: 'Days to sell',
                      value: '${part.daysToSell} days',
                    ),
                ],
              ),
            ),
          ],

          // ── Notes ───────────────────────────────────────────────────────
          if ((part.notes ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: kPad),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(title: 'Notes'),
                  const SizedBox(height: 4),
                  Text(
                    part.notes!,
                    style: const TextStyle(color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),
          ],

          // ── Listings ─────────────────────────────────────────────────────
          if (part.listings.isNotEmpty) ...[
            const SizedBox(height: kPad),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(title: 'Listings (${part.liveLinksCount} live)'),
                  ...part.listings.map((l) => Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 9,
                              color: l.isLive ? Colors.green : Colors.white24,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                l.displayPlatformName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (l.url.trim().isNotEmpty) ...[
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: () => openUrlEasy(context, l.url),
                            child: Text(
                              l.url,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.blue.shade300,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.blue.shade300,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => copyToClipboard(context, l.url, message: 'Link copied'),
                                  icon: const Icon(Icons.copy, size: 14),
                                  label: const Text('Copy'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () => openUrlEasy(context, l.url),
                                  icon: const Icon(Icons.open_in_new, size: 14),
                                  label: const Text('Open'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: Colors.white38),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ??
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// _PartGroup — data class for grouped search results
// ═════════════════════════════════════════════════════════════════════════════
class _PartGroup {
  /// Canonical key: part number string, or empty string for "no part number".
  final String partNumber;
  final List<_PartHit> hits;

  _PartGroup({required this.partNumber, required this.hits});

  int get qty => hits.fold(0, (s, h) => s + h.part.qty);

  /// Consistent part name across all hits, or "Multiple" if mixed.
  String get commonName {
    if (hits.isEmpty) return '';
    final first = hits.first.part.name.trim();
    return hits.every((h) => h.part.name.trim().toLowerCase() == first.toLowerCase())
        ? first
        : 'Multiple';
  }

  /// Consistent side across all hits, or empty string if mixed/unset.
  String get commonSide {
    if (hits.isEmpty) return '';
    final first = hits.first.part.side ?? '';
    if (first.isEmpty) return '';
    return hits.every((h) => (h.part.side ?? '') == first) ? first : '';
  }

  int get maxScore => hits.fold(0, (s, h) => h.score > s ? h.score : s);
}

// ═════════════════════════════════════════════════════════════════════════════
// _SearchGroupDrillScreen  (v1.2)
// Lists individual _PartHits within one part-number group.
// Tapping opens PartDetailScreen.
// ═════════════════════════════════════════════════════════════════════════════
class _SearchGroupDrillScreen extends StatelessWidget {
  final _PartGroup group;
  final void Function(Part updated, Vehicle vehicle)? onPartEdited;

  const _SearchGroupDrillScreen({
    required this.group,
    this.onPartEdited,
  });

  @override
  Widget build(BuildContext context) {
    final label = group.partNumber.isEmpty
        ? 'No part number'
        : group.partNumber;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(
              '${group.hits.length} part${group.hits.length == 1 ? '' : 's'} • Qty ${group.qty}',
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(kPad),
        itemCount: group.hits.length,
        itemBuilder: (ctx, i) {
          final hit = group.hits[i];
          return PartListRow(
            part: hit.part,
            vehicle: hit.vehicle,
            onTap: () => Navigator.of(ctx).push(
              MaterialPageRoute(
                builder: (_) => PartDetailScreen(
                  part: hit.part,
                  vehicle: hit.vehicle,
                  onPartEdited: onPartEdited == null
                      ? null
                      : (updated) => onPartEdited!(updated, hit.vehicle),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PartCard extends StatelessWidget {
  final Part part;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMarkSold;
  final VoidCallback onMarkScrapped;
  final VoidCallback onMarkInStock;
  final VoidCallback onOpenLinks;
  final VoidCallback? onAddToCommonParts;
  final VoidCallback? onDuplicate;

  const PartCard({
    super.key,
    required this.part,
    required this.onEdit,
    required this.onDelete,
    required this.onMarkSold,
    required this.onMarkScrapped,
    required this.onMarkInStock,
    required this.onOpenLinks,
    this.onAddToCommonParts,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final days = part.daysInStock();
    final state = part.state;
    final isSold     = state == PartState.sold;
    final isScrapped = state == PartState.scrapped;
    final isListed   = part.hasLiveListings;

    // ── State badge ──────────────────────────────────────────────────────────
    final (badgeLabel, badgeColor, badgeFilled) = isScrapped
        ? ('SCRAPPED', Colors.red,                   true)
        : isSold
            ? ('Sold',    Colors.green,              false)
            : isListed
                ? ('Listed',  Colors.green,          false)
                : ('In Stock', Colors.white38,       false);


    // ── Left bar colour ───────────────────────────────────────────────────────
    final barColor = isScrapped
        ? Colors.grey
        : isSold
            ? const Color(0xFF2E7D32)
            : isListed
                ? Colors.green
                : const Color(0xFFE8700A);

    // ── Stat line: stock ID · age · price ────────────────────────────────────
    final statParts = <String>[];
    if ((part.stockId ?? '').trim().isNotEmpty) {
      statParts.add(part.stockId!);
    }
    statParts.add('${days}d');
    if (part.qty > 1) {
      statParts.add('Qty ${part.qty}');
    }
    if (isSold && part.salePriceCents != null) {
      statParts.add(formatMoneyFromCents(part.salePriceCents!));
    } else if (!isScrapped && part.askingPriceCents != null) {
      statParts.add(formatMoneyFromCents(part.askingPriceCents!));
    }
    if (part.side != null) statParts.add(part.side!);
    final statLine = statParts.join('  ·  ');

    return Opacity(
      opacity: isScrapped ? 0.6 : 1.0,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF252525), Color(0xFF1A1A1A)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Left colour bar ────────────────────────────────────────────
              Container(
                width: 4,
                height: 66,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                  color: barColor,
                ),
              ),
              const SizedBox(width: 14),
              // ── Name + stat line ───────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(
                          part.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 3),
                    Text(
                      statLine,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // ── State badge ────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeFilled ? badgeColor : badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: badgeFilled ? null : Border.all(color: badgeColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    color: badgeFilled ? Colors.white : badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: badgeFilled ? 0.5 : 0,
                  ),
                ),
              ),
              // ── 3-dot menu ─────────────────────────────────────────────────
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit')      onEdit();
                  if (v == 'duplicate' && onDuplicate != null) onDuplicate!();
                  if (v == 'delete')    onDelete();
                  if (v == 'sold')      onMarkSold();
                  if (v == 'scrap')     onMarkScrapped();
                  if (v == 'instock')   onMarkInStock();
                  if (v == 'links')     onOpenLinks();
                  if (v == 'common' && onAddToCommonParts != null) onAddToCommonParts!();
                },
                padding: EdgeInsets.zero,
                iconSize: 20,
                icon: Icon(Icons.more_vert, color: Colors.white.withValues(alpha: 0.3), size: 20),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  )),
                  if (onDuplicate != null)
                    const PopupMenuItem(value: 'duplicate', child: ListTile(
                      leading: Icon(Icons.copy_outlined),
                      title: Text('Duplicate'),
                      contentPadding: EdgeInsets.zero,
                    )),
                  if (isSold || isScrapped)
                    const PopupMenuItem(value: 'instock', child: ListTile(
                      leading: Icon(Icons.undo),
                      title: Text('Back to stock'),
                      contentPadding: EdgeInsets.zero,
                    ))
                  else ...[
                    const PopupMenuItem(value: 'sold', child: ListTile(
                      leading: Icon(Icons.check_circle_outline),
                      title: Text('Mark sold'),
                      contentPadding: EdgeInsets.zero,
                    )),
                    const PopupMenuItem(value: 'scrap', child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Scrap'),
                      contentPadding: EdgeInsets.zero,
                    )),
                  ],
                  if (part.totalLinksCount > 0)
                    PopupMenuItem(value: 'links', child: ListTile(
                      leading: const Icon(Icons.open_in_new),
                      title: Text('Open links (${part.totalLinksCount})'),
                      contentPadding: EdgeInsets.zero,
                    )),
                  if (onAddToCommonParts != null)
                    const PopupMenuItem(value: 'common', child: ListTile(
                      leading: Icon(Icons.star_border_outlined),
                      title: Text('Add to Common Parts'),
                      contentPadding: EdgeInsets.zero,
                    )),
                  const PopupMenuDivider(),
                  const PopupMenuItem(value: 'delete', child: ListTile(
                    leading: Icon(Icons.delete_forever, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ----------------------------
/// Add Part Screen (full screen)
/// ----------------------------
class AddPartScreen extends StatefulWidget {
  /// Pass all current vehicles so we can generate a collision-free stock ID.
  final List<Vehicle> allVehicles;
  final Vehicle vehicle;

  const AddPartScreen({super.key, required this.allVehicles, required this.vehicle});

  @override
  State<AddPartScreen> createState() => _AddPartScreenState();
}

class _AddPartScreenState extends State<AddPartScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _askCtrl = TextEditingController();
  final _pnCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _notesCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _conditionCtrl = TextEditingController();
  final _saleCtrl = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _pnFocusNode = FocusNode();
  bool _showLink = false;
  String? _category;
  String? _suggestedCategory;
  String? _side;
  List<String> _categories = List.from(kPartCategories);

  DateTime? _dateListed;
  DateTime? _dateSold;

  // Vehicle snapshot fields (prefilled from widget.vehicle)
  String? _vMake;
  String? _vModel;
  int? _vYear;
  String? _vTrim;
  String? _vEngine;
  String? _vTransmission;
  String? _vDrivetrain;
  int? _vUsageValue;
  String? _vUsageUnit;

  /// Generated once on initState, shown read-only to the user.
  late final String _stockId;

  /// Part ID generated upfront so photos can be attached before save.
  late final String _partId;

  /// True once the part is saved — used to clean up photos on cancel.
  bool _saved = false;

  /// Recent unique part names for quick-tap shortcuts.
  List<String> _recentPartNames = [];

  /// Price hint from history — shown as helper text, not hard-filled.
  String? _priceHint;

  @override
  void initState() {
    super.initState();
    _partId = newId();
    _stockId = generateUniqueStockId(widget.allVehicles);
    PartCategoryStorage.load().then((cats) {
      if (mounted) setState(() => _categories = cats);
    }).catchError((Object e) { if (kDebugMode) debugPrint('PartCategoryStorage.load failed: $e'); });
    _nameFocusNode.addListener(_onNameFocusChanged);
    _pnFocusNode.addListener(_onPnFocusChanged);

    // Build recent part names list — unique names sorted by most recently added.
    final seen = <String>{};
    final recent = <String>[];
    final allParts = widget.allVehicles
        .expand((v) => v.parts)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    for (final p in allParts) {
      final name = p.name.trim();
      if (name.isNotEmpty && seen.add(name.toLowerCase())) {
        recent.add(name);
        if (recent.length >= 6) break;
      }
    }
    _recentPartNames = recent;
    final v = widget.vehicle;
    _vMake = v.make.isEmpty ? null : v.make;
    _vModel = v.model.isEmpty ? null : v.model;
    _vYear = v.year;
    _vTrim = v.trim;
    _vEngine = v.engine;
    _vTransmission = v.transmission;
    _vDrivetrain = v.drivetrain;
    _vUsageValue = v.usageValue;
    _vUsageUnit = v.usageUnit.isEmpty ? null : v.usageUnit;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locCtrl.dispose();
    _askCtrl.dispose();
    _pnCtrl.dispose();
    _qtyCtrl.dispose();
    _notesCtrl.dispose();
    _linkCtrl.dispose();
    _conditionCtrl.dispose();
    _saleCtrl.dispose();
    _nameFocusNode.dispose();
    _pnFocusNode.dispose();
    // If user cancelled without saving, clean up any photos they took
    if (!_saved) {
      PhotoStorage.deleteAllForOwner('part', _partId).catchError((Object e) {
        if (kDebugMode) debugPrint('AddPartScreen: photo cleanup failed: $e');
      });
    }
    super.dispose();
  }

  // ── Autofill from previous entries ────────────────────────────────
  Part? _findBestMatchingPart(String name) {
    if (name.trim().isEmpty) return null;
    final lower = name.trim().toLowerCase();
    Part? best;
    for (final v in widget.allVehicles) {
      for (final p in v.parts) {
        if (p.name.toLowerCase() == lower) {
          if (best == null || p.createdAt.isAfter(best.createdAt)) best = p;
        }
      }
    }
    return best;
  }

  /// Detects Left/Right/Pair from keywords in the part name.
  String? _detectSideFromName(String name) {
    final lower = name.toLowerCase();
    final leftKw  = ['left', ' lh', 'lh ', 'driver side', 'drivers side'];
    final rightKw = ['right', ' rh', 'rh ', 'passenger side'];
    final pairKw  = ['pair', 'set of 2', 'both sides'];
    if (pairKw.any((k) => lower.contains(k)))  return 'Pair';
    if (leftKw.any((k) => lower.contains(k)))  return 'Left';
    if (rightKw.any((k) => lower.contains(k))) return 'Right';
    return null;
  }

  void _onNameFocusChanged() {
    if (_nameFocusNode.hasFocus) return;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    // Auto-suggest side from name keywords if not already set.
    if (_side == null) {
      final detectedSide = _detectSideFromName(name);
      if (detectedSide != null) setState(() => _side = detectedSide);
    }

    final match = _findBestMatchingPart(name);

    bool filled = false;
    String? suggestion;

    if (match != null) {
      // History match — prefill empty fields silently
      setState(() {
        if (_category == null && match.category != null) {
          _category = match.category;
          filled = true;
        }
        if (_conditionCtrl.text.isEmpty && match.partCondition != null) {
          _conditionCtrl.text = match.partCondition!;
          filled = true;
        }
        if (_pnCtrl.text.isEmpty && match.partNumber != null) {
          _pnCtrl.text = match.partNumber!;
          filled = true;
        }
        // Show suggestion from history if category wasn't already set
        if (match.category != null) suggestion = match.category;
        _suggestedCategory = suggestion;
      });
      if (filled && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prefilled from a previous entry'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // No history — check predefined map
      final lower = name.toLowerCase();
      for (final entry in kPartCategorySuggestions.entries) {
        if (lower.contains(entry.key)) {
          suggestion = entry.value;
          break;
        }
      }
      setState(() => _suggestedCategory = suggestion);
    }
  }

  /// When part number loses focus, look up the most recent part with that number
  /// and prefill all empty fields from it.
  void _onPnFocusChanged() {
    if (_pnFocusNode.hasFocus) return;
    final pn = _pnCtrl.text.trim();
    if (pn.isEmpty) return;

    final normalizedPn = normalizePartNumber(pn);
    Part? best;
    for (final v in widget.allVehicles) {
      for (final p in v.parts) {
        if (p.partNumber == null) continue;
        if (normalizePartNumber(p.partNumber!) == normalizedPn) {
          if (best == null || p.createdAt.isAfter(best.createdAt)) best = p;
        }
      }
    }
    if (best == null) return;
    final b = best; // non-nullable local for use inside setState closure

    bool filled = false;
    setState(() {
      if (_nameCtrl.text.isEmpty) {
        _nameCtrl.text = b.name;
        filled = true;
      }
      if (_category == null && b.category != null) {
        _category = b.category;
        filled = true;
      }
      if (_conditionCtrl.text.isEmpty && b.partCondition != null) {
        _conditionCtrl.text = b.partCondition!;
        filled = true;
      }
      if (_side == null && b.side != null) {
        _side = b.side;
        filled = true;
      }
      if (_locCtrl.text.isEmpty && (b.location ?? '').isNotEmpty) {
        _locCtrl.text = b.location!;
        filled = true;
      }
      if (b.askingPriceCents != null) {
        _priceHint = 'Last used: ${formatMoneyFromCents(b.askingPriceCents!)}';
      }
      if (_notesCtrl.text.isEmpty && (b.notes ?? '').isNotEmpty) {
        _notesCtrl.text = b.notes!;
        filled = true;
      }
      if (b.category != null) _suggestedCategory = b.category;
    });

    if (filled && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prefilled from a previous entry — change anything you need'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// Returns the most recently sold price (formatted) for parts with the same name.
  String? _lastSoldHint() {
    final name = _nameCtrl.text.trim().toLowerCase();
    if (name.isEmpty) return null;
    Part? best;
    for (final v in widget.allVehicles) {
      for (final p in v.parts) {
        if (p.name.toLowerCase() == name &&
            p.state == PartState.sold &&
            p.salePriceCents != null) {
          if (best == null || p.createdAt.isAfter(best.createdAt)) best = p;
        }
      }
    }
    if (best == null) return null;
    return 'Last sold: ${formatMoneyFromCents(best.salePriceCents!)}';
  }

  Future<void> _pickDateListed() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
      initialDate: _dateListed ?? now,
    );
    if (picked == null) return;
    setState(() => _dateListed = picked);
  }

  Future<void> _pickDateSold() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
      initialDate: _dateSold ?? now,
    );
    if (picked == null) return;
    setState(() => _dateSold = picked);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // ── Duplicate part number check ───────────────────────────────────────
    final pnRaw = _pnCtrl.text.trim();
    if (pnRaw.isNotEmpty) {
      final normalizedNew = normalizePartNumber(pnRaw);
      final duplicate = widget.vehicle.parts.where((p) =>
        p.partNumber != null &&
        normalizePartNumber(p.partNumber!) == normalizedNew &&
        p.state != PartState.sold &&
        p.state != PartState.scrapped,
      ).firstOrNull;
      if (duplicate != null && mounted) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Duplicate part number'),
            content: Text(
              '"${duplicate.name}" already has part number $pnRaw and is in stock. '
              'Are you sure you want to add another?',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add anyway')),
            ],
          ),
        );
        if (!(proceed ?? false)) return;
      }
    }

    final askCents = parseMoneyToCents(_askCtrl.text);
    final saleCents = parseMoneyToCents(_saleCtrl.text);
    final pn = _pnCtrl.text.trim();
    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 1;
    final notes = _notesCtrl.text.trim();
    final loc = _locCtrl.text.trim();
    final condition = _conditionCtrl.text.trim();

    // Optional link — saved as a Listing record but NOT marked live.
    // User can mark it live via the part's links screen when ready.
    final url = _linkCtrl.text.trim();
    final listings = <Listing>[];
    DateTime? dateListed = _dateListed;
    if (url.isNotEmpty) {
      final detected = detectPlatformFromUrl(url);
      listings.add(Listing(
        id: newId(),
        platform: detected.isNotEmpty ? detected : 'Other',
        url: url,
        isLive: true,
        createdAt: DateTime.now(),
      ));
      dateListed ??= DateTime.now();
    }

    _saved = true;
    final p = Part(
      id: _partId,
      name: _nameCtrl.text.trim(),
      state: PartState.removed, // status unchanged — user decides when to list
      createdAt: DateTime.now(),
      location: loc.isEmpty ? null : loc,
      notes: notes.isEmpty ? null : notes,
      askingPriceCents: askCents,
      salePriceCents: saleCents,
      partNumber: pn.isEmpty ? null : pn,
      qty: qty < 1 ? 1 : qty,
      listings: listings,
      stockId: _stockId,
      category: _category,
      vehicleMake: _vMake,
      vehicleModel: _vModel,
      vehicleYear: _vYear,
      vehicleTrim: _vTrim,
      vehicleEngine: _vEngine,
      vehicleTransmission: _vTransmission,
      vehicleDrivetrain: _vDrivetrain,
      vehicleUsageValue: _vUsageValue,
      vehicleUsageUnit: _vUsageUnit,
      partCondition: condition.isEmpty ? null : condition,
      side: _side,
      dateListed: dateListed,
      dateSold: _dateSold,
    );

    if (!mounted) return;
    Navigator.of(context).pop(p);
  }

  @override
  Widget build(BuildContext context) {
    const divider = Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Divider(color: Colors.white12, height: 1),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        // If name is empty, allow exit without confirmation
        if (_nameCtrl.text.trim().isEmpty) {
          nav.pop();
          return;
        }
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Discard part?'),
            content: const Text('You have unsaved changes. Discard them?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep editing')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Discard'),
              ),
            ],
          ),
        );
        if ((ok ?? false) && mounted) nav.pop();
      },
      child: Scaffold(
      appBar: AppBar(title: const Text('Add Part')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(kPad, kPad, kPad, 32),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Part number + Qty ─────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _pnCtrl,
                          focusNode: _pnFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'Part number',
                            hintText: 'Optional — autofills from history',
                            prefixIcon: Icon(Icons.confirmation_number_outlined),
                          ),
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [LengthLimitingTextInputFormatter(100)],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 90,
                        child: TextFormField(
                          controller: _qtyCtrl,
                          decoration: const InputDecoration(labelText: 'Qty'),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final n = int.tryParse((v ?? '').trim());
                            if (n == null || n < 1) return 'Min 1';
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  // ── Recent part shortcuts ─────────────────────────────
                  if (_recentPartNames.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Text('Recent:', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.35))),
                        ..._recentPartNames.map((n) => GestureDetector(
                          onTap: () {
                            setState(() => _nameCtrl.text = n);
                            // Trigger autofill as if name focus changed
                            _onNameFocusChanged();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                            ),
                            child: Text(n, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                          ),
                        )),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  // ── Part name ─────────────────────────────────────────
                  TextFormField(
                    controller: _nameCtrl,
                    focusNode: _nameFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Part name *',
                      hintText: 'Tailgate / Headlight / ECU',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [LengthLimitingTextInputFormatter(150)],
                  ),
                  const SizedBox(height: 12),
                  // ── Condition (buffer — gives category suggestion time to appear) ──
                  TextFormField(
                    controller: _conditionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Condition (optional)',
                      hintText: 'Good / Used / Damaged',
                      prefixIcon: Icon(Icons.stars_outlined),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  // ── Category ──────────────────────────────────────────
                  DropdownButtonFormField<String>(
                    initialValue: _categories.contains(_category) ? _category : null,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    hint: const Text('Uncategorised'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Uncategorised')),
                      ..._categories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                    ],
                    onChanged: (v) => setState(() => _category = v),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Manage categories in Settings → Part Categories',
                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  if (_suggestedCategory != null && _category != _suggestedCategory) ...[
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => setState(() => _category = _suggestedCategory),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, size: 13, color: Color(0xFFE8700A)),
                          const SizedBox(width: 4),
                          Text(
                            'Suggested: $_suggestedCategory — tap to apply',
                            style: const TextStyle(fontSize: 12, color: Color(0xFFE8700A)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  divider,

                  // ── Location & Pricing ────────────────────────────────
                  TextFormField(
                    controller: _locCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      hintText: 'Shelf A3 / Bay 2 / Tote 7',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    inputFormatters: [LengthLimitingTextInputFormatter(150)],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _askCtrl,
                    decoration: InputDecoration(
                      labelText: 'Asking price',
                      hintText: 'Optional',
                      prefixText: '\$',
                      prefixIcon: const Icon(Icons.sell_outlined),
                      helperText: _priceHint ?? _lastSoldHint(),
                      helperStyle: const TextStyle(color: Color(0xFFE8700A), fontSize: 12),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _saleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Sold price',
                      hintText: 'Optional',
                      prefixText: '\$',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  // ── Side ──────────────────────────────────────────────
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.swap_horiz_outlined, size: 16, color: Colors.white38),
                        SizedBox(width: 6),
                        Text('Side:', style: TextStyle(fontSize: 13, color: Colors.white54)),
                      ]),
                      ...['Left', 'Right', 'Pair'].map((s) => ChoiceChip(
                        label: Text(s, style: const TextStyle(fontSize: 12)),
                        selected: _side == s,
                        onSelected: (v) => setState(() => _side = v ? s : null),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickDateListed,
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            _dateListed != null ? 'Listed: ${formatDateShort(_dateListed!)}' : 'Date Listed: Not set',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickDateSold,
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            _dateSold != null ? 'Sold: ${formatDateShort(_dateSold!)}' : 'Date Sold: Not set',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_dateListed != null && _dateSold != null) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.timer_outlined, size: 14, color: Colors.white38),
                      const SizedBox(width: 6),
                      Text('Days to sell: ${_dateSold!.difference(_dateListed!).inDays >= 0 ? _dateSold!.difference(_dateListed!).inDays : "—"}',
                        style: const TextStyle(fontSize: 13, color: Colors.white54)),
                    ]),
                  ],

                  divider,

                  // ── Notes ─────────────────────────────────────────────
                  TextFormField(
                    controller: _notesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Condition, colour, fitment, anything useful…',
                      prefixIcon: Icon(Icons.notes_outlined),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    maxLength: 2000,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.newline,
                  ),

                  divider,

                  // ── Photos ────────────────────────────────────────────
                  const Text(
                    'Photos',
                    style: TextStyle(fontSize: 13, color: Colors.white54, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  PhotoStrip(
                    ownerType: 'part',
                    ownerId: _partId,
                    maxCount: kMaxPartPhotos,
                  ),

                  divider,

                  // ── Listing link ──────────────────────────────────────
                  InkWell(
                    onTap: () => setState(() => _showLink = !_showLink),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            _showLink ? Icons.link_off : Icons.link,
                            size: 18,
                            color: Colors.white38,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Listing link',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _showLink ? 'Remove' : 'Add',
                            style: const TextStyle(
                              color: Color(0xFFE8700A),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showLink) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _linkCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Listing URL',
                        hintText: 'https://www.ebay.com.au/itm/...',
                        prefixIcon: Icon(Icons.open_in_new_outlined),
                      ),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      autocorrect: false,
                    ),
                  ],

                  divider,

                  // ── Stock ID (collapsed by default) ───────────────────
                  Row(
                    children: [
                      const Icon(Icons.qr_code_outlined, size: 16, color: Colors.white24),
                      const SizedBox(width: 8),
                      Text(
                        'Stock ID: ',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      Text(
                        _stockId,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          letterSpacing: 1.2,
                          color: Color(0xFFE8700A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.copy_outlined, size: 16),
                        color: Colors.white24,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Copy stock ID',
                        onPressed: () => copyToClipboard(context, _stockId, message: 'Stock ID copied'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Save button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE8700A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Save Part'),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    )); // PopScope + Scaffold
  }
}

/// ----------------------------
/// Edit Part Dialog (includes listings)
/// ----------------------------
class EditPartDialog extends StatefulWidget {
  final Part part;
  const EditPartDialog({super.key, required this.part});

  @override
  State<EditPartDialog> createState() => _EditPartDialogState();
}

class _EditPartDialogState extends State<EditPartDialog> {
  final _formKey = GlobalKey<FormState>();

  late Part _p;
  List<String> _categories = List.from(kPartCategories);
  String? _side;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _locCtrl;
  late final TextEditingController _askCtrl;
  late final TextEditingController _pnCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _conditionCtrl;
  late final TextEditingController _saleCtrl;

  DateTime? _dateListed;
  DateTime? _dateSold;

  @override
  void initState() {
    super.initState();
    _p = Part.fromJson(widget.part.toJson());
    PartCategoryStorage.load().then((cats) {
      if (mounted) setState(() => _categories = cats);
    }).catchError((Object e) { if (kDebugMode) debugPrint('PartCategoryStorage.load failed: $e'); });
    _nameCtrl = TextEditingController(text: _p.name);
    _locCtrl = TextEditingController(text: _p.location ?? '');
    _askCtrl = TextEditingController(
      text: _p.askingPriceCents == null ? '' : (_p.askingPriceCents! / 100).toStringAsFixed(2),
    );
    _pnCtrl = TextEditingController(text: _p.partNumber ?? '');
    _qtyCtrl = TextEditingController(text: _p.qty.toString());
    _notesCtrl = TextEditingController(text: _p.notes ?? '');
    _conditionCtrl = TextEditingController(text: _p.partCondition ?? '');
    _saleCtrl = TextEditingController(
      text: _p.salePriceCents == null ? '' : (_p.salePriceCents! / 100).toStringAsFixed(2),
    );
    _dateListed = _p.dateListed;
    _dateSold = _p.dateSold;
    _side = _p.side;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locCtrl.dispose();
    _askCtrl.dispose();
    _pnCtrl.dispose();
    _qtyCtrl.dispose();
    _notesCtrl.dispose();
    _conditionCtrl.dispose();
    _saleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateListed() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
      initialDate: _dateListed ?? now,
    );
    if (picked == null) return;
    setState(() => _dateListed = picked);
  }

  Future<void> _pickDateSold() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
      initialDate: _dateSold ?? now,
    );
    if (picked == null) return;
    setState(() => _dateSold = picked);
  }

  Future<void> _addListing() async {
    final created = await showDialog<Listing>(
      context: context,
      builder: (_) => const AddListingDialog(),
    );
    if (created == null) return;

    setState(() {
      _p.listings.insert(0, created);
      normalizePartStateFromListings(_p);
      _dateListed ??= DateTime.now();
    });
  }

  Future<void> _editListing(Listing l) async {
    final updated = await showDialog<Listing>(
      context: context,
      builder: (_) => EditListingDialog(listing: l),
    );
    if (updated == null) return;

    setState(() {
      final idx = _p.listings.indexWhere((x) => x.id == l.id);
      if (idx >= 0) _p.listings[idx] = updated;
      normalizePartStateFromListings(_p);
    });
  }

  Future<void> _deleteListing(Listing l) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete listing?'),
            content: Text('Remove listing for ${l.displayPlatformName}?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
            ],
          ),
        ) ??
        false;

    if (!ok) return;

    setState(() {
      _p.listings.removeWhere((x) => x.id == l.id);
      normalizePartStateFromListings(_p);
    });
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    _p.name = _nameCtrl.text.trim();
    final loc = _locCtrl.text.trim();
    _p.location = loc.isEmpty ? null : loc;

    _p.askingPriceCents = parseMoneyToCents(_askCtrl.text);
    _p.salePriceCents = parseMoneyToCents(_saleCtrl.text);

    final pn = _pnCtrl.text.trim();
    _p.partNumber = pn.isEmpty ? null : pn;

    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 1;
    _p.qty = qty < 1 ? 1 : qty;

    final notes = _notesCtrl.text.trim();
    _p.notes = notes.isEmpty ? null : notes;

    final condition = _conditionCtrl.text.trim();
    _p.partCondition = condition.isEmpty ? null : condition;

    _p.dateListed = _dateListed;
    _p.dateSold = _dateSold;
    _p.side = _side;
    _p.updatedAt = DateTime.now();

    normalizePartStateFromListings(_p);

    Navigator.of(context).pop(_p);
  }

  @override
  Widget build(BuildContext context) {
    final liveCount = _p.listings.where((l) => l.isLive && l.url.trim().isNotEmpty).length;

    return AlertDialog(
      title: const Text('Edit Part'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 560,
          child: ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Part name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                inputFormatters: [LengthLimitingTextInputFormatter(150)],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _categories.contains(_p.category) ? _p.category : null,
                decoration: const InputDecoration(labelText: 'Category'),
                hint: const Text('Uncategorised'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Uncategorised')),
                  ..._categories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                ],
                onChanged: (v) => setState(() => _p.category = v),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _pnCtrl,
                decoration: const InputDecoration(labelText: 'Part number (optional)'),
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _qtyCtrl,
                decoration: const InputDecoration(labelText: 'Qty'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null || n < 1) return 'Qty must be 1+';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locCtrl,
                decoration: const InputDecoration(labelText: 'Location (optional)'),
                inputFormatters: [LengthLimitingTextInputFormatter(150)],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _askCtrl,
                decoration: const InputDecoration(
                  labelText: 'Asking price (optional)',
                  prefixText: '\$',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _saleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Sold price (optional)',
                  prefixText: '\$',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _conditionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Condition (optional)',
                  hintText: 'Good / Used / Damaged',
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 10),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  const Text('Side:', style: TextStyle(fontSize: 13, color: Colors.white54)),
                  ...['Left', 'Right', 'Pair'].map((s) => ChoiceChip(
                    label: Text(s, style: const TextStyle(fontSize: 12)),
                    selected: _side == s,
                    onSelected: (v) => setState(() => _side = v ? s : null),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  )),
                ],
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _pickDateListed,
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(
                  _dateListed != null ? 'Listed: ${formatDateShort(_dateListed!)}' : 'Date Listed: Not set',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickDateSold,
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(
                  _dateSold != null ? 'Sold: ${formatDateShort(_dateSold!)}' : 'Date Sold: Not set',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              if (_dateListed != null && _dateSold != null) ...[
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.timer_outlined, size: 14, color: Colors.white38),
                  const SizedBox(width: 6),
                  Text('Days to sell: ${_dateSold!.difference(_dateListed!).inDays >= 0 ? _dateSold!.difference(_dateListed!).inDays : "—"}',
                    style: const TextStyle(fontSize: 13, color: Colors.white54)),
                ]),
              ],
              const SizedBox(height: 10),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Condition, colour, fitment, anything useful',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                maxLength: 2000,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Listings ($liveCount live)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _addListing,
                    icon: const Icon(Icons.add_link),
                    label: const Text('Add link'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_p.listings.isEmpty)
                const Text('No listing links yet. Add links to track where this part is listed.')
              else
                ..._p.listings.map(
                  (l) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l.displayPlatformName,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (v) {
                                    if (v == 'edit') _editListing(l);
                                    if (v == 'copy') copyToClipboard(context, l.url, message: 'Link copied');
                                    if (v == 'open') openUrlEasy(context, l.url);
                                    if (v == 'delete') _deleteListing(l);
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                                    PopupMenuItem(value: 'open', child: Text('Open')),
                                    PopupMenuItem(value: 'copy', child: Text('Copy link')),
                                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: l.url.trim().isEmpty ? null : () => openUrlEasy(context, l.url),
                              child: Text(
                                l.url,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: l.url.trim().isEmpty ? null : () => copyToClipboard(context, l.url, message: 'Link copied'),
                                    icon: const Icon(Icons.copy),
                                    label: const Text('Copy'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: l.url.trim().isEmpty ? null : () => openUrlEasy(context, l.url),
                                    icon: const Icon(Icons.open_in_new),
                                    label: const Text('Open'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

/// ----------------------------
/// Listing Dialogs
/// ----------------------------
class AddListingDialog extends StatefulWidget {
  const AddListingDialog({super.key});

  @override
  State<AddListingDialog> createState() => _AddListingDialogState();
}

class _AddListingDialogState extends State<AddListingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _urlCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  List<String> _platforms = List.from(kDefaultPlatforms);
  String? _platform;

  @override
  void initState() {
    super.initState();
    PlatformStorage.load().then((p) {
      if (mounted) {
        setState(() {
          _platforms = p;
          _platform ??= p.isNotEmpty ? p.first : null;
        });
      }
    }).catchError((Object e) { if (kDebugMode) debugPrint('PlatformStorage.load failed: $e'); });
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _applyDetection() {
    final detected = detectPlatformFromUrl(_urlCtrl.text);
    if (detected.isNotEmpty && _platforms.contains(detected)) {
      setState(() => _platform = detected);
    }
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l = Listing(
      id: newId(),
      platform: _platform ?? (_platforms.isNotEmpty ? _platforms.first : 'Other'),
      url: _urlCtrl.text.trim(),
      isLive: true,
      listedPriceCents: parseMoneyToCents(_priceCtrl.text),
      createdAt: DateTime.now(),
    );
    Navigator.of(context).pop(l);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add listing link'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _urlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Listing URL',
                  hintText: 'Paste your listing link here',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                onChanged: (_) => _applyDetection(),
                keyboardType: TextInputType.url,
                autocorrect: false,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _platforms.contains(_platform) ? _platform : null,
                decoration: const InputDecoration(labelText: 'Platform'),
                hint: const Text('Select platform'),
                items: _platforms.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setState(() => _platform = v),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Manage platforms in Settings → Listing Platforms',
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.3)),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: 'Listed price (optional)', prefixText: '\$'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Add')),
      ],
    );
  }
}

class EditListingDialog extends StatefulWidget {
  final Listing listing;
  const EditListingDialog({super.key, required this.listing});

  @override
  State<EditListingDialog> createState() => _EditListingDialogState();
}

class _EditListingDialogState extends State<EditListingDialog> {
  final _formKey = GlobalKey<FormState>();
  late Listing _l;
  List<String> _platforms = List.from(kDefaultPlatforms);

  late final TextEditingController _urlCtrl;
  late final TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _l = Listing.fromJson(widget.listing.toJson());
    _urlCtrl = TextEditingController(text: _l.url);
    _priceCtrl = TextEditingController(
      text: _l.listedPriceCents == null ? '' : (_l.listedPriceCents! / 100).toStringAsFixed(2),
    );
    PlatformStorage.load().then((p) {
      if (mounted) setState(() => _platforms = p);
    }).catchError((Object e) { if (kDebugMode) debugPrint('PlatformStorage.load failed: $e'); });
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _l.url = _urlCtrl.text.trim();
    _l.listedPriceCents = parseMoneyToCents(_priceCtrl.text);
    Navigator.of(context).pop(_l);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit listing'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _urlCtrl,
                decoration: const InputDecoration(labelText: 'Listing URL'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                keyboardType: TextInputType.url,
                autocorrect: false,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _platforms.contains(_l.platform) ? _l.platform : null,
                decoration: const InputDecoration(labelText: 'Platform'),
                hint: const Text('Select platform'),
                items: _platforms.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setState(() => _l.platform = v ?? _l.platform),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Manage platforms in Settings → Listing Platforms',
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.3)),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: 'Listed price (optional)', prefixText: '\$'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

/// ----------------------------
/// Quick Add Presets Dialog
/// ----------------------------

// ═════════════════════════════════════════════════════════════════════════════
// GroupedPresetsPickerScreen  (v1.2)
// Full-screen grouped preset picker with collapsible sections + Edit button
// ═════════════════════════════════════════════════════════════════════════════
class GroupedPresetsPickerScreen extends StatefulWidget {
  final ItemType itemType;
  final Map<String, List<String>> groups;
  final List<Vehicle> allVehicles;
  /// Parts already on this vehicle — used to show ×N count badges on chips.
  final List<Part> existingParts;

  const GroupedPresetsPickerScreen({
    super.key,
    required this.itemType,
    required this.groups,
    required this.allVehicles,
    this.existingParts = const [],
  });

  @override
  State<GroupedPresetsPickerScreen> createState() => _GroupedPresetsPickerScreenState();
}

class _GroupedPresetsPickerScreenState extends State<GroupedPresetsPickerScreen> {
  final Set<String> _selected = {};
  late Map<String, List<String>> _groups;
  // Track which groups are expanded (default: all expanded)
  late Map<String, bool> _expanded;
  // How many times each part name already exists on this vehicle (case-insensitive)
  late Map<String, int> _existingCounts;

  @override
  void initState() {
    super.initState();
    _groups = Map.from(widget.groups.map((k, v) => MapEntry(k, List<String>.from(v))));
    _expanded = {for (final k in _groups.keys) k: true};
    // Build count map once — normalised lowercase key → count
    _existingCounts = {};
    for (final p in widget.existingParts) {
      final key = p.name.trim().toLowerCase();
      _existingCounts[key] = (_existingCounts[key] ?? 0) + 1;
    }
  }

  Future<void> _openEditor() async {
    final updated = await Navigator.of(context).push<Map<String, List<String>>>(
      MaterialPageRoute(
        builder: (_) => PresetEditorScreen(
          itemType: widget.itemType,
          groups: _groups,
        ),
      ),
    );
    if (updated != null) {
      setState(() {
        _groups = updated;
        // Re-expand new groups, keep existing expansion state
        for (final k in _groups.keys) {
          _expanded.putIfAbsent(k, () => true);
        }
        // Remove selected items that no longer exist
        final allParts = {
          for (final parts in _groups.values) ...parts,
        };
        _selected.removeWhere((s) => !allParts.contains(s));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _groups.values.fold<int>(0, (sum, parts) => sum + parts.length);

    return Scaffold(
      appBar: AppBar(
        title: Text('Common parts — ${widget.itemType.label}'),
        actions: [
          TextButton.icon(
            onPressed: _openEditor,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit list'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Hint row
          Padding(
            padding: const EdgeInsets.fromLTRB(kPad, kPad, kPad, 0),
            child: Row(
              children: [
                const Icon(Icons.touch_app_outlined, size: 16, color: Colors.white38),
                const SizedBox(width: 6),
                Text(
                  'Tap parts to select • ${_selected.length}/$totalCount selected',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const Spacer(),
                if (_selected.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() => _selected.clear()),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      'Clear (${_selected.length})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          // Grouped list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(kPad, 8, kPad, 96),
              children: [
                for (final entry in _groups.entries)
                  _buildGroupTile(entry.key, entry.value),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(kPad, 8, kPad, kPad),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _selected.isEmpty
                      ? null
                      : () => Navigator.pop(context, Set<String>.from(_selected)),
                  child: Text(
                    _selected.isEmpty ? 'Add parts' : 'Add ${_selected.length} part${_selected.length == 1 ? '' : 's'}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupTile(String groupName, List<String> parts) {
    final groupSelectedCount = parts.where((p) => _selected.contains(p)).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Theme(
        // Remove default ExpansionTile divider
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey(groupName),
          initiallyExpanded: _expanded[groupName] ?? true,
          onExpansionChanged: (v) => setState(() => _expanded[groupName] = v),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          title: Row(
            children: [
              Text(
                groupName,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const SizedBox(width: 8),
              if (groupSelectedCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8700A).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE8700A).withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '$groupSelectedCount',
                    style: const TextStyle(
                      color: Color(0xFFE8700A),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          trailing: Text(
            '${parts.length} item${parts.length == 1 ? '' : 's'}',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: parts.map((item) {
                final isSelected = _selected.contains(item);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (isSelected) {
                      _selected.remove(item);
                    } else {
                      _selected.add(item);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE8700A).withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE8700A).withValues(alpha: 0.7)
                            : Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          const Icon(Icons.check, size: 13, color: Color(0xFFE8700A)),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          item,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                          ),
                        ),
                        // ×N badge — shows how many already added to this vehicle
                        Builder(builder: (_) {
                          final count = _existingCounts[item.trim().toLowerCase()] ?? 0;
                          if (count == 0) return const SizedBox.shrink();
                          return Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '×$count',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}


// ═════════════════════════════════════════════════════════════════════════════
// PresetEditorScreen  (v1.2)
// Add/rename/delete groups and items, reorder with up/down, reset to defaults
// ═════════════════════════════════════════════════════════════════════════════
class PresetEditorScreen extends StatefulWidget {
  final ItemType itemType;
  final Map<String, List<String>> groups;

  const PresetEditorScreen({
    super.key,
    required this.itemType,
    required this.groups,
  });

  @override
  State<PresetEditorScreen> createState() => _PresetEditorScreenState();
}

class _PresetEditorScreenState extends State<PresetEditorScreen> {
  late List<MapEntry<String, List<String>>> _groupList;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _groupList = widget.groups.entries
        .map((e) => MapEntry(e.key, List<String>.from(e.value)))
        .toList();
  }

  Map<String, List<String>> _toMap() =>
      {for (final e in _groupList) e.key: e.value};

  Future<void> _save() async {
    final map = _toMap();
    await PresetGroupStorage.save(widget.itemType, map);
    if (mounted) Navigator.of(context).pop(map);
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset to defaults?'),
        content: Text(
          'This will replace your custom list for ${widget.itemType.label} with the built-in defaults. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await PresetGroupStorage.reset(widget.itemType);
    final defaults = await PresetGroupStorage.load(widget.itemType);
    if (mounted) {
      Navigator.of(context).pop(defaults);
    }
  }

  void _addGroup() {
    final ctrl = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New group'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Group name'),
          onSubmitted: (_) => Navigator.pop(ctx),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              // Check duplicate group name (case-insensitive)
              final existing = _groupList.map((e) => e.key.toLowerCase()).toSet();
              if (existing.contains(name.toLowerCase())) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Group already exists')),
                );
                Navigator.pop(ctx);
                return;
              }
              setState(() {
                _groupList.add(MapEntry(name, []));
                _dirty = true;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ).then((_) => ctrl.dispose());
  }

  void _renameGroup(int index) {
    final ctrl = TextEditingController(text: _groupList[index].key);
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename group'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Group name'),
          onSubmitted: (_) => Navigator.pop(ctx),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isEmpty) { Navigator.pop(ctx); return; }
              final existing = _groupList
                  .asMap()
                  .entries
                  .where((e) => e.key != index)
                  .map((e) => e.value.key.toLowerCase())
                  .toSet();
              if (existing.contains(name.toLowerCase())) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Group already exists')),
                );
                Navigator.pop(ctx);
                return;
              }
              setState(() {
                _groupList[index] = MapEntry(name, _groupList[index].value);
                _dirty = true;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    ).then((_) => ctrl.dispose());
  }

  Future<void> _deleteGroup(int index) async {
    final name = _groupList[index].key;
    final count = _groupList[index].value.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "$name"?'),
        content: Text(count > 0
            ? 'This will also delete $count item${count == 1 ? '' : 's'} inside it.'
            : 'This group is empty.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() {
      _groupList.removeAt(index);
      _dirty = true;
    });
  }

  void _moveGroupUp(int index) {
    if (index == 0) return;
    setState(() {
      final tmp = _groupList[index - 1];
      _groupList[index - 1] = _groupList[index];
      _groupList[index] = tmp;
      _dirty = true;
    });
  }

  void _moveGroupDown(int index) {
    if (index >= _groupList.length - 1) return;
    setState(() {
      final tmp = _groupList[index + 1];
      _groupList[index + 1] = _groupList[index];
      _groupList[index] = tmp;
      _dirty = true;
    });
  }

  void _addItem(int groupIndex) {
    final ctrl = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add to "${_groupList[groupIndex].key}"'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Part name'),
          onSubmitted: (_) => Navigator.pop(ctx),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isEmpty) { Navigator.pop(ctx); return; }
              final items = _groupList[groupIndex].value;
              final normalised = _normalizePartName(name);
              if (items.any((i) => _normalizePartName(i) == normalised)) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Already exists in this group')),
                );
                Navigator.pop(ctx);
                return;
              }
              setState(() {
                items.add(name);
                _dirty = true;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ).then((_) => ctrl.dispose());
  }

  void _renameItem(int groupIndex, int itemIndex) {
    final ctrl = TextEditingController(text: _groupList[groupIndex].value[itemIndex]);
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename part'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) => Navigator.pop(ctx),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isEmpty) { Navigator.pop(ctx); return; }
              final items = _groupList[groupIndex].value;
              final normalised = _normalizePartName(name);
              final others = items
                  .asMap()
                  .entries
                  .where((e) => e.key != itemIndex)
                  .map((e) => _normalizePartName(e.value))
                  .toSet();
              if (others.contains(normalised)) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Already exists in this group')),
                );
                Navigator.pop(ctx);
                return;
              }
              setState(() {
                items[itemIndex] = name;
                _dirty = true;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    ).then((_) => ctrl.dispose());
  }

  void _deleteItem(int groupIndex, int itemIndex) {
    setState(() {
      _groupList[groupIndex].value.removeAt(itemIndex);
      _dirty = true;
    });
  }

  void _moveItemUp(int groupIndex, int itemIndex) {
    if (itemIndex == 0) return;
    setState(() {
      final items = _groupList[groupIndex].value;
      final tmp = items[itemIndex - 1];
      items[itemIndex - 1] = items[itemIndex];
      items[itemIndex] = tmp;
      _dirty = true;
    });
  }

  void _moveItemDown(int groupIndex, int itemIndex) {
    final items = _groupList[groupIndex].value;
    if (itemIndex >= items.length - 1) return;
    setState(() {
      final tmp = items[itemIndex + 1];
      items[itemIndex + 1] = items[itemIndex];
      items[itemIndex] = tmp;
      _dirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final choice = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Unsaved changes'),
            content: const Text('Save your changes before leaving?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, 'discard'), child: const Text('Discard')),
              TextButton(onPressed: () => Navigator.pop(ctx, 'cancel'), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(ctx, 'save'), child: const Text('Save')),
            ],
          ),
        );
        if (choice == 'save') { await _save(); return; }
        if (choice == 'discard' && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit parts — ${widget.itemType.label}'),
          actions: [
            TextButton(
              onPressed: _confirmReset,
              child: const Text('Reset', style: TextStyle(color: Colors.red)),
            ),
            FilledButton(onPressed: _save, child: const Text('Save')),
            const SizedBox(width: 10),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addGroup,
          icon: const Icon(Icons.create_new_folder_outlined),
          label: const Text('Add group'),
        ),
        body: _groupList.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.folder_open, size: 48, color: Colors.white38),
                    const SizedBox(height: 12),
                    const Text('No groups yet', style: TextStyle(color: Colors.white54)),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _addGroup,
                      icon: const Icon(Icons.add),
                      label: const Text('Add a group'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(kPad, kPad, kPad, 120),
                itemCount: _groupList.length,
                itemBuilder: (ctx, gi) {
                  final groupName = _groupList[gi].key;
                  final items = _groupList[gi].value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Group header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 10, 4, 4),
                          child: Row(
                            children: [
                              const Icon(Icons.folder_outlined, size: 18, color: Color(0xFFE8700A)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  groupName,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                ),
                              ),
                              // Move up/down
                              if (gi > 0)
                                IconButton(
                                  icon: const Icon(Icons.keyboard_arrow_up, size: 20),
                                  onPressed: () => _moveGroupUp(gi),
                                  tooltip: 'Move group up',
                                  visualDensity: VisualDensity.compact,
                                ),
                              if (gi < _groupList.length - 1)
                                IconButton(
                                  icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                                  onPressed: () => _moveGroupDown(gi),
                                  tooltip: 'Move group down',
                                  visualDensity: VisualDensity.compact,
                                ),
                              PopupMenuButton<String>(
                                onSelected: (v) {
                                  if (v == 'rename') _renameGroup(gi);
                                  if (v == 'delete') _deleteGroup(gi);
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(value: 'rename', child: ListTile(
                                    leading: Icon(Icons.edit_outlined),
                                    title: Text('Rename group'),
                                    contentPadding: EdgeInsets.zero,
                                  )),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem(value: 'delete', child: ListTile(
                                    leading: Icon(Icons.delete_outline, color: Colors.red),
                                    title: Text('Delete group', style: TextStyle(color: Colors.red)),
                                    contentPadding: EdgeInsets.zero,
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        // Items list
                        if (items.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'No parts yet — tap + Add part',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12),
                            ),
                          )
                        else
                          ...items.asMap().entries.map((entry) {
                            final ii = entry.key;
                            final item = entry.value;
                            return ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                              title: Text(item, style: const TextStyle(fontSize: 14)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (ii > 0)
                                    IconButton(
                                      icon: const Icon(Icons.keyboard_arrow_up, size: 18),
                                      onPressed: () => _moveItemUp(gi, ii),
                                      visualDensity: VisualDensity.compact,
                                      tooltip: 'Move up',
                                    ),
                                  if (ii < items.length - 1)
                                    IconButton(
                                      icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                                      onPressed: () => _moveItemDown(gi, ii),
                                      visualDensity: VisualDensity.compact,
                                      tooltip: 'Move down',
                                    ),
                                  PopupMenuButton<String>(
                                    onSelected: (v) {
                                      if (v == 'rename') _renameItem(gi, ii);
                                      if (v == 'delete') _deleteItem(gi, ii);
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(value: 'rename', child: ListTile(
                                        leading: Icon(Icons.edit_outlined),
                                        title: Text('Rename'),
                                        contentPadding: EdgeInsets.zero,
                                      )),
                                      const PopupMenuDivider(),
                                      const PopupMenuItem(value: 'delete', child: ListTile(
                                        leading: Icon(Icons.delete_outline, color: Colors.red),
                                        title: Text('Delete', style: TextStyle(color: Colors.red)),
                                        contentPadding: EdgeInsets.zero,
                                      )),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        // Add item button
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                          child: TextButton.icon(
                            onPressed: () => _addItem(gi),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add part', style: TextStyle(fontSize: 13)),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}


// ═════════════════════════════════════════════════════════════════════════════
// AddToCommonPartsSheet  (v1.2 optional feature)
// Bottom sheet shown from Part details — adds part name to a chosen group
// ═════════════════════════════════════════════════════════════════════════════
Future<void> showAddToCommonPartsSheet(
  BuildContext context, {
  required String partName,
  required ItemType itemType,
}) async {
  final groups = await PresetGroupStorage.load(itemType);
  if (!context.mounted) return;

  String? selectedGroup = groups.keys.isNotEmpty ? groups.keys.first : null;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setLocalState) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom +
            MediaQuery.of(ctx).padding.bottom +
            kPad;
        return Padding(
          padding: EdgeInsets.fromLTRB(kPad, kPad, kPad, bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add to Common Parts',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                '"$partName" will be added to your preset list for ${itemType.label}.',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedGroup,
                decoration: const InputDecoration(labelText: 'Add to group'),
                items: groups.isEmpty
                    ? [const DropdownMenuItem(value: 'General', child: Text('General'))]
                    : groups.keys
                        .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                onChanged: (v) => setLocalState(() => selectedGroup = v),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: selectedGroup == null
                          ? null
                          : () async {
                              final group = selectedGroup!;
                              final items = List<String>.from(groups[group] ?? []);
                              final normalised = _normalizePartName(partName);
                              if (items.any((i) => _normalizePartName(i) == normalised)) {
                                Navigator.pop(ctx);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('"$partName" already exists in $group')),
                                  );
                                }
                                return;
                              }
                              items.add(partName);
                              groups[group] = items;
                              await PresetGroupStorage.save(itemType, groups);
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Added "$partName" to $group')),
                                );
                              }
                            },
                      child: const Text('Add to list'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      });
    },
  );
}

class QuickAddPresetsDialog extends StatefulWidget {
  final List<String> items;
  const QuickAddPresetsDialog({super.key, required this.items});

  @override
  State<QuickAddPresetsDialog> createState() => _QuickAddPresetsDialogState();
}

class _QuickAddPresetsDialogState extends State<QuickAddPresetsDialog> {
  final Set<String> _selected = {};
  final List<GlobalKey> _keys = [];

  // Drag state
  bool _isDragging = false;
  bool _dragSelecting = true; // true = selecting, false = deselecting

  @override
  void initState() {
    super.initState();
    _keys.addAll(List.generate(widget.items.length, (_) => GlobalKey()));
  }

  void _handleDragUpdate(Offset globalPos) {
    for (int i = 0; i < _keys.length; i++) {
      final ctx = _keys[i].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final itemPos = box.localToGlobal(Offset.zero);
      final itemRect = itemPos & box.size;
      if (itemRect.contains(globalPos)) {
        final item = widget.items[i];
        setState(() {
          if (_dragSelecting) {
            _selected.add(item);
          } else {
            _selected.remove(item);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add common parts'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.swipe_down, size: 16, color: Colors.white38),
                SizedBox(width: 6),
                Text(
                  'Tap or slide finger to select multiple',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
              ),
              child: GestureDetector(
                onPanStart: (details) {
                  _isDragging = true;
                  // Figure out if we're selecting or deselecting based on first item touched
                  for (int i = 0; i < _keys.length; i++) {
                    final ctx = _keys[i].currentContext;
                    if (ctx == null) continue;
                    final box = ctx.findRenderObject() as RenderBox?;
                    if (box == null) continue;
                    final itemPos = box.localToGlobal(Offset.zero);
                    final itemRect = itemPos & box.size;
                    if (itemRect.contains(details.globalPosition)) {
                      _dragSelecting = !_selected.contains(widget.items[i]);
                      break;
                    }
                  }
                  _handleDragUpdate(details.globalPosition);
                },
                onPanUpdate: (details) {
                  if (_isDragging) _handleDragUpdate(details.globalPosition);
                },
                onPanEnd: (_) => _isDragging = false,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  itemBuilder: (ctx, i) {
                    final item = widget.items[i];
                    final isSelected = _selected.contains(item);
                    return GestureDetector(
                      key: _keys[i],
                      onTap: () => setState(() {
                        if (isSelected) {
                          _selected.remove(item);
                        } else {
                          _selected.add(item);
                        }
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE8700A).withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFE8700A).withValues(alpha: 0.6)
                                : Colors.white.withValues(alpha: 0.08),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE8700A)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFE8700A)
                                      : Colors.white24,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 14, color: Colors.black)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        if (_selected.isNotEmpty)
          TextButton(
            onPressed: () => setState(() => _selected.clear()),
            child: const Text('Clear'),
          ),
        FilledButton(
          onPressed: _selected.isEmpty
              ? null
              : () => Navigator.pop(context, _selected),
          child: Text(_selected.isEmpty ? 'Add' : 'Add (${_selected.length})'),
        ),
      ],
    );
  }
}

/// ----------------------------
/// Parts Search Tab
/// ----------------------------
class PartsSearchTab extends StatefulWidget {
  final List<Vehicle> vehicles;
  final Future<void> Function(String vehicleId) onOpenVehicle;
  /// Called when a part is edited from search/detail. Receives the updated
  /// part and its owning vehicle so the root can persist.
  final Future<void> Function(Part updated, Vehicle vehicle)? onPartEdited;

  const PartsSearchTab({
    super.key,
    required this.vehicles,
    required this.onOpenVehicle,
    this.onPartEdited,
  });

  @override
  State<PartsSearchTab> createState() => _PartsSearchTabState();
}

class _PartsSearchTabState extends State<PartsSearchTab> {
  final _qCtrl = TextEditingController();
  final _grainPainter = LeatherGrainPainter();
  PartState? _stateFilter;
  List<_PartHit> _hits = [];
  List<_PartGroup> _groups = [];
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _qCtrl.addListener(_onQueryChanged);
  }

  @override
  void didUpdateWidget(PartsSearchTab old) {
    super.didUpdateWidget(old);
    // Re-run search immediately when the vehicle list changes (e.g. a part edited)
    if (old.vehicles != widget.vehicles) _recompute();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _qCtrl.removeListener(_onQueryChanged);
    _qCtrl.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    // Debounce: wait 150 ms after the last keystroke before computing results.
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 150), _recompute);
  }

  void _recompute() {
    final q = _qCtrl.text.trim().toLowerCase();
    final newHits = <_PartHit>[];

    // Split into words — all words must match somewhere (AND logic).
    final words = q.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    for (final v in widget.vehicles) {
      for (final p in v.parts) {
        if (_stateFilter != null && p.state != _stateFilter) continue;
        if (words.isEmpty) continue;

        final pn = p.partNumber ?? '';
        final nameHay    = p.name.toLowerCase();
        final vehicleHay = [
          v.make, v.model, v.year.toString(),
          v.trim ?? '', v.engine ?? '', v.transmission ?? '', v.drivetrain ?? '',
          v.identifier ?? '', v.color,
        ].join(' ').toLowerCase();
        final fullHay = [
          nameHay,
          pn.toLowerCase(),
          normalizePartNumber(pn).toLowerCase(),
          p.stockId ?? '',
          p.notes ?? '',
          p.location ?? '',
          vehicleHay,
        ].join(' ');

        // All words must appear somewhere in the full haystack.
        final allMatch = words.every((w) {
          final nw = normalizePartNumber(w).toLowerCase();
          return fullHay.contains(w) || (nw.isNotEmpty && fullHay.contains(nw));
        });
        if (!allMatch) continue;

        // Score: higher = more relevant.
        final int score;
        final nameAndVehicle = '$nameHay $vehicleHay';
        if (words.every((w) => nameHay.contains(w))) {
          score = 3; // all words in part name
        } else if (words.every((w) => nameAndVehicle.contains(w))) {
          score = 2; // all words in name + vehicle fields
        } else {
          score = 1; // all words somewhere (notes, location, part number, etc.)
        }

        newHits.add(_PartHit(vehicle: v, part: p, score: score));
      }
    }

    final groupMap = <String, List<_PartHit>>{};
    for (final h in newHits) {
      // Use normalized key for grouping so ABC-123 and ABC123 merge into one group.
      final key = h.part.partNumber == null
          ? ''
          : normalizePartNumber(h.part.partNumber!);
      groupMap.putIfAbsent(key, () => []).add(h);
    }
    final newGroups = groupMap.entries
        .map((e) {
          final display = e.value.first.part.partNumber ?? '';
          return _PartGroup(partNumber: display, hits: e.value);
        })
        .toList()
      ..sort((a, b) {
        // Sort by relevance first, then qty, then part number.
        final sCmp = b.maxScore.compareTo(a.maxScore);
        if (sCmp != 0) return sCmp;
        final qCmp = b.qty.compareTo(a.qty);
        if (qCmp != 0) return qCmp;
        if (a.partNumber.isEmpty && b.partNumber.isNotEmpty) return 1;
        if (b.partNumber.isEmpty && a.partNumber.isNotEmpty) return -1;
        return a.partNumber.compareTo(b.partNumber);
      });

    if (mounted) setState(() { _hits = newHits; _groups = newGroups; });
  }

  @override
  Widget build(BuildContext context) {
    final q = _qCtrl.text.trim();
    final hits   = _hits;
    final groups = _groups;

    return Scaffold(
      appBar: AppBar(title: const Text('Search Parts')),
      body: Stack(
        children: [
          SizedBox.expand(
            child: CustomPaint(painter: _grainPainter),
          ),
          ListView(
            padding: const EdgeInsets.all(kPad),
            children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'Search',
                  subtitle: 'Search across part name, number, notes, vehicle make, model, year, trim and engine. Use multiple words to narrow results.',
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _qCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    hintText: 'e.g. ranger headlight, ford mirror, 2020 turbo, AB39-13005...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  // Listener on _qCtrl handles debounced search — no onChanged needed
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<PartState?>(
                  initialValue: _stateFilter,
                  decoration: const InputDecoration(labelText: 'Filter by state (optional)'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...PartState.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))),
                  ],
                  onChanged: (v) { setState(() => _stateFilter = v); _recompute(); },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Empty / no-results states ──────────────────────────────────
          if (q.isEmpty)
            AppCard(
              child: Column(
                children: [
                  const Icon(Icons.search, size: 42),
                  const SizedBox(height: 10),
                  Text('Type to search',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  const Text('Results appear grouped by part number.'),
                ],
              ),
            )
          else if (groups.isEmpty)
            AppCard(
              child: Column(
                children: [
                  const Icon(Icons.sentiment_dissatisfied, size: 42),
                  const SizedBox(height: 10),
                  Text('No results',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  const Text('Try a different term (name, location, identifier, part number).'),
                ],
              ),
            )
          else ...[
            // Summary line
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${groups.length} group${groups.length == 1 ? '' : 's'} • ${hits.length} part${hits.length == 1 ? '' : 's'}',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
            // ── Group rows ─────────────────────────────────────────────
            ...groups.map((g) {
              final label = g.partNumber.isEmpty ? 'No part number' : g.partNumber;
              final name  = g.commonName;
              final isSingle = g.hits.length == 1;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(kRadius),
                    onTap: () {
                      if (isSingle) {
                        // Only one hit — go straight to detail
                        final hit = g.hits.first;
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => PartDetailScreen(
                            part: hit.part,
                            vehicle: hit.vehicle,
                            onPartEdited: widget.onPartEdited == null
                                ? null
                                : (updated) => widget.onPartEdited!(updated, hit.vehicle),
                          ),
                        ));
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => _SearchGroupDrillScreen(
                            group: g,
                            onPartEdited: widget.onPartEdited,
                          ),
                        ));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Part number (primary)
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    fontFamily: g.partNumber.isEmpty
                                        ? null
                                        : 'monospace',
                                    color: g.partNumber.isEmpty
                                        ? Colors.white38
                                        : null,
                                    fontStyle: g.partNumber.isEmpty
                                        ? FontStyle.italic
                                        : null,
                                  ),
                                ),
                                // Part name (if consistent)
                                if (name.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: const TextStyle(
                                              color: Colors.white54, fontSize: 13),
                                        ),
                                      ),
                                      if (g.commonSide.isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            g.commonSide,
                                            style: const TextStyle(fontSize: 11, color: Colors.white54),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8700A).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFFE8700A)
                                          .withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  'Qty ${g.qty}',
                                  style: const TextStyle(
                                    color: Color(0xFFE8700A),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${g.hits.length} part${g.hits.length == 1 ? '' : 's'}',
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right,
                              size: 18, color: Colors.white24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PartHit {
  final Vehicle vehicle;
  final Part part;
  final int score; // relevance: 3=name match, 2=name+vehicle, 1=anywhere
  _PartHit({required this.vehicle, required this.part, this.score = 1});
}

/// ----------------------------
/// Stats Tab
/// ----------------------------
class StatsTab extends StatefulWidget {
  final bool loading;
  final List<Vehicle> vehicles;

  const StatsTab({
    super.key,
    required this.loading,
    required this.vehicles,
  });

  static String _withCommas(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromEnd = s.length - i;
      buf.write(s[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }

  static String _fmtMoney(int cents) {
    final sign = cents < 0 ? '-' : '';
    final abs = cents.abs();
    final dollars = abs ~/ 100;
    final rem = abs % 100;
    if (rem == 0) return '$sign\$${StatsTab._withCommas(dollars)}';
    return '$sign\$${StatsTab._withCommas(dollars)}.${rem.toString().padLeft(2, '0')}';
  }

  static Color _profitColor(int cents) {
    if (cents > 0) return Colors.green;
    if (cents < 0) return Colors.red;
    return Colors.blueGrey;
  }

  static Color _ageColor(int days) {
    if (days >= 90) return Colors.red;
    if (days >= 45) return Colors.orange;
    if (days >= 21) return Colors.amber;
    return Colors.green;
  }

  static String _vehicleTitle(Vehicle v) {
    final make = v.make.trim();
    final model = v.model.trim();
    final year = v.year.toString();
    final id = (v.identifier ?? '').trim();
    final base = [year, make, model].where((s) => s.isNotEmpty).join(' ');
    return id.isEmpty ? base : '$base • $id';
  }

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  final _grainPainter = LeatherGrainPainter();

  int _totalPurchase = 0;
  int _totalRevenue = 0;
  int _totalParts = 0;
  int _totalInStock = 0;
  int _totalListedLive = 0;
  int _totalNotListed = 0;
  int _totalQty = 0;
  Map<String, int> _liveListingsByPlatform = {};
  Map<String, int> _totalLinksByPlatform = {};
  List<String> _platforms = [];
  List<_StatPartRow> _oldestTop = [];
  int _avgDaysToSell = 0;
  int _stalledCount = 0;
  List<({String vehicleTitle, String partName, int days, String? partNumber})> _stalledParts = [];
  List<({String vehicleTitle, Part part, Vehicle vehicle})> _needsAttention = [];
  List<({Vehicle vehicle, Part part})> _listedParts = [];
  List<({Vehicle vehicle, Part part})> _unlistedParts = [];

  @override
  void initState() {
    super.initState();
    _computeStats();
  }

  @override
  void didUpdateWidget(StatsTab old) {
    super.didUpdateWidget(old);
    if (old.vehicles != widget.vehicles || old.loading != widget.loading) {
      _computeStats();
    }
  }

  void _computeStats() {
    int totalPurchase = 0;
    int totalRevenue = 0;
    int totalParts = 0;
    int totalInStock = 0;
    int totalListedLive = 0;
    int totalNotListed = 0;
    int totalQty = 0;
    final Map<String, int> liveListingsByPlatform = {};
    final Map<String, int> totalLinksByPlatform = {};
    final List<_StatPartRow> oldestNotListed = [];
    int daysToSellSum = 0;
    int daysToSellCount = 0;
    int stalledCount = 0;
    final stalledParts = <({String vehicleTitle, String partName, int days, String? partNumber})>[];
    final needsAttention = <({String vehicleTitle, Part part, Vehicle vehicle})>[];
    final listedParts = <({Vehicle vehicle, Part part})>[];
    final unlistedParts = <({Vehicle vehicle, Part part})>[];

    for (final v in widget.vehicles) {
      totalPurchase += (v.purchasePriceCents ?? 0);
      totalRevenue += v.soldRevenueCents;

      for (final p in v.parts) {
        totalParts += 1;
        totalQty += (p.qty < 1 ? 1 : p.qty);

        final inStock = (p.state == PartState.removed || p.state == PartState.listed);
        if (inStock) totalInStock += 1;

        if (p.hasLiveListings) {
          totalListedLive += 1;
          listedParts.add((vehicle: v, part: p));
        } else {
          if (inStock) {
            totalNotListed += 1;
            unlistedParts.add((vehicle: v, part: p));
          }
        }

        for (final l in p.listings) {
          if (l.url.trim().isEmpty) continue;
          final platform = l.displayPlatformName;
          totalLinksByPlatform[platform] = (totalLinksByPlatform[platform] ?? 0) + 1;
          if (l.isLive) {
            liveListingsByPlatform[platform] = (liveListingsByPlatform[platform] ?? 0) + 1;
          }
        }

        if (inStock && !p.hasLiveListings) {
          final pn = (p.partNumber ?? '').trim();
          oldestNotListed.add(
            _StatPartRow(
              vehicleTitle: StatsTab._vehicleTitle(v),
              partName: p.name,
              days: p.daysInStock(),
              partNumber: pn.isEmpty ? null : pn,
              qty: p.qty < 1 ? 1 : p.qty,
            ),
          );
        }

        // Avg days to sell
        if (p.state == PartState.sold && p.dateListed != null && p.dateSold != null) {
          daysToSellSum += p.dateSold!.difference(p.dateListed!).inDays.abs();
          daysToSellCount++;
        }

        // Stalled listings (live listing, 30+ days in stock)
        if (inStock && p.hasLiveListings && p.dateListed != null) {
          final daysListed = DateTime.now().difference(p.dateListed!).inDays;
          if (daysListed >= 30) {
            stalledCount++;
            final pn = (p.partNumber ?? '').trim();
            stalledParts.add((
              vehicleTitle: StatsTab._vehicleTitle(v),
              partName: p.name,
              days: daysListed,
              partNumber: pn.isEmpty ? null : pn,
            ));
          }
        }

        // Needs attention (in-stock, missing data)
        if (inStock) {
          final hasCategory = (p.category ?? '').trim().isNotEmpty;
          final hasPrice = p.askingPriceCents != null;
          final hasListingLink = p.listings.any((l) => l.url.trim().isNotEmpty);
          if (!hasCategory || !hasPrice || !hasListingLink) {
            needsAttention.add((
              vehicleTitle: StatsTab._vehicleTitle(v),
              part: p,
              vehicle: v,
            ));
          }
        }
      }
    }

    final platforms = <String>{
      ...totalLinksByPlatform.keys,
      ...liveListingsByPlatform.keys,
    }.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    oldestNotListed.sort((a, b) => b.days.compareTo(a.days));
    stalledParts.sort((a, b) => b.days.compareTo(a.days));

    _totalPurchase = totalPurchase;
    _totalRevenue = totalRevenue;
    _totalParts = totalParts;
    _totalInStock = totalInStock;
    _totalListedLive = totalListedLive;
    _totalNotListed = totalNotListed;
    _totalQty = totalQty;
    _liveListingsByPlatform = liveListingsByPlatform;
    _totalLinksByPlatform = totalLinksByPlatform;
    _platforms = platforms;
    _oldestTop = oldestNotListed.take(10).toList();
    _avgDaysToSell = daysToSellCount > 0 ? (daysToSellSum / daysToSellCount).round() : 0;
    _stalledCount = stalledCount;
    _stalledParts = stalledParts;
    _needsAttention = needsAttention;
    _listedParts = listedParts;
    _unlistedParts = unlistedParts;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Stats')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final totalPL = _totalRevenue - _totalPurchase;

    // ── Local helpers ───────────────────────────────────────────────────────
    Widget statBox(String value, String label, {Color? valueColor, VoidCallback? onTap}) {
      final color = valueColor ?? Colors.white;
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withValues(alpha: onTap != null ? 0.07 : 0.05),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Column(
              children: [
                Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: color)),
                const SizedBox(height: 3),
                Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
                if (onTap != null)
                  const Icon(Icons.chevron_right, size: 12, color: Colors.white24),
              ],
            ),
          ),
        ),
      );
    }

    const gap = SizedBox(width: 8);

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: Stack(
        children: [
          SizedBox.expand(
            child: CustomPaint(painter: _grainPainter),
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(kPad, kPad, kPad, 32),
            children: [

          // ── Financial ─────────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Financials', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white54)),
                const SizedBox(height: 12),
                Row(children: [
                  statBox(StatsTab._fmtMoney(_totalRevenue), 'Revenue'),
                  gap,
                  statBox(StatsTab._fmtMoney(_totalPurchase), 'Purchase', valueColor: const Color(0xFFE8700A)),
                  gap,
                  statBox(StatsTab._fmtMoney(totalPL), 'P / L', valueColor: StatsTab._profitColor(totalPL)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Inventory ─────────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Inventory', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white54)),
                const SizedBox(height: 12),
                Row(children: [
                  statBox('${widget.vehicles.length}', 'Vehicles',
                    onTap: widget.vehicles.isEmpty ? null : () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => _StatsVehicleListScreen(vehicles: widget.vehicles)),
                    )),
                  gap,
                  statBox('$_totalParts', 'Parts'),
                  gap,
                  statBox('$_totalInStock', 'In Stock', valueColor: const Color(0xFFE8700A)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  statBox('$_totalListedLive', 'Listed', valueColor: Colors.green,
                    onTap: _listedParts.isEmpty ? null : () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => _StatsPartListScreen(title: 'Listed Parts', parts: _listedParts)),
                    )),
                  gap,
                  statBox('$_totalNotListed', 'Unlisted',
                    valueColor: _totalNotListed > 0 ? Colors.orange : Colors.white,
                    onTap: _unlistedParts.isEmpty ? null : () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => _StatsPartListScreen(title: 'Unlisted Parts', parts: _unlistedParts)),
                    )),
                  gap,
                  if (_totalQty != _totalParts)
                    statBox('$_totalQty', 'Total Qty')
                  else
                    const Expanded(child: SizedBox()),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Platforms ─────────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Platforms', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white54)),
                const SizedBox(height: 12),
                if (_platforms.isEmpty)
                  Text(
                    'No listing links yet.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
                  )
                else
                  ..._platforms.map((name) {
                    final live = _liveListingsByPlatform[name] ?? 0;
                    final total = _totalLinksByPlatform[name] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          ),
                          Text(
                            '$live live',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          Text(
                            '  /  $total total',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Oldest unlisted ───────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Oldest Unlisted', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white54)),
                const SizedBox(height: 4),
                Text(
                  'In-stock parts with no live listing.',
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.3)),
                ),
                const SizedBox(height: 12),
                if (_oldestTop.isEmpty)
                  Text(
                    'Nothing sitting unlisted — great.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
                  )
                else
                  ..._oldestTop.map((r) {
                    final ageColor = StatsTab._ageColor(r.days);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.partName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text(
                                  r.vehicleTitle,
                                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if ((r.partNumber ?? '').trim().isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'PN: ${r.partNumber}',
                                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.3), fontFamily: 'monospace'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${r.days}d', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ageColor)),
                              if (r.qty > 1)
                                Text('qty ${r.qty}', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.35))),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Avg days to sell ──────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sales Performance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white54)),
                const SizedBox(height: 12),
                Row(children: [
                  statBox(_avgDaysToSell > 0 ? '${_avgDaysToSell}d' : '—', 'Avg Days to Sell',
                    valueColor: _avgDaysToSell > 0 ? StatsTab._ageColor(_avgDaysToSell) : null),
                  gap,
                  statBox('$_stalledCount', 'Stalled (30d+)',
                    valueColor: _stalledCount > 0 ? Colors.orange : Colors.white),
                  gap,
                  const Expanded(child: SizedBox()),
                ]),
              ],
            ),
          ),

          // ── Stalled listings ──────────────────────────────────────────
          if (_stalledParts.isNotEmpty) ...[
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Stalled Listings', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white54)),
                  const SizedBox(height: 4),
                  Text(
                    'Live listings sitting 30+ days without selling.',
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  const SizedBox(height: 12),
                  ..._stalledParts.take(10).map((r) {
                    final ageColor = StatsTab._ageColor(r.days);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.partName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text(r.vehicleTitle,
                                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                if ((r.partNumber ?? '').trim().isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text('PN: ${r.partNumber}',
                                      style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.3), fontFamily: 'monospace')),
                                ],
                              ],
                            ),
                          ),
                          Text('${r.days}d', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ageColor)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],

          // ── Needs attention ───────────────────────────────────────────
          if (_needsAttention.isNotEmpty) ...[
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Needs Attention', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white54)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          '${_needsAttention.length}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'In-stock parts that are incomplete — tap a row to open the vehicle.',
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  const SizedBox(height: 6),
                  // Legend
                  const Wrap(
                    spacing: 10,
                    children: [
                      _AttentionLegendItem(icon: Icons.label_outline, label: 'Category', color: Colors.blue),
                      _AttentionLegendItem(icon: Icons.attach_money, label: 'Price', color: Color(0xFFE8700A)),
                      _AttentionLegendItem(icon: Icons.link, label: 'Listing', color: Colors.green),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ..._needsAttention.take(15).map((r) {
                    final noCategory  = (r.part.category ?? '').trim().isEmpty;
                    final noPrice     = r.part.askingPriceCents == null;
                    final noListing   = !r.part.listings.any((l) => l.url.trim().isNotEmpty);
                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => VehicleDetailScreen(vehicle: r.vehicle, allVehicles: widget.vehicles),
                      )),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.part.name,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text(r.vehicleTitle,
                                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Missing-field icon badges
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (noCategory)
                                  const Padding(padding: EdgeInsets.only(left: 4),
                                    child: Tooltip(message: 'No category',
                                      child: Icon(Icons.label_outline, size: 16, color: Colors.blue))),
                                if (noPrice)
                                  const Padding(padding: EdgeInsets.only(left: 4),
                                    child: Tooltip(message: 'No asking price',
                                      child: Icon(Icons.attach_money, size: 16, color: Color(0xFFE8700A)))),
                                if (noListing)
                                  const Padding(padding: EdgeInsets.only(left: 4),
                                    child: Tooltip(message: 'No listing link',
                                      child: Icon(Icons.link, size: 16, color: Colors.green))),
                              ],
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right, size: 16, color: Colors.white.withValues(alpha: 0.2)),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (_needsAttention.length > 15) ...[
                    const SizedBox(height: 4),
                    Text(
                      '+ ${_needsAttention.length - 15} more parts need attention',
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.35)),
                    ),
                  ],
                ],
              ),
            ),
          ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Manage Part Categories Screen
// ─────────────────────────────────────────────────────────────────────────────
class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  List<String> _categories = [];
  final _addCtrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    PartCategoryStorage.load().then((cats) {
      if (mounted) setState(() { _categories = cats; _loading = false; });
    }).catchError((Object e) { if (kDebugMode) debugPrint('PartCategoryStorage.load failed: $e'); });
  }

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await PartCategoryStorage.save(_categories);
  }

  void _addCategory() {
    final name = _addCtrl.text.trim();
    if (name.isEmpty || name.length > 50 || _categories.contains(name)) return;
    setState(() => _categories.add(name));
    _addCtrl.clear();
    _save();
  }

  void _delete(int index) {
    setState(() => _categories.removeAt(index));
    _save();
  }

  Future<void> _renameCategory(int index, String current) async {
    final ctrl = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Category'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Category name'),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE8700A)),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result == null || result.isEmpty || result == current) return;
    setState(() => _categories[index] = result);
    _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Part Categories'),
        actions: [
          TextButton(
            onPressed: () async {
              await PartCategoryStorage.save(List.from(kPartCategories));
              final cats = await PartCategoryStorage.load();
              if (mounted) setState(() => _categories = cats);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Add new category ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(kPad, kPad, kPad, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _addCtrl,
                          decoration: const InputDecoration(
                            hintText: 'New category name…',
                            prefixIcon: Icon(Icons.add),
                            isDense: true,
                          ),
                          textCapitalization: TextCapitalization.words,
                          onSubmitted: (_) => _addCategory(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: _addCategory,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE8700A),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kPad),
                  child: Text(
                    'Drag ≡ to reorder  ·  tap ✎ to rename  ·  tap 🗑 to delete',
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.3)),
                  ),
                ),
                const SizedBox(height: 8),
                // ── Reorderable list ───────────────────────────────────
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(kPad, 0, kPad, 32),
                    buildDefaultDragHandles: false,
                    itemCount: _categories.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = _categories.removeAt(oldIndex);
                        _categories.insert(newIndex, item);
                      });
                      _save();
                    },
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      return Container(
                        key: ValueKey(cat),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withValues(alpha: 0.05),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                        ),
                        child: Row(
                          children: [
                            // Drag handle
                            ReorderableDragStartListener(
                              index: index,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                child: Icon(Icons.drag_handle, color: Colors.white38, size: 20),
                              ),
                            ),
                            // Orange accent
                            Container(
                              width: 3,
                              height: 18,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8700A),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Name
                            Expanded(
                              child: Text(cat, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            ),
                            // Edit
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              color: Colors.white38,
                              tooltip: 'Rename',
                              onPressed: () => _renameCategory(index, cat),
                            ),
                            // Delete
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              color: Colors.red.withValues(alpha: 0.6),
                              tooltip: 'Delete',
                              onPressed: () => _delete(index),
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Manage Listing Platforms Screen
// ─────────────────────────────────────────────────────────────────────────────
class ManagePlatformsScreen extends StatefulWidget {
  const ManagePlatformsScreen({super.key});

  @override
  State<ManagePlatformsScreen> createState() => _ManagePlatformsScreenState();
}

class _ManagePlatformsScreenState extends State<ManagePlatformsScreen> {
  List<String> _platforms = [];
  final _addCtrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    PlatformStorage.load().then((p) {
      if (mounted) setState(() { _platforms = p; _loading = false; });
    }).catchError((Object e) { if (kDebugMode) debugPrint('PlatformStorage.load failed: $e'); });
  }

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() => PlatformStorage.save(_platforms);

  void _add() {
    final name = _addCtrl.text.trim();
    if (name.isEmpty || _platforms.contains(name)) return;
    setState(() => _platforms.add(name));
    _addCtrl.clear();
    _save();
  }

  void _delete(int index) {
    setState(() => _platforms.removeAt(index));
    _save();
  }

  Future<void> _rename(int index, String current) async {
    final ctrl = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Platform'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Platform name'),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE8700A)),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result == null || result.isEmpty || result == current) return;
    setState(() => _platforms[index] = result);
    _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing Platforms'),
        actions: [
          TextButton(
            onPressed: () async {
              await PlatformStorage.save(List.from(kDefaultPlatforms));
              final p = await PlatformStorage.load();
              if (mounted) setState(() => _platforms = p);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(kPad, kPad, kPad, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _addCtrl,
                          decoration: const InputDecoration(
                            hintText: 'New platform name…',
                            prefixIcon: Icon(Icons.add),
                            isDense: true,
                          ),
                          textCapitalization: TextCapitalization.words,
                          onSubmitted: (_) => _add(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: _add,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE8700A),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kPad),
                  child: Text(
                    'Drag to reorder  ·  tap ✎ to rename  ·  tap 🗑 to delete',
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.3)),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(kPad, 0, kPad, 32),
                    buildDefaultDragHandles: false,
                    itemCount: _platforms.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = _platforms.removeAt(oldIndex);
                        _platforms.insert(newIndex, item);
                      });
                      _save();
                    },
                    itemBuilder: (context, index) {
                      final p = _platforms[index];
                      return Container(
                        key: ValueKey(p),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withValues(alpha: 0.05),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                        ),
                        child: Row(
                          children: [
                            ReorderableDragStartListener(
                              index: index,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                child: Icon(Icons.drag_handle, color: Colors.white38, size: 20),
                              ),
                            ),
                            Container(
                              width: 3,
                              height: 18,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8700A),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(p, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              color: Colors.white38,
                              tooltip: 'Rename',
                              onPressed: () => _rename(index, p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              color: Colors.red.withValues(alpha: 0.6),
                              tooltip: 'Delete',
                              onPressed: () => _delete(index),
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatsPartListScreen extends StatelessWidget {
  final String title;
  final List<({Vehicle vehicle, Part part})> parts;

  const _StatsPartListScreen({required this.title, required this.parts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: parts.isEmpty
          ? const Center(child: Text('No parts'))
          : ListView.builder(
              padding: const EdgeInsets.all(kPad),
              itemCount: parts.length,
              itemBuilder: (ctx, i) {
                final (:vehicle, :part) = parts[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(part.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${StatsTab._vehicleTitle(vehicle)}  ·  ${part.state.label}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                    trailing: part.askingPriceCents != null
                        ? Text(formatMoneyFromCents(part.askingPriceCents!), style: const TextStyle(color: Color(0xFFE8700A)))
                        : null,
                    tileColor: Colors.white.withValues(alpha: 0.04),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
    );
  }
}

class _StatsVehicleListScreen extends StatelessWidget {
  final List<Vehicle> vehicles;
  const _StatsVehicleListScreen({required this.vehicles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Vehicles (${vehicles.length})')),
      body: ListView.builder(
        padding: const EdgeInsets.all(kPad),
        itemCount: vehicles.length,
        itemBuilder: (ctx, i) {
          final v = vehicles[i];
          final pl = v.profitLossCents;
          final plColor = profitColor(pl);
          final isCompleted = v.status == VehicleStatus.shellGone;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Opacity(
              opacity: isCompleted ? 0.5 : 1.0,
              child: ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE8700A).withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    switch (v.itemType) {
                      ItemType.car        => Icons.directions_car,
                      ItemType.motorcycle => Icons.two_wheeler,
                      ItemType.boat       => Icons.directions_boat,
                      ItemType.tractor    => Icons.agriculture,
                      ItemType.other      => Icons.category,
                    },
                    size: 20,
                    color: isCompleted ? Colors.grey : const Color(0xFFE8700A),
                  ),
                ),
                title: Text(
                  _titleOrFallback(v),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                subtitle: Text(
                  '${v.partsCount} parts  ·  ${v.inStockCount} in stock'
                  '${isCompleted ? '  ·  Shell Gone' : ''}',
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.45)),
                ),
                trailing: v.partsCount > 0
                    ? Text(
                        'P/L ${formatMoneyFromCents(pl)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: plColor,
                        ),
                      )
                    : null,
                tileColor: Colors.white.withValues(alpha: 0.04),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AttentionLegendItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _AttentionLegendItem({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8))),
      ],
    );
  }
}

class _StatPartRow {
  final String vehicleTitle;
  final String partName;
  final int days;
  final String? partNumber;
  final int qty;

  _StatPartRow({
    required this.vehicleTitle,
    required this.partName,
    required this.days,
    required this.partNumber,
    required this.qty,
  });
}
/// ----------------------------
/// Settings Tab
/// ----------------------------
class SettingsTab extends StatefulWidget {
  final List<Vehicle> vehicles;
  final Future<void> Function(List<Vehicle> restored) onRestoreVehicles;
  final Future<void> Function() onWipeAll;

  const SettingsTab({
    super.key,
    required this.vehicles,
    required this.onRestoreVehicles,
    required this.onWipeAll,
  });

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  String _version = '';
  bool _showDevToggle = false;
  final _grainPainter = LeatherGrainPainter();

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = info.version);
    }).catchError((Object e) { if (kDebugMode) debugPrint('PackageInfo.fromPlatform failed: $e'); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Stack(
        children: [
          SizedBox.expand(
            child: CustomPaint(painter: _grainPainter),
          ),
          ListView(
            padding: const EdgeInsets.all(kPad),
            children: [
              // ── Pro / Monetisation ─────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isPro ? 'Pro unlocked' : 'Free tier',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    WLBadge(text: isPro ? 'PRO' : 'FREE', color: isPro ? Colors.green : Colors.grey),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  isPro
                      ? 'Unlimited vehicles and parts.'
                      : 'Free limits: $kFreeVehicleLimit vehicle and $kFreePartLimitPerVehicle parts per vehicle.',
                ),
                if (!isPro) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${billing.monthlyPrice} / month   or   ${billing.yearlyPrice} / year',
                    style: const TextStyle(
                      color: Color(0xFFE8700A),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (!isPro)
                      FilledButton(
                        onPressed: () => showProPaywall(
                          context,
                          title: 'Upgrade to Pro',
                          message: 'Unlock unlimited vehicles and parts.',
                        ),
                        child: const Text('Upgrade to Pro'),
                      ),
                    OutlinedButton(
                      onPressed: () => showRestoreDialog(context),
                      child: const Text('Restore'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Dev Pro Toggle (revealed by long-pressing version) ────
          if (_showDevToggle) ...[
            const SizedBox(height: kPad),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bug_report_outlined, color: Colors.orange),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Testing: Force Pro',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Bypasses free limits for testing. Long-press version to hide.',
                              style: TextStyle(color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _debugProOverride,
                        activeThumbColor: Colors.orange,
                        onChanged: (v) async {
                          await _saveDebugProFlag(v);
                          setState(() {}); // rebuild so isPro / UI updates
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // ── Part Categories ────────────────────────────────────────
          const SizedBox(height: kPad),
          AppCard(
            child: InkWell(
              borderRadius: BorderRadius.circular(kRadius),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ManageCategoriesScreen()),
              ),
              child: const Row(
                children: [
                  Icon(Icons.category_outlined, color: Color(0xFFE8700A)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Part Categories', style: TextStyle(fontWeight: FontWeight.w700)),
                        Text('Add, remove and reorder categories', style: TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white24),
                ],
              ),
            ),
          ),

          // ── Listing Platforms ──────────────────────────────────────
          const SizedBox(height: kPad),
          AppCard(
            child: InkWell(
              borderRadius: BorderRadius.circular(kRadius),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ManagePlatformsScreen()),
              ),
              child: const Row(
                children: [
                  Icon(Icons.link, color: Color(0xFFE8700A)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Listing Platforms', style: TextStyle(fontWeight: FontWeight.w700)),
                        Text('Add, remove and reorder listing platforms', style: TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white24),
                ],
              ),
            ),
          ),

          // ── Backup & Restore ───────────────────────────────────────
          const SizedBox(height: kPad),
          AppCard(
            child: InkWell(
              borderRadius: BorderRadius.circular(kRadius),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BackupRestorePage(
                  vehicles: widget.vehicles,
                  onRestoreVehicles: widget.onRestoreVehicles,
                  onWipeAll: widget.onWipeAll,
                )),
              ),
              child: const Row(
                children: [
                  Icon(Icons.cloud_upload_outlined, color: Color(0xFFE8700A)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Backup & Restore', style: TextStyle(fontWeight: FontWeight.w700)),
                        Text('Export, restore and manage your data', style: TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white24),
                ],
              ),
            ),
          ),

          // ── Parts Data ─────────────────────────────────────────────
          const SizedBox(height: kPad),
          AppCard(
            child: InkWell(
              borderRadius: BorderRadius.circular(kRadius),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PartsDataScreen(vehicles: widget.vehicles)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.table_rows_outlined, color: Color(0xFFE8700A)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Parts Data', style: TextStyle(fontWeight: FontWeight.w700)),
                        Text('View and export all part records', style: TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white24),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Feedback ───────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.feedback_outlined, color: Color(0xFFE8700A)),
                    SizedBox(width: 10),
                    Text('Feedback', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.bug_report_outlined, color: Colors.white54),
                  title: const Text('Report a Bug'),
                  onTap: () {
                    final subject = Uri.encodeComponent('Bug Report - WreckLog v$_version');
                    final body = Uri.encodeComponent('Describe the bug:\n\n\nSteps to reproduce:\n\n\nApp version: $_version\nPlatform: ${defaultTargetPlatform.name}');
                    launchUrl(Uri.parse('mailto:novasmic.au@gmail.com?subject=$subject&body=$body'));
                  },
                ),
                const Divider(color: Colors.white12, height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lightbulb_outline, color: Colors.white54),
                  title: const Text('Request a Feature'),
                  onTap: () {
                    final subject = Uri.encodeComponent('Feature Request - WreckLog v$_version');
                    final body = Uri.encodeComponent('Describe the feature:\n\n\nWhy would it be useful:\n\n\nApp version: $_version\nPlatform: ${defaultTargetPlatform.name}');
                    launchUrl(Uri.parse('mailto:novasmic.au@gmail.com?subject=$subject&body=$body'));
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── App info ───────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFFE8700A)),
                    SizedBox(width: 10),
                    Text('About',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 12),
                const _InfoRow(label: 'App', value: 'WreckLog'),
                const SizedBox(height: 6),
                GestureDetector(
                  onLongPress: () => setState(() => _showDevToggle = !_showDevToggle),
                  child: _InfoRow(label: 'Version', value: _version.isEmpty ? '…' : _version),
                ),
                const SizedBox(height: 6),
                const _InfoRow(label: 'Build', value: 'Release 1'),
              ],
            ),
          ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// BackupRestorePage
// ═════════════════════════════════════════════════════════════════════════════
class BackupRestorePage extends StatefulWidget {
  final List<Vehicle> vehicles;
  final Future<void> Function(List<Vehicle> restored) onRestoreVehicles;
  final Future<void> Function() onWipeAll;

  const BackupRestorePage({
    super.key,
    required this.vehicles,
    required this.onRestoreVehicles,
    required this.onWipeAll,
  });

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  final _grainPainter = LeatherGrainPainter();

  int get _totalParts => widget.vehicles.fold(0, (s, v) => s + v.parts.length);

  // ── Export JSON ────────────────────────────────────────────────────
  Future<void> _exportJson(BuildContext context) async {
    final content = await vehiclesToPrettyJson(widget.vehicles);
    downloadTextFileWeb(filename: 'wrecklog_export.json', content: content);
  }

  // ── Export CSV ─────────────────────────────────────────────────────
  Future<void> _exportCsv(BuildContext context) async {
    final content = vehiclesToCsv(widget.vehicles);
    downloadTextFileWeb(filename: 'wrecklog_export.csv', content: content);
  }

  // ── Backup: save JSON file ─────────────────────────────────────────
  Future<void> _backup(BuildContext context) async {
    try {
      final json = await vehiclesToPrettyJson(widget.vehicles);
      final now = DateTime.now();
      final stamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
          '_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      final filename = 'wrecklog_backup_$stamp.json';

      if (kIsWeb) {
        downloadTextFileWeb(filename: filename, content: json);
        return;
      }

      // Desktop (Windows/macOS/Linux): show a save-file dialog.
      if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux)) {
        final savePath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save WreckLog Backup',
          fileName: filename,
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        if (savePath == null) return; // user cancelled
        await File(savePath).writeAsString(json);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Backup saved to $savePath'), backgroundColor: Colors.green),
          );
        }
        return;
      }

      // Mobile (Android/iOS): share sheet.
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsString(json);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'WreckLog Backup $stamp',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup failed. Check storage permissions and try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Restore: pick JSON file and load ──────────────────────────────
  Future<void> _restore(BuildContext context) async {
    final vCount = widget.vehicles.length;
    final pCount = widget.vehicles.fold<int>(0, (s, v) => s + v.parts.length);
    final currentSummary = vCount == 0
        ? 'You have no data yet.'
        : 'You currently have $vCount vehicle${vCount == 1 ? '' : 's'} '
          'and $pCount part${pCount == 1 ? '' : 's'}.';

    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Restore from backup'),
            content: Text(
              '$currentSummary\n\n'
              'Restoring will permanently delete all of it and replace it '
              'with the backup file. This cannot be undone.\n\n'
              'Continue?',
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Yes, restore'),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok) return;
    if (!context.mounted) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final bytes = result.files.first.bytes;
      if (bytes == null) throw Exception('Could not read file');

      final jsonStr = const Utf8Decoder().convert(bytes);
      final decoded = jsonDecode(jsonStr);

      List<dynamic> rawList;
      if (decoded is Map<String, dynamic> && decoded['wrecklog_backup'] == true) {
        rawList = decoded['vehicles'] as List<dynamic>? ?? [];
      } else if (decoded is List) {
        rawList = decoded;
      } else {
        throw const FormatException('Unrecognised backup format');
      }

      final restored = <Vehicle>[];
      int skipped = 0;
      for (final e in rawList) {
        try {
          restored.add(Vehicle.fromJson(e as Map<String, dynamic>));
        } catch (_) {
          skipped++;
        }
      }

      if (restored.isEmpty) {
        throw const FormatException('Backup contains no valid vehicles — restore cancelled to protect your data.');
      }

      if (!context.mounted) return;
      await widget.onRestoreVehicles(restored);

      if (decoded is Map<String, dynamic>) {
        final cats = decoded['part_categories'];
        if (cats is List) await PartCategoryStorage.save(List<String>.from(cats));
        final plats = decoded['listing_platforms'];
        if (plats is List) await PlatformStorage.save(List<String>.from(plats));
        final presets = decoded['preset_groups'];
        if (presets is Map<String, dynamic>) {
          for (final type in ItemType.values) {
            final data = presets[type.name];
            if (data is Map<String, dynamic>) {
              await PresetGroupStorage.save(
                type,
                data.map((k, v) => MapEntry(k, List<String>.from(v as List))),
              );
            }
          }
        }
      }

      if (context.mounted) {
        final msg = skipped == 0
            ? 'Restored ${restored.length} vehicle${restored.length == 1 ? '' : 's'} successfully!'
            : 'Restored ${restored.length} vehicle${restored.length == 1 ? '' : 's'} ($skipped skipped — corrupted).';
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Restore complete'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(msg),
                const SizedBox(height: 12),
                const Text(
                  'Remember: photos are backed up separately. '
                  'If you haven\'t restored your photo backup yet, '
                  'use the Photo Backup section below to bring them back.',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Got it'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restore failed. The file may be corrupted or in the wrong format.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Global: delete photos of sold parts across all vehicles ──────
  Future<void> _deleteAllSoldPhotos(BuildContext context) async {
    final allSoldParts = widget.vehicles
        .expand((v) => v.parts)
        .where((p) => p.state == PartState.sold)
        .toList();

    if (allSoldParts.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No sold parts found across any vehicle.')));
      }
      return;
    }

    int photoCount = 0;
    for (final part in allSoldParts) {
      final photos = await PhotoStorage.forOwner('part', part.id);
      photoCount += photos.length;
    }

    if (photoCount == 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sold parts have no photos to delete.')));
      }
      return;
    }

    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete all sold part photos?'),
        content: Text(
          'This will permanently delete $photoCount photo${photoCount == 1 ? '' : 's'} '
          'from ${allSoldParts.length} sold part${allSoldParts.length == 1 ? '' : 's'} '
          'across all vehicles.\n\nThis cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete all'),
          ),
        ],
      ),
    ) ?? false;

    if (!ok || !context.mounted) return;

    for (final part in allSoldParts) {
      await PhotoStorage.deleteAllForOwner('part', part.id);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Deleted $photoCount photo${photoCount == 1 ? '' : 's'} from sold parts across all vehicles.'),
          backgroundColor: Colors.green,
        ));
    }
  }

  // ── Photo backup: zip all photo files and share ──────────────────
  Future<void> _backupPhotos(BuildContext context) async {
    try {
      final allPhotos = await PhotoStorage.loadAll();
      if (allPhotos.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No photos to back up.')));
        }
        return;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Building photo backup…'),
            duration: Duration(seconds: 60),
          ));
      }

      final encoder = ZipFileEncoder();
      final now = DateTime.now();
      final stamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
          '_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      final dir = await getTemporaryDirectory();
      final zipPath = '${dir.path}/wrecklog_photos_$stamp.zip';

      encoder.create(zipPath);

      int count = 0;
      try {
        for (final photo in allPhotos) {
          try {
            final f = File(photo.pathOrData);
            if (await f.exists()) {
              final archivePath = '${photo.ownerType}s/${photo.ownerId}/${photo.id}.jpg';
              final bytes = await f.readAsBytes();
              encoder.addArchiveFile(ArchiveFile(archivePath, bytes.length, bytes));
              count++;
            }
          } catch (e) {
            if (kDebugMode) debugPrint('Skipping photo ${photo.id}: $e');
          }
        }
      } finally {
        encoder.close();
      }

      if (context.mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (count == 0) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No photo files found to back up.')));
        }
        return;
      }

      // Desktop: save-file dialog; mobile: share sheet.
      if (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux) {
        final savePath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save WreckLog Photo Backup',
          fileName: 'wrecklog_photos_$stamp.zip',
          type: FileType.custom,
          allowedExtensions: ['zip'],
        );
        if (savePath == null) return; // user cancelled
        await File(zipPath).copy(savePath);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Photo backup saved to $savePath'), backgroundColor: Colors.green),
          );
        }
      } else {
        await Share.shareXFiles(
          [XFile(zipPath, mimeType: 'application/zip')],
          subject: 'WreckLog Photo Backup $stamp',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo backup failed. Please try again.'),
            backgroundColor: Colors.red,
          ));
      }
    }
  }

  // ── Photo restore: pick zip, extract photos, rebuild metadata ─────
  Future<void> _restorePhotos(BuildContext context) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Restore photo backup?'),
            content: const Text(
              'This will re-import photos from a WreckLog photo backup zip.\n\n'
              'Existing photos in the app will NOT be deleted — '
              'photos from the backup will be added alongside them.\n\n'
              'Make sure you have restored your data backup first so '
              'vehicle and part records exist.',
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Restore photos'),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok || !context.mounted) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;
      if (!context.mounted) return;
      final bytes = result.files.first.bytes;
      if (bytes == null) throw Exception('Could not read file');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restoring photos…'),
            duration: Duration(seconds: 60),
          ));
      }

      final archive = ZipDecoder().decodeBytes(bytes);
      final docsDir = await getApplicationDocumentsDirectory();
      int count = 0;

      final allExisting = await PhotoStorage.loadAll();
      final existingIds = <String>{for (final p in allExisting) p.id};

      for (final file in archive) {
        if (!file.isFile) continue;
        final parts = file.name.split('/');
        if (parts.length != 3) continue;
        final ownerFolder = parts[0];
        final ownerId     = parts[1];
        final fileName    = parts[2];
        if (!fileName.endsWith('.jpg')) continue;

        if (ownerId.contains('..') || ownerId.contains('/') ||
            fileName.contains('..') || fileName.contains('/') ||
            ownerFolder.contains('..')) { continue; }

        try {
          final ownerType = ownerFolder == 'vehicles' ? 'vehicle' : 'part';
          final photoId   = fileName.replaceAll('.jpg', '');

          final destDir = Directory(
            '${docsDir.path}/wrecklog/photos/$ownerFolder/$ownerId'
          );
          await destDir.create(recursive: true);
          final destPath = '${destDir.path}/$fileName';
          await File(destPath).writeAsBytes(file.content as List<int>);

          if (!existingIds.contains(photoId)) {
            await PhotoStorage.add(
              ownerType:  ownerType,
              ownerId:    ownerId,
              sourcePath: destPath,
            );
            existingIds.add(photoId);
          }
          count++;
        } catch (e) {
          if (kDebugMode) debugPrint('Failed to restore photo ${file.name}: $e');
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              count > 0
                ? 'Restored $count photo${count == 1 ? '' : 's'} successfully!'
                : 'No photos found in backup file.'),
            backgroundColor: count > 0 ? Colors.green : null,
          ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo restore failed. The backup file may be corrupted.'),
            backgroundColor: Colors.red,
          ));
      }
    }
  }

  // ── Wipe all data ──────────────────────────────────────────────────
  Future<void> _wipeAll(BuildContext context) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Wipe all data?'),
            content: const Text('This permanently deletes all vehicles, parts and photos from this device. This cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Wipe everything'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok || !context.mounted) return;
    await widget.onWipeAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: Stack(
        children: [
          SizedBox.expand(child: CustomPaint(painter: _grainPainter)),
          ListView(
            padding: const EdgeInsets.all(kPad),
            children: [

              // ── Data summary ─────────────────────────────────────────
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.cloud_upload_outlined, color: Color(0xFFE8700A)),
                        SizedBox(width: 10),
                        Text('Backup & Restore', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your data is stored on this device only. '
                      'Back up regularly so you never lose your inventory.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _DataPill(label: 'Vehicles', value: '${widget.vehicles.length}', icon: Icons.directions_car),
                          _DataPill(label: 'Parts', value: '$_totalParts', icon: Icons.inventory_2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: kPad),

              // ── Backup Data ───────────────────────────────────────────
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.save_outlined, size: 15, color: Color(0xFFE8700A)),
                      const SizedBox(width: 8),
                      Text('Backup Data',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.8))),
                    ]),
                    const SizedBox(height: 4),
                    Text(
                      'Saves all your vehicle and part records as a .json file. '
                      'Store it somewhere safe — Google Drive, email, USB, etc.',
                      style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.45), height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _backup(context),
                        icon: const Icon(Icons.upload),
                        label: const Text('Backup Data Now'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE8700A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _restore(context),
                        icon: const Icon(Icons.download),
                        label: const Text('Restore Data from Backup'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Row(children: [
                      Icon(Icons.info_outline, size: 13, color: Colors.white24),
                      SizedBox(width: 6),
                      Expanded(child: Text(
                        'Photos are not included — back them up separately using Backup Photos below.',
                        style: TextStyle(fontSize: 11, color: Colors.white38, height: 1.4),
                      )),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: kPad),

              // ── Backup Photos ─────────────────────────────────────────
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.photo_library_outlined, size: 15, color: Color(0xFFE8700A)),
                      const SizedBox(width: 8),
                      Text('Backup Photos',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.8))),
                    ]),
                    const SizedBox(height: 4),
                    Text(
                      'Saves all photos as a .zip file. '
                      'Restore data backup first, then restore photos.',
                      style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.45), height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _backupPhotos(context),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Backup Photos Now'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white12,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _restorePhotos(context),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Restore Photos from Backup'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: kPad),

              // ── Export to Another Location ────────────────────────────
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.open_in_new, size: 15, color: Color(0xFFE8700A)),
                      const SizedBox(width: 8),
                      Text('Export to Another Location',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.8))),
                    ]),
                    const SizedBox(height: 4),
                    Text(
                      'Export your data to open in a spreadsheet or another app. '
                      'Not intended as a backup — use Backup Data above for that.',
                      style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.45), height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _exportJson(context),
                        icon: const Icon(Icons.code),
                        label: const Text('Export as JSON'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _exportCsv(context),
                        icon: const Icon(Icons.table_rows_outlined),
                        label: const Text('Export as CSV (spreadsheet)'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: kPad),

              // ── Danger Zone ───────────────────────────────────────────
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.warning_amber_rounded, size: 15, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text('Danger Zone', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.redAccent)),
                    ]),
                    const SizedBox(height: 4),
                    Text(
                      'These actions are permanent and cannot be undone. Make sure you have a backup first.',
                      style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.45), height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteAllSoldPhotos(context),
                        icon: const Icon(Icons.delete_sweep_outlined),
                        label: const Text('Delete photos of all sold parts'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Row(children: [
                      Icon(Icons.info_outline, size: 13, color: Colors.white24),
                      SizedBox(width: 6),
                      Expanded(child: Text(
                        'Frees up storage by removing photos from sold parts across all vehicles.',
                        style: TextStyle(fontSize: 11, color: Colors.white38, height: 1.4),
                      )),
                    ]),
                    const SizedBox(height: 14),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _wipeAll(context),
                        icon: const Icon(Icons.delete_forever_outlined),
                        label: const Text('Wipe all data'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Row(children: [
                      Icon(Icons.info_outline, size: 13, color: Colors.white24),
                      SizedBox(width: 6),
                      Expanded(child: Text(
                        'Permanently deletes all vehicles, parts and photos from this device.',
                        style: TextStyle(fontSize: 11, color: Colors.white38, height: 1.4),
                      )),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: kPad),
            ],
          ),
        ],
      ),
    );
  }
}

class _DataPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _DataPill(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFE8700A), size: 22),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.white54)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PartsDataScreen
// ═════════════════════════════════════════════════════════════════════════════

/// Flat record pairing a [Part] with its parent [Vehicle].
class _PartEntry {
  final Part part;
  final Vehicle vehicle;
  const _PartEntry({required this.part, required this.vehicle});
}

enum _PartsDataFilter { all, unsold, sold }

enum _PartsDataSort { dateListed, dateSold, salePrice, daysToSell }

class PartsDataScreen extends StatefulWidget {
  final List<Vehicle> vehicles;
  const PartsDataScreen({super.key, required this.vehicles});

  @override
  State<PartsDataScreen> createState() => _PartsDataScreenState();
}

class _PartsDataScreenState extends State<PartsDataScreen> {
  final _searchCtrl = TextEditingController();
  final _grainPainter = LeatherGrainPainter();
  String _query = '';
  _PartsDataFilter _filter = _PartsDataFilter.all;
  _PartsDataSort _sort = _PartsDataSort.dateListed;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Build flat list ──────────────────────────────────────────────
  List<_PartEntry> get _entries {
    final all = <_PartEntry>[];
    for (final v in widget.vehicles) {
      for (final p in v.parts) {
        all.add(_PartEntry(part: p, vehicle: v));
      }
    }

    // Filter by state
    final filtered = all.where((e) {
      switch (_filter) {
        case _PartsDataFilter.all:
          return true;
        case _PartsDataFilter.unsold:
          return e.part.state != PartState.sold &&
              e.part.state != PartState.scrapped;
        case _PartsDataFilter.sold:
          return e.part.state == PartState.sold;
      }
    }).toList();

    // Filter by search query
    final q = _query.trim().toLowerCase();
    final searched = q.isEmpty
        ? filtered
        : filtered
            .where((e) => e.part.name.toLowerCase().contains(q))
            .toList();

    // Sort
    searched.sort((a, b) {
      switch (_sort) {
        case _PartsDataSort.dateListed:
          final ad = a.part.dateListed;
          final bd = b.part.dateListed;
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return bd.compareTo(ad); // newest first

        case _PartsDataSort.dateSold:
          final ad = a.part.dateSold;
          final bd = b.part.dateSold;
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return bd.compareTo(ad); // newest first

        case _PartsDataSort.salePrice:
          final ap = a.part.salePriceCents;
          final bp = b.part.salePriceCents;
          if (ap == null && bp == null) return 0;
          if (ap == null) return 1;
          if (bp == null) return -1;
          return bp.compareTo(ap); // highest first

        case _PartsDataSort.daysToSell:
          final ad = a.part.daysToSell;
          final bd = b.part.daysToSell;
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return ad.compareTo(bd); // lowest first
      }
    });

    return searched;
  }

  // ── Vehicle label for a part ─────────────────────────────────────
  String _vehicleLabel(_PartEntry e) {
    final make = e.part.vehicleMake ?? e.vehicle.make;
    final model = e.part.vehicleModel ?? e.vehicle.model;
    final year = e.part.vehicleYear ?? e.vehicle.year;
    final trim = e.part.vehicleTrim ?? e.vehicle.trim;
    final parts = <String>[];
    if (make.isNotEmpty) parts.add(make);
    if (model.isNotEmpty) parts.add(model);
    parts.add(year.toString());
    if (trim != null && trim.isNotEmpty) parts.add(trim);
    return parts.isEmpty ? 'Unknown vehicle' : parts.join(' ');
  }

  // ── Export ───────────────────────────────────────────────────────
  Future<void> _exportJson(BuildContext context) async {
    try {
      final content = await vehiclesToPrettyJson(widget.vehicles);
      if (kIsWeb) {
        downloadTextFileWeb(filename: 'wrecklog_parts_export.json', content: content);
        return;
      }
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.macOS ||
              defaultTargetPlatform == TargetPlatform.linux)) {
        final savePath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Parts Data (JSON)',
          fileName: 'wrecklog_parts_export.json',
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        if (savePath == null) return;
        await File(savePath).writeAsString(content);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved to $savePath'), backgroundColor: Colors.green),
          );
        }
        return;
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/wrecklog_parts_export.json');
      await file.writeAsString(content);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'WreckLog Parts Export',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export failed.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _exportCsv(BuildContext context) async {
    try {
      final content = vehiclesToCsv(widget.vehicles);
      if (kIsWeb) {
        downloadTextFileWeb(filename: 'wrecklog_parts_export.csv', content: content);
        return;
      }
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.macOS ||
              defaultTargetPlatform == TargetPlatform.linux)) {
        final savePath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Parts Data (CSV)',
          fileName: 'wrecklog_parts_export.csv',
          type: FileType.custom,
          allowedExtensions: ['csv'],
        );
        if (savePath == null) return;
        await File(savePath).writeAsString(content);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved to $savePath'), backgroundColor: Colors.green),
          );
        }
        return;
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/wrecklog_parts_export.csv');
      await file.writeAsString(content);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'WreckLog Parts Export',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export failed.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final entries = _entries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parts Data'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.ios_share_outlined),
            tooltip: 'Export',
            onSelected: (value) {
              if (value == 'json') _exportJson(context);
              if (value == 'csv') _exportCsv(context);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'json', child: Text('Export JSON')),
              PopupMenuItem(value: 'csv', child: Text('Export CSV')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox.expand(child: CustomPaint(painter: _grainPainter)),
          Column(
            children: [
              // ── Search bar ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(kPad, kPad, kPad, 0),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search parts…',
                    prefixIcon: const Icon(Icons.search, color: Colors.white38),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white38),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),

              // ── Filter chips ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(kPad, 8, kPad, 0),
                child: Row(
                  children: [
                    _filterChip('All', _PartsDataFilter.all),
                    const SizedBox(width: 8),
                    _filterChip('Unsold', _PartsDataFilter.unsold),
                    const SizedBox(width: 8),
                    _filterChip('Sold', _PartsDataFilter.sold),
                    const Spacer(),
                    // ── Sort dropdown ──────────────────────────
                    DropdownButton<_PartsDataSort>(
                      value: _sort,
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                      dropdownColor: const Color(0xFF1E1E1E),
                      icon: const Icon(Icons.sort, color: Colors.white38, size: 18),
                      items: const [
                        DropdownMenuItem(
                          value: _PartsDataSort.dateListed,
                          child: Text('Date Listed'),
                        ),
                        DropdownMenuItem(
                          value: _PartsDataSort.dateSold,
                          child: Text('Date Sold'),
                        ),
                        DropdownMenuItem(
                          value: _PartsDataSort.salePrice,
                          child: Text('Sale Price'),
                        ),
                        DropdownMenuItem(
                          value: _PartsDataSort.daysToSell,
                          child: Text('Days to Sell'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _sort = v);
                      },
                    ),
                  ],
                ),
              ),

              // ── List ────────────────────────────────────────────
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Text(
                          _query.isNotEmpty ? 'No parts match your search.' : 'No parts found.',
                          style: const TextStyle(color: Colors.white38),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(kPad, kPad, kPad, 32),
                        itemCount: entries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final e = entries[index];
                          final p = e.part;
                          final askStr = p.askingPriceCents != null
                              ? formatMoneyFromCents(p.askingPriceCents!)
                              : '—';
                          final saleStr = p.salePriceCents != null
                              ? formatMoneyFromCents(p.salePriceCents!)
                              : '—';
                          final listedStr = p.dateListed != null
                              ? formatDateShort(p.dateListed!)
                              : '—';
                          final soldStr = p.dateSold != null
                              ? formatDateShort(p.dateSold!)
                              : '—';
                          final dtsStr = p.daysToSell != null
                              ? '${p.daysToSell} day${p.daysToSell == 1 ? '' : 's'}'
                              : '—';

                          return AppCard(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Line 1: name + part number
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        p.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (p.partNumber != null && p.partNumber!.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        p.partNumber!,
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),

                                const SizedBox(height: 3),

                                // Line 2: vehicle
                                Text(
                                  _vehicleLabel(e),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 4),

                                // Line 3: prices
                                Text(
                                  'Listed: $askStr  →  Sold: $saleStr',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(height: 2),

                                // Line 4: dates + days to sell
                                Text(
                                  'Date listed: $listedStr  |  Date sold: $soldStr  |  Days to sell: $dtsStr',
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, _PartsDataFilter value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8700A) : Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white54,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

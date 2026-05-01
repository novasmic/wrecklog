// lib/db/vehicle_store.dart
//
// New storage layer — reads and writes from Drift/SQLite.
// Replaces the SharedPreferences-based Storage class at call sites in main.dart.
//
// Falls back to Storage (SharedPreferences) if migration has not completed.

import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart';
import '../main.dart'
    show
        Vehicle,
        Part,
        Listing,
        InterchangeGroup,
        PartStateX,
        VehicleStatusX,
        ItemTypeX,
        Storage;
import 'app_database.dart';

class VehicleStore {
  static const _kMigrationVersion = 'db_migration_version';
  static const _kTargetVersion    = 1;

  static Future<bool> get _migrationDone async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getInt(_kMigrationVersion) ?? 0) >= _kTargetVersion;
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  static Future<List<Vehicle>> loadVehicles() async {
    if (!await _migrationDone) {
      if (kDebugMode) debugPrint('[VehicleStore] Migration not done — using SharedPreferences fallback');
      return Storage.loadVehicles();
    }

    try {
      final db = AppDatabase.instance;

      final vehicleRows = await (db.select(db.vehiclesTable)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.acquiredAt)]))
          .get();

      final vehicles = <Vehicle>[];
      for (final vRow in vehicleRows) {
        final partRows = await (db.select(db.partsTable)
              ..where((t) => t.vehicleId.equals(vRow.id) & t.deletedAt.isNull()))
            .get();

        final parts = <Part>[];
        for (final pRow in partRows) {
          final listingRows = await (db.select(db.listingsTable)
                ..where((t) => t.partId.equals(pRow.id) & t.deletedAt.isNull()))
              .get();

          parts.add(_partFromRow(pRow, listingRows));
        }

        vehicles.add(_vehicleFromRow(vRow, parts));
      }

      return vehicles;
    } catch (e) {
      if (kDebugMode) debugPrint('[VehicleStore] loadVehicles error: $e — falling back to SharedPreferences');
      return Storage.loadVehicles();
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  static Future<void> saveVehicles(List<Vehicle> vehicles) async {
    if (!await _migrationDone) {
      return Storage.saveVehicles(vehicles);
    }

    try {
      final db = AppDatabase.instance;
      await db.transaction(() async {
        // Full replace — mirrors current SharedPreferences behaviour exactly.
        await db.delete(db.listingsTable).go();
        await db.delete(db.partsTable).go();
        await db.delete(db.vehiclesTable).go();

        for (final v in vehicles) {
          await db.into(db.vehiclesTable).insert(_vehicleToCompanion(v));

          for (final part in v.parts) {
            await db.into(db.partsTable).insert(_partToCompanion(part, v.id));

            for (final listing in part.listings) {
              await db.into(db.listingsTable)
                  .insert(_listingToCompanion(listing, part.id));
            }
          }
        }
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[VehicleStore] saveVehicles error: $e');
      rethrow;
    }
  }

  // ── Wipe ──────────────────────────────────────────────────────────────────

  static Future<void> wipeAll() async {
    // Wipe Drift tables
    try {
      final db = AppDatabase.instance;
      await db.transaction(() async {
        await db.delete(db.listingsTable).go();
        await db.delete(db.partsTable).go();
        await db.delete(db.vehiclesTable).go();
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[VehicleStore] wipeAll Drift error: $e');
    }

    // Wipe SharedPreferences (vehicles + settings + migration flag)
    await Storage.wipeAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kMigrationVersion);
  }

  // ── Row → Domain model ─────────────────────────────────────────────────────

  static Vehicle _vehicleFromRow(VehicleRow r, List<Part> parts) {
    return Vehicle(
      id:                r.id,
      make:              r.make,
      model:             r.model,
      year:              r.year,
      itemType:          ItemTypeX.fromString(r.itemType),
      identifier:        r.identifier,
      status:            VehicleStatusX.fromString(r.status),
      purchasePriceCents: r.purchasePriceCents,
      acquiredAt:        DateTime.fromMillisecondsSinceEpoch(r.acquiredAt),
      usageValue:        r.usageValue,
      usageUnit:         r.usageUnit,
      color:             r.color,
      notes:             r.notes,
      createdAt:         DateTime.fromMillisecondsSinceEpoch(r.createdAt),
      updatedAt:         r.updatedAt != null
                             ? DateTime.fromMillisecondsSinceEpoch(r.updatedAt!)
                             : null,
      photoIds:          _decodeStringList(r.photoIds),
      trim:              r.trim,
      engine:            r.engine,
      transmission:      r.transmission,
      drivetrain:        r.drivetrain,
      bidPriceCents:     r.bidPriceCents,
      auctionFeesCents:  r.auctionFeesCents,
      transportCents:    r.transportCents,
      parts:             parts,
    );
  }

  static Part _partFromRow(PartRow r, List<ListingRow> listingRows) {
    return Part(
      id:                  r.id,
      name:                r.name,
      state:               PartStateX.fromString(r.state),
      vehicleId:           r.vehicleId,
      location:            r.location,
      notes:               r.notes,
      partNumber:          r.partNumber,
      qty:                 r.qty,
      askingPriceCents:    r.askingPriceCents,
      salePriceCents:      r.salePriceCents,
      stockId:             r.stockId,
      category:            r.category,
      partCondition:       r.partCondition,
      side:                r.side,
      dateListed:          r.dateListed != null
                               ? DateTime.fromMillisecondsSinceEpoch(r.dateListed!)
                               : null,
      dateSold:            r.dateSold != null
                               ? DateTime.fromMillisecondsSinceEpoch(r.dateSold!)
                               : null,
      createdAt:           DateTime.fromMillisecondsSinceEpoch(r.createdAt),
      updatedAt:           r.updatedAt != null
                               ? DateTime.fromMillisecondsSinceEpoch(r.updatedAt!)
                               : null,
      photoIds:            _decodeStringList(r.photoIds),
      vehicleMake:         r.vehicleMake,
      vehicleModel:        r.vehicleModel,
      vehicleYear:         r.vehicleYear,
      vehicleTrim:         r.vehicleTrim,
      vehicleEngine:       r.vehicleEngine,
      vehicleTransmission: r.vehicleTransmission,
      vehicleDrivetrain:   r.vehicleDrivetrain,
      vehicleUsageValue:   r.vehicleUsageValue,
      vehicleUsageUnit:    r.vehicleUsageUnit,
      listings:            listingRows.map(_listingFromRow).toList(),
      interchangeGroupId:  r.interchangeGroupId,
    );
  }

  static Listing _listingFromRow(ListingRow r) {
    return Listing(
      id:               r.id,
      platform:         r.platform,
      url:              r.url,
      isLive:           r.isLive == 1,
      createdAt:        DateTime.fromMillisecondsSinceEpoch(r.createdAt),
      listedPriceCents: r.listedPriceCents,
    );
  }

  // ── Domain model → Companion ───────────────────────────────────────────────

  static VehiclesTableCompanion _vehicleToCompanion(Vehicle v) {
    final createdMs  = (v.createdAt ?? v.acquiredAt).millisecondsSinceEpoch;
    final updatedMs  = (v.updatedAt ?? v.createdAt ?? v.acquiredAt).millisecondsSinceEpoch;

    return VehiclesTableCompanion.insert(
      id:                 v.id,
      make:               v.make,
      model:              v.model,
      year:               v.year,
      itemType:           v.itemType.name,
      identifier:         Value(v.identifier),
      status:             v.status.name,
      purchasePriceCents: Value(v.purchasePriceCents),
      acquiredAt:         v.acquiredAt.millisecondsSinceEpoch,
      usageValue:         Value(v.usageValue),
      usageUnit:          Value(v.usageUnit),
      color:              Value(v.color),
      notes:              Value(v.notes),
      createdAt:          createdMs,
      updatedAt:          Value(updatedMs),
      photoIds:           Value(jsonEncode(v.photoIds)),
      trim:               Value(v.trim),
      engine:             Value(v.engine),
      transmission:       Value(v.transmission),
      drivetrain:         Value(v.drivetrain),
      bidPriceCents:      Value(v.bidPriceCents),
      auctionFeesCents:   Value(v.auctionFeesCents),
      transportCents:     Value(v.transportCents),
      ownerId:            const Value(null),
      deletedAt:          const Value(null),
    );
  }

  static PartsTableCompanion _partToCompanion(Part part, String vehicleId) {
    final pCreatedMs = part.createdAt.millisecondsSinceEpoch;
    final pUpdatedMs = (part.updatedAt ?? part.createdAt).millisecondsSinceEpoch;

    return PartsTableCompanion.insert(
      id:                  part.id,
      vehicleId:           vehicleId,
      name:                part.name,
      state:               part.state.name,
      location:            Value(part.location),
      notes:               Value(part.notes),
      partNumber:          Value(part.partNumber),
      qty:                 Value(part.qty),
      askingPriceCents:    Value(part.askingPriceCents),
      salePriceCents:      Value(part.salePriceCents),
      stockId:             Value(part.stockId),
      category:            Value(part.category),
      partCondition:       Value(part.partCondition),
      side:                Value(part.side),
      dateListed:          Value(part.dateListed?.millisecondsSinceEpoch),
      dateSold:            Value(part.dateSold?.millisecondsSinceEpoch),
      createdAt:           pCreatedMs,
      updatedAt:           Value(pUpdatedMs),
      photoIds:            Value(jsonEncode(part.photoIds)),
      vehicleMake:         Value(part.vehicleMake),
      vehicleModel:        Value(part.vehicleModel),
      vehicleYear:         Value(part.vehicleYear),
      vehicleTrim:         Value(part.vehicleTrim),
      vehicleEngine:       Value(part.vehicleEngine),
      vehicleTransmission: Value(part.vehicleTransmission),
      vehicleDrivetrain:   Value(part.vehicleDrivetrain),
      vehicleUsageValue:   Value(part.vehicleUsageValue),
      vehicleUsageUnit:    Value(part.vehicleUsageUnit),
      interchangeGroupId:  Value(part.interchangeGroupId),
      ownerId:             const Value(null),
      deletedAt:           const Value(null),
    );
  }

  static ListingsTableCompanion _listingToCompanion(
      Listing listing, String partId) {
    return ListingsTableCompanion.insert(
      id:               listing.id,
      partId:           partId,
      platform:         listing.platform,
      url:              listing.url,
      isLive:           Value(listing.isLive ? 1 : 0),
      listedPriceCents: Value(listing.listedPriceCents),
      createdAt:        listing.createdAt.millisecondsSinceEpoch,
      ownerId:          const Value(null),
      deletedAt:        const Value(null),
    );
  }

  // ── Interchange groups ────────────────────────────────────────────────────

  static Future<List<InterchangeGroup>> loadInterchangeGroups() async {
    if (!await _migrationDone) return [];
    try {
      final db = AppDatabase.instance;
      final rows = await db.select(db.interchangeGroupsTable).get();
      return rows.map(_groupFromRow).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[VehicleStore] loadInterchangeGroups error: $e');
      return [];
    }
  }

  static Future<void> upsertInterchangeGroup(InterchangeGroup g) async {
    if (!await _migrationDone) return;
    try {
      final db = AppDatabase.instance;
      await db.into(db.interchangeGroupsTable).insertOnConflictUpdate(
        InterchangeGroupsTableCompanion.insert(
          id:        g.id,
          label:     Value(g.label),
          numbers:   Value(jsonEncode(g.numbers)),
          createdAt: g.createdAt.millisecondsSinceEpoch,
          updatedAt: Value(g.updatedAt?.millisecondsSinceEpoch),
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[VehicleStore] upsertInterchangeGroup error: $e');
    }
  }

  static Future<void> deleteInterchangeGroup(String id) async {
    if (!await _migrationDone) return;
    try {
      final db = AppDatabase.instance;
      await (db.delete(db.interchangeGroupsTable)
            ..where((t) => t.id.equals(id)))
          .go();
    } catch (e) {
      if (kDebugMode) debugPrint('[VehicleStore] deleteInterchangeGroup error: $e');
    }
  }

  static InterchangeGroup _groupFromRow(InterchangeGroupRow r) => InterchangeGroup(
    id:        r.id,
    label:     r.label,
    numbers:   _decodeStringList(r.numbers),
    createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt),
    updatedAt: r.updatedAt != null ? DateTime.fromMillisecondsSinceEpoch(r.updatedAt!) : null,
  );

  // ── Helpers ───────────────────────────────────────────────────────────────

  static List<String> _decodeStringList(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) return decoded.map((e) => e as String).toList();
    } catch (_) {}
    return [];
  }
}

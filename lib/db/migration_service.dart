// lib/db/migration_service.dart
//
// One-time migration from SharedPreferences JSON → Drift/SQLite.
//
// Safety contract:
//   - Source data (SharedPreferences) is NEVER deleted by this service.
//   - migrationVersion is only written after count validation passes.
//   - If validation fails the app falls back to SharedPreferences via Storage.
//   - The migration is idempotent: safe to re-run if the flag was never set.

import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart';
import '../main.dart' show Vehicle, Storage;
import 'app_database.dart';

class MigrationService {
  static const _kMigrationVersion = 'db_migration_version';
  static const _kTargetVersion    = 1;

  /// Runs the migration if it has not already completed successfully.
  /// Safe to call on every cold start — exits immediately when already done.
  static Future<void> runIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_kMigrationVersion) ?? 0;
    if (current >= _kTargetVersion) return;

    _log('Starting migration to v$_kTargetVersion …');
    await _migrateV1(prefs);
  }

  static Future<void> _migrateV1(SharedPreferences prefs) async {
    // ── 1. Read source data via Storage (handles all legacy key migrations) ───
    List<Vehicle> vehicles;
    try {
      vehicles = await Storage.loadVehicles();
    } catch (e) {
      _log('ERROR: Failed to read SharedPreferences data: $e');
      return; // Do not mark complete — will retry next launch
    }

    if (vehicles.isEmpty) {
      // No existing data — new install or already wiped.
      // Mark migration done so we don't retry on every start.
      _log('No existing data — skipping migration.');
      await prefs.setInt(_kMigrationVersion, _kTargetVersion);
      return;
    }

    // ── 2. Count expected records ─────────────────────────────────────────────
    final expectedVehicles = vehicles.length;
    final expectedParts    = vehicles.fold<int>(0, (s, v) => s + v.parts.length);
    final expectedListings = vehicles.fold<int>(
        0, (s, v) => v.parts.fold(0, (ps, p) => ps + p.listings.length) + s);

    _log('Source: $expectedVehicles vehicles, $expectedParts parts, '
        '$expectedListings listings');

    // ── 3. Insert inside a transaction ────────────────────────────────────────
    final db = AppDatabase.instance;
    try {
      await db.transaction(() async {
        for (final v in vehicles) {
          final createdMs  = (v.createdAt ?? v.acquiredAt).millisecondsSinceEpoch;
          final updatedMs  = (v.updatedAt ?? v.createdAt ?? v.acquiredAt).millisecondsSinceEpoch;

          await db.into(db.vehiclesTable).insertOnConflictUpdate(
            VehiclesTableCompanion.insert(
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
              ownerId:            const Value(null),
              deletedAt:          const Value(null),
            ),
          );

          for (final part in v.parts) {
            final pCreatedMs = part.createdAt.millisecondsSinceEpoch;
            final pUpdatedMs = (part.updatedAt ?? part.createdAt).millisecondsSinceEpoch;

            await db.into(db.partsTable).insertOnConflictUpdate(
              PartsTableCompanion.insert(
                id:                  part.id,
                vehicleId:           v.id,
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
                ownerId:             const Value(null),
                deletedAt:           const Value(null),
              ),
            );

            for (final listing in part.listings) {
              await db.into(db.listingsTable).insertOnConflictUpdate(
                ListingsTableCompanion.insert(
                  id:               listing.id,
                  partId:           part.id,
                  platform:         listing.platform,
                  url:              listing.url,
                  isLive:           Value(listing.isLive ? 1 : 0),
                  listedPriceCents: Value(listing.listedPriceCents),
                  createdAt:        listing.createdAt.millisecondsSinceEpoch,
                  ownerId:          const Value(null),
                  deletedAt:        const Value(null),
                ),
              );
            }
          }
        }
      });
    } catch (e) {
      _log('ERROR: Transaction failed: $e');
      return;
    }

    // ── 4. Validate row counts ────────────────────────────────────────────────
    final actualVehicles = await db.vehiclesTable.count().getSingle();
    final actualParts    = await db.partsTable.count().getSingle();
    final actualListings = await db.listingsTable.count().getSingle();

    _log('Drift: $actualVehicles vehicles, $actualParts parts, '
        '$actualListings listings');

    if (actualVehicles != expectedVehicles ||
        actualParts    != expectedParts    ||
        actualListings != expectedListings) {
      _log('ERROR: Count mismatch — migration NOT marked complete. '
          'App will use SharedPreferences fallback.');
      return;
    }

    // ── 5. Mark complete ──────────────────────────────────────────────────────
    await prefs.setInt(_kMigrationVersion, _kTargetVersion);
    _log('Migration v$_kTargetVersion complete ✓');
  }

  static void _log(String msg) {
    if (kDebugMode) debugPrint('[MigrationService] $msg');
  }
}

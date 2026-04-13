// lib/db/app_database.dart
//
// Drift (SQLite) schema for WreckLog.
// After any change to this file run:
//   dart run build_runner build --delete-conflicting-outputs

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ── Vehicles ──────────────────────────────────────────────────────────────────

@DataClassName('VehicleRow')
class VehiclesTable extends Table {
  @override
  String get tableName => 'vehicles';

  TextColumn get id                 => text()();
  TextColumn get make               => text()();
  TextColumn get model              => text()();
  IntColumn  get year               => integer()();
  TextColumn get itemType           => text()();
  TextColumn get identifier         => text().nullable()();
  TextColumn get status             => text()();
  IntColumn  get purchasePriceCents => integer().nullable()();
  IntColumn  get acquiredAt         => integer()(); // unix ms
  IntColumn  get usageValue         => integer().nullable()();
  TextColumn get usageUnit          => text().withDefault(const Constant('km'))();
  TextColumn get color              => text().withDefault(const Constant(''))();
  TextColumn get notes              => text().nullable()();
  IntColumn  get createdAt          => integer()(); // never null — fallback applied in migration
  IntColumn  get updatedAt          => integer().nullable()();
  TextColumn get photoIds           => text().withDefault(const Constant('[]'))();
  TextColumn get trim               => text().nullable()();
  TextColumn get engine             => text().nullable()();
  TextColumn get transmission       => text().nullable()();
  TextColumn get drivetrain         => text().nullable()();
  TextColumn get ownerId            => text().nullable()(); // reserved for future auth
  IntColumn  get deletedAt          => integer().nullable()(); // null = active

  @override
  Set<Column> get primaryKey => {id};
}

// ── Parts ─────────────────────────────────────────────────────────────────────

@DataClassName('PartRow')
class PartsTable extends Table {
  @override
  String get tableName => 'parts';

  TextColumn get id                  => text()();
  TextColumn get vehicleId           => text()();
  TextColumn get name                => text()();
  TextColumn get state               => text()();
  TextColumn get location            => text().nullable()();
  TextColumn get notes               => text().nullable()();
  TextColumn get partNumber          => text().nullable()();
  IntColumn  get qty                 => integer().withDefault(const Constant(1))();
  IntColumn  get askingPriceCents    => integer().nullable()();
  IntColumn  get salePriceCents      => integer().nullable()();
  TextColumn get stockId             => text().nullable()();
  TextColumn get category            => text().nullable()();
  TextColumn get partCondition       => text().nullable()();
  TextColumn get side                => text().nullable()();
  IntColumn  get dateListed          => integer().nullable()(); // unix ms
  IntColumn  get dateSold            => integer().nullable()(); // unix ms
  IntColumn  get createdAt           => integer()();
  IntColumn  get updatedAt           => integer().nullable()();
  TextColumn get photoIds            => text().withDefault(const Constant('[]'))();
  // Vehicle snapshot — copied at part creation, never updated
  TextColumn get vehicleMake         => text().nullable()();
  TextColumn get vehicleModel        => text().nullable()();
  IntColumn  get vehicleYear         => integer().nullable()();
  TextColumn get vehicleTrim         => text().nullable()();
  TextColumn get vehicleEngine       => text().nullable()();
  TextColumn get vehicleTransmission => text().nullable()();
  TextColumn get vehicleDrivetrain   => text().nullable()();
  IntColumn  get vehicleUsageValue   => integer().nullable()();
  TextColumn get vehicleUsageUnit    => text().nullable()();
  TextColumn get ownerId             => text().nullable()();
  IntColumn  get deletedAt           => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Listings ──────────────────────────────────────────────────────────────────

@DataClassName('ListingRow')
class ListingsTable extends Table {
  @override
  String get tableName => 'listings';

  TextColumn get id               => text()();
  TextColumn get partId           => text()();
  TextColumn get platform         => text()();
  TextColumn get url              => text()();
  IntColumn  get isLive           => integer().withDefault(const Constant(0))();
  IntColumn  get listedPriceCents => integer().nullable()();
  IntColumn  get createdAt        => integer()();
  TextColumn get ownerId          => text().nullable()();
  IntColumn  get deletedAt        => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Database ──────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [VehiclesTable, PartsTable, ListingsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());

  static final AppDatabase instance = AppDatabase._();

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // Indexes for the most common query patterns
      await customStatement(
          'CREATE INDEX idx_parts_vehicle_id ON parts(vehicle_id)');
      await customStatement(
          'CREATE INDEX idx_listings_part_id ON listings(part_id)');
    },
  );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'wrecklog.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}

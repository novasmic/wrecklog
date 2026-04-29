// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VehiclesTableTable extends VehiclesTable
    with TableInfo<$VehiclesTableTable, VehicleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _makeMeta = const VerificationMeta('make');
  @override
  late final GeneratedColumn<String> make = GeneratedColumn<String>(
      'make', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
      'model', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
      'year', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _itemTypeMeta =
      const VerificationMeta('itemType');
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
      'item_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _identifierMeta =
      const VerificationMeta('identifier');
  @override
  late final GeneratedColumn<String> identifier = GeneratedColumn<String>(
      'identifier', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _purchasePriceCentsMeta =
      const VerificationMeta('purchasePriceCents');
  @override
  late final GeneratedColumn<int> purchasePriceCents = GeneratedColumn<int>(
      'purchase_price_cents', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _acquiredAtMeta =
      const VerificationMeta('acquiredAt');
  @override
  late final GeneratedColumn<int> acquiredAt = GeneratedColumn<int>(
      'acquired_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _usageValueMeta =
      const VerificationMeta('usageValue');
  @override
  late final GeneratedColumn<int> usageValue = GeneratedColumn<int>(
      'usage_value', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _usageUnitMeta =
      const VerificationMeta('usageUnit');
  @override
  late final GeneratedColumn<String> usageUnit = GeneratedColumn<String>(
      'usage_unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('km'));
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _photoIdsMeta =
      const VerificationMeta('photoIds');
  @override
  late final GeneratedColumn<String> photoIds = GeneratedColumn<String>(
      'photo_ids', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _trimMeta = const VerificationMeta('trim');
  @override
  late final GeneratedColumn<String> trim = GeneratedColumn<String>(
      'trim', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _engineMeta = const VerificationMeta('engine');
  @override
  late final GeneratedColumn<String> engine = GeneratedColumn<String>(
      'engine', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _transmissionMeta =
      const VerificationMeta('transmission');
  @override
  late final GeneratedColumn<String> transmission = GeneratedColumn<String>(
      'transmission', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _drivetrainMeta =
      const VerificationMeta('drivetrain');
  @override
  late final GeneratedColumn<String> drivetrain = GeneratedColumn<String>(
      'drivetrain', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        make,
        model,
        year,
        itemType,
        identifier,
        status,
        purchasePriceCents,
        acquiredAt,
        usageValue,
        usageUnit,
        color,
        notes,
        createdAt,
        updatedAt,
        photoIds,
        trim,
        engine,
        transmission,
        drivetrain,
        ownerId,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(Insertable<VehicleRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('make')) {
      context.handle(
          _makeMeta, make.isAcceptableOrUnknown(data['make']!, _makeMeta));
    } else if (isInserting) {
      context.missing(_makeMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
          _modelMeta, model.isAcceptableOrUnknown(data['model']!, _modelMeta));
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('item_type')) {
      context.handle(_itemTypeMeta,
          itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta));
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    if (data.containsKey('identifier')) {
      context.handle(
          _identifierMeta,
          identifier.isAcceptableOrUnknown(
              data['identifier']!, _identifierMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('purchase_price_cents')) {
      context.handle(
          _purchasePriceCentsMeta,
          purchasePriceCents.isAcceptableOrUnknown(
              data['purchase_price_cents']!, _purchasePriceCentsMeta));
    }
    if (data.containsKey('acquired_at')) {
      context.handle(
          _acquiredAtMeta,
          acquiredAt.isAcceptableOrUnknown(
              data['acquired_at']!, _acquiredAtMeta));
    } else if (isInserting) {
      context.missing(_acquiredAtMeta);
    }
    if (data.containsKey('usage_value')) {
      context.handle(
          _usageValueMeta,
          usageValue.isAcceptableOrUnknown(
              data['usage_value']!, _usageValueMeta));
    }
    if (data.containsKey('usage_unit')) {
      context.handle(_usageUnitMeta,
          usageUnit.isAcceptableOrUnknown(data['usage_unit']!, _usageUnitMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('photo_ids')) {
      context.handle(_photoIdsMeta,
          photoIds.isAcceptableOrUnknown(data['photo_ids']!, _photoIdsMeta));
    }
    if (data.containsKey('trim')) {
      context.handle(
          _trimMeta, trim.isAcceptableOrUnknown(data['trim']!, _trimMeta));
    }
    if (data.containsKey('engine')) {
      context.handle(_engineMeta,
          engine.isAcceptableOrUnknown(data['engine']!, _engineMeta));
    }
    if (data.containsKey('transmission')) {
      context.handle(
          _transmissionMeta,
          transmission.isAcceptableOrUnknown(
              data['transmission']!, _transmissionMeta));
    }
    if (data.containsKey('drivetrain')) {
      context.handle(
          _drivetrainMeta,
          drivetrain.isAcceptableOrUnknown(
              data['drivetrain']!, _drivetrainMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VehicleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehicleRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      make: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}make'])!,
      model: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model'])!,
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year'])!,
      itemType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_type'])!,
      identifier: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}identifier']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      purchasePriceCents: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}purchase_price_cents']),
      acquiredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}acquired_at'])!,
      usageValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}usage_value']),
      usageUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}usage_unit'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at']),
      photoIds: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_ids'])!,
      trim: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trim']),
      engine: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}engine']),
      transmission: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transmission']),
      drivetrain: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}drivetrain']),
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $VehiclesTableTable createAlias(String alias) {
    return $VehiclesTableTable(attachedDatabase, alias);
  }
}

class VehicleRow extends DataClass implements Insertable<VehicleRow> {
  final String id;
  final String make;
  final String model;
  final int year;
  final String itemType;
  final String? identifier;
  final String status;
  final int? purchasePriceCents;
  final int acquiredAt;
  final int? usageValue;
  final String usageUnit;
  final String color;
  final String? notes;
  final int createdAt;
  final int? updatedAt;
  final String photoIds;
  final String? trim;
  final String? engine;
  final String? transmission;
  final String? drivetrain;
  final String? ownerId;
  final int? deletedAt;
  const VehicleRow(
      {required this.id,
      required this.make,
      required this.model,
      required this.year,
      required this.itemType,
      this.identifier,
      required this.status,
      this.purchasePriceCents,
      required this.acquiredAt,
      this.usageValue,
      required this.usageUnit,
      required this.color,
      this.notes,
      required this.createdAt,
      this.updatedAt,
      required this.photoIds,
      this.trim,
      this.engine,
      this.transmission,
      this.drivetrain,
      this.ownerId,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['make'] = Variable<String>(make);
    map['model'] = Variable<String>(model);
    map['year'] = Variable<int>(year);
    map['item_type'] = Variable<String>(itemType);
    if (!nullToAbsent || identifier != null) {
      map['identifier'] = Variable<String>(identifier);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || purchasePriceCents != null) {
      map['purchase_price_cents'] = Variable<int>(purchasePriceCents);
    }
    map['acquired_at'] = Variable<int>(acquiredAt);
    if (!nullToAbsent || usageValue != null) {
      map['usage_value'] = Variable<int>(usageValue);
    }
    map['usage_unit'] = Variable<String>(usageUnit);
    map['color'] = Variable<String>(color);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    map['photo_ids'] = Variable<String>(photoIds);
    if (!nullToAbsent || trim != null) {
      map['trim'] = Variable<String>(trim);
    }
    if (!nullToAbsent || engine != null) {
      map['engine'] = Variable<String>(engine);
    }
    if (!nullToAbsent || transmission != null) {
      map['transmission'] = Variable<String>(transmission);
    }
    if (!nullToAbsent || drivetrain != null) {
      map['drivetrain'] = Variable<String>(drivetrain);
    }
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  VehiclesTableCompanion toCompanion(bool nullToAbsent) {
    return VehiclesTableCompanion(
      id: Value(id),
      make: Value(make),
      model: Value(model),
      year: Value(year),
      itemType: Value(itemType),
      identifier: identifier == null && nullToAbsent
          ? const Value.absent()
          : Value(identifier),
      status: Value(status),
      purchasePriceCents: purchasePriceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(purchasePriceCents),
      acquiredAt: Value(acquiredAt),
      usageValue: usageValue == null && nullToAbsent
          ? const Value.absent()
          : Value(usageValue),
      usageUnit: Value(usageUnit),
      color: Value(color),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      photoIds: Value(photoIds),
      trim: trim == null && nullToAbsent ? const Value.absent() : Value(trim),
      engine:
          engine == null && nullToAbsent ? const Value.absent() : Value(engine),
      transmission: transmission == null && nullToAbsent
          ? const Value.absent()
          : Value(transmission),
      drivetrain: drivetrain == null && nullToAbsent
          ? const Value.absent()
          : Value(drivetrain),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory VehicleRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehicleRow(
      id: serializer.fromJson<String>(json['id']),
      make: serializer.fromJson<String>(json['make']),
      model: serializer.fromJson<String>(json['model']),
      year: serializer.fromJson<int>(json['year']),
      itemType: serializer.fromJson<String>(json['itemType']),
      identifier: serializer.fromJson<String?>(json['identifier']),
      status: serializer.fromJson<String>(json['status']),
      purchasePriceCents: serializer.fromJson<int?>(json['purchasePriceCents']),
      acquiredAt: serializer.fromJson<int>(json['acquiredAt']),
      usageValue: serializer.fromJson<int?>(json['usageValue']),
      usageUnit: serializer.fromJson<String>(json['usageUnit']),
      color: serializer.fromJson<String>(json['color']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
      photoIds: serializer.fromJson<String>(json['photoIds']),
      trim: serializer.fromJson<String?>(json['trim']),
      engine: serializer.fromJson<String?>(json['engine']),
      transmission: serializer.fromJson<String?>(json['transmission']),
      drivetrain: serializer.fromJson<String?>(json['drivetrain']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'make': serializer.toJson<String>(make),
      'model': serializer.toJson<String>(model),
      'year': serializer.toJson<int>(year),
      'itemType': serializer.toJson<String>(itemType),
      'identifier': serializer.toJson<String?>(identifier),
      'status': serializer.toJson<String>(status),
      'purchasePriceCents': serializer.toJson<int?>(purchasePriceCents),
      'acquiredAt': serializer.toJson<int>(acquiredAt),
      'usageValue': serializer.toJson<int?>(usageValue),
      'usageUnit': serializer.toJson<String>(usageUnit),
      'color': serializer.toJson<String>(color),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int?>(updatedAt),
      'photoIds': serializer.toJson<String>(photoIds),
      'trim': serializer.toJson<String?>(trim),
      'engine': serializer.toJson<String?>(engine),
      'transmission': serializer.toJson<String?>(transmission),
      'drivetrain': serializer.toJson<String?>(drivetrain),
      'ownerId': serializer.toJson<String?>(ownerId),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  VehicleRow copyWith(
          {String? id,
          String? make,
          String? model,
          int? year,
          String? itemType,
          Value<String?> identifier = const Value.absent(),
          String? status,
          Value<int?> purchasePriceCents = const Value.absent(),
          int? acquiredAt,
          Value<int?> usageValue = const Value.absent(),
          String? usageUnit,
          String? color,
          Value<String?> notes = const Value.absent(),
          int? createdAt,
          Value<int?> updatedAt = const Value.absent(),
          String? photoIds,
          Value<String?> trim = const Value.absent(),
          Value<String?> engine = const Value.absent(),
          Value<String?> transmission = const Value.absent(),
          Value<String?> drivetrain = const Value.absent(),
          Value<String?> ownerId = const Value.absent(),
          Value<int?> deletedAt = const Value.absent()}) =>
      VehicleRow(
        id: id ?? this.id,
        make: make ?? this.make,
        model: model ?? this.model,
        year: year ?? this.year,
        itemType: itemType ?? this.itemType,
        identifier: identifier.present ? identifier.value : this.identifier,
        status: status ?? this.status,
        purchasePriceCents: purchasePriceCents.present
            ? purchasePriceCents.value
            : this.purchasePriceCents,
        acquiredAt: acquiredAt ?? this.acquiredAt,
        usageValue: usageValue.present ? usageValue.value : this.usageValue,
        usageUnit: usageUnit ?? this.usageUnit,
        color: color ?? this.color,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        photoIds: photoIds ?? this.photoIds,
        trim: trim.present ? trim.value : this.trim,
        engine: engine.present ? engine.value : this.engine,
        transmission:
            transmission.present ? transmission.value : this.transmission,
        drivetrain: drivetrain.present ? drivetrain.value : this.drivetrain,
        ownerId: ownerId.present ? ownerId.value : this.ownerId,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  VehicleRow copyWithCompanion(VehiclesTableCompanion data) {
    return VehicleRow(
      id: data.id.present ? data.id.value : this.id,
      make: data.make.present ? data.make.value : this.make,
      model: data.model.present ? data.model.value : this.model,
      year: data.year.present ? data.year.value : this.year,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      identifier:
          data.identifier.present ? data.identifier.value : this.identifier,
      status: data.status.present ? data.status.value : this.status,
      purchasePriceCents: data.purchasePriceCents.present
          ? data.purchasePriceCents.value
          : this.purchasePriceCents,
      acquiredAt:
          data.acquiredAt.present ? data.acquiredAt.value : this.acquiredAt,
      usageValue:
          data.usageValue.present ? data.usageValue.value : this.usageValue,
      usageUnit: data.usageUnit.present ? data.usageUnit.value : this.usageUnit,
      color: data.color.present ? data.color.value : this.color,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      photoIds: data.photoIds.present ? data.photoIds.value : this.photoIds,
      trim: data.trim.present ? data.trim.value : this.trim,
      engine: data.engine.present ? data.engine.value : this.engine,
      transmission: data.transmission.present
          ? data.transmission.value
          : this.transmission,
      drivetrain:
          data.drivetrain.present ? data.drivetrain.value : this.drivetrain,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehicleRow(')
          ..write('id: $id, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('itemType: $itemType, ')
          ..write('identifier: $identifier, ')
          ..write('status: $status, ')
          ..write('purchasePriceCents: $purchasePriceCents, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('usageValue: $usageValue, ')
          ..write('usageUnit: $usageUnit, ')
          ..write('color: $color, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('photoIds: $photoIds, ')
          ..write('trim: $trim, ')
          ..write('engine: $engine, ')
          ..write('transmission: $transmission, ')
          ..write('drivetrain: $drivetrain, ')
          ..write('ownerId: $ownerId, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        make,
        model,
        year,
        itemType,
        identifier,
        status,
        purchasePriceCents,
        acquiredAt,
        usageValue,
        usageUnit,
        color,
        notes,
        createdAt,
        updatedAt,
        photoIds,
        trim,
        engine,
        transmission,
        drivetrain,
        ownerId,
        deletedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleRow &&
          other.id == this.id &&
          other.make == this.make &&
          other.model == this.model &&
          other.year == this.year &&
          other.itemType == this.itemType &&
          other.identifier == this.identifier &&
          other.status == this.status &&
          other.purchasePriceCents == this.purchasePriceCents &&
          other.acquiredAt == this.acquiredAt &&
          other.usageValue == this.usageValue &&
          other.usageUnit == this.usageUnit &&
          other.color == this.color &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.photoIds == this.photoIds &&
          other.trim == this.trim &&
          other.engine == this.engine &&
          other.transmission == this.transmission &&
          other.drivetrain == this.drivetrain &&
          other.ownerId == this.ownerId &&
          other.deletedAt == this.deletedAt);
}

class VehiclesTableCompanion extends UpdateCompanion<VehicleRow> {
  final Value<String> id;
  final Value<String> make;
  final Value<String> model;
  final Value<int> year;
  final Value<String> itemType;
  final Value<String?> identifier;
  final Value<String> status;
  final Value<int?> purchasePriceCents;
  final Value<int> acquiredAt;
  final Value<int?> usageValue;
  final Value<String> usageUnit;
  final Value<String> color;
  final Value<String?> notes;
  final Value<int> createdAt;
  final Value<int?> updatedAt;
  final Value<String> photoIds;
  final Value<String?> trim;
  final Value<String?> engine;
  final Value<String?> transmission;
  final Value<String?> drivetrain;
  final Value<String?> ownerId;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const VehiclesTableCompanion({
    this.id = const Value.absent(),
    this.make = const Value.absent(),
    this.model = const Value.absent(),
    this.year = const Value.absent(),
    this.itemType = const Value.absent(),
    this.identifier = const Value.absent(),
    this.status = const Value.absent(),
    this.purchasePriceCents = const Value.absent(),
    this.acquiredAt = const Value.absent(),
    this.usageValue = const Value.absent(),
    this.usageUnit = const Value.absent(),
    this.color = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.photoIds = const Value.absent(),
    this.trim = const Value.absent(),
    this.engine = const Value.absent(),
    this.transmission = const Value.absent(),
    this.drivetrain = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehiclesTableCompanion.insert({
    required String id,
    required String make,
    required String model,
    required int year,
    required String itemType,
    this.identifier = const Value.absent(),
    required String status,
    this.purchasePriceCents = const Value.absent(),
    required int acquiredAt,
    this.usageValue = const Value.absent(),
    this.usageUnit = const Value.absent(),
    this.color = const Value.absent(),
    this.notes = const Value.absent(),
    required int createdAt,
    this.updatedAt = const Value.absent(),
    this.photoIds = const Value.absent(),
    this.trim = const Value.absent(),
    this.engine = const Value.absent(),
    this.transmission = const Value.absent(),
    this.drivetrain = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        make = Value(make),
        model = Value(model),
        year = Value(year),
        itemType = Value(itemType),
        status = Value(status),
        acquiredAt = Value(acquiredAt),
        createdAt = Value(createdAt);
  static Insertable<VehicleRow> custom({
    Expression<String>? id,
    Expression<String>? make,
    Expression<String>? model,
    Expression<int>? year,
    Expression<String>? itemType,
    Expression<String>? identifier,
    Expression<String>? status,
    Expression<int>? purchasePriceCents,
    Expression<int>? acquiredAt,
    Expression<int>? usageValue,
    Expression<String>? usageUnit,
    Expression<String>? color,
    Expression<String>? notes,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? photoIds,
    Expression<String>? trim,
    Expression<String>? engine,
    Expression<String>? transmission,
    Expression<String>? drivetrain,
    Expression<String>? ownerId,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (year != null) 'year': year,
      if (itemType != null) 'item_type': itemType,
      if (identifier != null) 'identifier': identifier,
      if (status != null) 'status': status,
      if (purchasePriceCents != null)
        'purchase_price_cents': purchasePriceCents,
      if (acquiredAt != null) 'acquired_at': acquiredAt,
      if (usageValue != null) 'usage_value': usageValue,
      if (usageUnit != null) 'usage_unit': usageUnit,
      if (color != null) 'color': color,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (photoIds != null) 'photo_ids': photoIds,
      if (trim != null) 'trim': trim,
      if (engine != null) 'engine': engine,
      if (transmission != null) 'transmission': transmission,
      if (drivetrain != null) 'drivetrain': drivetrain,
      if (ownerId != null) 'owner_id': ownerId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehiclesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? make,
      Value<String>? model,
      Value<int>? year,
      Value<String>? itemType,
      Value<String?>? identifier,
      Value<String>? status,
      Value<int?>? purchasePriceCents,
      Value<int>? acquiredAt,
      Value<int?>? usageValue,
      Value<String>? usageUnit,
      Value<String>? color,
      Value<String?>? notes,
      Value<int>? createdAt,
      Value<int?>? updatedAt,
      Value<String>? photoIds,
      Value<String?>? trim,
      Value<String?>? engine,
      Value<String?>? transmission,
      Value<String?>? drivetrain,
      Value<String?>? ownerId,
      Value<int?>? deletedAt,
      Value<int>? rowid}) {
    return VehiclesTableCompanion(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      itemType: itemType ?? this.itemType,
      identifier: identifier ?? this.identifier,
      status: status ?? this.status,
      purchasePriceCents: purchasePriceCents ?? this.purchasePriceCents,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      usageValue: usageValue ?? this.usageValue,
      usageUnit: usageUnit ?? this.usageUnit,
      color: color ?? this.color,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      photoIds: photoIds ?? this.photoIds,
      trim: trim ?? this.trim,
      engine: engine ?? this.engine,
      transmission: transmission ?? this.transmission,
      drivetrain: drivetrain ?? this.drivetrain,
      ownerId: ownerId ?? this.ownerId,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (make.present) {
      map['make'] = Variable<String>(make.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (identifier.present) {
      map['identifier'] = Variable<String>(identifier.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (purchasePriceCents.present) {
      map['purchase_price_cents'] = Variable<int>(purchasePriceCents.value);
    }
    if (acquiredAt.present) {
      map['acquired_at'] = Variable<int>(acquiredAt.value);
    }
    if (usageValue.present) {
      map['usage_value'] = Variable<int>(usageValue.value);
    }
    if (usageUnit.present) {
      map['usage_unit'] = Variable<String>(usageUnit.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (photoIds.present) {
      map['photo_ids'] = Variable<String>(photoIds.value);
    }
    if (trim.present) {
      map['trim'] = Variable<String>(trim.value);
    }
    if (engine.present) {
      map['engine'] = Variable<String>(engine.value);
    }
    if (transmission.present) {
      map['transmission'] = Variable<String>(transmission.value);
    }
    if (drivetrain.present) {
      map['drivetrain'] = Variable<String>(drivetrain.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesTableCompanion(')
          ..write('id: $id, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('itemType: $itemType, ')
          ..write('identifier: $identifier, ')
          ..write('status: $status, ')
          ..write('purchasePriceCents: $purchasePriceCents, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('usageValue: $usageValue, ')
          ..write('usageUnit: $usageUnit, ')
          ..write('color: $color, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('photoIds: $photoIds, ')
          ..write('trim: $trim, ')
          ..write('engine: $engine, ')
          ..write('transmission: $transmission, ')
          ..write('drivetrain: $drivetrain, ')
          ..write('ownerId: $ownerId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PartsTableTable extends PartsTable
    with TableInfo<$PartsTableTable, PartRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vehicleIdMeta =
      const VerificationMeta('vehicleId');
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
      'vehicle_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _partNumberMeta =
      const VerificationMeta('partNumber');
  @override
  late final GeneratedColumn<String> partNumber = GeneratedColumn<String>(
      'part_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
      'qty', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _askingPriceCentsMeta =
      const VerificationMeta('askingPriceCents');
  @override
  late final GeneratedColumn<int> askingPriceCents = GeneratedColumn<int>(
      'asking_price_cents', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _salePriceCentsMeta =
      const VerificationMeta('salePriceCents');
  @override
  late final GeneratedColumn<int> salePriceCents = GeneratedColumn<int>(
      'sale_price_cents', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _stockIdMeta =
      const VerificationMeta('stockId');
  @override
  late final GeneratedColumn<String> stockId = GeneratedColumn<String>(
      'stock_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _partConditionMeta =
      const VerificationMeta('partCondition');
  @override
  late final GeneratedColumn<String> partCondition = GeneratedColumn<String>(
      'part_condition', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
      'side', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateListedMeta =
      const VerificationMeta('dateListed');
  @override
  late final GeneratedColumn<int> dateListed = GeneratedColumn<int>(
      'date_listed', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dateSoldMeta =
      const VerificationMeta('dateSold');
  @override
  late final GeneratedColumn<int> dateSold = GeneratedColumn<int>(
      'date_sold', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _photoIdsMeta =
      const VerificationMeta('photoIds');
  @override
  late final GeneratedColumn<String> photoIds = GeneratedColumn<String>(
      'photo_ids', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _vehicleMakeMeta =
      const VerificationMeta('vehicleMake');
  @override
  late final GeneratedColumn<String> vehicleMake = GeneratedColumn<String>(
      'vehicle_make', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vehicleModelMeta =
      const VerificationMeta('vehicleModel');
  @override
  late final GeneratedColumn<String> vehicleModel = GeneratedColumn<String>(
      'vehicle_model', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vehicleYearMeta =
      const VerificationMeta('vehicleYear');
  @override
  late final GeneratedColumn<int> vehicleYear = GeneratedColumn<int>(
      'vehicle_year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _vehicleTrimMeta =
      const VerificationMeta('vehicleTrim');
  @override
  late final GeneratedColumn<String> vehicleTrim = GeneratedColumn<String>(
      'vehicle_trim', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vehicleEngineMeta =
      const VerificationMeta('vehicleEngine');
  @override
  late final GeneratedColumn<String> vehicleEngine = GeneratedColumn<String>(
      'vehicle_engine', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vehicleTransmissionMeta =
      const VerificationMeta('vehicleTransmission');
  @override
  late final GeneratedColumn<String> vehicleTransmission =
      GeneratedColumn<String>('vehicle_transmission', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vehicleDrivetrainMeta =
      const VerificationMeta('vehicleDrivetrain');
  @override
  late final GeneratedColumn<String> vehicleDrivetrain =
      GeneratedColumn<String>('vehicle_drivetrain', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vehicleUsageValueMeta =
      const VerificationMeta('vehicleUsageValue');
  @override
  late final GeneratedColumn<int> vehicleUsageValue = GeneratedColumn<int>(
      'vehicle_usage_value', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _vehicleUsageUnitMeta =
      const VerificationMeta('vehicleUsageUnit');
  @override
  late final GeneratedColumn<String> vehicleUsageUnit = GeneratedColumn<String>(
      'vehicle_usage_unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _interchangeGroupIdMeta =
      const VerificationMeta('interchangeGroupId');
  @override
  late final GeneratedColumn<String> interchangeGroupId =
      GeneratedColumn<String>('interchange_group_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        vehicleId,
        name,
        state,
        location,
        notes,
        partNumber,
        qty,
        askingPriceCents,
        salePriceCents,
        stockId,
        category,
        partCondition,
        side,
        dateListed,
        dateSold,
        createdAt,
        updatedAt,
        photoIds,
        vehicleMake,
        vehicleModel,
        vehicleYear,
        vehicleTrim,
        vehicleEngine,
        vehicleTransmission,
        vehicleDrivetrain,
        vehicleUsageValue,
        vehicleUsageUnit,
        ownerId,
        deletedAt,
        interchangeGroupId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parts';
  @override
  VerificationContext validateIntegrity(Insertable<PartRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(_vehicleIdMeta,
          vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta));
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('part_number')) {
      context.handle(
          _partNumberMeta,
          partNumber.isAcceptableOrUnknown(
              data['part_number']!, _partNumberMeta));
    }
    if (data.containsKey('qty')) {
      context.handle(
          _qtyMeta, qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta));
    }
    if (data.containsKey('asking_price_cents')) {
      context.handle(
          _askingPriceCentsMeta,
          askingPriceCents.isAcceptableOrUnknown(
              data['asking_price_cents']!, _askingPriceCentsMeta));
    }
    if (data.containsKey('sale_price_cents')) {
      context.handle(
          _salePriceCentsMeta,
          salePriceCents.isAcceptableOrUnknown(
              data['sale_price_cents']!, _salePriceCentsMeta));
    }
    if (data.containsKey('stock_id')) {
      context.handle(_stockIdMeta,
          stockId.isAcceptableOrUnknown(data['stock_id']!, _stockIdMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('part_condition')) {
      context.handle(
          _partConditionMeta,
          partCondition.isAcceptableOrUnknown(
              data['part_condition']!, _partConditionMeta));
    }
    if (data.containsKey('side')) {
      context.handle(
          _sideMeta, side.isAcceptableOrUnknown(data['side']!, _sideMeta));
    }
    if (data.containsKey('date_listed')) {
      context.handle(
          _dateListedMeta,
          dateListed.isAcceptableOrUnknown(
              data['date_listed']!, _dateListedMeta));
    }
    if (data.containsKey('date_sold')) {
      context.handle(_dateSoldMeta,
          dateSold.isAcceptableOrUnknown(data['date_sold']!, _dateSoldMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('photo_ids')) {
      context.handle(_photoIdsMeta,
          photoIds.isAcceptableOrUnknown(data['photo_ids']!, _photoIdsMeta));
    }
    if (data.containsKey('vehicle_make')) {
      context.handle(
          _vehicleMakeMeta,
          vehicleMake.isAcceptableOrUnknown(
              data['vehicle_make']!, _vehicleMakeMeta));
    }
    if (data.containsKey('vehicle_model')) {
      context.handle(
          _vehicleModelMeta,
          vehicleModel.isAcceptableOrUnknown(
              data['vehicle_model']!, _vehicleModelMeta));
    }
    if (data.containsKey('vehicle_year')) {
      context.handle(
          _vehicleYearMeta,
          vehicleYear.isAcceptableOrUnknown(
              data['vehicle_year']!, _vehicleYearMeta));
    }
    if (data.containsKey('vehicle_trim')) {
      context.handle(
          _vehicleTrimMeta,
          vehicleTrim.isAcceptableOrUnknown(
              data['vehicle_trim']!, _vehicleTrimMeta));
    }
    if (data.containsKey('vehicle_engine')) {
      context.handle(
          _vehicleEngineMeta,
          vehicleEngine.isAcceptableOrUnknown(
              data['vehicle_engine']!, _vehicleEngineMeta));
    }
    if (data.containsKey('vehicle_transmission')) {
      context.handle(
          _vehicleTransmissionMeta,
          vehicleTransmission.isAcceptableOrUnknown(
              data['vehicle_transmission']!, _vehicleTransmissionMeta));
    }
    if (data.containsKey('vehicle_drivetrain')) {
      context.handle(
          _vehicleDrivetrainMeta,
          vehicleDrivetrain.isAcceptableOrUnknown(
              data['vehicle_drivetrain']!, _vehicleDrivetrainMeta));
    }
    if (data.containsKey('vehicle_usage_value')) {
      context.handle(
          _vehicleUsageValueMeta,
          vehicleUsageValue.isAcceptableOrUnknown(
              data['vehicle_usage_value']!, _vehicleUsageValueMeta));
    }
    if (data.containsKey('vehicle_usage_unit')) {
      context.handle(
          _vehicleUsageUnitMeta,
          vehicleUsageUnit.isAcceptableOrUnknown(
              data['vehicle_usage_unit']!, _vehicleUsageUnitMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('interchange_group_id')) {
      context.handle(
          _interchangeGroupIdMeta,
          interchangeGroupId.isAcceptableOrUnknown(
              data['interchange_group_id']!, _interchangeGroupIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PartRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      vehicleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vehicle_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      partNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}part_number']),
      qty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}qty'])!,
      askingPriceCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}asking_price_cents']),
      salePriceCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sale_price_cents']),
      stockId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stock_id']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      partCondition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}part_condition']),
      side: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}side']),
      dateListed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}date_listed']),
      dateSold: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}date_sold']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at']),
      photoIds: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_ids'])!,
      vehicleMake: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vehicle_make']),
      vehicleModel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vehicle_model']),
      vehicleYear: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vehicle_year']),
      vehicleTrim: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vehicle_trim']),
      vehicleEngine: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vehicle_engine']),
      vehicleTransmission: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}vehicle_transmission']),
      vehicleDrivetrain: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}vehicle_drivetrain']),
      vehicleUsageValue: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}vehicle_usage_value']),
      vehicleUsageUnit: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}vehicle_usage_unit']),
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
      interchangeGroupId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}interchange_group_id']),
    );
  }

  @override
  $PartsTableTable createAlias(String alias) {
    return $PartsTableTable(attachedDatabase, alias);
  }
}

class PartRow extends DataClass implements Insertable<PartRow> {
  final String id;
  final String vehicleId;
  final String name;
  final String state;
  final String? location;
  final String? notes;
  final String? partNumber;
  final int qty;
  final int? askingPriceCents;
  final int? salePriceCents;
  final String? stockId;
  final String? category;
  final String? partCondition;
  final String? side;
  final int? dateListed;
  final int? dateSold;
  final int createdAt;
  final int? updatedAt;
  final String photoIds;
  final String? vehicleMake;
  final String? vehicleModel;
  final int? vehicleYear;
  final String? vehicleTrim;
  final String? vehicleEngine;
  final String? vehicleTransmission;
  final String? vehicleDrivetrain;
  final int? vehicleUsageValue;
  final String? vehicleUsageUnit;
  final String? ownerId;
  final int? deletedAt;
  final String? interchangeGroupId;
  const PartRow(
      {required this.id,
      required this.vehicleId,
      required this.name,
      required this.state,
      this.location,
      this.notes,
      this.partNumber,
      required this.qty,
      this.askingPriceCents,
      this.salePriceCents,
      this.stockId,
      this.category,
      this.partCondition,
      this.side,
      this.dateListed,
      this.dateSold,
      required this.createdAt,
      this.updatedAt,
      required this.photoIds,
      this.vehicleMake,
      this.vehicleModel,
      this.vehicleYear,
      this.vehicleTrim,
      this.vehicleEngine,
      this.vehicleTransmission,
      this.vehicleDrivetrain,
      this.vehicleUsageValue,
      this.vehicleUsageUnit,
      this.ownerId,
      this.deletedAt,
      this.interchangeGroupId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['name'] = Variable<String>(name);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || partNumber != null) {
      map['part_number'] = Variable<String>(partNumber);
    }
    map['qty'] = Variable<int>(qty);
    if (!nullToAbsent || askingPriceCents != null) {
      map['asking_price_cents'] = Variable<int>(askingPriceCents);
    }
    if (!nullToAbsent || salePriceCents != null) {
      map['sale_price_cents'] = Variable<int>(salePriceCents);
    }
    if (!nullToAbsent || stockId != null) {
      map['stock_id'] = Variable<String>(stockId);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || partCondition != null) {
      map['part_condition'] = Variable<String>(partCondition);
    }
    if (!nullToAbsent || side != null) {
      map['side'] = Variable<String>(side);
    }
    if (!nullToAbsent || dateListed != null) {
      map['date_listed'] = Variable<int>(dateListed);
    }
    if (!nullToAbsent || dateSold != null) {
      map['date_sold'] = Variable<int>(dateSold);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    map['photo_ids'] = Variable<String>(photoIds);
    if (!nullToAbsent || vehicleMake != null) {
      map['vehicle_make'] = Variable<String>(vehicleMake);
    }
    if (!nullToAbsent || vehicleModel != null) {
      map['vehicle_model'] = Variable<String>(vehicleModel);
    }
    if (!nullToAbsent || vehicleYear != null) {
      map['vehicle_year'] = Variable<int>(vehicleYear);
    }
    if (!nullToAbsent || vehicleTrim != null) {
      map['vehicle_trim'] = Variable<String>(vehicleTrim);
    }
    if (!nullToAbsent || vehicleEngine != null) {
      map['vehicle_engine'] = Variable<String>(vehicleEngine);
    }
    if (!nullToAbsent || vehicleTransmission != null) {
      map['vehicle_transmission'] = Variable<String>(vehicleTransmission);
    }
    if (!nullToAbsent || vehicleDrivetrain != null) {
      map['vehicle_drivetrain'] = Variable<String>(vehicleDrivetrain);
    }
    if (!nullToAbsent || vehicleUsageValue != null) {
      map['vehicle_usage_value'] = Variable<int>(vehicleUsageValue);
    }
    if (!nullToAbsent || vehicleUsageUnit != null) {
      map['vehicle_usage_unit'] = Variable<String>(vehicleUsageUnit);
    }
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    if (!nullToAbsent || interchangeGroupId != null) {
      map['interchange_group_id'] = Variable<String>(interchangeGroupId);
    }
    return map;
  }

  PartsTableCompanion toCompanion(bool nullToAbsent) {
    return PartsTableCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      name: Value(name),
      state: Value(state),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      partNumber: partNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(partNumber),
      qty: Value(qty),
      askingPriceCents: askingPriceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(askingPriceCents),
      salePriceCents: salePriceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(salePriceCents),
      stockId: stockId == null && nullToAbsent
          ? const Value.absent()
          : Value(stockId),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      partCondition: partCondition == null && nullToAbsent
          ? const Value.absent()
          : Value(partCondition),
      side: side == null && nullToAbsent ? const Value.absent() : Value(side),
      dateListed: dateListed == null && nullToAbsent
          ? const Value.absent()
          : Value(dateListed),
      dateSold: dateSold == null && nullToAbsent
          ? const Value.absent()
          : Value(dateSold),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      photoIds: Value(photoIds),
      vehicleMake: vehicleMake == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleMake),
      vehicleModel: vehicleModel == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleModel),
      vehicleYear: vehicleYear == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleYear),
      vehicleTrim: vehicleTrim == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleTrim),
      vehicleEngine: vehicleEngine == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleEngine),
      vehicleTransmission: vehicleTransmission == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleTransmission),
      vehicleDrivetrain: vehicleDrivetrain == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleDrivetrain),
      vehicleUsageValue: vehicleUsageValue == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleUsageValue),
      vehicleUsageUnit: vehicleUsageUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleUsageUnit),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      interchangeGroupId: interchangeGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(interchangeGroupId),
    );
  }

  factory PartRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartRow(
      id: serializer.fromJson<String>(json['id']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      name: serializer.fromJson<String>(json['name']),
      state: serializer.fromJson<String>(json['state']),
      location: serializer.fromJson<String?>(json['location']),
      notes: serializer.fromJson<String?>(json['notes']),
      partNumber: serializer.fromJson<String?>(json['partNumber']),
      qty: serializer.fromJson<int>(json['qty']),
      askingPriceCents: serializer.fromJson<int?>(json['askingPriceCents']),
      salePriceCents: serializer.fromJson<int?>(json['salePriceCents']),
      stockId: serializer.fromJson<String?>(json['stockId']),
      category: serializer.fromJson<String?>(json['category']),
      partCondition: serializer.fromJson<String?>(json['partCondition']),
      side: serializer.fromJson<String?>(json['side']),
      dateListed: serializer.fromJson<int?>(json['dateListed']),
      dateSold: serializer.fromJson<int?>(json['dateSold']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
      photoIds: serializer.fromJson<String>(json['photoIds']),
      vehicleMake: serializer.fromJson<String?>(json['vehicleMake']),
      vehicleModel: serializer.fromJson<String?>(json['vehicleModel']),
      vehicleYear: serializer.fromJson<int?>(json['vehicleYear']),
      vehicleTrim: serializer.fromJson<String?>(json['vehicleTrim']),
      vehicleEngine: serializer.fromJson<String?>(json['vehicleEngine']),
      vehicleTransmission:
          serializer.fromJson<String?>(json['vehicleTransmission']),
      vehicleDrivetrain:
          serializer.fromJson<String?>(json['vehicleDrivetrain']),
      vehicleUsageValue: serializer.fromJson<int?>(json['vehicleUsageValue']),
      vehicleUsageUnit: serializer.fromJson<String?>(json['vehicleUsageUnit']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      interchangeGroupId:
          serializer.fromJson<String?>(json['interchangeGroupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'name': serializer.toJson<String>(name),
      'state': serializer.toJson<String>(state),
      'location': serializer.toJson<String?>(location),
      'notes': serializer.toJson<String?>(notes),
      'partNumber': serializer.toJson<String?>(partNumber),
      'qty': serializer.toJson<int>(qty),
      'askingPriceCents': serializer.toJson<int?>(askingPriceCents),
      'salePriceCents': serializer.toJson<int?>(salePriceCents),
      'stockId': serializer.toJson<String?>(stockId),
      'category': serializer.toJson<String?>(category),
      'partCondition': serializer.toJson<String?>(partCondition),
      'side': serializer.toJson<String?>(side),
      'dateListed': serializer.toJson<int?>(dateListed),
      'dateSold': serializer.toJson<int?>(dateSold),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int?>(updatedAt),
      'photoIds': serializer.toJson<String>(photoIds),
      'vehicleMake': serializer.toJson<String?>(vehicleMake),
      'vehicleModel': serializer.toJson<String?>(vehicleModel),
      'vehicleYear': serializer.toJson<int?>(vehicleYear),
      'vehicleTrim': serializer.toJson<String?>(vehicleTrim),
      'vehicleEngine': serializer.toJson<String?>(vehicleEngine),
      'vehicleTransmission': serializer.toJson<String?>(vehicleTransmission),
      'vehicleDrivetrain': serializer.toJson<String?>(vehicleDrivetrain),
      'vehicleUsageValue': serializer.toJson<int?>(vehicleUsageValue),
      'vehicleUsageUnit': serializer.toJson<String?>(vehicleUsageUnit),
      'ownerId': serializer.toJson<String?>(ownerId),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'interchangeGroupId': serializer.toJson<String?>(interchangeGroupId),
    };
  }

  PartRow copyWith(
          {String? id,
          String? vehicleId,
          String? name,
          String? state,
          Value<String?> location = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<String?> partNumber = const Value.absent(),
          int? qty,
          Value<int?> askingPriceCents = const Value.absent(),
          Value<int?> salePriceCents = const Value.absent(),
          Value<String?> stockId = const Value.absent(),
          Value<String?> category = const Value.absent(),
          Value<String?> partCondition = const Value.absent(),
          Value<String?> side = const Value.absent(),
          Value<int?> dateListed = const Value.absent(),
          Value<int?> dateSold = const Value.absent(),
          int? createdAt,
          Value<int?> updatedAt = const Value.absent(),
          String? photoIds,
          Value<String?> vehicleMake = const Value.absent(),
          Value<String?> vehicleModel = const Value.absent(),
          Value<int?> vehicleYear = const Value.absent(),
          Value<String?> vehicleTrim = const Value.absent(),
          Value<String?> vehicleEngine = const Value.absent(),
          Value<String?> vehicleTransmission = const Value.absent(),
          Value<String?> vehicleDrivetrain = const Value.absent(),
          Value<int?> vehicleUsageValue = const Value.absent(),
          Value<String?> vehicleUsageUnit = const Value.absent(),
          Value<String?> ownerId = const Value.absent(),
          Value<int?> deletedAt = const Value.absent(),
          Value<String?> interchangeGroupId = const Value.absent()}) =>
      PartRow(
        id: id ?? this.id,
        vehicleId: vehicleId ?? this.vehicleId,
        name: name ?? this.name,
        state: state ?? this.state,
        location: location.present ? location.value : this.location,
        notes: notes.present ? notes.value : this.notes,
        partNumber: partNumber.present ? partNumber.value : this.partNumber,
        qty: qty ?? this.qty,
        askingPriceCents: askingPriceCents.present
            ? askingPriceCents.value
            : this.askingPriceCents,
        salePriceCents:
            salePriceCents.present ? salePriceCents.value : this.salePriceCents,
        stockId: stockId.present ? stockId.value : this.stockId,
        category: category.present ? category.value : this.category,
        partCondition:
            partCondition.present ? partCondition.value : this.partCondition,
        side: side.present ? side.value : this.side,
        dateListed: dateListed.present ? dateListed.value : this.dateListed,
        dateSold: dateSold.present ? dateSold.value : this.dateSold,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        photoIds: photoIds ?? this.photoIds,
        vehicleMake: vehicleMake.present ? vehicleMake.value : this.vehicleMake,
        vehicleModel:
            vehicleModel.present ? vehicleModel.value : this.vehicleModel,
        vehicleYear: vehicleYear.present ? vehicleYear.value : this.vehicleYear,
        vehicleTrim: vehicleTrim.present ? vehicleTrim.value : this.vehicleTrim,
        vehicleEngine:
            vehicleEngine.present ? vehicleEngine.value : this.vehicleEngine,
        vehicleTransmission: vehicleTransmission.present
            ? vehicleTransmission.value
            : this.vehicleTransmission,
        vehicleDrivetrain: vehicleDrivetrain.present
            ? vehicleDrivetrain.value
            : this.vehicleDrivetrain,
        vehicleUsageValue: vehicleUsageValue.present
            ? vehicleUsageValue.value
            : this.vehicleUsageValue,
        vehicleUsageUnit: vehicleUsageUnit.present
            ? vehicleUsageUnit.value
            : this.vehicleUsageUnit,
        ownerId: ownerId.present ? ownerId.value : this.ownerId,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        interchangeGroupId: interchangeGroupId.present
            ? interchangeGroupId.value
            : this.interchangeGroupId,
      );
  PartRow copyWithCompanion(PartsTableCompanion data) {
    return PartRow(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      name: data.name.present ? data.name.value : this.name,
      state: data.state.present ? data.state.value : this.state,
      location: data.location.present ? data.location.value : this.location,
      notes: data.notes.present ? data.notes.value : this.notes,
      partNumber:
          data.partNumber.present ? data.partNumber.value : this.partNumber,
      qty: data.qty.present ? data.qty.value : this.qty,
      askingPriceCents: data.askingPriceCents.present
          ? data.askingPriceCents.value
          : this.askingPriceCents,
      salePriceCents: data.salePriceCents.present
          ? data.salePriceCents.value
          : this.salePriceCents,
      stockId: data.stockId.present ? data.stockId.value : this.stockId,
      category: data.category.present ? data.category.value : this.category,
      partCondition: data.partCondition.present
          ? data.partCondition.value
          : this.partCondition,
      side: data.side.present ? data.side.value : this.side,
      dateListed:
          data.dateListed.present ? data.dateListed.value : this.dateListed,
      dateSold: data.dateSold.present ? data.dateSold.value : this.dateSold,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      photoIds: data.photoIds.present ? data.photoIds.value : this.photoIds,
      vehicleMake:
          data.vehicleMake.present ? data.vehicleMake.value : this.vehicleMake,
      vehicleModel: data.vehicleModel.present
          ? data.vehicleModel.value
          : this.vehicleModel,
      vehicleYear:
          data.vehicleYear.present ? data.vehicleYear.value : this.vehicleYear,
      vehicleTrim:
          data.vehicleTrim.present ? data.vehicleTrim.value : this.vehicleTrim,
      vehicleEngine: data.vehicleEngine.present
          ? data.vehicleEngine.value
          : this.vehicleEngine,
      vehicleTransmission: data.vehicleTransmission.present
          ? data.vehicleTransmission.value
          : this.vehicleTransmission,
      vehicleDrivetrain: data.vehicleDrivetrain.present
          ? data.vehicleDrivetrain.value
          : this.vehicleDrivetrain,
      vehicleUsageValue: data.vehicleUsageValue.present
          ? data.vehicleUsageValue.value
          : this.vehicleUsageValue,
      vehicleUsageUnit: data.vehicleUsageUnit.present
          ? data.vehicleUsageUnit.value
          : this.vehicleUsageUnit,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      interchangeGroupId: data.interchangeGroupId.present
          ? data.interchangeGroupId.value
          : this.interchangeGroupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartRow(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('name: $name, ')
          ..write('state: $state, ')
          ..write('location: $location, ')
          ..write('notes: $notes, ')
          ..write('partNumber: $partNumber, ')
          ..write('qty: $qty, ')
          ..write('askingPriceCents: $askingPriceCents, ')
          ..write('salePriceCents: $salePriceCents, ')
          ..write('stockId: $stockId, ')
          ..write('category: $category, ')
          ..write('partCondition: $partCondition, ')
          ..write('side: $side, ')
          ..write('dateListed: $dateListed, ')
          ..write('dateSold: $dateSold, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('photoIds: $photoIds, ')
          ..write('vehicleMake: $vehicleMake, ')
          ..write('vehicleModel: $vehicleModel, ')
          ..write('vehicleYear: $vehicleYear, ')
          ..write('vehicleTrim: $vehicleTrim, ')
          ..write('vehicleEngine: $vehicleEngine, ')
          ..write('vehicleTransmission: $vehicleTransmission, ')
          ..write('vehicleDrivetrain: $vehicleDrivetrain, ')
          ..write('vehicleUsageValue: $vehicleUsageValue, ')
          ..write('vehicleUsageUnit: $vehicleUsageUnit, ')
          ..write('ownerId: $ownerId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('interchangeGroupId: $interchangeGroupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        vehicleId,
        name,
        state,
        location,
        notes,
        partNumber,
        qty,
        askingPriceCents,
        salePriceCents,
        stockId,
        category,
        partCondition,
        side,
        dateListed,
        dateSold,
        createdAt,
        updatedAt,
        photoIds,
        vehicleMake,
        vehicleModel,
        vehicleYear,
        vehicleTrim,
        vehicleEngine,
        vehicleTransmission,
        vehicleDrivetrain,
        vehicleUsageValue,
        vehicleUsageUnit,
        ownerId,
        deletedAt,
        interchangeGroupId
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartRow &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.name == this.name &&
          other.state == this.state &&
          other.location == this.location &&
          other.notes == this.notes &&
          other.partNumber == this.partNumber &&
          other.qty == this.qty &&
          other.askingPriceCents == this.askingPriceCents &&
          other.salePriceCents == this.salePriceCents &&
          other.stockId == this.stockId &&
          other.category == this.category &&
          other.partCondition == this.partCondition &&
          other.side == this.side &&
          other.dateListed == this.dateListed &&
          other.dateSold == this.dateSold &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.photoIds == this.photoIds &&
          other.vehicleMake == this.vehicleMake &&
          other.vehicleModel == this.vehicleModel &&
          other.vehicleYear == this.vehicleYear &&
          other.vehicleTrim == this.vehicleTrim &&
          other.vehicleEngine == this.vehicleEngine &&
          other.vehicleTransmission == this.vehicleTransmission &&
          other.vehicleDrivetrain == this.vehicleDrivetrain &&
          other.vehicleUsageValue == this.vehicleUsageValue &&
          other.vehicleUsageUnit == this.vehicleUsageUnit &&
          other.ownerId == this.ownerId &&
          other.deletedAt == this.deletedAt &&
          other.interchangeGroupId == this.interchangeGroupId);
}

class PartsTableCompanion extends UpdateCompanion<PartRow> {
  final Value<String> id;
  final Value<String> vehicleId;
  final Value<String> name;
  final Value<String> state;
  final Value<String?> location;
  final Value<String?> notes;
  final Value<String?> partNumber;
  final Value<int> qty;
  final Value<int?> askingPriceCents;
  final Value<int?> salePriceCents;
  final Value<String?> stockId;
  final Value<String?> category;
  final Value<String?> partCondition;
  final Value<String?> side;
  final Value<int?> dateListed;
  final Value<int?> dateSold;
  final Value<int> createdAt;
  final Value<int?> updatedAt;
  final Value<String> photoIds;
  final Value<String?> vehicleMake;
  final Value<String?> vehicleModel;
  final Value<int?> vehicleYear;
  final Value<String?> vehicleTrim;
  final Value<String?> vehicleEngine;
  final Value<String?> vehicleTransmission;
  final Value<String?> vehicleDrivetrain;
  final Value<int?> vehicleUsageValue;
  final Value<String?> vehicleUsageUnit;
  final Value<String?> ownerId;
  final Value<int?> deletedAt;
  final Value<String?> interchangeGroupId;
  final Value<int> rowid;
  const PartsTableCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.name = const Value.absent(),
    this.state = const Value.absent(),
    this.location = const Value.absent(),
    this.notes = const Value.absent(),
    this.partNumber = const Value.absent(),
    this.qty = const Value.absent(),
    this.askingPriceCents = const Value.absent(),
    this.salePriceCents = const Value.absent(),
    this.stockId = const Value.absent(),
    this.category = const Value.absent(),
    this.partCondition = const Value.absent(),
    this.side = const Value.absent(),
    this.dateListed = const Value.absent(),
    this.dateSold = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.photoIds = const Value.absent(),
    this.vehicleMake = const Value.absent(),
    this.vehicleModel = const Value.absent(),
    this.vehicleYear = const Value.absent(),
    this.vehicleTrim = const Value.absent(),
    this.vehicleEngine = const Value.absent(),
    this.vehicleTransmission = const Value.absent(),
    this.vehicleDrivetrain = const Value.absent(),
    this.vehicleUsageValue = const Value.absent(),
    this.vehicleUsageUnit = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.interchangeGroupId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartsTableCompanion.insert({
    required String id,
    required String vehicleId,
    required String name,
    required String state,
    this.location = const Value.absent(),
    this.notes = const Value.absent(),
    this.partNumber = const Value.absent(),
    this.qty = const Value.absent(),
    this.askingPriceCents = const Value.absent(),
    this.salePriceCents = const Value.absent(),
    this.stockId = const Value.absent(),
    this.category = const Value.absent(),
    this.partCondition = const Value.absent(),
    this.side = const Value.absent(),
    this.dateListed = const Value.absent(),
    this.dateSold = const Value.absent(),
    required int createdAt,
    this.updatedAt = const Value.absent(),
    this.photoIds = const Value.absent(),
    this.vehicleMake = const Value.absent(),
    this.vehicleModel = const Value.absent(),
    this.vehicleYear = const Value.absent(),
    this.vehicleTrim = const Value.absent(),
    this.vehicleEngine = const Value.absent(),
    this.vehicleTransmission = const Value.absent(),
    this.vehicleDrivetrain = const Value.absent(),
    this.vehicleUsageValue = const Value.absent(),
    this.vehicleUsageUnit = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.interchangeGroupId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        vehicleId = Value(vehicleId),
        name = Value(name),
        state = Value(state),
        createdAt = Value(createdAt);
  static Insertable<PartRow> custom({
    Expression<String>? id,
    Expression<String>? vehicleId,
    Expression<String>? name,
    Expression<String>? state,
    Expression<String>? location,
    Expression<String>? notes,
    Expression<String>? partNumber,
    Expression<int>? qty,
    Expression<int>? askingPriceCents,
    Expression<int>? salePriceCents,
    Expression<String>? stockId,
    Expression<String>? category,
    Expression<String>? partCondition,
    Expression<String>? side,
    Expression<int>? dateListed,
    Expression<int>? dateSold,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? photoIds,
    Expression<String>? vehicleMake,
    Expression<String>? vehicleModel,
    Expression<int>? vehicleYear,
    Expression<String>? vehicleTrim,
    Expression<String>? vehicleEngine,
    Expression<String>? vehicleTransmission,
    Expression<String>? vehicleDrivetrain,
    Expression<int>? vehicleUsageValue,
    Expression<String>? vehicleUsageUnit,
    Expression<String>? ownerId,
    Expression<int>? deletedAt,
    Expression<String>? interchangeGroupId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (name != null) 'name': name,
      if (state != null) 'state': state,
      if (location != null) 'location': location,
      if (notes != null) 'notes': notes,
      if (partNumber != null) 'part_number': partNumber,
      if (qty != null) 'qty': qty,
      if (askingPriceCents != null) 'asking_price_cents': askingPriceCents,
      if (salePriceCents != null) 'sale_price_cents': salePriceCents,
      if (stockId != null) 'stock_id': stockId,
      if (category != null) 'category': category,
      if (partCondition != null) 'part_condition': partCondition,
      if (side != null) 'side': side,
      if (dateListed != null) 'date_listed': dateListed,
      if (dateSold != null) 'date_sold': dateSold,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (photoIds != null) 'photo_ids': photoIds,
      if (vehicleMake != null) 'vehicle_make': vehicleMake,
      if (vehicleModel != null) 'vehicle_model': vehicleModel,
      if (vehicleYear != null) 'vehicle_year': vehicleYear,
      if (vehicleTrim != null) 'vehicle_trim': vehicleTrim,
      if (vehicleEngine != null) 'vehicle_engine': vehicleEngine,
      if (vehicleTransmission != null)
        'vehicle_transmission': vehicleTransmission,
      if (vehicleDrivetrain != null) 'vehicle_drivetrain': vehicleDrivetrain,
      if (vehicleUsageValue != null) 'vehicle_usage_value': vehicleUsageValue,
      if (vehicleUsageUnit != null) 'vehicle_usage_unit': vehicleUsageUnit,
      if (ownerId != null) 'owner_id': ownerId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (interchangeGroupId != null)
        'interchange_group_id': interchangeGroupId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? vehicleId,
      Value<String>? name,
      Value<String>? state,
      Value<String?>? location,
      Value<String?>? notes,
      Value<String?>? partNumber,
      Value<int>? qty,
      Value<int?>? askingPriceCents,
      Value<int?>? salePriceCents,
      Value<String?>? stockId,
      Value<String?>? category,
      Value<String?>? partCondition,
      Value<String?>? side,
      Value<int?>? dateListed,
      Value<int?>? dateSold,
      Value<int>? createdAt,
      Value<int?>? updatedAt,
      Value<String>? photoIds,
      Value<String?>? vehicleMake,
      Value<String?>? vehicleModel,
      Value<int?>? vehicleYear,
      Value<String?>? vehicleTrim,
      Value<String?>? vehicleEngine,
      Value<String?>? vehicleTransmission,
      Value<String?>? vehicleDrivetrain,
      Value<int?>? vehicleUsageValue,
      Value<String?>? vehicleUsageUnit,
      Value<String?>? ownerId,
      Value<int?>? deletedAt,
      Value<String?>? interchangeGroupId,
      Value<int>? rowid}) {
    return PartsTableCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      name: name ?? this.name,
      state: state ?? this.state,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      partNumber: partNumber ?? this.partNumber,
      qty: qty ?? this.qty,
      askingPriceCents: askingPriceCents ?? this.askingPriceCents,
      salePriceCents: salePriceCents ?? this.salePriceCents,
      stockId: stockId ?? this.stockId,
      category: category ?? this.category,
      partCondition: partCondition ?? this.partCondition,
      side: side ?? this.side,
      dateListed: dateListed ?? this.dateListed,
      dateSold: dateSold ?? this.dateSold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      photoIds: photoIds ?? this.photoIds,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      vehicleTrim: vehicleTrim ?? this.vehicleTrim,
      vehicleEngine: vehicleEngine ?? this.vehicleEngine,
      vehicleTransmission: vehicleTransmission ?? this.vehicleTransmission,
      vehicleDrivetrain: vehicleDrivetrain ?? this.vehicleDrivetrain,
      vehicleUsageValue: vehicleUsageValue ?? this.vehicleUsageValue,
      vehicleUsageUnit: vehicleUsageUnit ?? this.vehicleUsageUnit,
      ownerId: ownerId ?? this.ownerId,
      deletedAt: deletedAt ?? this.deletedAt,
      interchangeGroupId: interchangeGroupId ?? this.interchangeGroupId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (partNumber.present) {
      map['part_number'] = Variable<String>(partNumber.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (askingPriceCents.present) {
      map['asking_price_cents'] = Variable<int>(askingPriceCents.value);
    }
    if (salePriceCents.present) {
      map['sale_price_cents'] = Variable<int>(salePriceCents.value);
    }
    if (stockId.present) {
      map['stock_id'] = Variable<String>(stockId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (partCondition.present) {
      map['part_condition'] = Variable<String>(partCondition.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (dateListed.present) {
      map['date_listed'] = Variable<int>(dateListed.value);
    }
    if (dateSold.present) {
      map['date_sold'] = Variable<int>(dateSold.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (photoIds.present) {
      map['photo_ids'] = Variable<String>(photoIds.value);
    }
    if (vehicleMake.present) {
      map['vehicle_make'] = Variable<String>(vehicleMake.value);
    }
    if (vehicleModel.present) {
      map['vehicle_model'] = Variable<String>(vehicleModel.value);
    }
    if (vehicleYear.present) {
      map['vehicle_year'] = Variable<int>(vehicleYear.value);
    }
    if (vehicleTrim.present) {
      map['vehicle_trim'] = Variable<String>(vehicleTrim.value);
    }
    if (vehicleEngine.present) {
      map['vehicle_engine'] = Variable<String>(vehicleEngine.value);
    }
    if (vehicleTransmission.present) {
      map['vehicle_transmission'] = Variable<String>(vehicleTransmission.value);
    }
    if (vehicleDrivetrain.present) {
      map['vehicle_drivetrain'] = Variable<String>(vehicleDrivetrain.value);
    }
    if (vehicleUsageValue.present) {
      map['vehicle_usage_value'] = Variable<int>(vehicleUsageValue.value);
    }
    if (vehicleUsageUnit.present) {
      map['vehicle_usage_unit'] = Variable<String>(vehicleUsageUnit.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (interchangeGroupId.present) {
      map['interchange_group_id'] = Variable<String>(interchangeGroupId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartsTableCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('name: $name, ')
          ..write('state: $state, ')
          ..write('location: $location, ')
          ..write('notes: $notes, ')
          ..write('partNumber: $partNumber, ')
          ..write('qty: $qty, ')
          ..write('askingPriceCents: $askingPriceCents, ')
          ..write('salePriceCents: $salePriceCents, ')
          ..write('stockId: $stockId, ')
          ..write('category: $category, ')
          ..write('partCondition: $partCondition, ')
          ..write('side: $side, ')
          ..write('dateListed: $dateListed, ')
          ..write('dateSold: $dateSold, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('photoIds: $photoIds, ')
          ..write('vehicleMake: $vehicleMake, ')
          ..write('vehicleModel: $vehicleModel, ')
          ..write('vehicleYear: $vehicleYear, ')
          ..write('vehicleTrim: $vehicleTrim, ')
          ..write('vehicleEngine: $vehicleEngine, ')
          ..write('vehicleTransmission: $vehicleTransmission, ')
          ..write('vehicleDrivetrain: $vehicleDrivetrain, ')
          ..write('vehicleUsageValue: $vehicleUsageValue, ')
          ..write('vehicleUsageUnit: $vehicleUsageUnit, ')
          ..write('ownerId: $ownerId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('interchangeGroupId: $interchangeGroupId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ListingsTableTable extends ListingsTable
    with TableInfo<$ListingsTableTable, ListingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _partIdMeta = const VerificationMeta('partId');
  @override
  late final GeneratedColumn<String> partId = GeneratedColumn<String>(
      'part_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _platformMeta =
      const VerificationMeta('platform');
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
      'platform', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isLiveMeta = const VerificationMeta('isLive');
  @override
  late final GeneratedColumn<int> isLive = GeneratedColumn<int>(
      'is_live', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _listedPriceCentsMeta =
      const VerificationMeta('listedPriceCents');
  @override
  late final GeneratedColumn<int> listedPriceCents = GeneratedColumn<int>(
      'listed_price_cents', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        partId,
        platform,
        url,
        isLive,
        listedPriceCents,
        createdAt,
        ownerId,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'listings';
  @override
  VerificationContext validateIntegrity(Insertable<ListingRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('part_id')) {
      context.handle(_partIdMeta,
          partId.isAcceptableOrUnknown(data['part_id']!, _partIdMeta));
    } else if (isInserting) {
      context.missing(_partIdMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(_platformMeta,
          platform.isAcceptableOrUnknown(data['platform']!, _platformMeta));
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('is_live')) {
      context.handle(_isLiveMeta,
          isLive.isAcceptableOrUnknown(data['is_live']!, _isLiveMeta));
    }
    if (data.containsKey('listed_price_cents')) {
      context.handle(
          _listedPriceCentsMeta,
          listedPriceCents.isAcceptableOrUnknown(
              data['listed_price_cents']!, _listedPriceCentsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListingRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      partId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}part_id'])!,
      platform: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}platform'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      isLive: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_live'])!,
      listedPriceCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}listed_price_cents']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $ListingsTableTable createAlias(String alias) {
    return $ListingsTableTable(attachedDatabase, alias);
  }
}

class ListingRow extends DataClass implements Insertable<ListingRow> {
  final String id;
  final String partId;
  final String platform;
  final String url;
  final int isLive;
  final int? listedPriceCents;
  final int createdAt;
  final String? ownerId;
  final int? deletedAt;
  const ListingRow(
      {required this.id,
      required this.partId,
      required this.platform,
      required this.url,
      required this.isLive,
      this.listedPriceCents,
      required this.createdAt,
      this.ownerId,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['part_id'] = Variable<String>(partId);
    map['platform'] = Variable<String>(platform);
    map['url'] = Variable<String>(url);
    map['is_live'] = Variable<int>(isLive);
    if (!nullToAbsent || listedPriceCents != null) {
      map['listed_price_cents'] = Variable<int>(listedPriceCents);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  ListingsTableCompanion toCompanion(bool nullToAbsent) {
    return ListingsTableCompanion(
      id: Value(id),
      partId: Value(partId),
      platform: Value(platform),
      url: Value(url),
      isLive: Value(isLive),
      listedPriceCents: listedPriceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(listedPriceCents),
      createdAt: Value(createdAt),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ListingRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListingRow(
      id: serializer.fromJson<String>(json['id']),
      partId: serializer.fromJson<String>(json['partId']),
      platform: serializer.fromJson<String>(json['platform']),
      url: serializer.fromJson<String>(json['url']),
      isLive: serializer.fromJson<int>(json['isLive']),
      listedPriceCents: serializer.fromJson<int?>(json['listedPriceCents']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'partId': serializer.toJson<String>(partId),
      'platform': serializer.toJson<String>(platform),
      'url': serializer.toJson<String>(url),
      'isLive': serializer.toJson<int>(isLive),
      'listedPriceCents': serializer.toJson<int?>(listedPriceCents),
      'createdAt': serializer.toJson<int>(createdAt),
      'ownerId': serializer.toJson<String?>(ownerId),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  ListingRow copyWith(
          {String? id,
          String? partId,
          String? platform,
          String? url,
          int? isLive,
          Value<int?> listedPriceCents = const Value.absent(),
          int? createdAt,
          Value<String?> ownerId = const Value.absent(),
          Value<int?> deletedAt = const Value.absent()}) =>
      ListingRow(
        id: id ?? this.id,
        partId: partId ?? this.partId,
        platform: platform ?? this.platform,
        url: url ?? this.url,
        isLive: isLive ?? this.isLive,
        listedPriceCents: listedPriceCents.present
            ? listedPriceCents.value
            : this.listedPriceCents,
        createdAt: createdAt ?? this.createdAt,
        ownerId: ownerId.present ? ownerId.value : this.ownerId,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  ListingRow copyWithCompanion(ListingsTableCompanion data) {
    return ListingRow(
      id: data.id.present ? data.id.value : this.id,
      partId: data.partId.present ? data.partId.value : this.partId,
      platform: data.platform.present ? data.platform.value : this.platform,
      url: data.url.present ? data.url.value : this.url,
      isLive: data.isLive.present ? data.isLive.value : this.isLive,
      listedPriceCents: data.listedPriceCents.present
          ? data.listedPriceCents.value
          : this.listedPriceCents,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListingRow(')
          ..write('id: $id, ')
          ..write('partId: $partId, ')
          ..write('platform: $platform, ')
          ..write('url: $url, ')
          ..write('isLive: $isLive, ')
          ..write('listedPriceCents: $listedPriceCents, ')
          ..write('createdAt: $createdAt, ')
          ..write('ownerId: $ownerId, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, partId, platform, url, isLive,
      listedPriceCents, createdAt, ownerId, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListingRow &&
          other.id == this.id &&
          other.partId == this.partId &&
          other.platform == this.platform &&
          other.url == this.url &&
          other.isLive == this.isLive &&
          other.listedPriceCents == this.listedPriceCents &&
          other.createdAt == this.createdAt &&
          other.ownerId == this.ownerId &&
          other.deletedAt == this.deletedAt);
}

class ListingsTableCompanion extends UpdateCompanion<ListingRow> {
  final Value<String> id;
  final Value<String> partId;
  final Value<String> platform;
  final Value<String> url;
  final Value<int> isLive;
  final Value<int?> listedPriceCents;
  final Value<int> createdAt;
  final Value<String?> ownerId;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const ListingsTableCompanion({
    this.id = const Value.absent(),
    this.partId = const Value.absent(),
    this.platform = const Value.absent(),
    this.url = const Value.absent(),
    this.isLive = const Value.absent(),
    this.listedPriceCents = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ListingsTableCompanion.insert({
    required String id,
    required String partId,
    required String platform,
    required String url,
    this.isLive = const Value.absent(),
    this.listedPriceCents = const Value.absent(),
    required int createdAt,
    this.ownerId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        partId = Value(partId),
        platform = Value(platform),
        url = Value(url),
        createdAt = Value(createdAt);
  static Insertable<ListingRow> custom({
    Expression<String>? id,
    Expression<String>? partId,
    Expression<String>? platform,
    Expression<String>? url,
    Expression<int>? isLive,
    Expression<int>? listedPriceCents,
    Expression<int>? createdAt,
    Expression<String>? ownerId,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (partId != null) 'part_id': partId,
      if (platform != null) 'platform': platform,
      if (url != null) 'url': url,
      if (isLive != null) 'is_live': isLive,
      if (listedPriceCents != null) 'listed_price_cents': listedPriceCents,
      if (createdAt != null) 'created_at': createdAt,
      if (ownerId != null) 'owner_id': ownerId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ListingsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? partId,
      Value<String>? platform,
      Value<String>? url,
      Value<int>? isLive,
      Value<int?>? listedPriceCents,
      Value<int>? createdAt,
      Value<String?>? ownerId,
      Value<int?>? deletedAt,
      Value<int>? rowid}) {
    return ListingsTableCompanion(
      id: id ?? this.id,
      partId: partId ?? this.partId,
      platform: platform ?? this.platform,
      url: url ?? this.url,
      isLive: isLive ?? this.isLive,
      listedPriceCents: listedPriceCents ?? this.listedPriceCents,
      createdAt: createdAt ?? this.createdAt,
      ownerId: ownerId ?? this.ownerId,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (partId.present) {
      map['part_id'] = Variable<String>(partId.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (isLive.present) {
      map['is_live'] = Variable<int>(isLive.value);
    }
    if (listedPriceCents.present) {
      map['listed_price_cents'] = Variable<int>(listedPriceCents.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListingsTableCompanion(')
          ..write('id: $id, ')
          ..write('partId: $partId, ')
          ..write('platform: $platform, ')
          ..write('url: $url, ')
          ..write('isLive: $isLive, ')
          ..write('listedPriceCents: $listedPriceCents, ')
          ..write('createdAt: $createdAt, ')
          ..write('ownerId: $ownerId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InterchangeGroupsTableTable extends InterchangeGroupsTable
    with TableInfo<$InterchangeGroupsTableTable, InterchangeGroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InterchangeGroupsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _numbersMeta =
      const VerificationMeta('numbers');
  @override
  late final GeneratedColumn<String> numbers = GeneratedColumn<String>(
      'numbers', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, label, numbers, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'interchange_groups';
  @override
  VerificationContext validateIntegrity(
      Insertable<InterchangeGroupRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('numbers')) {
      context.handle(_numbersMeta,
          numbers.isAcceptableOrUnknown(data['numbers']!, _numbersMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InterchangeGroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InterchangeGroupRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      numbers: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}numbers'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $InterchangeGroupsTableTable createAlias(String alias) {
    return $InterchangeGroupsTableTable(attachedDatabase, alias);
  }
}

class InterchangeGroupRow extends DataClass
    implements Insertable<InterchangeGroupRow> {
  final String id;
  final String label;
  final String numbers;
  final int createdAt;
  final int? updatedAt;
  const InterchangeGroupRow(
      {required this.id,
      required this.label,
      required this.numbers,
      required this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['numbers'] = Variable<String>(numbers);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    return map;
  }

  InterchangeGroupsTableCompanion toCompanion(bool nullToAbsent) {
    return InterchangeGroupsTableCompanion(
      id: Value(id),
      label: Value(label),
      numbers: Value(numbers),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory InterchangeGroupRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InterchangeGroupRow(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      numbers: serializer.fromJson<String>(json['numbers']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'numbers': serializer.toJson<String>(numbers),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int?>(updatedAt),
    };
  }

  InterchangeGroupRow copyWith(
          {String? id,
          String? label,
          String? numbers,
          int? createdAt,
          Value<int?> updatedAt = const Value.absent()}) =>
      InterchangeGroupRow(
        id: id ?? this.id,
        label: label ?? this.label,
        numbers: numbers ?? this.numbers,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  InterchangeGroupRow copyWithCompanion(InterchangeGroupsTableCompanion data) {
    return InterchangeGroupRow(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      numbers: data.numbers.present ? data.numbers.value : this.numbers,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InterchangeGroupRow(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('numbers: $numbers, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, numbers, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InterchangeGroupRow &&
          other.id == this.id &&
          other.label == this.label &&
          other.numbers == this.numbers &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class InterchangeGroupsTableCompanion
    extends UpdateCompanion<InterchangeGroupRow> {
  final Value<String> id;
  final Value<String> label;
  final Value<String> numbers;
  final Value<int> createdAt;
  final Value<int?> updatedAt;
  final Value<int> rowid;
  const InterchangeGroupsTableCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.numbers = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InterchangeGroupsTableCompanion.insert({
    required String id,
    this.label = const Value.absent(),
    this.numbers = const Value.absent(),
    required int createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt);
  static Insertable<InterchangeGroupRow> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<String>? numbers,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (numbers != null) 'numbers': numbers,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InterchangeGroupsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? label,
      Value<String>? numbers,
      Value<int>? createdAt,
      Value<int?>? updatedAt,
      Value<int>? rowid}) {
    return InterchangeGroupsTableCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      numbers: numbers ?? this.numbers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (numbers.present) {
      map['numbers'] = Variable<String>(numbers.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InterchangeGroupsTableCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('numbers: $numbers, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VehiclesTableTable vehiclesTable = $VehiclesTableTable(this);
  late final $PartsTableTable partsTable = $PartsTableTable(this);
  late final $ListingsTableTable listingsTable = $ListingsTableTable(this);
  late final $InterchangeGroupsTableTable interchangeGroupsTable =
      $InterchangeGroupsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [vehiclesTable, partsTable, listingsTable, interchangeGroupsTable];
}

typedef $$VehiclesTableTableCreateCompanionBuilder = VehiclesTableCompanion
    Function({
  required String id,
  required String make,
  required String model,
  required int year,
  required String itemType,
  Value<String?> identifier,
  required String status,
  Value<int?> purchasePriceCents,
  required int acquiredAt,
  Value<int?> usageValue,
  Value<String> usageUnit,
  Value<String> color,
  Value<String?> notes,
  required int createdAt,
  Value<int?> updatedAt,
  Value<String> photoIds,
  Value<String?> trim,
  Value<String?> engine,
  Value<String?> transmission,
  Value<String?> drivetrain,
  Value<String?> ownerId,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$VehiclesTableTableUpdateCompanionBuilder = VehiclesTableCompanion
    Function({
  Value<String> id,
  Value<String> make,
  Value<String> model,
  Value<int> year,
  Value<String> itemType,
  Value<String?> identifier,
  Value<String> status,
  Value<int?> purchasePriceCents,
  Value<int> acquiredAt,
  Value<int?> usageValue,
  Value<String> usageUnit,
  Value<String> color,
  Value<String?> notes,
  Value<int> createdAt,
  Value<int?> updatedAt,
  Value<String> photoIds,
  Value<String?> trim,
  Value<String?> engine,
  Value<String?> transmission,
  Value<String?> drivetrain,
  Value<String?> ownerId,
  Value<int?> deletedAt,
  Value<int> rowid,
});

class $$VehiclesTableTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTableTable> {
  $$VehiclesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get make => $composableBuilder(
      column: $table.make, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemType => $composableBuilder(
      column: $table.itemType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get identifier => $composableBuilder(
      column: $table.identifier, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get purchasePriceCents => $composableBuilder(
      column: $table.purchasePriceCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get acquiredAt => $composableBuilder(
      column: $table.acquiredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get usageValue => $composableBuilder(
      column: $table.usageValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get usageUnit => $composableBuilder(
      column: $table.usageUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoIds => $composableBuilder(
      column: $table.photoIds, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trim => $composableBuilder(
      column: $table.trim, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get engine => $composableBuilder(
      column: $table.engine, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transmission => $composableBuilder(
      column: $table.transmission, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get drivetrain => $composableBuilder(
      column: $table.drivetrain, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$VehiclesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTableTable> {
  $$VehiclesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get make => $composableBuilder(
      column: $table.make, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemType => $composableBuilder(
      column: $table.itemType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get identifier => $composableBuilder(
      column: $table.identifier, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get purchasePriceCents => $composableBuilder(
      column: $table.purchasePriceCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get acquiredAt => $composableBuilder(
      column: $table.acquiredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get usageValue => $composableBuilder(
      column: $table.usageValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get usageUnit => $composableBuilder(
      column: $table.usageUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoIds => $composableBuilder(
      column: $table.photoIds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trim => $composableBuilder(
      column: $table.trim, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get engine => $composableBuilder(
      column: $table.engine, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transmission => $composableBuilder(
      column: $table.transmission,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get drivetrain => $composableBuilder(
      column: $table.drivetrain, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$VehiclesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTableTable> {
  $$VehiclesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get make =>
      $composableBuilder(column: $table.make, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<String> get identifier => $composableBuilder(
      column: $table.identifier, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get purchasePriceCents => $composableBuilder(
      column: $table.purchasePriceCents, builder: (column) => column);

  GeneratedColumn<int> get acquiredAt => $composableBuilder(
      column: $table.acquiredAt, builder: (column) => column);

  GeneratedColumn<int> get usageValue => $composableBuilder(
      column: $table.usageValue, builder: (column) => column);

  GeneratedColumn<String> get usageUnit =>
      $composableBuilder(column: $table.usageUnit, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get photoIds =>
      $composableBuilder(column: $table.photoIds, builder: (column) => column);

  GeneratedColumn<String> get trim =>
      $composableBuilder(column: $table.trim, builder: (column) => column);

  GeneratedColumn<String> get engine =>
      $composableBuilder(column: $table.engine, builder: (column) => column);

  GeneratedColumn<String> get transmission => $composableBuilder(
      column: $table.transmission, builder: (column) => column);

  GeneratedColumn<String> get drivetrain => $composableBuilder(
      column: $table.drivetrain, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$VehiclesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VehiclesTableTable,
    VehicleRow,
    $$VehiclesTableTableFilterComposer,
    $$VehiclesTableTableOrderingComposer,
    $$VehiclesTableTableAnnotationComposer,
    $$VehiclesTableTableCreateCompanionBuilder,
    $$VehiclesTableTableUpdateCompanionBuilder,
    (
      VehicleRow,
      BaseReferences<_$AppDatabase, $VehiclesTableTable, VehicleRow>
    ),
    VehicleRow,
    PrefetchHooks Function()> {
  $$VehiclesTableTableTableManager(_$AppDatabase db, $VehiclesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> make = const Value.absent(),
            Value<String> model = const Value.absent(),
            Value<int> year = const Value.absent(),
            Value<String> itemType = const Value.absent(),
            Value<String?> identifier = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int?> purchasePriceCents = const Value.absent(),
            Value<int> acquiredAt = const Value.absent(),
            Value<int?> usageValue = const Value.absent(),
            Value<String> usageUnit = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int?> updatedAt = const Value.absent(),
            Value<String> photoIds = const Value.absent(),
            Value<String?> trim = const Value.absent(),
            Value<String?> engine = const Value.absent(),
            Value<String?> transmission = const Value.absent(),
            Value<String?> drivetrain = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VehiclesTableCompanion(
            id: id,
            make: make,
            model: model,
            year: year,
            itemType: itemType,
            identifier: identifier,
            status: status,
            purchasePriceCents: purchasePriceCents,
            acquiredAt: acquiredAt,
            usageValue: usageValue,
            usageUnit: usageUnit,
            color: color,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            photoIds: photoIds,
            trim: trim,
            engine: engine,
            transmission: transmission,
            drivetrain: drivetrain,
            ownerId: ownerId,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String make,
            required String model,
            required int year,
            required String itemType,
            Value<String?> identifier = const Value.absent(),
            required String status,
            Value<int?> purchasePriceCents = const Value.absent(),
            required int acquiredAt,
            Value<int?> usageValue = const Value.absent(),
            Value<String> usageUnit = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required int createdAt,
            Value<int?> updatedAt = const Value.absent(),
            Value<String> photoIds = const Value.absent(),
            Value<String?> trim = const Value.absent(),
            Value<String?> engine = const Value.absent(),
            Value<String?> transmission = const Value.absent(),
            Value<String?> drivetrain = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VehiclesTableCompanion.insert(
            id: id,
            make: make,
            model: model,
            year: year,
            itemType: itemType,
            identifier: identifier,
            status: status,
            purchasePriceCents: purchasePriceCents,
            acquiredAt: acquiredAt,
            usageValue: usageValue,
            usageUnit: usageUnit,
            color: color,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            photoIds: photoIds,
            trim: trim,
            engine: engine,
            transmission: transmission,
            drivetrain: drivetrain,
            ownerId: ownerId,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VehiclesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VehiclesTableTable,
    VehicleRow,
    $$VehiclesTableTableFilterComposer,
    $$VehiclesTableTableOrderingComposer,
    $$VehiclesTableTableAnnotationComposer,
    $$VehiclesTableTableCreateCompanionBuilder,
    $$VehiclesTableTableUpdateCompanionBuilder,
    (
      VehicleRow,
      BaseReferences<_$AppDatabase, $VehiclesTableTable, VehicleRow>
    ),
    VehicleRow,
    PrefetchHooks Function()>;
typedef $$PartsTableTableCreateCompanionBuilder = PartsTableCompanion Function({
  required String id,
  required String vehicleId,
  required String name,
  required String state,
  Value<String?> location,
  Value<String?> notes,
  Value<String?> partNumber,
  Value<int> qty,
  Value<int?> askingPriceCents,
  Value<int?> salePriceCents,
  Value<String?> stockId,
  Value<String?> category,
  Value<String?> partCondition,
  Value<String?> side,
  Value<int?> dateListed,
  Value<int?> dateSold,
  required int createdAt,
  Value<int?> updatedAt,
  Value<String> photoIds,
  Value<String?> vehicleMake,
  Value<String?> vehicleModel,
  Value<int?> vehicleYear,
  Value<String?> vehicleTrim,
  Value<String?> vehicleEngine,
  Value<String?> vehicleTransmission,
  Value<String?> vehicleDrivetrain,
  Value<int?> vehicleUsageValue,
  Value<String?> vehicleUsageUnit,
  Value<String?> ownerId,
  Value<int?> deletedAt,
  Value<String?> interchangeGroupId,
  Value<int> rowid,
});
typedef $$PartsTableTableUpdateCompanionBuilder = PartsTableCompanion Function({
  Value<String> id,
  Value<String> vehicleId,
  Value<String> name,
  Value<String> state,
  Value<String?> location,
  Value<String?> notes,
  Value<String?> partNumber,
  Value<int> qty,
  Value<int?> askingPriceCents,
  Value<int?> salePriceCents,
  Value<String?> stockId,
  Value<String?> category,
  Value<String?> partCondition,
  Value<String?> side,
  Value<int?> dateListed,
  Value<int?> dateSold,
  Value<int> createdAt,
  Value<int?> updatedAt,
  Value<String> photoIds,
  Value<String?> vehicleMake,
  Value<String?> vehicleModel,
  Value<int?> vehicleYear,
  Value<String?> vehicleTrim,
  Value<String?> vehicleEngine,
  Value<String?> vehicleTransmission,
  Value<String?> vehicleDrivetrain,
  Value<int?> vehicleUsageValue,
  Value<String?> vehicleUsageUnit,
  Value<String?> ownerId,
  Value<int?> deletedAt,
  Value<String?> interchangeGroupId,
  Value<int> rowid,
});

class $$PartsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PartsTableTable> {
  $$PartsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehicleId => $composableBuilder(
      column: $table.vehicleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partNumber => $composableBuilder(
      column: $table.partNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qty => $composableBuilder(
      column: $table.qty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get askingPriceCents => $composableBuilder(
      column: $table.askingPriceCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get salePriceCents => $composableBuilder(
      column: $table.salePriceCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stockId => $composableBuilder(
      column: $table.stockId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partCondition => $composableBuilder(
      column: $table.partCondition, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get side => $composableBuilder(
      column: $table.side, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dateListed => $composableBuilder(
      column: $table.dateListed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dateSold => $composableBuilder(
      column: $table.dateSold, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoIds => $composableBuilder(
      column: $table.photoIds, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehicleMake => $composableBuilder(
      column: $table.vehicleMake, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehicleModel => $composableBuilder(
      column: $table.vehicleModel, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get vehicleYear => $composableBuilder(
      column: $table.vehicleYear, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehicleTrim => $composableBuilder(
      column: $table.vehicleTrim, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehicleEngine => $composableBuilder(
      column: $table.vehicleEngine, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehicleTransmission => $composableBuilder(
      column: $table.vehicleTransmission,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehicleDrivetrain => $composableBuilder(
      column: $table.vehicleDrivetrain,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get vehicleUsageValue => $composableBuilder(
      column: $table.vehicleUsageValue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehicleUsageUnit => $composableBuilder(
      column: $table.vehicleUsageUnit,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get interchangeGroupId => $composableBuilder(
      column: $table.interchangeGroupId,
      builder: (column) => ColumnFilters(column));
}

class $$PartsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PartsTableTable> {
  $$PartsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehicleId => $composableBuilder(
      column: $table.vehicleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partNumber => $composableBuilder(
      column: $table.partNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qty => $composableBuilder(
      column: $table.qty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get askingPriceCents => $composableBuilder(
      column: $table.askingPriceCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get salePriceCents => $composableBuilder(
      column: $table.salePriceCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stockId => $composableBuilder(
      column: $table.stockId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partCondition => $composableBuilder(
      column: $table.partCondition,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get side => $composableBuilder(
      column: $table.side, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dateListed => $composableBuilder(
      column: $table.dateListed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dateSold => $composableBuilder(
      column: $table.dateSold, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoIds => $composableBuilder(
      column: $table.photoIds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehicleMake => $composableBuilder(
      column: $table.vehicleMake, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehicleModel => $composableBuilder(
      column: $table.vehicleModel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get vehicleYear => $composableBuilder(
      column: $table.vehicleYear, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehicleTrim => $composableBuilder(
      column: $table.vehicleTrim, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehicleEngine => $composableBuilder(
      column: $table.vehicleEngine,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehicleTransmission => $composableBuilder(
      column: $table.vehicleTransmission,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehicleDrivetrain => $composableBuilder(
      column: $table.vehicleDrivetrain,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get vehicleUsageValue => $composableBuilder(
      column: $table.vehicleUsageValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehicleUsageUnit => $composableBuilder(
      column: $table.vehicleUsageUnit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get interchangeGroupId => $composableBuilder(
      column: $table.interchangeGroupId,
      builder: (column) => ColumnOrderings(column));
}

class $$PartsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartsTableTable> {
  $$PartsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get partNumber => $composableBuilder(
      column: $table.partNumber, builder: (column) => column);

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<int> get askingPriceCents => $composableBuilder(
      column: $table.askingPriceCents, builder: (column) => column);

  GeneratedColumn<int> get salePriceCents => $composableBuilder(
      column: $table.salePriceCents, builder: (column) => column);

  GeneratedColumn<String> get stockId =>
      $composableBuilder(column: $table.stockId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get partCondition => $composableBuilder(
      column: $table.partCondition, builder: (column) => column);

  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<int> get dateListed => $composableBuilder(
      column: $table.dateListed, builder: (column) => column);

  GeneratedColumn<int> get dateSold =>
      $composableBuilder(column: $table.dateSold, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get photoIds =>
      $composableBuilder(column: $table.photoIds, builder: (column) => column);

  GeneratedColumn<String> get vehicleMake => $composableBuilder(
      column: $table.vehicleMake, builder: (column) => column);

  GeneratedColumn<String> get vehicleModel => $composableBuilder(
      column: $table.vehicleModel, builder: (column) => column);

  GeneratedColumn<int> get vehicleYear => $composableBuilder(
      column: $table.vehicleYear, builder: (column) => column);

  GeneratedColumn<String> get vehicleTrim => $composableBuilder(
      column: $table.vehicleTrim, builder: (column) => column);

  GeneratedColumn<String> get vehicleEngine => $composableBuilder(
      column: $table.vehicleEngine, builder: (column) => column);

  GeneratedColumn<String> get vehicleTransmission => $composableBuilder(
      column: $table.vehicleTransmission, builder: (column) => column);

  GeneratedColumn<String> get vehicleDrivetrain => $composableBuilder(
      column: $table.vehicleDrivetrain, builder: (column) => column);

  GeneratedColumn<int> get vehicleUsageValue => $composableBuilder(
      column: $table.vehicleUsageValue, builder: (column) => column);

  GeneratedColumn<String> get vehicleUsageUnit => $composableBuilder(
      column: $table.vehicleUsageUnit, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get interchangeGroupId => $composableBuilder(
      column: $table.interchangeGroupId, builder: (column) => column);
}

class $$PartsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PartsTableTable,
    PartRow,
    $$PartsTableTableFilterComposer,
    $$PartsTableTableOrderingComposer,
    $$PartsTableTableAnnotationComposer,
    $$PartsTableTableCreateCompanionBuilder,
    $$PartsTableTableUpdateCompanionBuilder,
    (PartRow, BaseReferences<_$AppDatabase, $PartsTableTable, PartRow>),
    PartRow,
    PrefetchHooks Function()> {
  $$PartsTableTableTableManager(_$AppDatabase db, $PartsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> vehicleId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> state = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> partNumber = const Value.absent(),
            Value<int> qty = const Value.absent(),
            Value<int?> askingPriceCents = const Value.absent(),
            Value<int?> salePriceCents = const Value.absent(),
            Value<String?> stockId = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> partCondition = const Value.absent(),
            Value<String?> side = const Value.absent(),
            Value<int?> dateListed = const Value.absent(),
            Value<int?> dateSold = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int?> updatedAt = const Value.absent(),
            Value<String> photoIds = const Value.absent(),
            Value<String?> vehicleMake = const Value.absent(),
            Value<String?> vehicleModel = const Value.absent(),
            Value<int?> vehicleYear = const Value.absent(),
            Value<String?> vehicleTrim = const Value.absent(),
            Value<String?> vehicleEngine = const Value.absent(),
            Value<String?> vehicleTransmission = const Value.absent(),
            Value<String?> vehicleDrivetrain = const Value.absent(),
            Value<int?> vehicleUsageValue = const Value.absent(),
            Value<String?> vehicleUsageUnit = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<String?> interchangeGroupId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PartsTableCompanion(
            id: id,
            vehicleId: vehicleId,
            name: name,
            state: state,
            location: location,
            notes: notes,
            partNumber: partNumber,
            qty: qty,
            askingPriceCents: askingPriceCents,
            salePriceCents: salePriceCents,
            stockId: stockId,
            category: category,
            partCondition: partCondition,
            side: side,
            dateListed: dateListed,
            dateSold: dateSold,
            createdAt: createdAt,
            updatedAt: updatedAt,
            photoIds: photoIds,
            vehicleMake: vehicleMake,
            vehicleModel: vehicleModel,
            vehicleYear: vehicleYear,
            vehicleTrim: vehicleTrim,
            vehicleEngine: vehicleEngine,
            vehicleTransmission: vehicleTransmission,
            vehicleDrivetrain: vehicleDrivetrain,
            vehicleUsageValue: vehicleUsageValue,
            vehicleUsageUnit: vehicleUsageUnit,
            ownerId: ownerId,
            deletedAt: deletedAt,
            interchangeGroupId: interchangeGroupId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String vehicleId,
            required String name,
            required String state,
            Value<String?> location = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> partNumber = const Value.absent(),
            Value<int> qty = const Value.absent(),
            Value<int?> askingPriceCents = const Value.absent(),
            Value<int?> salePriceCents = const Value.absent(),
            Value<String?> stockId = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> partCondition = const Value.absent(),
            Value<String?> side = const Value.absent(),
            Value<int?> dateListed = const Value.absent(),
            Value<int?> dateSold = const Value.absent(),
            required int createdAt,
            Value<int?> updatedAt = const Value.absent(),
            Value<String> photoIds = const Value.absent(),
            Value<String?> vehicleMake = const Value.absent(),
            Value<String?> vehicleModel = const Value.absent(),
            Value<int?> vehicleYear = const Value.absent(),
            Value<String?> vehicleTrim = const Value.absent(),
            Value<String?> vehicleEngine = const Value.absent(),
            Value<String?> vehicleTransmission = const Value.absent(),
            Value<String?> vehicleDrivetrain = const Value.absent(),
            Value<int?> vehicleUsageValue = const Value.absent(),
            Value<String?> vehicleUsageUnit = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<String?> interchangeGroupId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PartsTableCompanion.insert(
            id: id,
            vehicleId: vehicleId,
            name: name,
            state: state,
            location: location,
            notes: notes,
            partNumber: partNumber,
            qty: qty,
            askingPriceCents: askingPriceCents,
            salePriceCents: salePriceCents,
            stockId: stockId,
            category: category,
            partCondition: partCondition,
            side: side,
            dateListed: dateListed,
            dateSold: dateSold,
            createdAt: createdAt,
            updatedAt: updatedAt,
            photoIds: photoIds,
            vehicleMake: vehicleMake,
            vehicleModel: vehicleModel,
            vehicleYear: vehicleYear,
            vehicleTrim: vehicleTrim,
            vehicleEngine: vehicleEngine,
            vehicleTransmission: vehicleTransmission,
            vehicleDrivetrain: vehicleDrivetrain,
            vehicleUsageValue: vehicleUsageValue,
            vehicleUsageUnit: vehicleUsageUnit,
            ownerId: ownerId,
            deletedAt: deletedAt,
            interchangeGroupId: interchangeGroupId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PartsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PartsTableTable,
    PartRow,
    $$PartsTableTableFilterComposer,
    $$PartsTableTableOrderingComposer,
    $$PartsTableTableAnnotationComposer,
    $$PartsTableTableCreateCompanionBuilder,
    $$PartsTableTableUpdateCompanionBuilder,
    (PartRow, BaseReferences<_$AppDatabase, $PartsTableTable, PartRow>),
    PartRow,
    PrefetchHooks Function()>;
typedef $$ListingsTableTableCreateCompanionBuilder = ListingsTableCompanion
    Function({
  required String id,
  required String partId,
  required String platform,
  required String url,
  Value<int> isLive,
  Value<int?> listedPriceCents,
  required int createdAt,
  Value<String?> ownerId,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$ListingsTableTableUpdateCompanionBuilder = ListingsTableCompanion
    Function({
  Value<String> id,
  Value<String> partId,
  Value<String> platform,
  Value<String> url,
  Value<int> isLive,
  Value<int?> listedPriceCents,
  Value<int> createdAt,
  Value<String?> ownerId,
  Value<int?> deletedAt,
  Value<int> rowid,
});

class $$ListingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ListingsTableTable> {
  $$ListingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partId => $composableBuilder(
      column: $table.partId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isLive => $composableBuilder(
      column: $table.isLive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get listedPriceCents => $composableBuilder(
      column: $table.listedPriceCents,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$ListingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ListingsTableTable> {
  $$ListingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partId => $composableBuilder(
      column: $table.partId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isLive => $composableBuilder(
      column: $table.isLive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get listedPriceCents => $composableBuilder(
      column: $table.listedPriceCents,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$ListingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListingsTableTable> {
  $$ListingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get partId =>
      $composableBuilder(column: $table.partId, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get isLive =>
      $composableBuilder(column: $table.isLive, builder: (column) => column);

  GeneratedColumn<int> get listedPriceCents => $composableBuilder(
      column: $table.listedPriceCents, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$ListingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ListingsTableTable,
    ListingRow,
    $$ListingsTableTableFilterComposer,
    $$ListingsTableTableOrderingComposer,
    $$ListingsTableTableAnnotationComposer,
    $$ListingsTableTableCreateCompanionBuilder,
    $$ListingsTableTableUpdateCompanionBuilder,
    (
      ListingRow,
      BaseReferences<_$AppDatabase, $ListingsTableTable, ListingRow>
    ),
    ListingRow,
    PrefetchHooks Function()> {
  $$ListingsTableTableTableManager(_$AppDatabase db, $ListingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> partId = const Value.absent(),
            Value<String> platform = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<int> isLive = const Value.absent(),
            Value<int?> listedPriceCents = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ListingsTableCompanion(
            id: id,
            partId: partId,
            platform: platform,
            url: url,
            isLive: isLive,
            listedPriceCents: listedPriceCents,
            createdAt: createdAt,
            ownerId: ownerId,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String partId,
            required String platform,
            required String url,
            Value<int> isLive = const Value.absent(),
            Value<int?> listedPriceCents = const Value.absent(),
            required int createdAt,
            Value<String?> ownerId = const Value.absent(),
            Value<int?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ListingsTableCompanion.insert(
            id: id,
            partId: partId,
            platform: platform,
            url: url,
            isLive: isLive,
            listedPriceCents: listedPriceCents,
            createdAt: createdAt,
            ownerId: ownerId,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ListingsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ListingsTableTable,
    ListingRow,
    $$ListingsTableTableFilterComposer,
    $$ListingsTableTableOrderingComposer,
    $$ListingsTableTableAnnotationComposer,
    $$ListingsTableTableCreateCompanionBuilder,
    $$ListingsTableTableUpdateCompanionBuilder,
    (
      ListingRow,
      BaseReferences<_$AppDatabase, $ListingsTableTable, ListingRow>
    ),
    ListingRow,
    PrefetchHooks Function()>;
typedef $$InterchangeGroupsTableTableCreateCompanionBuilder
    = InterchangeGroupsTableCompanion Function({
  required String id,
  Value<String> label,
  Value<String> numbers,
  required int createdAt,
  Value<int?> updatedAt,
  Value<int> rowid,
});
typedef $$InterchangeGroupsTableTableUpdateCompanionBuilder
    = InterchangeGroupsTableCompanion Function({
  Value<String> id,
  Value<String> label,
  Value<String> numbers,
  Value<int> createdAt,
  Value<int?> updatedAt,
  Value<int> rowid,
});

class $$InterchangeGroupsTableTableFilterComposer
    extends Composer<_$AppDatabase, $InterchangeGroupsTableTable> {
  $$InterchangeGroupsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get numbers => $composableBuilder(
      column: $table.numbers, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$InterchangeGroupsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $InterchangeGroupsTableTable> {
  $$InterchangeGroupsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get numbers => $composableBuilder(
      column: $table.numbers, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$InterchangeGroupsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $InterchangeGroupsTableTable> {
  $$InterchangeGroupsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get numbers =>
      $composableBuilder(column: $table.numbers, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$InterchangeGroupsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InterchangeGroupsTableTable,
    InterchangeGroupRow,
    $$InterchangeGroupsTableTableFilterComposer,
    $$InterchangeGroupsTableTableOrderingComposer,
    $$InterchangeGroupsTableTableAnnotationComposer,
    $$InterchangeGroupsTableTableCreateCompanionBuilder,
    $$InterchangeGroupsTableTableUpdateCompanionBuilder,
    (
      InterchangeGroupRow,
      BaseReferences<_$AppDatabase, $InterchangeGroupsTableTable,
          InterchangeGroupRow>
    ),
    InterchangeGroupRow,
    PrefetchHooks Function()> {
  $$InterchangeGroupsTableTableTableManager(
      _$AppDatabase db, $InterchangeGroupsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InterchangeGroupsTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$InterchangeGroupsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InterchangeGroupsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<String> numbers = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InterchangeGroupsTableCompanion(
            id: id,
            label: label,
            numbers: numbers,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> label = const Value.absent(),
            Value<String> numbers = const Value.absent(),
            required int createdAt,
            Value<int?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InterchangeGroupsTableCompanion.insert(
            id: id,
            label: label,
            numbers: numbers,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InterchangeGroupsTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $InterchangeGroupsTableTable,
        InterchangeGroupRow,
        $$InterchangeGroupsTableTableFilterComposer,
        $$InterchangeGroupsTableTableOrderingComposer,
        $$InterchangeGroupsTableTableAnnotationComposer,
        $$InterchangeGroupsTableTableCreateCompanionBuilder,
        $$InterchangeGroupsTableTableUpdateCompanionBuilder,
        (
          InterchangeGroupRow,
          BaseReferences<_$AppDatabase, $InterchangeGroupsTableTable,
              InterchangeGroupRow>
        ),
        InterchangeGroupRow,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VehiclesTableTableTableManager get vehiclesTable =>
      $$VehiclesTableTableTableManager(_db, _db.vehiclesTable);
  $$PartsTableTableTableManager get partsTable =>
      $$PartsTableTableTableManager(_db, _db.partsTable);
  $$ListingsTableTableTableManager get listingsTable =>
      $$ListingsTableTableTableManager(_db, _db.listingsTable);
  $$InterchangeGroupsTableTableTableManager get interchangeGroupsTable =>
      $$InterchangeGroupsTableTableTableManager(
          _db, _db.interchangeGroupsTable);
}

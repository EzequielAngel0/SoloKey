// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CredentialEntriesTable extends CredentialEntries
    with TableInfo<$CredentialEntriesTable, CredentialEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CredentialEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDoubleEncryptedMeta = const VerificationMeta(
    'isDoubleEncrypted',
  );
  @override
  late final GeneratedColumn<bool> isDoubleEncrypted = GeneratedColumn<bool>(
    'is_double_encrypted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_double_encrypted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _encryptedPayloadMeta = const VerificationMeta(
    'encryptedPayload',
  );
  @override
  late final GeneratedColumn<Uint8List> encryptedPayload =
      GeneratedColumn<Uint8List>(
        'encrypted_payload',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rotationIntervalMeta = const VerificationMeta(
    'rotationInterval',
  );
  @override
  late final GeneratedColumn<String> rotationInterval = GeneratedColumn<String>(
    'rotation_interval',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _customRotationDaysMeta =
      const VerificationMeta('customRotationDays');
  @override
  late final GeneratedColumn<int> customRotationDays = GeneratedColumn<int>(
    'custom_rotation_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastRotationPromptedAtMeta =
      const VerificationMeta('lastRotationPromptedAt');
  @override
  late final GeneratedColumn<int> lastRotationPromptedAt = GeneratedColumn<int>(
    'last_rotation_prompted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    type,
    categoryId,
    folderId,
    isFavorite,
    isDoubleEncrypted,
    encryptedPayload,
    createdAt,
    updatedAt,
    rotationInterval,
    customRotationDays,
    lastRotationPromptedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'credential_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CredentialEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_double_encrypted')) {
      context.handle(
        _isDoubleEncryptedMeta,
        isDoubleEncrypted.isAcceptableOrUnknown(
          data['is_double_encrypted']!,
          _isDoubleEncryptedMeta,
        ),
      );
    }
    if (data.containsKey('encrypted_payload')) {
      context.handle(
        _encryptedPayloadMeta,
        encryptedPayload.isAcceptableOrUnknown(
          data['encrypted_payload']!,
          _encryptedPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedPayloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('rotation_interval')) {
      context.handle(
        _rotationIntervalMeta,
        rotationInterval.isAcceptableOrUnknown(
          data['rotation_interval']!,
          _rotationIntervalMeta,
        ),
      );
    }
    if (data.containsKey('custom_rotation_days')) {
      context.handle(
        _customRotationDaysMeta,
        customRotationDays.isAcceptableOrUnknown(
          data['custom_rotation_days']!,
          _customRotationDaysMeta,
        ),
      );
    }
    if (data.containsKey('last_rotation_prompted_at')) {
      context.handle(
        _lastRotationPromptedAtMeta,
        lastRotationPromptedAt.isAcceptableOrUnknown(
          data['last_rotation_prompted_at']!,
          _lastRotationPromptedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CredentialEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CredentialEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_id'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isDoubleEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_double_encrypted'],
      )!,
      encryptedPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}encrypted_payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      rotationInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rotation_interval'],
      )!,
      customRotationDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_rotation_days'],
      ),
      lastRotationPromptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_rotation_prompted_at'],
      ),
    );
  }

  @override
  $CredentialEntriesTable createAlias(String alias) {
    return $CredentialEntriesTable(attachedDatabase, alias);
  }
}

class CredentialEntry extends DataClass implements Insertable<CredentialEntry> {
  /// Unique credential ID (UUID v4).
  final String id;

  /// Human-readable title — not considered a secret (shown in vault list).
  final String title;

  /// Credential type enum string (password, apiKey, secureNote, totp, passkey).
  final String type;

  /// Optional category ID — unencrypted for filtering.
  final String? categoryId;

  /// Optional folder ID — unencrypted for tree navigation.
  final String? folderId;

  /// Favourite flag — unencrypted for quick access.
  final bool isFavorite;

  /// Whether the credential is double-encrypted using a secondary PIN.
  final bool isDoubleEncrypted;

  /// AES-256-GCM blob: nonce(12) || ciphertext || tag(16).
  /// Contains JSON-encoded sensitive payload including passkeyMetadata.
  final Uint8List encryptedPayload;

  /// Unix timestamp in milliseconds.
  final int createdAt;

  /// Unix timestamp in milliseconds.
  final int updatedAt;

  /// Rotation reminder interval (none, monthly, quarterly, semiAnnually, custom).
  final String rotationInterval;

  /// Custom rotation period in days (only used when rotationInterval == 'custom').
  final int? customRotationDays;

  /// Unix timestamp in ms — last time a rotation notification was shown.
  final int? lastRotationPromptedAt;
  const CredentialEntry({
    required this.id,
    required this.title,
    required this.type,
    this.categoryId,
    this.folderId,
    required this.isFavorite,
    required this.isDoubleEncrypted,
    required this.encryptedPayload,
    required this.createdAt,
    required this.updatedAt,
    required this.rotationInterval,
    this.customRotationDays,
    this.lastRotationPromptedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<String>(folderId);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_double_encrypted'] = Variable<bool>(isDoubleEncrypted);
    map['encrypted_payload'] = Variable<Uint8List>(encryptedPayload);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['rotation_interval'] = Variable<String>(rotationInterval);
    if (!nullToAbsent || customRotationDays != null) {
      map['custom_rotation_days'] = Variable<int>(customRotationDays);
    }
    if (!nullToAbsent || lastRotationPromptedAt != null) {
      map['last_rotation_prompted_at'] = Variable<int>(lastRotationPromptedAt);
    }
    return map;
  }

  CredentialEntriesCompanion toCompanion(bool nullToAbsent) {
    return CredentialEntriesCompanion(
      id: Value(id),
      title: Value(title),
      type: Value(type),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
      isFavorite: Value(isFavorite),
      isDoubleEncrypted: Value(isDoubleEncrypted),
      encryptedPayload: Value(encryptedPayload),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      rotationInterval: Value(rotationInterval),
      customRotationDays: customRotationDays == null && nullToAbsent
          ? const Value.absent()
          : Value(customRotationDays),
      lastRotationPromptedAt: lastRotationPromptedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRotationPromptedAt),
    );
  }

  factory CredentialEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CredentialEntry(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      type: serializer.fromJson<String>(json['type']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      folderId: serializer.fromJson<String?>(json['folderId']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isDoubleEncrypted: serializer.fromJson<bool>(json['isDoubleEncrypted']),
      encryptedPayload: serializer.fromJson<Uint8List>(
        json['encryptedPayload'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      rotationInterval: serializer.fromJson<String>(json['rotationInterval']),
      customRotationDays: serializer.fromJson<int?>(json['customRotationDays']),
      lastRotationPromptedAt: serializer.fromJson<int?>(
        json['lastRotationPromptedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'type': serializer.toJson<String>(type),
      'categoryId': serializer.toJson<String?>(categoryId),
      'folderId': serializer.toJson<String?>(folderId),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isDoubleEncrypted': serializer.toJson<bool>(isDoubleEncrypted),
      'encryptedPayload': serializer.toJson<Uint8List>(encryptedPayload),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'rotationInterval': serializer.toJson<String>(rotationInterval),
      'customRotationDays': serializer.toJson<int?>(customRotationDays),
      'lastRotationPromptedAt': serializer.toJson<int?>(lastRotationPromptedAt),
    };
  }

  CredentialEntry copyWith({
    String? id,
    String? title,
    String? type,
    Value<String?> categoryId = const Value.absent(),
    Value<String?> folderId = const Value.absent(),
    bool? isFavorite,
    bool? isDoubleEncrypted,
    Uint8List? encryptedPayload,
    int? createdAt,
    int? updatedAt,
    String? rotationInterval,
    Value<int?> customRotationDays = const Value.absent(),
    Value<int?> lastRotationPromptedAt = const Value.absent(),
  }) => CredentialEntry(
    id: id ?? this.id,
    title: title ?? this.title,
    type: type ?? this.type,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    folderId: folderId.present ? folderId.value : this.folderId,
    isFavorite: isFavorite ?? this.isFavorite,
    isDoubleEncrypted: isDoubleEncrypted ?? this.isDoubleEncrypted,
    encryptedPayload: encryptedPayload ?? this.encryptedPayload,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    rotationInterval: rotationInterval ?? this.rotationInterval,
    customRotationDays: customRotationDays.present
        ? customRotationDays.value
        : this.customRotationDays,
    lastRotationPromptedAt: lastRotationPromptedAt.present
        ? lastRotationPromptedAt.value
        : this.lastRotationPromptedAt,
  );
  CredentialEntry copyWithCompanion(CredentialEntriesCompanion data) {
    return CredentialEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      type: data.type.present ? data.type.value : this.type,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isDoubleEncrypted: data.isDoubleEncrypted.present
          ? data.isDoubleEncrypted.value
          : this.isDoubleEncrypted,
      encryptedPayload: data.encryptedPayload.present
          ? data.encryptedPayload.value
          : this.encryptedPayload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      rotationInterval: data.rotationInterval.present
          ? data.rotationInterval.value
          : this.rotationInterval,
      customRotationDays: data.customRotationDays.present
          ? data.customRotationDays.value
          : this.customRotationDays,
      lastRotationPromptedAt: data.lastRotationPromptedAt.present
          ? data.lastRotationPromptedAt.value
          : this.lastRotationPromptedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CredentialEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('folderId: $folderId, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isDoubleEncrypted: $isDoubleEncrypted, ')
          ..write('encryptedPayload: $encryptedPayload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rotationInterval: $rotationInterval, ')
          ..write('customRotationDays: $customRotationDays, ')
          ..write('lastRotationPromptedAt: $lastRotationPromptedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    type,
    categoryId,
    folderId,
    isFavorite,
    isDoubleEncrypted,
    $driftBlobEquality.hash(encryptedPayload),
    createdAt,
    updatedAt,
    rotationInterval,
    customRotationDays,
    lastRotationPromptedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CredentialEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.type == this.type &&
          other.categoryId == this.categoryId &&
          other.folderId == this.folderId &&
          other.isFavorite == this.isFavorite &&
          other.isDoubleEncrypted == this.isDoubleEncrypted &&
          $driftBlobEquality.equals(
            other.encryptedPayload,
            this.encryptedPayload,
          ) &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.rotationInterval == this.rotationInterval &&
          other.customRotationDays == this.customRotationDays &&
          other.lastRotationPromptedAt == this.lastRotationPromptedAt);
}

class CredentialEntriesCompanion extends UpdateCompanion<CredentialEntry> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> type;
  final Value<String?> categoryId;
  final Value<String?> folderId;
  final Value<bool> isFavorite;
  final Value<bool> isDoubleEncrypted;
  final Value<Uint8List> encryptedPayload;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> rotationInterval;
  final Value<int?> customRotationDays;
  final Value<int?> lastRotationPromptedAt;
  final Value<int> rowid;
  const CredentialEntriesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.folderId = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isDoubleEncrypted = const Value.absent(),
    this.encryptedPayload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rotationInterval = const Value.absent(),
    this.customRotationDays = const Value.absent(),
    this.lastRotationPromptedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CredentialEntriesCompanion.insert({
    required String id,
    required String title,
    required String type,
    this.categoryId = const Value.absent(),
    this.folderId = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isDoubleEncrypted = const Value.absent(),
    required Uint8List encryptedPayload,
    required int createdAt,
    required int updatedAt,
    this.rotationInterval = const Value.absent(),
    this.customRotationDays = const Value.absent(),
    this.lastRotationPromptedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       type = Value(type),
       encryptedPayload = Value(encryptedPayload),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CredentialEntry> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? type,
    Expression<String>? categoryId,
    Expression<String>? folderId,
    Expression<bool>? isFavorite,
    Expression<bool>? isDoubleEncrypted,
    Expression<Uint8List>? encryptedPayload,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? rotationInterval,
    Expression<int>? customRotationDays,
    Expression<int>? lastRotationPromptedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (categoryId != null) 'category_id': categoryId,
      if (folderId != null) 'folder_id': folderId,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isDoubleEncrypted != null) 'is_double_encrypted': isDoubleEncrypted,
      if (encryptedPayload != null) 'encrypted_payload': encryptedPayload,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rotationInterval != null) 'rotation_interval': rotationInterval,
      if (customRotationDays != null)
        'custom_rotation_days': customRotationDays,
      if (lastRotationPromptedAt != null)
        'last_rotation_prompted_at': lastRotationPromptedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CredentialEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? type,
    Value<String?>? categoryId,
    Value<String?>? folderId,
    Value<bool>? isFavorite,
    Value<bool>? isDoubleEncrypted,
    Value<Uint8List>? encryptedPayload,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? rotationInterval,
    Value<int?>? customRotationDays,
    Value<int?>? lastRotationPromptedAt,
    Value<int>? rowid,
  }) {
    return CredentialEntriesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      folderId: folderId ?? this.folderId,
      isFavorite: isFavorite ?? this.isFavorite,
      isDoubleEncrypted: isDoubleEncrypted ?? this.isDoubleEncrypted,
      encryptedPayload: encryptedPayload ?? this.encryptedPayload,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rotationInterval: rotationInterval ?? this.rotationInterval,
      customRotationDays: customRotationDays ?? this.customRotationDays,
      lastRotationPromptedAt:
          lastRotationPromptedAt ?? this.lastRotationPromptedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isDoubleEncrypted.present) {
      map['is_double_encrypted'] = Variable<bool>(isDoubleEncrypted.value);
    }
    if (encryptedPayload.present) {
      map['encrypted_payload'] = Variable<Uint8List>(encryptedPayload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rotationInterval.present) {
      map['rotation_interval'] = Variable<String>(rotationInterval.value);
    }
    if (customRotationDays.present) {
      map['custom_rotation_days'] = Variable<int>(customRotationDays.value);
    }
    if (lastRotationPromptedAt.present) {
      map['last_rotation_prompted_at'] = Variable<int>(
        lastRotationPromptedAt.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CredentialEntriesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('folderId: $folderId, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isDoubleEncrypted: $isDoubleEncrypted, ')
          ..write('encryptedPayload: $encryptedPayload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rotationInterval: $rotationInterval, ')
          ..write('customRotationDays: $customRotationDays, ')
          ..write('lastRotationPromptedAt: $lastRotationPromptedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoryEntriesTable extends CategoryEntries
    with TableInfo<$CategoryEntriesTable, CategoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, icon, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CategoryEntriesTable createAlias(String alias) {
    return $CategoryEntriesTable(attachedDatabase, alias);
  }
}

class CategoryEntry extends DataClass implements Insertable<CategoryEntry> {
  final String id;
  final String name;
  final String icon;
  final int createdAt;
  const CategoryEntry({
    required this.id,
    required this.name,
    required this.icon,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CategoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return CategoryEntriesCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      createdAt: Value(createdAt),
    );
  }

  factory CategoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  CategoryEntry copyWith({
    String? id,
    String? name,
    String? icon,
    int? createdAt,
  }) => CategoryEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    createdAt: createdAt ?? this.createdAt,
  );
  CategoryEntry copyWithCompanion(CategoryEntriesCompanion data) {
    return CategoryEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, icon, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.createdAt == this.createdAt);
}

class CategoryEntriesCompanion extends UpdateCompanion<CategoryEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<int> createdAt;
  final Value<int> rowid;
  const CategoryEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryEntriesCompanion.insert({
    required String id,
    required String name,
    required String icon,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       icon = Value(icon),
       createdAt = Value(createdAt);
  static Insertable<CategoryEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? icon,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return CategoryEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FolderEntriesTable extends FolderEntries
    with TableInfo<$FolderEntriesTable, FolderEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FolderEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('folder'),
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#6C63FF'),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    parentId,
    name,
    icon,
    colorHex,
    isFavorite,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folder_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<FolderEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FolderEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FolderEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FolderEntriesTable createAlias(String alias) {
    return $FolderEntriesTable(attachedDatabase, alias);
  }
}

class FolderEntry extends DataClass implements Insertable<FolderEntry> {
  final String id;
  final String? parentId;
  final String name;
  final String icon;
  final String colorHex;
  final bool isFavorite;
  final int createdAt;
  const FolderEntry({
    required this.id,
    this.parentId,
    required this.name,
    required this.icon,
    required this.colorHex,
    required this.isFavorite,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color_hex'] = Variable<String>(colorHex);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  FolderEntriesCompanion toCompanion(bool nullToAbsent) {
    return FolderEntriesCompanion(
      id: Value(id),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      name: Value(name),
      icon: Value(icon),
      colorHex: Value(colorHex),
      isFavorite: Value(isFavorite),
      createdAt: Value(createdAt),
    );
  }

  factory FolderEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FolderEntry(
      id: serializer.fromJson<String>(json['id']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'parentId': serializer.toJson<String?>(parentId),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'colorHex': serializer.toJson<String>(colorHex),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  FolderEntry copyWith({
    String? id,
    Value<String?> parentId = const Value.absent(),
    String? name,
    String? icon,
    String? colorHex,
    bool? isFavorite,
    int? createdAt,
  }) => FolderEntry(
    id: id ?? this.id,
    parentId: parentId.present ? parentId.value : this.parentId,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    colorHex: colorHex ?? this.colorHex,
    isFavorite: isFavorite ?? this.isFavorite,
    createdAt: createdAt ?? this.createdAt,
  );
  FolderEntry copyWithCompanion(FolderEntriesCompanion data) {
    return FolderEntry(
      id: data.id.present ? data.id.value : this.id,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FolderEntry(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('colorHex: $colorHex, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, parentId, name, icon, colorHex, isFavorite, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FolderEntry &&
          other.id == this.id &&
          other.parentId == this.parentId &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.colorHex == this.colorHex &&
          other.isFavorite == this.isFavorite &&
          other.createdAt == this.createdAt);
}

class FolderEntriesCompanion extends UpdateCompanion<FolderEntry> {
  final Value<String> id;
  final Value<String?> parentId;
  final Value<String> name;
  final Value<String> icon;
  final Value<String> colorHex;
  final Value<bool> isFavorite;
  final Value<int> createdAt;
  final Value<int> rowid;
  const FolderEntriesCompanion({
    this.id = const Value.absent(),
    this.parentId = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FolderEntriesCompanion.insert({
    required String id,
    this.parentId = const Value.absent(),
    required String name,
    this.icon = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isFavorite = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<FolderEntry> custom({
    Expression<String>? id,
    Expression<String>? parentId,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? colorHex,
    Expression<bool>? isFavorite,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentId != null) 'parent_id': parentId,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (colorHex != null) 'color_hex': colorHex,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FolderEntriesCompanion copyWith({
    Value<String>? id,
    Value<String?>? parentId,
    Value<String>? name,
    Value<String>? icon,
    Value<String>? colorHex,
    Value<bool>? isFavorite,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return FolderEntriesCompanion(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FolderEntriesCompanion(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('colorHex: $colorHex, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PasswordHistoryEntriesTable extends PasswordHistoryEntries
    with TableInfo<$PasswordHistoryEntriesTable, PasswordHistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PasswordHistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _credentialIdMeta = const VerificationMeta(
    'credentialId',
  );
  @override
  late final GeneratedColumn<String> credentialId = GeneratedColumn<String>(
    'credential_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptedPayloadMeta = const VerificationMeta(
    'encryptedPayload',
  );
  @override
  late final GeneratedColumn<Uint8List> encryptedPayload =
      GeneratedColumn<Uint8List>(
        'encrypted_payload',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    credentialId,
    encryptedPayload,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'password_history_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PasswordHistoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('credential_id')) {
      context.handle(
        _credentialIdMeta,
        credentialId.isAcceptableOrUnknown(
          data['credential_id']!,
          _credentialIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_credentialIdMeta);
    }
    if (data.containsKey('encrypted_payload')) {
      context.handle(
        _encryptedPayloadMeta,
        encryptedPayload.isAcceptableOrUnknown(
          data['encrypted_payload']!,
          _encryptedPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedPayloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PasswordHistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PasswordHistoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      credentialId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}credential_id'],
      )!,
      encryptedPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}encrypted_payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PasswordHistoryEntriesTable createAlias(String alias) {
    return $PasswordHistoryEntriesTable(attachedDatabase, alias);
  }
}

class PasswordHistoryEntry extends DataClass
    implements Insertable<PasswordHistoryEntry> {
  final String id;

  /// FK to credential.
  final String credentialId;

  /// AES-256-GCM encrypted password snapshot.
  final Uint8List encryptedPayload;
  final int createdAt;
  const PasswordHistoryEntry({
    required this.id,
    required this.credentialId,
    required this.encryptedPayload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['credential_id'] = Variable<String>(credentialId);
    map['encrypted_payload'] = Variable<Uint8List>(encryptedPayload);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  PasswordHistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return PasswordHistoryEntriesCompanion(
      id: Value(id),
      credentialId: Value(credentialId),
      encryptedPayload: Value(encryptedPayload),
      createdAt: Value(createdAt),
    );
  }

  factory PasswordHistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PasswordHistoryEntry(
      id: serializer.fromJson<String>(json['id']),
      credentialId: serializer.fromJson<String>(json['credentialId']),
      encryptedPayload: serializer.fromJson<Uint8List>(
        json['encryptedPayload'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'credentialId': serializer.toJson<String>(credentialId),
      'encryptedPayload': serializer.toJson<Uint8List>(encryptedPayload),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  PasswordHistoryEntry copyWith({
    String? id,
    String? credentialId,
    Uint8List? encryptedPayload,
    int? createdAt,
  }) => PasswordHistoryEntry(
    id: id ?? this.id,
    credentialId: credentialId ?? this.credentialId,
    encryptedPayload: encryptedPayload ?? this.encryptedPayload,
    createdAt: createdAt ?? this.createdAt,
  );
  PasswordHistoryEntry copyWithCompanion(PasswordHistoryEntriesCompanion data) {
    return PasswordHistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      credentialId: data.credentialId.present
          ? data.credentialId.value
          : this.credentialId,
      encryptedPayload: data.encryptedPayload.present
          ? data.encryptedPayload.value
          : this.encryptedPayload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PasswordHistoryEntry(')
          ..write('id: $id, ')
          ..write('credentialId: $credentialId, ')
          ..write('encryptedPayload: $encryptedPayload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    credentialId,
    $driftBlobEquality.hash(encryptedPayload),
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PasswordHistoryEntry &&
          other.id == this.id &&
          other.credentialId == this.credentialId &&
          $driftBlobEquality.equals(
            other.encryptedPayload,
            this.encryptedPayload,
          ) &&
          other.createdAt == this.createdAt);
}

class PasswordHistoryEntriesCompanion
    extends UpdateCompanion<PasswordHistoryEntry> {
  final Value<String> id;
  final Value<String> credentialId;
  final Value<Uint8List> encryptedPayload;
  final Value<int> createdAt;
  final Value<int> rowid;
  const PasswordHistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.credentialId = const Value.absent(),
    this.encryptedPayload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PasswordHistoryEntriesCompanion.insert({
    required String id,
    required String credentialId,
    required Uint8List encryptedPayload,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       credentialId = Value(credentialId),
       encryptedPayload = Value(encryptedPayload),
       createdAt = Value(createdAt);
  static Insertable<PasswordHistoryEntry> custom({
    Expression<String>? id,
    Expression<String>? credentialId,
    Expression<Uint8List>? encryptedPayload,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (credentialId != null) 'credential_id': credentialId,
      if (encryptedPayload != null) 'encrypted_payload': encryptedPayload,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PasswordHistoryEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? credentialId,
    Value<Uint8List>? encryptedPayload,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return PasswordHistoryEntriesCompanion(
      id: id ?? this.id,
      credentialId: credentialId ?? this.credentialId,
      encryptedPayload: encryptedPayload ?? this.encryptedPayload,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (credentialId.present) {
      map['credential_id'] = Variable<String>(credentialId.value);
    }
    if (encryptedPayload.present) {
      map['encrypted_payload'] = Variable<Uint8List>(encryptedPayload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PasswordHistoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('credentialId: $credentialId, ')
          ..write('encryptedPayload: $encryptedPayload, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SecureFileEntriesTable extends SecureFileEntries
    with TableInfo<$SecureFileEntriesTable, SecureFileEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SecureFileEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storedFileNameMeta = const VerificationMeta(
    'storedFileName',
  );
  @override
  late final GeneratedColumn<String> storedFileName = GeneratedColumn<String>(
    'stored_file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeHintMeta = const VerificationMeta(
    'mimeHint',
  );
  @override
  late final GeneratedColumn<String> mimeHint = GeneratedColumn<String>(
    'mime_hint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sizeBytes,
    storedFileName,
    mimeHint,
    note,
    folderId,
    isFavorite,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'secure_file_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SecureFileEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('stored_file_name')) {
      context.handle(
        _storedFileNameMeta,
        storedFileName.isAcceptableOrUnknown(
          data['stored_file_name']!,
          _storedFileNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storedFileNameMeta);
    }
    if (data.containsKey('mime_hint')) {
      context.handle(
        _mimeHintMeta,
        mimeHint.isAcceptableOrUnknown(data['mime_hint']!, _mimeHintMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SecureFileEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SecureFileEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      storedFileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stored_file_name'],
      )!,
      mimeHint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_hint'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_id'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SecureFileEntriesTable createAlias(String alias) {
    return $SecureFileEntriesTable(attachedDatabase, alias);
  }
}

class SecureFileEntry extends DataClass implements Insertable<SecureFileEntry> {
  final String id;
  final String name;
  final int sizeBytes;
  final String storedFileName;
  final String? mimeHint;
  final String? note;
  final String? folderId;
  final bool isFavorite;
  final int createdAt;
  final int updatedAt;
  const SecureFileEntry({
    required this.id,
    required this.name,
    required this.sizeBytes,
    required this.storedFileName,
    this.mimeHint,
    this.note,
    this.folderId,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['stored_file_name'] = Variable<String>(storedFileName);
    if (!nullToAbsent || mimeHint != null) {
      map['mime_hint'] = Variable<String>(mimeHint);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<String>(folderId);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SecureFileEntriesCompanion toCompanion(bool nullToAbsent) {
    return SecureFileEntriesCompanion(
      id: Value(id),
      name: Value(name),
      sizeBytes: Value(sizeBytes),
      storedFileName: Value(storedFileName),
      mimeHint: mimeHint == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeHint),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
      isFavorite: Value(isFavorite),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SecureFileEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SecureFileEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      storedFileName: serializer.fromJson<String>(json['storedFileName']),
      mimeHint: serializer.fromJson<String?>(json['mimeHint']),
      note: serializer.fromJson<String?>(json['note']),
      folderId: serializer.fromJson<String?>(json['folderId']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'storedFileName': serializer.toJson<String>(storedFileName),
      'mimeHint': serializer.toJson<String?>(mimeHint),
      'note': serializer.toJson<String?>(note),
      'folderId': serializer.toJson<String?>(folderId),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  SecureFileEntry copyWith({
    String? id,
    String? name,
    int? sizeBytes,
    String? storedFileName,
    Value<String?> mimeHint = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> folderId = const Value.absent(),
    bool? isFavorite,
    int? createdAt,
    int? updatedAt,
  }) => SecureFileEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    storedFileName: storedFileName ?? this.storedFileName,
    mimeHint: mimeHint.present ? mimeHint.value : this.mimeHint,
    note: note.present ? note.value : this.note,
    folderId: folderId.present ? folderId.value : this.folderId,
    isFavorite: isFavorite ?? this.isFavorite,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SecureFileEntry copyWithCompanion(SecureFileEntriesCompanion data) {
    return SecureFileEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      storedFileName: data.storedFileName.present
          ? data.storedFileName.value
          : this.storedFileName,
      mimeHint: data.mimeHint.present ? data.mimeHint.value : this.mimeHint,
      note: data.note.present ? data.note.value : this.note,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SecureFileEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('storedFileName: $storedFileName, ')
          ..write('mimeHint: $mimeHint, ')
          ..write('note: $note, ')
          ..write('folderId: $folderId, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sizeBytes,
    storedFileName,
    mimeHint,
    note,
    folderId,
    isFavorite,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SecureFileEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.sizeBytes == this.sizeBytes &&
          other.storedFileName == this.storedFileName &&
          other.mimeHint == this.mimeHint &&
          other.note == this.note &&
          other.folderId == this.folderId &&
          other.isFavorite == this.isFavorite &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SecureFileEntriesCompanion extends UpdateCompanion<SecureFileEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> sizeBytes;
  final Value<String> storedFileName;
  final Value<String?> mimeHint;
  final Value<String?> note;
  final Value<String?> folderId;
  final Value<bool> isFavorite;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const SecureFileEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.storedFileName = const Value.absent(),
    this.mimeHint = const Value.absent(),
    this.note = const Value.absent(),
    this.folderId = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SecureFileEntriesCompanion.insert({
    required String id,
    required String name,
    required int sizeBytes,
    required String storedFileName,
    this.mimeHint = const Value.absent(),
    this.note = const Value.absent(),
    this.folderId = const Value.absent(),
    this.isFavorite = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       sizeBytes = Value(sizeBytes),
       storedFileName = Value(storedFileName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SecureFileEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? sizeBytes,
    Expression<String>? storedFileName,
    Expression<String>? mimeHint,
    Expression<String>? note,
    Expression<String>? folderId,
    Expression<bool>? isFavorite,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (storedFileName != null) 'stored_file_name': storedFileName,
      if (mimeHint != null) 'mime_hint': mimeHint,
      if (note != null) 'note': note,
      if (folderId != null) 'folder_id': folderId,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SecureFileEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? sizeBytes,
    Value<String>? storedFileName,
    Value<String?>? mimeHint,
    Value<String?>? note,
    Value<String?>? folderId,
    Value<bool>? isFavorite,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return SecureFileEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      storedFileName: storedFileName ?? this.storedFileName,
      mimeHint: mimeHint ?? this.mimeHint,
      note: note ?? this.note,
      folderId: folderId ?? this.folderId,
      isFavorite: isFavorite ?? this.isFavorite,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (storedFileName.present) {
      map['stored_file_name'] = Variable<String>(storedFileName.value);
    }
    if (mimeHint.present) {
      map['mime_hint'] = Variable<String>(mimeHint.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
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
    return (StringBuffer('SecureFileEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('storedFileName: $storedFileName, ')
          ..write('mimeHint: $mimeHint, ')
          ..write('note: $note, ')
          ..write('folderId: $folderId, ')
          ..write('isFavorite: $isFavorite, ')
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
  late final $CredentialEntriesTable credentialEntries =
      $CredentialEntriesTable(this);
  late final $CategoryEntriesTable categoryEntries = $CategoryEntriesTable(
    this,
  );
  late final $FolderEntriesTable folderEntries = $FolderEntriesTable(this);
  late final $PasswordHistoryEntriesTable passwordHistoryEntries =
      $PasswordHistoryEntriesTable(this);
  late final $SecureFileEntriesTable secureFileEntries =
      $SecureFileEntriesTable(this);
  late final CredentialDao credentialDao = CredentialDao(this as AppDatabase);
  late final CategoryDao categoryDao = CategoryDao(this as AppDatabase);
  late final FolderDao folderDao = FolderDao(this as AppDatabase);
  late final PasswordHistoryDao passwordHistoryDao = PasswordHistoryDao(
    this as AppDatabase,
  );
  late final SecureFileDao secureFileDao = SecureFileDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    credentialEntries,
    categoryEntries,
    folderEntries,
    passwordHistoryEntries,
    secureFileEntries,
  ];
}

typedef $$CredentialEntriesTableCreateCompanionBuilder =
    CredentialEntriesCompanion Function({
      required String id,
      required String title,
      required String type,
      Value<String?> categoryId,
      Value<String?> folderId,
      Value<bool> isFavorite,
      Value<bool> isDoubleEncrypted,
      required Uint8List encryptedPayload,
      required int createdAt,
      required int updatedAt,
      Value<String> rotationInterval,
      Value<int?> customRotationDays,
      Value<int?> lastRotationPromptedAt,
      Value<int> rowid,
    });
typedef $$CredentialEntriesTableUpdateCompanionBuilder =
    CredentialEntriesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> type,
      Value<String?> categoryId,
      Value<String?> folderId,
      Value<bool> isFavorite,
      Value<bool> isDoubleEncrypted,
      Value<Uint8List> encryptedPayload,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> rotationInterval,
      Value<int?> customRotationDays,
      Value<int?> lastRotationPromptedAt,
      Value<int> rowid,
    });

class $$CredentialEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CredentialEntriesTable> {
  $$CredentialEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDoubleEncrypted => $composableBuilder(
    column: $table.isDoubleEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get encryptedPayload => $composableBuilder(
    column: $table.encryptedPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rotationInterval => $composableBuilder(
    column: $table.rotationInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customRotationDays => $composableBuilder(
    column: $table.customRotationDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastRotationPromptedAt => $composableBuilder(
    column: $table.lastRotationPromptedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CredentialEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CredentialEntriesTable> {
  $$CredentialEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDoubleEncrypted => $composableBuilder(
    column: $table.isDoubleEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get encryptedPayload => $composableBuilder(
    column: $table.encryptedPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rotationInterval => $composableBuilder(
    column: $table.rotationInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customRotationDays => $composableBuilder(
    column: $table.customRotationDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastRotationPromptedAt => $composableBuilder(
    column: $table.lastRotationPromptedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CredentialEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CredentialEntriesTable> {
  $$CredentialEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDoubleEncrypted => $composableBuilder(
    column: $table.isDoubleEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get encryptedPayload => $composableBuilder(
    column: $table.encryptedPayload,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get rotationInterval => $composableBuilder(
    column: $table.rotationInterval,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customRotationDays => $composableBuilder(
    column: $table.customRotationDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastRotationPromptedAt => $composableBuilder(
    column: $table.lastRotationPromptedAt,
    builder: (column) => column,
  );
}

class $$CredentialEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CredentialEntriesTable,
          CredentialEntry,
          $$CredentialEntriesTableFilterComposer,
          $$CredentialEntriesTableOrderingComposer,
          $$CredentialEntriesTableAnnotationComposer,
          $$CredentialEntriesTableCreateCompanionBuilder,
          $$CredentialEntriesTableUpdateCompanionBuilder,
          (
            CredentialEntry,
            BaseReferences<
              _$AppDatabase,
              $CredentialEntriesTable,
              CredentialEntry
            >,
          ),
          CredentialEntry,
          PrefetchHooks Function()
        > {
  $$CredentialEntriesTableTableManager(
    _$AppDatabase db,
    $CredentialEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CredentialEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CredentialEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CredentialEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isDoubleEncrypted = const Value.absent(),
                Value<Uint8List> encryptedPayload = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> rotationInterval = const Value.absent(),
                Value<int?> customRotationDays = const Value.absent(),
                Value<int?> lastRotationPromptedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CredentialEntriesCompanion(
                id: id,
                title: title,
                type: type,
                categoryId: categoryId,
                folderId: folderId,
                isFavorite: isFavorite,
                isDoubleEncrypted: isDoubleEncrypted,
                encryptedPayload: encryptedPayload,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rotationInterval: rotationInterval,
                customRotationDays: customRotationDays,
                lastRotationPromptedAt: lastRotationPromptedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String type,
                Value<String?> categoryId = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isDoubleEncrypted = const Value.absent(),
                required Uint8List encryptedPayload,
                required int createdAt,
                required int updatedAt,
                Value<String> rotationInterval = const Value.absent(),
                Value<int?> customRotationDays = const Value.absent(),
                Value<int?> lastRotationPromptedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CredentialEntriesCompanion.insert(
                id: id,
                title: title,
                type: type,
                categoryId: categoryId,
                folderId: folderId,
                isFavorite: isFavorite,
                isDoubleEncrypted: isDoubleEncrypted,
                encryptedPayload: encryptedPayload,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rotationInterval: rotationInterval,
                customRotationDays: customRotationDays,
                lastRotationPromptedAt: lastRotationPromptedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CredentialEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CredentialEntriesTable,
      CredentialEntry,
      $$CredentialEntriesTableFilterComposer,
      $$CredentialEntriesTableOrderingComposer,
      $$CredentialEntriesTableAnnotationComposer,
      $$CredentialEntriesTableCreateCompanionBuilder,
      $$CredentialEntriesTableUpdateCompanionBuilder,
      (
        CredentialEntry,
        BaseReferences<_$AppDatabase, $CredentialEntriesTable, CredentialEntry>,
      ),
      CredentialEntry,
      PrefetchHooks Function()
    >;
typedef $$CategoryEntriesTableCreateCompanionBuilder =
    CategoryEntriesCompanion Function({
      required String id,
      required String name,
      required String icon,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$CategoryEntriesTableUpdateCompanionBuilder =
    CategoryEntriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> icon,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$CategoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryEntriesTable> {
  $$CategoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryEntriesTable> {
  $$CategoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryEntriesTable> {
  $$CategoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CategoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryEntriesTable,
          CategoryEntry,
          $$CategoryEntriesTableFilterComposer,
          $$CategoryEntriesTableOrderingComposer,
          $$CategoryEntriesTableAnnotationComposer,
          $$CategoryEntriesTableCreateCompanionBuilder,
          $$CategoryEntriesTableUpdateCompanionBuilder,
          (
            CategoryEntry,
            BaseReferences<_$AppDatabase, $CategoryEntriesTable, CategoryEntry>,
          ),
          CategoryEntry,
          PrefetchHooks Function()
        > {
  $$CategoryEntriesTableTableManager(
    _$AppDatabase db,
    $CategoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryEntriesCompanion(
                id: id,
                name: name,
                icon: icon,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String icon,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CategoryEntriesCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryEntriesTable,
      CategoryEntry,
      $$CategoryEntriesTableFilterComposer,
      $$CategoryEntriesTableOrderingComposer,
      $$CategoryEntriesTableAnnotationComposer,
      $$CategoryEntriesTableCreateCompanionBuilder,
      $$CategoryEntriesTableUpdateCompanionBuilder,
      (
        CategoryEntry,
        BaseReferences<_$AppDatabase, $CategoryEntriesTable, CategoryEntry>,
      ),
      CategoryEntry,
      PrefetchHooks Function()
    >;
typedef $$FolderEntriesTableCreateCompanionBuilder =
    FolderEntriesCompanion Function({
      required String id,
      Value<String?> parentId,
      required String name,
      Value<String> icon,
      Value<String> colorHex,
      Value<bool> isFavorite,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$FolderEntriesTableUpdateCompanionBuilder =
    FolderEntriesCompanion Function({
      Value<String> id,
      Value<String?> parentId,
      Value<String> name,
      Value<String> icon,
      Value<String> colorHex,
      Value<bool> isFavorite,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$FolderEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $FolderEntriesTable> {
  $$FolderEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FolderEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $FolderEntriesTable> {
  $$FolderEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FolderEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FolderEntriesTable> {
  $$FolderEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FolderEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FolderEntriesTable,
          FolderEntry,
          $$FolderEntriesTableFilterComposer,
          $$FolderEntriesTableOrderingComposer,
          $$FolderEntriesTableAnnotationComposer,
          $$FolderEntriesTableCreateCompanionBuilder,
          $$FolderEntriesTableUpdateCompanionBuilder,
          (
            FolderEntry,
            BaseReferences<_$AppDatabase, $FolderEntriesTable, FolderEntry>,
          ),
          FolderEntry,
          PrefetchHooks Function()
        > {
  $$FolderEntriesTableTableManager(_$AppDatabase db, $FolderEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FolderEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FolderEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FolderEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FolderEntriesCompanion(
                id: id,
                parentId: parentId,
                name: name,
                icon: icon,
                colorHex: colorHex,
                isFavorite: isFavorite,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> parentId = const Value.absent(),
                required String name,
                Value<String> icon = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FolderEntriesCompanion.insert(
                id: id,
                parentId: parentId,
                name: name,
                icon: icon,
                colorHex: colorHex,
                isFavorite: isFavorite,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FolderEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FolderEntriesTable,
      FolderEntry,
      $$FolderEntriesTableFilterComposer,
      $$FolderEntriesTableOrderingComposer,
      $$FolderEntriesTableAnnotationComposer,
      $$FolderEntriesTableCreateCompanionBuilder,
      $$FolderEntriesTableUpdateCompanionBuilder,
      (
        FolderEntry,
        BaseReferences<_$AppDatabase, $FolderEntriesTable, FolderEntry>,
      ),
      FolderEntry,
      PrefetchHooks Function()
    >;
typedef $$PasswordHistoryEntriesTableCreateCompanionBuilder =
    PasswordHistoryEntriesCompanion Function({
      required String id,
      required String credentialId,
      required Uint8List encryptedPayload,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$PasswordHistoryEntriesTableUpdateCompanionBuilder =
    PasswordHistoryEntriesCompanion Function({
      Value<String> id,
      Value<String> credentialId,
      Value<Uint8List> encryptedPayload,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$PasswordHistoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PasswordHistoryEntriesTable> {
  $$PasswordHistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get credentialId => $composableBuilder(
    column: $table.credentialId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get encryptedPayload => $composableBuilder(
    column: $table.encryptedPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PasswordHistoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PasswordHistoryEntriesTable> {
  $$PasswordHistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get credentialId => $composableBuilder(
    column: $table.credentialId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get encryptedPayload => $composableBuilder(
    column: $table.encryptedPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PasswordHistoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PasswordHistoryEntriesTable> {
  $$PasswordHistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get credentialId => $composableBuilder(
    column: $table.credentialId,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get encryptedPayload => $composableBuilder(
    column: $table.encryptedPayload,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PasswordHistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PasswordHistoryEntriesTable,
          PasswordHistoryEntry,
          $$PasswordHistoryEntriesTableFilterComposer,
          $$PasswordHistoryEntriesTableOrderingComposer,
          $$PasswordHistoryEntriesTableAnnotationComposer,
          $$PasswordHistoryEntriesTableCreateCompanionBuilder,
          $$PasswordHistoryEntriesTableUpdateCompanionBuilder,
          (
            PasswordHistoryEntry,
            BaseReferences<
              _$AppDatabase,
              $PasswordHistoryEntriesTable,
              PasswordHistoryEntry
            >,
          ),
          PasswordHistoryEntry,
          PrefetchHooks Function()
        > {
  $$PasswordHistoryEntriesTableTableManager(
    _$AppDatabase db,
    $PasswordHistoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PasswordHistoryEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PasswordHistoryEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PasswordHistoryEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> credentialId = const Value.absent(),
                Value<Uint8List> encryptedPayload = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PasswordHistoryEntriesCompanion(
                id: id,
                credentialId: credentialId,
                encryptedPayload: encryptedPayload,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String credentialId,
                required Uint8List encryptedPayload,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PasswordHistoryEntriesCompanion.insert(
                id: id,
                credentialId: credentialId,
                encryptedPayload: encryptedPayload,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PasswordHistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PasswordHistoryEntriesTable,
      PasswordHistoryEntry,
      $$PasswordHistoryEntriesTableFilterComposer,
      $$PasswordHistoryEntriesTableOrderingComposer,
      $$PasswordHistoryEntriesTableAnnotationComposer,
      $$PasswordHistoryEntriesTableCreateCompanionBuilder,
      $$PasswordHistoryEntriesTableUpdateCompanionBuilder,
      (
        PasswordHistoryEntry,
        BaseReferences<
          _$AppDatabase,
          $PasswordHistoryEntriesTable,
          PasswordHistoryEntry
        >,
      ),
      PasswordHistoryEntry,
      PrefetchHooks Function()
    >;
typedef $$SecureFileEntriesTableCreateCompanionBuilder =
    SecureFileEntriesCompanion Function({
      required String id,
      required String name,
      required int sizeBytes,
      required String storedFileName,
      Value<String?> mimeHint,
      Value<String?> note,
      Value<String?> folderId,
      Value<bool> isFavorite,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$SecureFileEntriesTableUpdateCompanionBuilder =
    SecureFileEntriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> sizeBytes,
      Value<String> storedFileName,
      Value<String?> mimeHint,
      Value<String?> note,
      Value<String?> folderId,
      Value<bool> isFavorite,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$SecureFileEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SecureFileEntriesTable> {
  $$SecureFileEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storedFileName => $composableBuilder(
    column: $table.storedFileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeHint => $composableBuilder(
    column: $table.mimeHint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SecureFileEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SecureFileEntriesTable> {
  $$SecureFileEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storedFileName => $composableBuilder(
    column: $table.storedFileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeHint => $composableBuilder(
    column: $table.mimeHint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SecureFileEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SecureFileEntriesTable> {
  $$SecureFileEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get storedFileName => $composableBuilder(
    column: $table.storedFileName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeHint =>
      $composableBuilder(column: $table.mimeHint, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SecureFileEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SecureFileEntriesTable,
          SecureFileEntry,
          $$SecureFileEntriesTableFilterComposer,
          $$SecureFileEntriesTableOrderingComposer,
          $$SecureFileEntriesTableAnnotationComposer,
          $$SecureFileEntriesTableCreateCompanionBuilder,
          $$SecureFileEntriesTableUpdateCompanionBuilder,
          (
            SecureFileEntry,
            BaseReferences<
              _$AppDatabase,
              $SecureFileEntriesTable,
              SecureFileEntry
            >,
          ),
          SecureFileEntry,
          PrefetchHooks Function()
        > {
  $$SecureFileEntriesTableTableManager(
    _$AppDatabase db,
    $SecureFileEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SecureFileEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SecureFileEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SecureFileEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String> storedFileName = const Value.absent(),
                Value<String?> mimeHint = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SecureFileEntriesCompanion(
                id: id,
                name: name,
                sizeBytes: sizeBytes,
                storedFileName: storedFileName,
                mimeHint: mimeHint,
                note: note,
                folderId: folderId,
                isFavorite: isFavorite,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int sizeBytes,
                required String storedFileName,
                Value<String?> mimeHint = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SecureFileEntriesCompanion.insert(
                id: id,
                name: name,
                sizeBytes: sizeBytes,
                storedFileName: storedFileName,
                mimeHint: mimeHint,
                note: note,
                folderId: folderId,
                isFavorite: isFavorite,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SecureFileEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SecureFileEntriesTable,
      SecureFileEntry,
      $$SecureFileEntriesTableFilterComposer,
      $$SecureFileEntriesTableOrderingComposer,
      $$SecureFileEntriesTableAnnotationComposer,
      $$SecureFileEntriesTableCreateCompanionBuilder,
      $$SecureFileEntriesTableUpdateCompanionBuilder,
      (
        SecureFileEntry,
        BaseReferences<_$AppDatabase, $SecureFileEntriesTable, SecureFileEntry>,
      ),
      SecureFileEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CredentialEntriesTableTableManager get credentialEntries =>
      $$CredentialEntriesTableTableManager(_db, _db.credentialEntries);
  $$CategoryEntriesTableTableManager get categoryEntries =>
      $$CategoryEntriesTableTableManager(_db, _db.categoryEntries);
  $$FolderEntriesTableTableManager get folderEntries =>
      $$FolderEntriesTableTableManager(_db, _db.folderEntries);
  $$PasswordHistoryEntriesTableTableManager get passwordHistoryEntries =>
      $$PasswordHistoryEntriesTableTableManager(
        _db,
        _db.passwordHistoryEntries,
      );
  $$SecureFileEntriesTableTableManager get secureFileEntries =>
      $$SecureFileEntriesTableTableManager(_db, _db.secureFileEntries);
}

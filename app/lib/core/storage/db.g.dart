// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $ConnectionsMetaTable extends ConnectionsMeta
    with TableInfo<$ConnectionsMetaTable, ConnectionsMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConnectionsMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('hosting'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerId,
    displayName,
    accountId,
    fetchedAt,
    lastError,
    kind,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'connections_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConnectionsMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConnectionsMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConnectionsMetaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
    );
  }

  @override
  $ConnectionsMetaTable createAlias(String alias) {
    return $ConnectionsMetaTable(attachedDatabase, alias);
  }
}

class ConnectionsMetaData extends DataClass
    implements Insertable<ConnectionsMetaData> {
  final String id;
  final String providerId;
  final String displayName;
  final String? accountId;
  final DateTime? fetchedAt;
  final String? lastError;

  /// 'hosting' | 'registrar' — distinguishes a HostRef from a RegistrarRef
  /// connection (§3.1). Existing v1 rows migrate to 'hosting' with no
  /// backfill needed.
  final String kind;
  const ConnectionsMetaData({
    required this.id,
    required this.providerId,
    required this.displayName,
    this.accountId,
    this.fetchedAt,
    this.lastError,
    required this.kind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['provider_id'] = Variable<String>(providerId);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    if (!nullToAbsent || fetchedAt != null) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['kind'] = Variable<String>(kind);
    return map;
  }

  ConnectionsMetaCompanion toCompanion(bool nullToAbsent) {
    return ConnectionsMetaCompanion(
      id: Value(id),
      providerId: Value(providerId),
      displayName: Value(displayName),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      fetchedAt: fetchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(fetchedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      kind: Value(kind),
    );
  }

  factory ConnectionsMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConnectionsMetaData(
      id: serializer.fromJson<String>(json['id']),
      providerId: serializer.fromJson<String>(json['providerId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      fetchedAt: serializer.fromJson<DateTime?>(json['fetchedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      kind: serializer.fromJson<String>(json['kind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'providerId': serializer.toJson<String>(providerId),
      'displayName': serializer.toJson<String>(displayName),
      'accountId': serializer.toJson<String?>(accountId),
      'fetchedAt': serializer.toJson<DateTime?>(fetchedAt),
      'lastError': serializer.toJson<String?>(lastError),
      'kind': serializer.toJson<String>(kind),
    };
  }

  ConnectionsMetaData copyWith({
    String? id,
    String? providerId,
    String? displayName,
    Value<String?> accountId = const Value.absent(),
    Value<DateTime?> fetchedAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    String? kind,
  }) => ConnectionsMetaData(
    id: id ?? this.id,
    providerId: providerId ?? this.providerId,
    displayName: displayName ?? this.displayName,
    accountId: accountId.present ? accountId.value : this.accountId,
    fetchedAt: fetchedAt.present ? fetchedAt.value : this.fetchedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    kind: kind ?? this.kind,
  );
  ConnectionsMetaData copyWithCompanion(ConnectionsMetaCompanion data) {
    return ConnectionsMetaData(
      id: data.id.present ? data.id.value : this.id,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionsMetaData(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('displayName: $displayName, ')
          ..write('accountId: $accountId, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('lastError: $lastError, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    providerId,
    displayName,
    accountId,
    fetchedAt,
    lastError,
    kind,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConnectionsMetaData &&
          other.id == this.id &&
          other.providerId == this.providerId &&
          other.displayName == this.displayName &&
          other.accountId == this.accountId &&
          other.fetchedAt == this.fetchedAt &&
          other.lastError == this.lastError &&
          other.kind == this.kind);
}

class ConnectionsMetaCompanion extends UpdateCompanion<ConnectionsMetaData> {
  final Value<String> id;
  final Value<String> providerId;
  final Value<String> displayName;
  final Value<String?> accountId;
  final Value<DateTime?> fetchedAt;
  final Value<String?> lastError;
  final Value<String> kind;
  final Value<int> rowid;
  const ConnectionsMetaCompanion({
    this.id = const Value.absent(),
    this.providerId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.accountId = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.kind = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConnectionsMetaCompanion.insert({
    required String id,
    required String providerId,
    required String displayName,
    this.accountId = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.kind = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       providerId = Value(providerId),
       displayName = Value(displayName);
  static Insertable<ConnectionsMetaData> custom({
    Expression<String>? id,
    Expression<String>? providerId,
    Expression<String>? displayName,
    Expression<String>? accountId,
    Expression<DateTime>? fetchedAt,
    Expression<String>? lastError,
    Expression<String>? kind,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerId != null) 'provider_id': providerId,
      if (displayName != null) 'display_name': displayName,
      if (accountId != null) 'account_id': accountId,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (lastError != null) 'last_error': lastError,
      if (kind != null) 'kind': kind,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConnectionsMetaCompanion copyWith({
    Value<String>? id,
    Value<String>? providerId,
    Value<String>? displayName,
    Value<String?>? accountId,
    Value<DateTime?>? fetchedAt,
    Value<String?>? lastError,
    Value<String>? kind,
    Value<int>? rowid,
  }) {
    return ConnectionsMetaCompanion(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      displayName: displayName ?? this.displayName,
      accountId: accountId ?? this.accountId,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      lastError: lastError ?? this.lastError,
      kind: kind ?? this.kind,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionsMetaCompanion(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('displayName: $displayName, ')
          ..write('accountId: $accountId, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('lastError: $lastError, ')
          ..write('kind: $kind, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _connectionIdMeta = const VerificationMeta(
    'connectionId',
  );
  @override
  late final GeneratedColumn<String> connectionId = GeneratedColumn<String>(
    'connection_id',
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
  static const VerificationMeta _frameworkMeta = const VerificationMeta(
    'framework',
  );
  @override
  late final GeneratedColumn<String> framework = GeneratedColumn<String>(
    'framework',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productionBranchMeta = const VerificationMeta(
    'productionBranch',
  );
  @override
  late final GeneratedColumn<String> productionBranch = GeneratedColumn<String>(
    'production_branch',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    connectionId,
    name,
    framework,
    productionBranch,
    updatedAt,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('connection_id')) {
      context.handle(
        _connectionIdMeta,
        connectionId.isAcceptableOrUnknown(
          data['connection_id']!,
          _connectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_connectionIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('framework')) {
      context.handle(
        _frameworkMeta,
        framework.isAcceptableOrUnknown(data['framework']!, _frameworkMeta),
      );
    }
    if (data.containsKey('production_branch')) {
      context.handle(
        _productionBranchMeta,
        productionBranch.isAcceptableOrUnknown(
          data['production_branch']!,
          _productionBranchMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      connectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}connection_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      framework: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}framework'],
      ),
      productionBranch: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}production_branch'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final String id;
  final String connectionId;
  final String name;
  final String? framework;
  final String? productionBranch;
  final DateTime? updatedAt;
  final DateTime fetchedAt;
  const Project({
    required this.id,
    required this.connectionId,
    required this.name,
    this.framework,
    this.productionBranch,
    this.updatedAt,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['connection_id'] = Variable<String>(connectionId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || framework != null) {
      map['framework'] = Variable<String>(framework);
    }
    if (!nullToAbsent || productionBranch != null) {
      map['production_branch'] = Variable<String>(productionBranch);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      connectionId: Value(connectionId),
      name: Value(name),
      framework: framework == null && nullToAbsent
          ? const Value.absent()
          : Value(framework),
      productionBranch: productionBranch == null && nullToAbsent
          ? const Value.absent()
          : Value(productionBranch),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<String>(json['id']),
      connectionId: serializer.fromJson<String>(json['connectionId']),
      name: serializer.fromJson<String>(json['name']),
      framework: serializer.fromJson<String?>(json['framework']),
      productionBranch: serializer.fromJson<String?>(json['productionBranch']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'connectionId': serializer.toJson<String>(connectionId),
      'name': serializer.toJson<String>(name),
      'framework': serializer.toJson<String?>(framework),
      'productionBranch': serializer.toJson<String?>(productionBranch),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  Project copyWith({
    String? id,
    String? connectionId,
    String? name,
    Value<String?> framework = const Value.absent(),
    Value<String?> productionBranch = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    DateTime? fetchedAt,
  }) => Project(
    id: id ?? this.id,
    connectionId: connectionId ?? this.connectionId,
    name: name ?? this.name,
    framework: framework.present ? framework.value : this.framework,
    productionBranch: productionBranch.present
        ? productionBranch.value
        : this.productionBranch,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      connectionId: data.connectionId.present
          ? data.connectionId.value
          : this.connectionId,
      name: data.name.present ? data.name.value : this.name,
      framework: data.framework.present ? data.framework.value : this.framework,
      productionBranch: data.productionBranch.present
          ? data.productionBranch.value
          : this.productionBranch,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('connectionId: $connectionId, ')
          ..write('name: $name, ')
          ..write('framework: $framework, ')
          ..write('productionBranch: $productionBranch, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    connectionId,
    name,
    framework,
    productionBranch,
    updatedAt,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.connectionId == this.connectionId &&
          other.name == this.name &&
          other.framework == this.framework &&
          other.productionBranch == this.productionBranch &&
          other.updatedAt == this.updatedAt &&
          other.fetchedAt == this.fetchedAt);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<String> id;
  final Value<String> connectionId;
  final Value<String> name;
  final Value<String?> framework;
  final Value<String?> productionBranch;
  final Value<DateTime?> updatedAt;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.connectionId = const Value.absent(),
    this.name = const Value.absent(),
    this.framework = const Value.absent(),
    this.productionBranch = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String id,
    required String connectionId,
    required String name,
    this.framework = const Value.absent(),
    this.productionBranch = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       connectionId = Value(connectionId),
       name = Value(name),
       fetchedAt = Value(fetchedAt);
  static Insertable<Project> custom({
    Expression<String>? id,
    Expression<String>? connectionId,
    Expression<String>? name,
    Expression<String>? framework,
    Expression<String>? productionBranch,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (connectionId != null) 'connection_id': connectionId,
      if (name != null) 'name': name,
      if (framework != null) 'framework': framework,
      if (productionBranch != null) 'production_branch': productionBranch,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? connectionId,
    Value<String>? name,
    Value<String?>? framework,
    Value<String?>? productionBranch,
    Value<DateTime?>? updatedAt,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      connectionId: connectionId ?? this.connectionId,
      name: name ?? this.name,
      framework: framework ?? this.framework,
      productionBranch: productionBranch ?? this.productionBranch,
      updatedAt: updatedAt ?? this.updatedAt,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (connectionId.present) {
      map['connection_id'] = Variable<String>(connectionId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (framework.present) {
      map['framework'] = Variable<String>(framework.value);
    }
    if (productionBranch.present) {
      map['production_branch'] = Variable<String>(productionBranch.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('connectionId: $connectionId, ')
          ..write('name: $name, ')
          ..write('framework: $framework, ')
          ..write('productionBranch: $productionBranch, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectDomainsTable extends ProjectDomains
    with TableInfo<$ProjectDomainsTable, ProjectDomain> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectDomainsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<int> rowId = GeneratedColumn<int>(
    'row_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _connectionIdMeta = const VerificationMeta(
    'connectionId',
  );
  @override
  late final GeneratedColumn<String> connectionId = GeneratedColumn<String>(
    'connection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    rowId,
    projectId,
    connectionId,
    domain,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_domains';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectDomain> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('connection_id')) {
      context.handle(
        _connectionIdMeta,
        connectionId.isAcceptableOrUnknown(
          data['connection_id']!,
          _connectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_connectionIdMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rowId};
  @override
  ProjectDomain map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectDomain(
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      connectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}connection_id'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $ProjectDomainsTable createAlias(String alias) {
    return $ProjectDomainsTable(attachedDatabase, alias);
  }
}

class ProjectDomain extends DataClass implements Insertable<ProjectDomain> {
  final int rowId;
  final String projectId;
  final String connectionId;
  final String domain;
  final DateTime fetchedAt;
  const ProjectDomain({
    required this.rowId,
    required this.projectId,
    required this.connectionId,
    required this.domain,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_id'] = Variable<int>(rowId);
    map['project_id'] = Variable<String>(projectId);
    map['connection_id'] = Variable<String>(connectionId);
    map['domain'] = Variable<String>(domain);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  ProjectDomainsCompanion toCompanion(bool nullToAbsent) {
    return ProjectDomainsCompanion(
      rowId: Value(rowId),
      projectId: Value(projectId),
      connectionId: Value(connectionId),
      domain: Value(domain),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory ProjectDomain.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectDomain(
      rowId: serializer.fromJson<int>(json['rowId']),
      projectId: serializer.fromJson<String>(json['projectId']),
      connectionId: serializer.fromJson<String>(json['connectionId']),
      domain: serializer.fromJson<String>(json['domain']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowId': serializer.toJson<int>(rowId),
      'projectId': serializer.toJson<String>(projectId),
      'connectionId': serializer.toJson<String>(connectionId),
      'domain': serializer.toJson<String>(domain),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  ProjectDomain copyWith({
    int? rowId,
    String? projectId,
    String? connectionId,
    String? domain,
    DateTime? fetchedAt,
  }) => ProjectDomain(
    rowId: rowId ?? this.rowId,
    projectId: projectId ?? this.projectId,
    connectionId: connectionId ?? this.connectionId,
    domain: domain ?? this.domain,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  ProjectDomain copyWithCompanion(ProjectDomainsCompanion data) {
    return ProjectDomain(
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      connectionId: data.connectionId.present
          ? data.connectionId.value
          : this.connectionId,
      domain: data.domain.present ? data.domain.value : this.domain,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectDomain(')
          ..write('rowId: $rowId, ')
          ..write('projectId: $projectId, ')
          ..write('connectionId: $connectionId, ')
          ..write('domain: $domain, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(rowId, projectId, connectionId, domain, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectDomain &&
          other.rowId == this.rowId &&
          other.projectId == this.projectId &&
          other.connectionId == this.connectionId &&
          other.domain == this.domain &&
          other.fetchedAt == this.fetchedAt);
}

class ProjectDomainsCompanion extends UpdateCompanion<ProjectDomain> {
  final Value<int> rowId;
  final Value<String> projectId;
  final Value<String> connectionId;
  final Value<String> domain;
  final Value<DateTime> fetchedAt;
  const ProjectDomainsCompanion({
    this.rowId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.connectionId = const Value.absent(),
    this.domain = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  ProjectDomainsCompanion.insert({
    this.rowId = const Value.absent(),
    required String projectId,
    required String connectionId,
    required String domain,
    required DateTime fetchedAt,
  }) : projectId = Value(projectId),
       connectionId = Value(connectionId),
       domain = Value(domain),
       fetchedAt = Value(fetchedAt);
  static Insertable<ProjectDomain> custom({
    Expression<int>? rowId,
    Expression<String>? projectId,
    Expression<String>? connectionId,
    Expression<String>? domain,
    Expression<DateTime>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (rowId != null) 'row_id': rowId,
      if (projectId != null) 'project_id': projectId,
      if (connectionId != null) 'connection_id': connectionId,
      if (domain != null) 'domain': domain,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  ProjectDomainsCompanion copyWith({
    Value<int>? rowId,
    Value<String>? projectId,
    Value<String>? connectionId,
    Value<String>? domain,
    Value<DateTime>? fetchedAt,
  }) {
    return ProjectDomainsCompanion(
      rowId: rowId ?? this.rowId,
      projectId: projectId ?? this.projectId,
      connectionId: connectionId ?? this.connectionId,
      domain: domain ?? this.domain,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowId.present) {
      map['row_id'] = Variable<int>(rowId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (connectionId.present) {
      map['connection_id'] = Variable<String>(connectionId.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectDomainsCompanion(')
          ..write('rowId: $rowId, ')
          ..write('projectId: $projectId, ')
          ..write('connectionId: $connectionId, ')
          ..write('domain: $domain, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

class $DeploymentsTable extends Deployments
    with TableInfo<$DeploymentsTable, Deployment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeploymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _connectionIdMeta = const VerificationMeta(
    'connectionId',
  );
  @override
  late final GeneratedColumn<String> connectionId = GeneratedColumn<String>(
    'connection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _branchMeta = const VerificationMeta('branch');
  @override
  late final GeneratedColumn<String> branch = GeneratedColumn<String>(
    'branch',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _environmentMeta = const VerificationMeta(
    'environment',
  );
  @override
  late final GeneratedColumn<String> environment = GeneratedColumn<String>(
    'environment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commitMessageMeta = const VerificationMeta(
    'commitMessage',
  );
  @override
  late final GeneratedColumn<String> commitMessage = GeneratedColumn<String>(
    'commit_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commitShaMeta = const VerificationMeta(
    'commitSha',
  );
  @override
  late final GeneratedColumn<String> commitSha = GeneratedColumn<String>(
    'commit_sha',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commitAuthorMeta = const VerificationMeta(
    'commitAuthor',
  );
  @override
  late final GeneratedColumn<String> commitAuthor = GeneratedColumn<String>(
    'commit_author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    connectionId,
    status,
    url,
    branch,
    environment,
    createdAt,
    durationSeconds,
    errorMessage,
    commitMessage,
    commitSha,
    commitAuthor,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deployments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Deployment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('connection_id')) {
      context.handle(
        _connectionIdMeta,
        connectionId.isAcceptableOrUnknown(
          data['connection_id']!,
          _connectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_connectionIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('branch')) {
      context.handle(
        _branchMeta,
        branch.isAcceptableOrUnknown(data['branch']!, _branchMeta),
      );
    }
    if (data.containsKey('environment')) {
      context.handle(
        _environmentMeta,
        environment.isAcceptableOrUnknown(
          data['environment']!,
          _environmentMeta,
        ),
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
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('commit_message')) {
      context.handle(
        _commitMessageMeta,
        commitMessage.isAcceptableOrUnknown(
          data['commit_message']!,
          _commitMessageMeta,
        ),
      );
    }
    if (data.containsKey('commit_sha')) {
      context.handle(
        _commitShaMeta,
        commitSha.isAcceptableOrUnknown(data['commit_sha']!, _commitShaMeta),
      );
    }
    if (data.containsKey('commit_author')) {
      context.handle(
        _commitAuthorMeta,
        commitAuthor.isAcceptableOrUnknown(
          data['commit_author']!,
          _commitAuthorMeta,
        ),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Deployment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Deployment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      connectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}connection_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      branch: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch'],
      ),
      environment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}environment'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      commitMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commit_message'],
      ),
      commitSha: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commit_sha'],
      ),
      commitAuthor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commit_author'],
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $DeploymentsTable createAlias(String alias) {
    return $DeploymentsTable(attachedDatabase, alias);
  }
}

class Deployment extends DataClass implements Insertable<Deployment> {
  final String id;
  final String projectId;
  final String connectionId;

  /// Canonical DeployStatus enum name string.
  final String status;
  final String? url;
  final String? branch;
  final String? environment;
  final DateTime createdAt;
  final int? durationSeconds;
  final String? errorMessage;
  final String? commitMessage;
  final String? commitSha;
  final String? commitAuthor;
  final DateTime fetchedAt;
  const Deployment({
    required this.id,
    required this.projectId,
    required this.connectionId,
    required this.status,
    this.url,
    this.branch,
    this.environment,
    required this.createdAt,
    this.durationSeconds,
    this.errorMessage,
    this.commitMessage,
    this.commitSha,
    this.commitAuthor,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['connection_id'] = Variable<String>(connectionId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || branch != null) {
      map['branch'] = Variable<String>(branch);
    }
    if (!nullToAbsent || environment != null) {
      map['environment'] = Variable<String>(environment);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || commitMessage != null) {
      map['commit_message'] = Variable<String>(commitMessage);
    }
    if (!nullToAbsent || commitSha != null) {
      map['commit_sha'] = Variable<String>(commitSha);
    }
    if (!nullToAbsent || commitAuthor != null) {
      map['commit_author'] = Variable<String>(commitAuthor);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  DeploymentsCompanion toCompanion(bool nullToAbsent) {
    return DeploymentsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      connectionId: Value(connectionId),
      status: Value(status),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      branch: branch == null && nullToAbsent
          ? const Value.absent()
          : Value(branch),
      environment: environment == null && nullToAbsent
          ? const Value.absent()
          : Value(environment),
      createdAt: Value(createdAt),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      commitMessage: commitMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(commitMessage),
      commitSha: commitSha == null && nullToAbsent
          ? const Value.absent()
          : Value(commitSha),
      commitAuthor: commitAuthor == null && nullToAbsent
          ? const Value.absent()
          : Value(commitAuthor),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory Deployment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Deployment(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      connectionId: serializer.fromJson<String>(json['connectionId']),
      status: serializer.fromJson<String>(json['status']),
      url: serializer.fromJson<String?>(json['url']),
      branch: serializer.fromJson<String?>(json['branch']),
      environment: serializer.fromJson<String?>(json['environment']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      commitMessage: serializer.fromJson<String?>(json['commitMessage']),
      commitSha: serializer.fromJson<String?>(json['commitSha']),
      commitAuthor: serializer.fromJson<String?>(json['commitAuthor']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'connectionId': serializer.toJson<String>(connectionId),
      'status': serializer.toJson<String>(status),
      'url': serializer.toJson<String?>(url),
      'branch': serializer.toJson<String?>(branch),
      'environment': serializer.toJson<String?>(environment),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'commitMessage': serializer.toJson<String?>(commitMessage),
      'commitSha': serializer.toJson<String?>(commitSha),
      'commitAuthor': serializer.toJson<String?>(commitAuthor),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  Deployment copyWith({
    String? id,
    String? projectId,
    String? connectionId,
    String? status,
    Value<String?> url = const Value.absent(),
    Value<String?> branch = const Value.absent(),
    Value<String?> environment = const Value.absent(),
    DateTime? createdAt,
    Value<int?> durationSeconds = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    Value<String?> commitMessage = const Value.absent(),
    Value<String?> commitSha = const Value.absent(),
    Value<String?> commitAuthor = const Value.absent(),
    DateTime? fetchedAt,
  }) => Deployment(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    connectionId: connectionId ?? this.connectionId,
    status: status ?? this.status,
    url: url.present ? url.value : this.url,
    branch: branch.present ? branch.value : this.branch,
    environment: environment.present ? environment.value : this.environment,
    createdAt: createdAt ?? this.createdAt,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    commitMessage: commitMessage.present
        ? commitMessage.value
        : this.commitMessage,
    commitSha: commitSha.present ? commitSha.value : this.commitSha,
    commitAuthor: commitAuthor.present ? commitAuthor.value : this.commitAuthor,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  Deployment copyWithCompanion(DeploymentsCompanion data) {
    return Deployment(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      connectionId: data.connectionId.present
          ? data.connectionId.value
          : this.connectionId,
      status: data.status.present ? data.status.value : this.status,
      url: data.url.present ? data.url.value : this.url,
      branch: data.branch.present ? data.branch.value : this.branch,
      environment: data.environment.present
          ? data.environment.value
          : this.environment,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      commitMessage: data.commitMessage.present
          ? data.commitMessage.value
          : this.commitMessage,
      commitSha: data.commitSha.present ? data.commitSha.value : this.commitSha,
      commitAuthor: data.commitAuthor.present
          ? data.commitAuthor.value
          : this.commitAuthor,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Deployment(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('connectionId: $connectionId, ')
          ..write('status: $status, ')
          ..write('url: $url, ')
          ..write('branch: $branch, ')
          ..write('environment: $environment, ')
          ..write('createdAt: $createdAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('commitMessage: $commitMessage, ')
          ..write('commitSha: $commitSha, ')
          ..write('commitAuthor: $commitAuthor, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    connectionId,
    status,
    url,
    branch,
    environment,
    createdAt,
    durationSeconds,
    errorMessage,
    commitMessage,
    commitSha,
    commitAuthor,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Deployment &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.connectionId == this.connectionId &&
          other.status == this.status &&
          other.url == this.url &&
          other.branch == this.branch &&
          other.environment == this.environment &&
          other.createdAt == this.createdAt &&
          other.durationSeconds == this.durationSeconds &&
          other.errorMessage == this.errorMessage &&
          other.commitMessage == this.commitMessage &&
          other.commitSha == this.commitSha &&
          other.commitAuthor == this.commitAuthor &&
          other.fetchedAt == this.fetchedAt);
}

class DeploymentsCompanion extends UpdateCompanion<Deployment> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> connectionId;
  final Value<String> status;
  final Value<String?> url;
  final Value<String?> branch;
  final Value<String?> environment;
  final Value<DateTime> createdAt;
  final Value<int?> durationSeconds;
  final Value<String?> errorMessage;
  final Value<String?> commitMessage;
  final Value<String?> commitSha;
  final Value<String?> commitAuthor;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const DeploymentsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.connectionId = const Value.absent(),
    this.status = const Value.absent(),
    this.url = const Value.absent(),
    this.branch = const Value.absent(),
    this.environment = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.commitMessage = const Value.absent(),
    this.commitSha = const Value.absent(),
    this.commitAuthor = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeploymentsCompanion.insert({
    required String id,
    required String projectId,
    required String connectionId,
    required String status,
    this.url = const Value.absent(),
    this.branch = const Value.absent(),
    this.environment = const Value.absent(),
    required DateTime createdAt,
    this.durationSeconds = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.commitMessage = const Value.absent(),
    this.commitSha = const Value.absent(),
    this.commitAuthor = const Value.absent(),
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       connectionId = Value(connectionId),
       status = Value(status),
       createdAt = Value(createdAt),
       fetchedAt = Value(fetchedAt);
  static Insertable<Deployment> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? connectionId,
    Expression<String>? status,
    Expression<String>? url,
    Expression<String>? branch,
    Expression<String>? environment,
    Expression<DateTime>? createdAt,
    Expression<int>? durationSeconds,
    Expression<String>? errorMessage,
    Expression<String>? commitMessage,
    Expression<String>? commitSha,
    Expression<String>? commitAuthor,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (connectionId != null) 'connection_id': connectionId,
      if (status != null) 'status': status,
      if (url != null) 'url': url,
      if (branch != null) 'branch': branch,
      if (environment != null) 'environment': environment,
      if (createdAt != null) 'created_at': createdAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (errorMessage != null) 'error_message': errorMessage,
      if (commitMessage != null) 'commit_message': commitMessage,
      if (commitSha != null) 'commit_sha': commitSha,
      if (commitAuthor != null) 'commit_author': commitAuthor,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeploymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? connectionId,
    Value<String>? status,
    Value<String?>? url,
    Value<String?>? branch,
    Value<String?>? environment,
    Value<DateTime>? createdAt,
    Value<int?>? durationSeconds,
    Value<String?>? errorMessage,
    Value<String?>? commitMessage,
    Value<String?>? commitSha,
    Value<String?>? commitAuthor,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return DeploymentsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      connectionId: connectionId ?? this.connectionId,
      status: status ?? this.status,
      url: url ?? this.url,
      branch: branch ?? this.branch,
      environment: environment ?? this.environment,
      createdAt: createdAt ?? this.createdAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      errorMessage: errorMessage ?? this.errorMessage,
      commitMessage: commitMessage ?? this.commitMessage,
      commitSha: commitSha ?? this.commitSha,
      commitAuthor: commitAuthor ?? this.commitAuthor,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (connectionId.present) {
      map['connection_id'] = Variable<String>(connectionId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (branch.present) {
      map['branch'] = Variable<String>(branch.value);
    }
    if (environment.present) {
      map['environment'] = Variable<String>(environment.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (commitMessage.present) {
      map['commit_message'] = Variable<String>(commitMessage.value);
    }
    if (commitSha.present) {
      map['commit_sha'] = Variable<String>(commitSha.value);
    }
    if (commitAuthor.present) {
      map['commit_author'] = Variable<String>(commitAuthor.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeploymentsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('connectionId: $connectionId, ')
          ..write('status: $status, ')
          ..write('url: $url, ')
          ..write('branch: $branch, ')
          ..write('environment: $environment, ')
          ..write('createdAt: $createdAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('commitMessage: $commitMessage, ')
          ..write('commitSha: $commitSha, ')
          ..write('commitAuthor: $commitAuthor, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SiteLinksTable extends SiteLinks
    with TableInfo<$SiteLinksTable, SiteLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SiteLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<String> siteId = GeneratedColumn<String>(
    'site_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [siteId, source, externalId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'site_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<SiteLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_externalIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {siteId, source};
  @override
  SiteLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SiteLink(
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      )!,
    );
  }

  @override
  $SiteLinksTable createAlias(String alias) {
    return $SiteLinksTable(attachedDatabase, alias);
  }
}

class SiteLink extends DataClass implements Insertable<SiteLink> {
  final String siteId;
  final String source;
  final String externalId;
  const SiteLink({
    required this.siteId,
    required this.source,
    required this.externalId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['site_id'] = Variable<String>(siteId);
    map['source'] = Variable<String>(source);
    map['external_id'] = Variable<String>(externalId);
    return map;
  }

  SiteLinksCompanion toCompanion(bool nullToAbsent) {
    return SiteLinksCompanion(
      siteId: Value(siteId),
      source: Value(source),
      externalId: Value(externalId),
    );
  }

  factory SiteLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SiteLink(
      siteId: serializer.fromJson<String>(json['siteId']),
      source: serializer.fromJson<String>(json['source']),
      externalId: serializer.fromJson<String>(json['externalId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'siteId': serializer.toJson<String>(siteId),
      'source': serializer.toJson<String>(source),
      'externalId': serializer.toJson<String>(externalId),
    };
  }

  SiteLink copyWith({String? siteId, String? source, String? externalId}) =>
      SiteLink(
        siteId: siteId ?? this.siteId,
        source: source ?? this.source,
        externalId: externalId ?? this.externalId,
      );
  SiteLink copyWithCompanion(SiteLinksCompanion data) {
    return SiteLink(
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      source: data.source.present ? data.source.value : this.source,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SiteLink(')
          ..write('siteId: $siteId, ')
          ..write('source: $source, ')
          ..write('externalId: $externalId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(siteId, source, externalId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SiteLink &&
          other.siteId == this.siteId &&
          other.source == this.source &&
          other.externalId == this.externalId);
}

class SiteLinksCompanion extends UpdateCompanion<SiteLink> {
  final Value<String> siteId;
  final Value<String> source;
  final Value<String> externalId;
  final Value<int> rowid;
  const SiteLinksCompanion({
    this.siteId = const Value.absent(),
    this.source = const Value.absent(),
    this.externalId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SiteLinksCompanion.insert({
    required String siteId,
    required String source,
    required String externalId,
    this.rowid = const Value.absent(),
  }) : siteId = Value(siteId),
       source = Value(source),
       externalId = Value(externalId);
  static Insertable<SiteLink> custom({
    Expression<String>? siteId,
    Expression<String>? source,
    Expression<String>? externalId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (siteId != null) 'site_id': siteId,
      if (source != null) 'source': source,
      if (externalId != null) 'external_id': externalId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SiteLinksCompanion copyWith({
    Value<String>? siteId,
    Value<String>? source,
    Value<String>? externalId,
    Value<int>? rowid,
  }) {
    return SiteLinksCompanion(
      siteId: siteId ?? this.siteId,
      source: source ?? this.source,
      externalId: externalId ?? this.externalId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SiteLinksCompanion(')
          ..write('siteId: $siteId, ')
          ..write('source: $source, ')
          ..write('externalId: $externalId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RegisteredDomainsTable extends RegisteredDomains
    with TableInfo<$RegisteredDomainsTable, RegisteredDomainRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegisteredDomainsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _connectionIdMeta = const VerificationMeta(
    'connectionId',
  );
  @override
  late final GeneratedColumn<String> connectionId = GeneratedColumn<String>(
    'connection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _registrarIdMeta = const VerificationMeta(
    'registrarId',
  );
  @override
  late final GeneratedColumn<String> registrarId = GeneratedColumn<String>(
    'registrar_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawStatusMeta = const VerificationMeta(
    'rawStatus',
  );
  @override
  late final GeneratedColumn<String> rawStatus = GeneratedColumn<String>(
    'raw_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _autoRenewMeta = const VerificationMeta(
    'autoRenew',
  );
  @override
  late final GeneratedColumn<bool> autoRenew = GeneratedColumn<bool>(
    'auto_renew',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_renew" IN (0, 1))',
    ),
  );
  static const VerificationMeta _lockedMeta = const VerificationMeta('locked');
  @override
  late final GeneratedColumn<bool> locked = GeneratedColumn<bool>(
    'locked',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("locked" IN (0, 1))',
    ),
  );
  static const VerificationMeta _privacyMeta = const VerificationMeta(
    'privacy',
  );
  @override
  late final GeneratedColumn<bool> privacy = GeneratedColumn<bool>(
    'privacy',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("privacy" IN (0, 1))',
    ),
  );
  static const VerificationMeta _nameServersMeta = const VerificationMeta(
    'nameServers',
  );
  @override
  late final GeneratedColumn<String> nameServers = GeneratedColumn<String>(
    'name_servers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    domain,
    connectionId,
    registrarId,
    rawStatus,
    expiresAt,
    autoRenew,
    locked,
    privacy,
    nameServers,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'registered_domains';
  @override
  VerificationContext validateIntegrity(
    Insertable<RegisteredDomainRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('connection_id')) {
      context.handle(
        _connectionIdMeta,
        connectionId.isAcceptableOrUnknown(
          data['connection_id']!,
          _connectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_connectionIdMeta);
    }
    if (data.containsKey('registrar_id')) {
      context.handle(
        _registrarIdMeta,
        registrarId.isAcceptableOrUnknown(
          data['registrar_id']!,
          _registrarIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_registrarIdMeta);
    }
    if (data.containsKey('raw_status')) {
      context.handle(
        _rawStatusMeta,
        rawStatus.isAcceptableOrUnknown(data['raw_status']!, _rawStatusMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('auto_renew')) {
      context.handle(
        _autoRenewMeta,
        autoRenew.isAcceptableOrUnknown(data['auto_renew']!, _autoRenewMeta),
      );
    }
    if (data.containsKey('locked')) {
      context.handle(
        _lockedMeta,
        locked.isAcceptableOrUnknown(data['locked']!, _lockedMeta),
      );
    }
    if (data.containsKey('privacy')) {
      context.handle(
        _privacyMeta,
        privacy.isAcceptableOrUnknown(data['privacy']!, _privacyMeta),
      );
    }
    if (data.containsKey('name_servers')) {
      context.handle(
        _nameServersMeta,
        nameServers.isAcceptableOrUnknown(
          data['name_servers']!,
          _nameServersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nameServersMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {domain, connectionId};
  @override
  RegisteredDomainRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RegisteredDomainRow(
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      connectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}connection_id'],
      )!,
      registrarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registrar_id'],
      )!,
      rawStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_status'],
      ),
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
      autoRenew: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_renew'],
      ),
      locked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}locked'],
      ),
      privacy: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}privacy'],
      ),
      nameServers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_servers'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $RegisteredDomainsTable createAlias(String alias) {
    return $RegisteredDomainsTable(attachedDatabase, alias);
  }
}

class RegisteredDomainRow extends DataClass
    implements Insertable<RegisteredDomainRow> {
  final String domain;
  final String connectionId;
  final String registrarId;
  final String? rawStatus;
  final DateTime? expiresAt;
  final bool? autoRenew;
  final bool? locked;
  final bool? privacy;
  final String nameServers;
  final DateTime fetchedAt;
  const RegisteredDomainRow({
    required this.domain,
    required this.connectionId,
    required this.registrarId,
    this.rawStatus,
    this.expiresAt,
    this.autoRenew,
    this.locked,
    this.privacy,
    required this.nameServers,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['domain'] = Variable<String>(domain);
    map['connection_id'] = Variable<String>(connectionId);
    map['registrar_id'] = Variable<String>(registrarId);
    if (!nullToAbsent || rawStatus != null) {
      map['raw_status'] = Variable<String>(rawStatus);
    }
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    if (!nullToAbsent || autoRenew != null) {
      map['auto_renew'] = Variable<bool>(autoRenew);
    }
    if (!nullToAbsent || locked != null) {
      map['locked'] = Variable<bool>(locked);
    }
    if (!nullToAbsent || privacy != null) {
      map['privacy'] = Variable<bool>(privacy);
    }
    map['name_servers'] = Variable<String>(nameServers);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  RegisteredDomainsCompanion toCompanion(bool nullToAbsent) {
    return RegisteredDomainsCompanion(
      domain: Value(domain),
      connectionId: Value(connectionId),
      registrarId: Value(registrarId),
      rawStatus: rawStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(rawStatus),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      autoRenew: autoRenew == null && nullToAbsent
          ? const Value.absent()
          : Value(autoRenew),
      locked: locked == null && nullToAbsent
          ? const Value.absent()
          : Value(locked),
      privacy: privacy == null && nullToAbsent
          ? const Value.absent()
          : Value(privacy),
      nameServers: Value(nameServers),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory RegisteredDomainRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RegisteredDomainRow(
      domain: serializer.fromJson<String>(json['domain']),
      connectionId: serializer.fromJson<String>(json['connectionId']),
      registrarId: serializer.fromJson<String>(json['registrarId']),
      rawStatus: serializer.fromJson<String?>(json['rawStatus']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      autoRenew: serializer.fromJson<bool?>(json['autoRenew']),
      locked: serializer.fromJson<bool?>(json['locked']),
      privacy: serializer.fromJson<bool?>(json['privacy']),
      nameServers: serializer.fromJson<String>(json['nameServers']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'domain': serializer.toJson<String>(domain),
      'connectionId': serializer.toJson<String>(connectionId),
      'registrarId': serializer.toJson<String>(registrarId),
      'rawStatus': serializer.toJson<String?>(rawStatus),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'autoRenew': serializer.toJson<bool?>(autoRenew),
      'locked': serializer.toJson<bool?>(locked),
      'privacy': serializer.toJson<bool?>(privacy),
      'nameServers': serializer.toJson<String>(nameServers),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  RegisteredDomainRow copyWith({
    String? domain,
    String? connectionId,
    String? registrarId,
    Value<String?> rawStatus = const Value.absent(),
    Value<DateTime?> expiresAt = const Value.absent(),
    Value<bool?> autoRenew = const Value.absent(),
    Value<bool?> locked = const Value.absent(),
    Value<bool?> privacy = const Value.absent(),
    String? nameServers,
    DateTime? fetchedAt,
  }) => RegisteredDomainRow(
    domain: domain ?? this.domain,
    connectionId: connectionId ?? this.connectionId,
    registrarId: registrarId ?? this.registrarId,
    rawStatus: rawStatus.present ? rawStatus.value : this.rawStatus,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    autoRenew: autoRenew.present ? autoRenew.value : this.autoRenew,
    locked: locked.present ? locked.value : this.locked,
    privacy: privacy.present ? privacy.value : this.privacy,
    nameServers: nameServers ?? this.nameServers,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  RegisteredDomainRow copyWithCompanion(RegisteredDomainsCompanion data) {
    return RegisteredDomainRow(
      domain: data.domain.present ? data.domain.value : this.domain,
      connectionId: data.connectionId.present
          ? data.connectionId.value
          : this.connectionId,
      registrarId: data.registrarId.present
          ? data.registrarId.value
          : this.registrarId,
      rawStatus: data.rawStatus.present ? data.rawStatus.value : this.rawStatus,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      autoRenew: data.autoRenew.present ? data.autoRenew.value : this.autoRenew,
      locked: data.locked.present ? data.locked.value : this.locked,
      privacy: data.privacy.present ? data.privacy.value : this.privacy,
      nameServers: data.nameServers.present
          ? data.nameServers.value
          : this.nameServers,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RegisteredDomainRow(')
          ..write('domain: $domain, ')
          ..write('connectionId: $connectionId, ')
          ..write('registrarId: $registrarId, ')
          ..write('rawStatus: $rawStatus, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('autoRenew: $autoRenew, ')
          ..write('locked: $locked, ')
          ..write('privacy: $privacy, ')
          ..write('nameServers: $nameServers, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    domain,
    connectionId,
    registrarId,
    rawStatus,
    expiresAt,
    autoRenew,
    locked,
    privacy,
    nameServers,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegisteredDomainRow &&
          other.domain == this.domain &&
          other.connectionId == this.connectionId &&
          other.registrarId == this.registrarId &&
          other.rawStatus == this.rawStatus &&
          other.expiresAt == this.expiresAt &&
          other.autoRenew == this.autoRenew &&
          other.locked == this.locked &&
          other.privacy == this.privacy &&
          other.nameServers == this.nameServers &&
          other.fetchedAt == this.fetchedAt);
}

class RegisteredDomainsCompanion extends UpdateCompanion<RegisteredDomainRow> {
  final Value<String> domain;
  final Value<String> connectionId;
  final Value<String> registrarId;
  final Value<String?> rawStatus;
  final Value<DateTime?> expiresAt;
  final Value<bool?> autoRenew;
  final Value<bool?> locked;
  final Value<bool?> privacy;
  final Value<String> nameServers;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const RegisteredDomainsCompanion({
    this.domain = const Value.absent(),
    this.connectionId = const Value.absent(),
    this.registrarId = const Value.absent(),
    this.rawStatus = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.autoRenew = const Value.absent(),
    this.locked = const Value.absent(),
    this.privacy = const Value.absent(),
    this.nameServers = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RegisteredDomainsCompanion.insert({
    required String domain,
    required String connectionId,
    required String registrarId,
    this.rawStatus = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.autoRenew = const Value.absent(),
    this.locked = const Value.absent(),
    this.privacy = const Value.absent(),
    required String nameServers,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : domain = Value(domain),
       connectionId = Value(connectionId),
       registrarId = Value(registrarId),
       nameServers = Value(nameServers),
       fetchedAt = Value(fetchedAt);
  static Insertable<RegisteredDomainRow> custom({
    Expression<String>? domain,
    Expression<String>? connectionId,
    Expression<String>? registrarId,
    Expression<String>? rawStatus,
    Expression<DateTime>? expiresAt,
    Expression<bool>? autoRenew,
    Expression<bool>? locked,
    Expression<bool>? privacy,
    Expression<String>? nameServers,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (domain != null) 'domain': domain,
      if (connectionId != null) 'connection_id': connectionId,
      if (registrarId != null) 'registrar_id': registrarId,
      if (rawStatus != null) 'raw_status': rawStatus,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (autoRenew != null) 'auto_renew': autoRenew,
      if (locked != null) 'locked': locked,
      if (privacy != null) 'privacy': privacy,
      if (nameServers != null) 'name_servers': nameServers,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RegisteredDomainsCompanion copyWith({
    Value<String>? domain,
    Value<String>? connectionId,
    Value<String>? registrarId,
    Value<String?>? rawStatus,
    Value<DateTime?>? expiresAt,
    Value<bool?>? autoRenew,
    Value<bool?>? locked,
    Value<bool?>? privacy,
    Value<String>? nameServers,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return RegisteredDomainsCompanion(
      domain: domain ?? this.domain,
      connectionId: connectionId ?? this.connectionId,
      registrarId: registrarId ?? this.registrarId,
      rawStatus: rawStatus ?? this.rawStatus,
      expiresAt: expiresAt ?? this.expiresAt,
      autoRenew: autoRenew ?? this.autoRenew,
      locked: locked ?? this.locked,
      privacy: privacy ?? this.privacy,
      nameServers: nameServers ?? this.nameServers,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (connectionId.present) {
      map['connection_id'] = Variable<String>(connectionId.value);
    }
    if (registrarId.present) {
      map['registrar_id'] = Variable<String>(registrarId.value);
    }
    if (rawStatus.present) {
      map['raw_status'] = Variable<String>(rawStatus.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (autoRenew.present) {
      map['auto_renew'] = Variable<bool>(autoRenew.value);
    }
    if (locked.present) {
      map['locked'] = Variable<bool>(locked.value);
    }
    if (privacy.present) {
      map['privacy'] = Variable<bool>(privacy.value);
    }
    if (nameServers.present) {
      map['name_servers'] = Variable<String>(nameServers.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RegisteredDomainsCompanion(')
          ..write('domain: $domain, ')
          ..write('connectionId: $connectionId, ')
          ..write('registrarId: $registrarId, ')
          ..write('rawStatus: $rawStatus, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('autoRenew: $autoRenew, ')
          ..write('locked: $locked, ')
          ..write('privacy: $privacy, ')
          ..write('nameServers: $nameServers, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DnsRecordsCacheTable extends DnsRecordsCache
    with TableInfo<$DnsRecordsCacheTable, DnsRecordsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DnsRecordsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _connectionIdMeta = const VerificationMeta(
    'connectionId',
  );
  @override
  late final GeneratedColumn<String> connectionId = GeneratedColumn<String>(
    'connection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ttlMeta = const VerificationMeta('ttl');
  @override
  late final GeneratedColumn<int> ttl = GeneratedColumn<int>(
    'ttl',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proxiedMeta = const VerificationMeta(
    'proxied',
  );
  @override
  late final GeneratedColumn<bool> proxied = GeneratedColumn<bool>(
    'proxied',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("proxied" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    connectionId,
    domain,
    type,
    name,
    content,
    ttl,
    priority,
    proxied,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dns_records_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<DnsRecordsCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('connection_id')) {
      context.handle(
        _connectionIdMeta,
        connectionId.isAcceptableOrUnknown(
          data['connection_id']!,
          _connectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_connectionIdMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('ttl')) {
      context.handle(
        _ttlMeta,
        ttl.isAcceptableOrUnknown(data['ttl']!, _ttlMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('proxied')) {
      context.handle(
        _proxiedMeta,
        proxied.isAcceptableOrUnknown(data['proxied']!, _proxiedMeta),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, connectionId};
  @override
  DnsRecordsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DnsRecordsCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      connectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}connection_id'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      ttl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ttl'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      ),
      proxied: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}proxied'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $DnsRecordsCacheTable createAlias(String alias) {
    return $DnsRecordsCacheTable(attachedDatabase, alias);
  }
}

class DnsRecordsCacheData extends DataClass
    implements Insertable<DnsRecordsCacheData> {
  final String id;
  final String connectionId;
  final String domain;
  final String type;
  final String name;
  final String content;
  final int? ttl;
  final int? priority;
  final bool proxied;
  final DateTime fetchedAt;
  const DnsRecordsCacheData({
    required this.id,
    required this.connectionId,
    required this.domain,
    required this.type,
    required this.name,
    required this.content,
    this.ttl,
    this.priority,
    required this.proxied,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['connection_id'] = Variable<String>(connectionId);
    map['domain'] = Variable<String>(domain);
    map['type'] = Variable<String>(type);
    map['name'] = Variable<String>(name);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || ttl != null) {
      map['ttl'] = Variable<int>(ttl);
    }
    if (!nullToAbsent || priority != null) {
      map['priority'] = Variable<int>(priority);
    }
    map['proxied'] = Variable<bool>(proxied);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  DnsRecordsCacheCompanion toCompanion(bool nullToAbsent) {
    return DnsRecordsCacheCompanion(
      id: Value(id),
      connectionId: Value(connectionId),
      domain: Value(domain),
      type: Value(type),
      name: Value(name),
      content: Value(content),
      ttl: ttl == null && nullToAbsent ? const Value.absent() : Value(ttl),
      priority: priority == null && nullToAbsent
          ? const Value.absent()
          : Value(priority),
      proxied: Value(proxied),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory DnsRecordsCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DnsRecordsCacheData(
      id: serializer.fromJson<String>(json['id']),
      connectionId: serializer.fromJson<String>(json['connectionId']),
      domain: serializer.fromJson<String>(json['domain']),
      type: serializer.fromJson<String>(json['type']),
      name: serializer.fromJson<String>(json['name']),
      content: serializer.fromJson<String>(json['content']),
      ttl: serializer.fromJson<int?>(json['ttl']),
      priority: serializer.fromJson<int?>(json['priority']),
      proxied: serializer.fromJson<bool>(json['proxied']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'connectionId': serializer.toJson<String>(connectionId),
      'domain': serializer.toJson<String>(domain),
      'type': serializer.toJson<String>(type),
      'name': serializer.toJson<String>(name),
      'content': serializer.toJson<String>(content),
      'ttl': serializer.toJson<int?>(ttl),
      'priority': serializer.toJson<int?>(priority),
      'proxied': serializer.toJson<bool>(proxied),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  DnsRecordsCacheData copyWith({
    String? id,
    String? connectionId,
    String? domain,
    String? type,
    String? name,
    String? content,
    Value<int?> ttl = const Value.absent(),
    Value<int?> priority = const Value.absent(),
    bool? proxied,
    DateTime? fetchedAt,
  }) => DnsRecordsCacheData(
    id: id ?? this.id,
    connectionId: connectionId ?? this.connectionId,
    domain: domain ?? this.domain,
    type: type ?? this.type,
    name: name ?? this.name,
    content: content ?? this.content,
    ttl: ttl.present ? ttl.value : this.ttl,
    priority: priority.present ? priority.value : this.priority,
    proxied: proxied ?? this.proxied,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  DnsRecordsCacheData copyWithCompanion(DnsRecordsCacheCompanion data) {
    return DnsRecordsCacheData(
      id: data.id.present ? data.id.value : this.id,
      connectionId: data.connectionId.present
          ? data.connectionId.value
          : this.connectionId,
      domain: data.domain.present ? data.domain.value : this.domain,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      content: data.content.present ? data.content.value : this.content,
      ttl: data.ttl.present ? data.ttl.value : this.ttl,
      priority: data.priority.present ? data.priority.value : this.priority,
      proxied: data.proxied.present ? data.proxied.value : this.proxied,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DnsRecordsCacheData(')
          ..write('id: $id, ')
          ..write('connectionId: $connectionId, ')
          ..write('domain: $domain, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('content: $content, ')
          ..write('ttl: $ttl, ')
          ..write('priority: $priority, ')
          ..write('proxied: $proxied, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    connectionId,
    domain,
    type,
    name,
    content,
    ttl,
    priority,
    proxied,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DnsRecordsCacheData &&
          other.id == this.id &&
          other.connectionId == this.connectionId &&
          other.domain == this.domain &&
          other.type == this.type &&
          other.name == this.name &&
          other.content == this.content &&
          other.ttl == this.ttl &&
          other.priority == this.priority &&
          other.proxied == this.proxied &&
          other.fetchedAt == this.fetchedAt);
}

class DnsRecordsCacheCompanion extends UpdateCompanion<DnsRecordsCacheData> {
  final Value<String> id;
  final Value<String> connectionId;
  final Value<String> domain;
  final Value<String> type;
  final Value<String> name;
  final Value<String> content;
  final Value<int?> ttl;
  final Value<int?> priority;
  final Value<bool> proxied;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const DnsRecordsCacheCompanion({
    this.id = const Value.absent(),
    this.connectionId = const Value.absent(),
    this.domain = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.content = const Value.absent(),
    this.ttl = const Value.absent(),
    this.priority = const Value.absent(),
    this.proxied = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DnsRecordsCacheCompanion.insert({
    required String id,
    required String connectionId,
    required String domain,
    required String type,
    required String name,
    required String content,
    this.ttl = const Value.absent(),
    this.priority = const Value.absent(),
    this.proxied = const Value.absent(),
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       connectionId = Value(connectionId),
       domain = Value(domain),
       type = Value(type),
       name = Value(name),
       content = Value(content),
       fetchedAt = Value(fetchedAt);
  static Insertable<DnsRecordsCacheData> custom({
    Expression<String>? id,
    Expression<String>? connectionId,
    Expression<String>? domain,
    Expression<String>? type,
    Expression<String>? name,
    Expression<String>? content,
    Expression<int>? ttl,
    Expression<int>? priority,
    Expression<bool>? proxied,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (connectionId != null) 'connection_id': connectionId,
      if (domain != null) 'domain': domain,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (content != null) 'content': content,
      if (ttl != null) 'ttl': ttl,
      if (priority != null) 'priority': priority,
      if (proxied != null) 'proxied': proxied,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DnsRecordsCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? connectionId,
    Value<String>? domain,
    Value<String>? type,
    Value<String>? name,
    Value<String>? content,
    Value<int?>? ttl,
    Value<int?>? priority,
    Value<bool>? proxied,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return DnsRecordsCacheCompanion(
      id: id ?? this.id,
      connectionId: connectionId ?? this.connectionId,
      domain: domain ?? this.domain,
      type: type ?? this.type,
      name: name ?? this.name,
      content: content ?? this.content,
      ttl: ttl ?? this.ttl,
      priority: priority ?? this.priority,
      proxied: proxied ?? this.proxied,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (connectionId.present) {
      map['connection_id'] = Variable<String>(connectionId.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (ttl.present) {
      map['ttl'] = Variable<int>(ttl.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (proxied.present) {
      map['proxied'] = Variable<bool>(proxied.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DnsRecordsCacheCompanion(')
          ..write('id: $id, ')
          ..write('connectionId: $connectionId, ')
          ..write('domain: $domain, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('content: $content, ')
          ..write('ttl: $ttl, ')
          ..write('priority: $priority, ')
          ..write('proxied: $proxied, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ConnectionsMetaTable connectionsMeta = $ConnectionsMetaTable(
    this,
  );
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $ProjectDomainsTable projectDomains = $ProjectDomainsTable(this);
  late final $DeploymentsTable deployments = $DeploymentsTable(this);
  late final $SiteLinksTable siteLinks = $SiteLinksTable(this);
  late final $RegisteredDomainsTable registeredDomains =
      $RegisteredDomainsTable(this);
  late final $DnsRecordsCacheTable dnsRecordsCache = $DnsRecordsCacheTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    connectionsMeta,
    projects,
    projectDomains,
    deployments,
    siteLinks,
    registeredDomains,
    dnsRecordsCache,
  ];
}

typedef $$ConnectionsMetaTableCreateCompanionBuilder =
    ConnectionsMetaCompanion Function({
      required String id,
      required String providerId,
      required String displayName,
      Value<String?> accountId,
      Value<DateTime?> fetchedAt,
      Value<String?> lastError,
      Value<String> kind,
      Value<int> rowid,
    });
typedef $$ConnectionsMetaTableUpdateCompanionBuilder =
    ConnectionsMetaCompanion Function({
      Value<String> id,
      Value<String> providerId,
      Value<String> displayName,
      Value<String?> accountId,
      Value<DateTime?> fetchedAt,
      Value<String?> lastError,
      Value<String> kind,
      Value<int> rowid,
    });

class $$ConnectionsMetaTableFilterComposer
    extends Composer<_$AppDatabase, $ConnectionsMetaTable> {
  $$ConnectionsMetaTableFilterComposer({
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

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConnectionsMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $ConnectionsMetaTable> {
  $$ConnectionsMetaTableOrderingComposer({
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

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConnectionsMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConnectionsMetaTable> {
  $$ConnectionsMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);
}

class $$ConnectionsMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConnectionsMetaTable,
          ConnectionsMetaData,
          $$ConnectionsMetaTableFilterComposer,
          $$ConnectionsMetaTableOrderingComposer,
          $$ConnectionsMetaTableAnnotationComposer,
          $$ConnectionsMetaTableCreateCompanionBuilder,
          $$ConnectionsMetaTableUpdateCompanionBuilder,
          (
            ConnectionsMetaData,
            BaseReferences<
              _$AppDatabase,
              $ConnectionsMetaTable,
              ConnectionsMetaData
            >,
          ),
          ConnectionsMetaData,
          PrefetchHooks Function()
        > {
  $$ConnectionsMetaTableTableManager(
    _$AppDatabase db,
    $ConnectionsMetaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConnectionsMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConnectionsMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConnectionsMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<DateTime?> fetchedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConnectionsMetaCompanion(
                id: id,
                providerId: providerId,
                displayName: displayName,
                accountId: accountId,
                fetchedAt: fetchedAt,
                lastError: lastError,
                kind: kind,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String providerId,
                required String displayName,
                Value<String?> accountId = const Value.absent(),
                Value<DateTime?> fetchedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConnectionsMetaCompanion.insert(
                id: id,
                providerId: providerId,
                displayName: displayName,
                accountId: accountId,
                fetchedAt: fetchedAt,
                lastError: lastError,
                kind: kind,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConnectionsMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConnectionsMetaTable,
      ConnectionsMetaData,
      $$ConnectionsMetaTableFilterComposer,
      $$ConnectionsMetaTableOrderingComposer,
      $$ConnectionsMetaTableAnnotationComposer,
      $$ConnectionsMetaTableCreateCompanionBuilder,
      $$ConnectionsMetaTableUpdateCompanionBuilder,
      (
        ConnectionsMetaData,
        BaseReferences<
          _$AppDatabase,
          $ConnectionsMetaTable,
          ConnectionsMetaData
        >,
      ),
      ConnectionsMetaData,
      PrefetchHooks Function()
    >;
typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      required String id,
      required String connectionId,
      required String name,
      Value<String?> framework,
      Value<String?> productionBranch,
      Value<DateTime?> updatedAt,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<String> id,
      Value<String> connectionId,
      Value<String> name,
      Value<String?> framework,
      Value<String?> productionBranch,
      Value<DateTime?> updatedAt,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
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

  ColumnFilters<String> get connectionId => $composableBuilder(
    column: $table.connectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get framework => $composableBuilder(
    column: $table.framework,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productionBranch => $composableBuilder(
    column: $table.productionBranch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
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

  ColumnOrderings<String> get connectionId => $composableBuilder(
    column: $table.connectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get framework => $composableBuilder(
    column: $table.framework,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productionBranch => $composableBuilder(
    column: $table.productionBranch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get connectionId => $composableBuilder(
    column: $table.connectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get framework =>
      $composableBuilder(column: $table.framework, builder: (column) => column);

  GeneratedColumn<String> get productionBranch => $composableBuilder(
    column: $table.productionBranch,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
          Project,
          PrefetchHooks Function()
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> connectionId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> framework = const Value.absent(),
                Value<String?> productionBranch = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                connectionId: connectionId,
                name: name,
                framework: framework,
                productionBranch: productionBranch,
                updatedAt: updatedAt,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String connectionId,
                required String name,
                Value<String?> framework = const Value.absent(),
                Value<String?> productionBranch = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                connectionId: connectionId,
                name: name,
                framework: framework,
                productionBranch: productionBranch,
                updatedAt: updatedAt,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
      Project,
      PrefetchHooks Function()
    >;
typedef $$ProjectDomainsTableCreateCompanionBuilder =
    ProjectDomainsCompanion Function({
      Value<int> rowId,
      required String projectId,
      required String connectionId,
      required String domain,
      required DateTime fetchedAt,
    });
typedef $$ProjectDomainsTableUpdateCompanionBuilder =
    ProjectDomainsCompanion Function({
      Value<int> rowId,
      Value<String> projectId,
      Value<String> connectionId,
      Value<String> domain,
      Value<DateTime> fetchedAt,
    });

class $$ProjectDomainsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectDomainsTable> {
  $$ProjectDomainsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get connectionId => $composableBuilder(
    column: $table.connectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProjectDomainsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectDomainsTable> {
  $$ProjectDomainsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get connectionId => $composableBuilder(
    column: $table.connectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectDomainsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectDomainsTable> {
  $$ProjectDomainsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get connectionId => $composableBuilder(
    column: $table.connectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$ProjectDomainsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectDomainsTable,
          ProjectDomain,
          $$ProjectDomainsTableFilterComposer,
          $$ProjectDomainsTableOrderingComposer,
          $$ProjectDomainsTableAnnotationComposer,
          $$ProjectDomainsTableCreateCompanionBuilder,
          $$ProjectDomainsTableUpdateCompanionBuilder,
          (
            ProjectDomain,
            BaseReferences<_$AppDatabase, $ProjectDomainsTable, ProjectDomain>,
          ),
          ProjectDomain,
          PrefetchHooks Function()
        > {
  $$ProjectDomainsTableTableManager(
    _$AppDatabase db,
    $ProjectDomainsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectDomainsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectDomainsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectDomainsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> rowId = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> connectionId = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
              }) => ProjectDomainsCompanion(
                rowId: rowId,
                projectId: projectId,
                connectionId: connectionId,
                domain: domain,
                fetchedAt: fetchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> rowId = const Value.absent(),
                required String projectId,
                required String connectionId,
                required String domain,
                required DateTime fetchedAt,
              }) => ProjectDomainsCompanion.insert(
                rowId: rowId,
                projectId: projectId,
                connectionId: connectionId,
                domain: domain,
                fetchedAt: fetchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectDomainsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectDomainsTable,
      ProjectDomain,
      $$ProjectDomainsTableFilterComposer,
      $$ProjectDomainsTableOrderingComposer,
      $$ProjectDomainsTableAnnotationComposer,
      $$ProjectDomainsTableCreateCompanionBuilder,
      $$ProjectDomainsTableUpdateCompanionBuilder,
      (
        ProjectDomain,
        BaseReferences<_$AppDatabase, $ProjectDomainsTable, ProjectDomain>,
      ),
      ProjectDomain,
      PrefetchHooks Function()
    >;
typedef $$DeploymentsTableCreateCompanionBuilder =
    DeploymentsCompanion Function({
      required String id,
      required String projectId,
      required String connectionId,
      required String status,
      Value<String?> url,
      Value<String?> branch,
      Value<String?> environment,
      required DateTime createdAt,
      Value<int?> durationSeconds,
      Value<String?> errorMessage,
      Value<String?> commitMessage,
      Value<String?> commitSha,
      Value<String?> commitAuthor,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$DeploymentsTableUpdateCompanionBuilder =
    DeploymentsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> connectionId,
      Value<String> status,
      Value<String?> url,
      Value<String?> branch,
      Value<String?> environment,
      Value<DateTime> createdAt,
      Value<int?> durationSeconds,
      Value<String?> errorMessage,
      Value<String?> commitMessage,
      Value<String?> commitSha,
      Value<String?> commitAuthor,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$DeploymentsTableFilterComposer
    extends Composer<_$AppDatabase, $DeploymentsTable> {
  $$DeploymentsTableFilterComposer({
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

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get connectionId => $composableBuilder(
    column: $table.connectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branch => $composableBuilder(
    column: $table.branch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get environment => $composableBuilder(
    column: $table.environment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commitMessage => $composableBuilder(
    column: $table.commitMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commitSha => $composableBuilder(
    column: $table.commitSha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commitAuthor => $composableBuilder(
    column: $table.commitAuthor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeploymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeploymentsTable> {
  $$DeploymentsTableOrderingComposer({
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

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get connectionId => $composableBuilder(
    column: $table.connectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branch => $composableBuilder(
    column: $table.branch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get environment => $composableBuilder(
    column: $table.environment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commitMessage => $composableBuilder(
    column: $table.commitMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commitSha => $composableBuilder(
    column: $table.commitSha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commitAuthor => $composableBuilder(
    column: $table.commitAuthor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeploymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeploymentsTable> {
  $$DeploymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get connectionId => $composableBuilder(
    column: $table.connectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get branch =>
      $composableBuilder(column: $table.branch, builder: (column) => column);

  GeneratedColumn<String> get environment => $composableBuilder(
    column: $table.environment,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get commitMessage => $composableBuilder(
    column: $table.commitMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get commitSha =>
      $composableBuilder(column: $table.commitSha, builder: (column) => column);

  GeneratedColumn<String> get commitAuthor => $composableBuilder(
    column: $table.commitAuthor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$DeploymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeploymentsTable,
          Deployment,
          $$DeploymentsTableFilterComposer,
          $$DeploymentsTableOrderingComposer,
          $$DeploymentsTableAnnotationComposer,
          $$DeploymentsTableCreateCompanionBuilder,
          $$DeploymentsTableUpdateCompanionBuilder,
          (
            Deployment,
            BaseReferences<_$AppDatabase, $DeploymentsTable, Deployment>,
          ),
          Deployment,
          PrefetchHooks Function()
        > {
  $$DeploymentsTableTableManager(_$AppDatabase db, $DeploymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeploymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeploymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeploymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> connectionId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> branch = const Value.absent(),
                Value<String?> environment = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> commitMessage = const Value.absent(),
                Value<String?> commitSha = const Value.absent(),
                Value<String?> commitAuthor = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeploymentsCompanion(
                id: id,
                projectId: projectId,
                connectionId: connectionId,
                status: status,
                url: url,
                branch: branch,
                environment: environment,
                createdAt: createdAt,
                durationSeconds: durationSeconds,
                errorMessage: errorMessage,
                commitMessage: commitMessage,
                commitSha: commitSha,
                commitAuthor: commitAuthor,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String connectionId,
                required String status,
                Value<String?> url = const Value.absent(),
                Value<String?> branch = const Value.absent(),
                Value<String?> environment = const Value.absent(),
                required DateTime createdAt,
                Value<int?> durationSeconds = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> commitMessage = const Value.absent(),
                Value<String?> commitSha = const Value.absent(),
                Value<String?> commitAuthor = const Value.absent(),
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => DeploymentsCompanion.insert(
                id: id,
                projectId: projectId,
                connectionId: connectionId,
                status: status,
                url: url,
                branch: branch,
                environment: environment,
                createdAt: createdAt,
                durationSeconds: durationSeconds,
                errorMessage: errorMessage,
                commitMessage: commitMessage,
                commitSha: commitSha,
                commitAuthor: commitAuthor,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeploymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeploymentsTable,
      Deployment,
      $$DeploymentsTableFilterComposer,
      $$DeploymentsTableOrderingComposer,
      $$DeploymentsTableAnnotationComposer,
      $$DeploymentsTableCreateCompanionBuilder,
      $$DeploymentsTableUpdateCompanionBuilder,
      (
        Deployment,
        BaseReferences<_$AppDatabase, $DeploymentsTable, Deployment>,
      ),
      Deployment,
      PrefetchHooks Function()
    >;
typedef $$SiteLinksTableCreateCompanionBuilder =
    SiteLinksCompanion Function({
      required String siteId,
      required String source,
      required String externalId,
      Value<int> rowid,
    });
typedef $$SiteLinksTableUpdateCompanionBuilder =
    SiteLinksCompanion Function({
      Value<String> siteId,
      Value<String> source,
      Value<String> externalId,
      Value<int> rowid,
    });

class $$SiteLinksTableFilterComposer
    extends Composer<_$AppDatabase, $SiteLinksTable> {
  $$SiteLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SiteLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $SiteLinksTable> {
  $$SiteLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SiteLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $SiteLinksTable> {
  $$SiteLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );
}

class $$SiteLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SiteLinksTable,
          SiteLink,
          $$SiteLinksTableFilterComposer,
          $$SiteLinksTableOrderingComposer,
          $$SiteLinksTableAnnotationComposer,
          $$SiteLinksTableCreateCompanionBuilder,
          $$SiteLinksTableUpdateCompanionBuilder,
          (SiteLink, BaseReferences<_$AppDatabase, $SiteLinksTable, SiteLink>),
          SiteLink,
          PrefetchHooks Function()
        > {
  $$SiteLinksTableTableManager(_$AppDatabase db, $SiteLinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SiteLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SiteLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SiteLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> siteId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> externalId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SiteLinksCompanion(
                siteId: siteId,
                source: source,
                externalId: externalId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String siteId,
                required String source,
                required String externalId,
                Value<int> rowid = const Value.absent(),
              }) => SiteLinksCompanion.insert(
                siteId: siteId,
                source: source,
                externalId: externalId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SiteLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SiteLinksTable,
      SiteLink,
      $$SiteLinksTableFilterComposer,
      $$SiteLinksTableOrderingComposer,
      $$SiteLinksTableAnnotationComposer,
      $$SiteLinksTableCreateCompanionBuilder,
      $$SiteLinksTableUpdateCompanionBuilder,
      (SiteLink, BaseReferences<_$AppDatabase, $SiteLinksTable, SiteLink>),
      SiteLink,
      PrefetchHooks Function()
    >;
typedef $$RegisteredDomainsTableCreateCompanionBuilder =
    RegisteredDomainsCompanion Function({
      required String domain,
      required String connectionId,
      required String registrarId,
      Value<String?> rawStatus,
      Value<DateTime?> expiresAt,
      Value<bool?> autoRenew,
      Value<bool?> locked,
      Value<bool?> privacy,
      required String nameServers,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$RegisteredDomainsTableUpdateCompanionBuilder =
    RegisteredDomainsCompanion Function({
      Value<String> domain,
      Value<String> connectionId,
      Value<String> registrarId,
      Value<String?> rawStatus,
      Value<DateTime?> expiresAt,
      Value<bool?> autoRenew,
      Value<bool?> locked,
      Value<bool?> privacy,
      Value<String> nameServers,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$RegisteredDomainsTableFilterComposer
    extends Composer<_$AppDatabase, $RegisteredDomainsTable> {
  $$RegisteredDomainsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get connectionId => $composableBuilder(
    column: $table.connectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registrarId => $composableBuilder(
    column: $table.registrarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawStatus => $composableBuilder(
    column: $table.rawStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoRenew => $composableBuilder(
    column: $table.autoRenew,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get privacy => $composableBuilder(
    column: $table.privacy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameServers => $composableBuilder(
    column: $table.nameServers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RegisteredDomainsTableOrderingComposer
    extends Composer<_$AppDatabase, $RegisteredDomainsTable> {
  $$RegisteredDomainsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get connectionId => $composableBuilder(
    column: $table.connectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registrarId => $composableBuilder(
    column: $table.registrarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawStatus => $composableBuilder(
    column: $table.rawStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoRenew => $composableBuilder(
    column: $table.autoRenew,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get privacy => $composableBuilder(
    column: $table.privacy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameServers => $composableBuilder(
    column: $table.nameServers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RegisteredDomainsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RegisteredDomainsTable> {
  $$RegisteredDomainsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get connectionId => $composableBuilder(
    column: $table.connectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get registrarId => $composableBuilder(
    column: $table.registrarId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawStatus =>
      $composableBuilder(column: $table.rawStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<bool> get autoRenew =>
      $composableBuilder(column: $table.autoRenew, builder: (column) => column);

  GeneratedColumn<bool> get locked =>
      $composableBuilder(column: $table.locked, builder: (column) => column);

  GeneratedColumn<bool> get privacy =>
      $composableBuilder(column: $table.privacy, builder: (column) => column);

  GeneratedColumn<String> get nameServers => $composableBuilder(
    column: $table.nameServers,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$RegisteredDomainsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RegisteredDomainsTable,
          RegisteredDomainRow,
          $$RegisteredDomainsTableFilterComposer,
          $$RegisteredDomainsTableOrderingComposer,
          $$RegisteredDomainsTableAnnotationComposer,
          $$RegisteredDomainsTableCreateCompanionBuilder,
          $$RegisteredDomainsTableUpdateCompanionBuilder,
          (
            RegisteredDomainRow,
            BaseReferences<
              _$AppDatabase,
              $RegisteredDomainsTable,
              RegisteredDomainRow
            >,
          ),
          RegisteredDomainRow,
          PrefetchHooks Function()
        > {
  $$RegisteredDomainsTableTableManager(
    _$AppDatabase db,
    $RegisteredDomainsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RegisteredDomainsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RegisteredDomainsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RegisteredDomainsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> domain = const Value.absent(),
                Value<String> connectionId = const Value.absent(),
                Value<String> registrarId = const Value.absent(),
                Value<String?> rawStatus = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<bool?> autoRenew = const Value.absent(),
                Value<bool?> locked = const Value.absent(),
                Value<bool?> privacy = const Value.absent(),
                Value<String> nameServers = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RegisteredDomainsCompanion(
                domain: domain,
                connectionId: connectionId,
                registrarId: registrarId,
                rawStatus: rawStatus,
                expiresAt: expiresAt,
                autoRenew: autoRenew,
                locked: locked,
                privacy: privacy,
                nameServers: nameServers,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String domain,
                required String connectionId,
                required String registrarId,
                Value<String?> rawStatus = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<bool?> autoRenew = const Value.absent(),
                Value<bool?> locked = const Value.absent(),
                Value<bool?> privacy = const Value.absent(),
                required String nameServers,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => RegisteredDomainsCompanion.insert(
                domain: domain,
                connectionId: connectionId,
                registrarId: registrarId,
                rawStatus: rawStatus,
                expiresAt: expiresAt,
                autoRenew: autoRenew,
                locked: locked,
                privacy: privacy,
                nameServers: nameServers,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RegisteredDomainsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RegisteredDomainsTable,
      RegisteredDomainRow,
      $$RegisteredDomainsTableFilterComposer,
      $$RegisteredDomainsTableOrderingComposer,
      $$RegisteredDomainsTableAnnotationComposer,
      $$RegisteredDomainsTableCreateCompanionBuilder,
      $$RegisteredDomainsTableUpdateCompanionBuilder,
      (
        RegisteredDomainRow,
        BaseReferences<
          _$AppDatabase,
          $RegisteredDomainsTable,
          RegisteredDomainRow
        >,
      ),
      RegisteredDomainRow,
      PrefetchHooks Function()
    >;
typedef $$DnsRecordsCacheTableCreateCompanionBuilder =
    DnsRecordsCacheCompanion Function({
      required String id,
      required String connectionId,
      required String domain,
      required String type,
      required String name,
      required String content,
      Value<int?> ttl,
      Value<int?> priority,
      Value<bool> proxied,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$DnsRecordsCacheTableUpdateCompanionBuilder =
    DnsRecordsCacheCompanion Function({
      Value<String> id,
      Value<String> connectionId,
      Value<String> domain,
      Value<String> type,
      Value<String> name,
      Value<String> content,
      Value<int?> ttl,
      Value<int?> priority,
      Value<bool> proxied,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$DnsRecordsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $DnsRecordsCacheTable> {
  $$DnsRecordsCacheTableFilterComposer({
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

  ColumnFilters<String> get connectionId => $composableBuilder(
    column: $table.connectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ttl => $composableBuilder(
    column: $table.ttl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get proxied => $composableBuilder(
    column: $table.proxied,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DnsRecordsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $DnsRecordsCacheTable> {
  $$DnsRecordsCacheTableOrderingComposer({
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

  ColumnOrderings<String> get connectionId => $composableBuilder(
    column: $table.connectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ttl => $composableBuilder(
    column: $table.ttl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get proxied => $composableBuilder(
    column: $table.proxied,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DnsRecordsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $DnsRecordsCacheTable> {
  $$DnsRecordsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get connectionId => $composableBuilder(
    column: $table.connectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get ttl =>
      $composableBuilder(column: $table.ttl, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get proxied =>
      $composableBuilder(column: $table.proxied, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$DnsRecordsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DnsRecordsCacheTable,
          DnsRecordsCacheData,
          $$DnsRecordsCacheTableFilterComposer,
          $$DnsRecordsCacheTableOrderingComposer,
          $$DnsRecordsCacheTableAnnotationComposer,
          $$DnsRecordsCacheTableCreateCompanionBuilder,
          $$DnsRecordsCacheTableUpdateCompanionBuilder,
          (
            DnsRecordsCacheData,
            BaseReferences<
              _$AppDatabase,
              $DnsRecordsCacheTable,
              DnsRecordsCacheData
            >,
          ),
          DnsRecordsCacheData,
          PrefetchHooks Function()
        > {
  $$DnsRecordsCacheTableTableManager(
    _$AppDatabase db,
    $DnsRecordsCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DnsRecordsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DnsRecordsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DnsRecordsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> connectionId = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int?> ttl = const Value.absent(),
                Value<int?> priority = const Value.absent(),
                Value<bool> proxied = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DnsRecordsCacheCompanion(
                id: id,
                connectionId: connectionId,
                domain: domain,
                type: type,
                name: name,
                content: content,
                ttl: ttl,
                priority: priority,
                proxied: proxied,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String connectionId,
                required String domain,
                required String type,
                required String name,
                required String content,
                Value<int?> ttl = const Value.absent(),
                Value<int?> priority = const Value.absent(),
                Value<bool> proxied = const Value.absent(),
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => DnsRecordsCacheCompanion.insert(
                id: id,
                connectionId: connectionId,
                domain: domain,
                type: type,
                name: name,
                content: content,
                ttl: ttl,
                priority: priority,
                proxied: proxied,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DnsRecordsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DnsRecordsCacheTable,
      DnsRecordsCacheData,
      $$DnsRecordsCacheTableFilterComposer,
      $$DnsRecordsCacheTableOrderingComposer,
      $$DnsRecordsCacheTableAnnotationComposer,
      $$DnsRecordsCacheTableCreateCompanionBuilder,
      $$DnsRecordsCacheTableUpdateCompanionBuilder,
      (
        DnsRecordsCacheData,
        BaseReferences<
          _$AppDatabase,
          $DnsRecordsCacheTable,
          DnsRecordsCacheData
        >,
      ),
      DnsRecordsCacheData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ConnectionsMetaTableTableManager get connectionsMeta =>
      $$ConnectionsMetaTableTableManager(_db, _db.connectionsMeta);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$ProjectDomainsTableTableManager get projectDomains =>
      $$ProjectDomainsTableTableManager(_db, _db.projectDomains);
  $$DeploymentsTableTableManager get deployments =>
      $$DeploymentsTableTableManager(_db, _db.deployments);
  $$SiteLinksTableTableManager get siteLinks =>
      $$SiteLinksTableTableManager(_db, _db.siteLinks);
  $$RegisteredDomainsTableTableManager get registeredDomains =>
      $$RegisteredDomainsTableTableManager(_db, _db.registeredDomains);
  $$DnsRecordsCacheTableTableManager get dnsRecordsCache =>
      $$DnsRecordsCacheTableTableManager(_db, _db.dnsRecordsCache);
}

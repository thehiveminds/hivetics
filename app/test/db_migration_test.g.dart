// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_migration_test.dart';

// ignore_for_file: type=lint
class $V1ConnectionsMetaTable extends V1ConnectionsMeta
    with TableInfo<$V1ConnectionsMetaTable, V1ConnectionsMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $V1ConnectionsMetaTable(this.attachedDatabase, [this._alias]);
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerId,
    displayName,
    accountId,
    fetchedAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'connections_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<V1ConnectionsMetaData> instance, {
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  V1ConnectionsMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return V1ConnectionsMetaData(
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
    );
  }

  @override
  $V1ConnectionsMetaTable createAlias(String alias) {
    return $V1ConnectionsMetaTable(attachedDatabase, alias);
  }
}

class V1ConnectionsMetaData extends DataClass
    implements Insertable<V1ConnectionsMetaData> {
  final String id;
  final String providerId;
  final String displayName;
  final String? accountId;
  final DateTime? fetchedAt;
  final String? lastError;
  const V1ConnectionsMetaData({
    required this.id,
    required this.providerId,
    required this.displayName,
    this.accountId,
    this.fetchedAt,
    this.lastError,
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
    return map;
  }

  V1ConnectionsMetaCompanion toCompanion(bool nullToAbsent) {
    return V1ConnectionsMetaCompanion(
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
    );
  }

  factory V1ConnectionsMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return V1ConnectionsMetaData(
      id: serializer.fromJson<String>(json['id']),
      providerId: serializer.fromJson<String>(json['providerId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      fetchedAt: serializer.fromJson<DateTime?>(json['fetchedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
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
    };
  }

  V1ConnectionsMetaData copyWith({
    String? id,
    String? providerId,
    String? displayName,
    Value<String?> accountId = const Value.absent(),
    Value<DateTime?> fetchedAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => V1ConnectionsMetaData(
    id: id ?? this.id,
    providerId: providerId ?? this.providerId,
    displayName: displayName ?? this.displayName,
    accountId: accountId.present ? accountId.value : this.accountId,
    fetchedAt: fetchedAt.present ? fetchedAt.value : this.fetchedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  V1ConnectionsMetaData copyWithCompanion(V1ConnectionsMetaCompanion data) {
    return V1ConnectionsMetaData(
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
    );
  }

  @override
  String toString() {
    return (StringBuffer('V1ConnectionsMetaData(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('displayName: $displayName, ')
          ..write('accountId: $accountId, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, providerId, displayName, accountId, fetchedAt, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is V1ConnectionsMetaData &&
          other.id == this.id &&
          other.providerId == this.providerId &&
          other.displayName == this.displayName &&
          other.accountId == this.accountId &&
          other.fetchedAt == this.fetchedAt &&
          other.lastError == this.lastError);
}

class V1ConnectionsMetaCompanion
    extends UpdateCompanion<V1ConnectionsMetaData> {
  final Value<String> id;
  final Value<String> providerId;
  final Value<String> displayName;
  final Value<String?> accountId;
  final Value<DateTime?> fetchedAt;
  final Value<String?> lastError;
  final Value<int> rowid;
  const V1ConnectionsMetaCompanion({
    this.id = const Value.absent(),
    this.providerId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.accountId = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  V1ConnectionsMetaCompanion.insert({
    required String id,
    required String providerId,
    required String displayName,
    this.accountId = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       providerId = Value(providerId),
       displayName = Value(displayName);
  static Insertable<V1ConnectionsMetaData> custom({
    Expression<String>? id,
    Expression<String>? providerId,
    Expression<String>? displayName,
    Expression<String>? accountId,
    Expression<DateTime>? fetchedAt,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerId != null) 'provider_id': providerId,
      if (displayName != null) 'display_name': displayName,
      if (accountId != null) 'account_id': accountId,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  V1ConnectionsMetaCompanion copyWith({
    Value<String>? id,
    Value<String>? providerId,
    Value<String>? displayName,
    Value<String?>? accountId,
    Value<DateTime?>? fetchedAt,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return V1ConnectionsMetaCompanion(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      displayName: displayName ?? this.displayName,
      accountId: accountId ?? this.accountId,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      lastError: lastError ?? this.lastError,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('V1ConnectionsMetaCompanion(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('displayName: $displayName, ')
          ..write('accountId: $accountId, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $V1ProjectsTable extends V1Projects
    with TableInfo<$V1ProjectsTable, V1Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $V1ProjectsTable(this.attachedDatabase, [this._alias]);
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
    Insertable<V1Project> instance, {
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
  V1Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return V1Project(
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
  $V1ProjectsTable createAlias(String alias) {
    return $V1ProjectsTable(attachedDatabase, alias);
  }
}

class V1Project extends DataClass implements Insertable<V1Project> {
  final String id;
  final String connectionId;
  final String name;
  final String? framework;
  final String? productionBranch;
  final DateTime? updatedAt;
  final DateTime fetchedAt;
  const V1Project({
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

  V1ProjectsCompanion toCompanion(bool nullToAbsent) {
    return V1ProjectsCompanion(
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

  factory V1Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return V1Project(
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

  V1Project copyWith({
    String? id,
    String? connectionId,
    String? name,
    Value<String?> framework = const Value.absent(),
    Value<String?> productionBranch = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    DateTime? fetchedAt,
  }) => V1Project(
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
  V1Project copyWithCompanion(V1ProjectsCompanion data) {
    return V1Project(
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
    return (StringBuffer('V1Project(')
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
      (other is V1Project &&
          other.id == this.id &&
          other.connectionId == this.connectionId &&
          other.name == this.name &&
          other.framework == this.framework &&
          other.productionBranch == this.productionBranch &&
          other.updatedAt == this.updatedAt &&
          other.fetchedAt == this.fetchedAt);
}

class V1ProjectsCompanion extends UpdateCompanion<V1Project> {
  final Value<String> id;
  final Value<String> connectionId;
  final Value<String> name;
  final Value<String?> framework;
  final Value<String?> productionBranch;
  final Value<DateTime?> updatedAt;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const V1ProjectsCompanion({
    this.id = const Value.absent(),
    this.connectionId = const Value.absent(),
    this.name = const Value.absent(),
    this.framework = const Value.absent(),
    this.productionBranch = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  V1ProjectsCompanion.insert({
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
  static Insertable<V1Project> custom({
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

  V1ProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? connectionId,
    Value<String>? name,
    Value<String?>? framework,
    Value<String?>? productionBranch,
    Value<DateTime?>? updatedAt,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return V1ProjectsCompanion(
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
    return (StringBuffer('V1ProjectsCompanion(')
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

class $V1ProjectDomainsTable extends V1ProjectDomains
    with TableInfo<$V1ProjectDomainsTable, V1ProjectDomain> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $V1ProjectDomainsTable(this.attachedDatabase, [this._alias]);
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
    Insertable<V1ProjectDomain> instance, {
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
  V1ProjectDomain map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return V1ProjectDomain(
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
  $V1ProjectDomainsTable createAlias(String alias) {
    return $V1ProjectDomainsTable(attachedDatabase, alias);
  }
}

class V1ProjectDomain extends DataClass implements Insertable<V1ProjectDomain> {
  final int rowId;
  final String projectId;
  final String connectionId;
  final String domain;
  final DateTime fetchedAt;
  const V1ProjectDomain({
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

  V1ProjectDomainsCompanion toCompanion(bool nullToAbsent) {
    return V1ProjectDomainsCompanion(
      rowId: Value(rowId),
      projectId: Value(projectId),
      connectionId: Value(connectionId),
      domain: Value(domain),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory V1ProjectDomain.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return V1ProjectDomain(
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

  V1ProjectDomain copyWith({
    int? rowId,
    String? projectId,
    String? connectionId,
    String? domain,
    DateTime? fetchedAt,
  }) => V1ProjectDomain(
    rowId: rowId ?? this.rowId,
    projectId: projectId ?? this.projectId,
    connectionId: connectionId ?? this.connectionId,
    domain: domain ?? this.domain,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  V1ProjectDomain copyWithCompanion(V1ProjectDomainsCompanion data) {
    return V1ProjectDomain(
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
    return (StringBuffer('V1ProjectDomain(')
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
      (other is V1ProjectDomain &&
          other.rowId == this.rowId &&
          other.projectId == this.projectId &&
          other.connectionId == this.connectionId &&
          other.domain == this.domain &&
          other.fetchedAt == this.fetchedAt);
}

class V1ProjectDomainsCompanion extends UpdateCompanion<V1ProjectDomain> {
  final Value<int> rowId;
  final Value<String> projectId;
  final Value<String> connectionId;
  final Value<String> domain;
  final Value<DateTime> fetchedAt;
  const V1ProjectDomainsCompanion({
    this.rowId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.connectionId = const Value.absent(),
    this.domain = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  V1ProjectDomainsCompanion.insert({
    this.rowId = const Value.absent(),
    required String projectId,
    required String connectionId,
    required String domain,
    required DateTime fetchedAt,
  }) : projectId = Value(projectId),
       connectionId = Value(connectionId),
       domain = Value(domain),
       fetchedAt = Value(fetchedAt);
  static Insertable<V1ProjectDomain> custom({
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

  V1ProjectDomainsCompanion copyWith({
    Value<int>? rowId,
    Value<String>? projectId,
    Value<String>? connectionId,
    Value<String>? domain,
    Value<DateTime>? fetchedAt,
  }) {
    return V1ProjectDomainsCompanion(
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
    return (StringBuffer('V1ProjectDomainsCompanion(')
          ..write('rowId: $rowId, ')
          ..write('projectId: $projectId, ')
          ..write('connectionId: $connectionId, ')
          ..write('domain: $domain, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

class $V1DeploymentsTable extends V1Deployments
    with TableInfo<$V1DeploymentsTable, V1Deployment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $V1DeploymentsTable(this.attachedDatabase, [this._alias]);
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
    Insertable<V1Deployment> instance, {
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
  V1Deployment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return V1Deployment(
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
  $V1DeploymentsTable createAlias(String alias) {
    return $V1DeploymentsTable(attachedDatabase, alias);
  }
}

class V1Deployment extends DataClass implements Insertable<V1Deployment> {
  final String id;
  final String projectId;
  final String connectionId;
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
  const V1Deployment({
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

  V1DeploymentsCompanion toCompanion(bool nullToAbsent) {
    return V1DeploymentsCompanion(
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

  factory V1Deployment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return V1Deployment(
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

  V1Deployment copyWith({
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
  }) => V1Deployment(
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
  V1Deployment copyWithCompanion(V1DeploymentsCompanion data) {
    return V1Deployment(
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
    return (StringBuffer('V1Deployment(')
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
      (other is V1Deployment &&
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

class V1DeploymentsCompanion extends UpdateCompanion<V1Deployment> {
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
  const V1DeploymentsCompanion({
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
  V1DeploymentsCompanion.insert({
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
  static Insertable<V1Deployment> custom({
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

  V1DeploymentsCompanion copyWith({
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
    return V1DeploymentsCompanion(
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
    return (StringBuffer('V1DeploymentsCompanion(')
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

class $V1SiteLinksTable extends V1SiteLinks
    with TableInfo<$V1SiteLinksTable, V1SiteLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $V1SiteLinksTable(this.attachedDatabase, [this._alias]);
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
    Insertable<V1SiteLink> instance, {
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
  V1SiteLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return V1SiteLink(
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
  $V1SiteLinksTable createAlias(String alias) {
    return $V1SiteLinksTable(attachedDatabase, alias);
  }
}

class V1SiteLink extends DataClass implements Insertable<V1SiteLink> {
  final String siteId;
  final String source;
  final String externalId;
  const V1SiteLink({
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

  V1SiteLinksCompanion toCompanion(bool nullToAbsent) {
    return V1SiteLinksCompanion(
      siteId: Value(siteId),
      source: Value(source),
      externalId: Value(externalId),
    );
  }

  factory V1SiteLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return V1SiteLink(
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

  V1SiteLink copyWith({String? siteId, String? source, String? externalId}) =>
      V1SiteLink(
        siteId: siteId ?? this.siteId,
        source: source ?? this.source,
        externalId: externalId ?? this.externalId,
      );
  V1SiteLink copyWithCompanion(V1SiteLinksCompanion data) {
    return V1SiteLink(
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      source: data.source.present ? data.source.value : this.source,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('V1SiteLink(')
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
      (other is V1SiteLink &&
          other.siteId == this.siteId &&
          other.source == this.source &&
          other.externalId == this.externalId);
}

class V1SiteLinksCompanion extends UpdateCompanion<V1SiteLink> {
  final Value<String> siteId;
  final Value<String> source;
  final Value<String> externalId;
  final Value<int> rowid;
  const V1SiteLinksCompanion({
    this.siteId = const Value.absent(),
    this.source = const Value.absent(),
    this.externalId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  V1SiteLinksCompanion.insert({
    required String siteId,
    required String source,
    required String externalId,
    this.rowid = const Value.absent(),
  }) : siteId = Value(siteId),
       source = Value(source),
       externalId = Value(externalId);
  static Insertable<V1SiteLink> custom({
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

  V1SiteLinksCompanion copyWith({
    Value<String>? siteId,
    Value<String>? source,
    Value<String>? externalId,
    Value<int>? rowid,
  }) {
    return V1SiteLinksCompanion(
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
    return (StringBuffer('V1SiteLinksCompanion(')
          ..write('siteId: $siteId, ')
          ..write('source: $source, ')
          ..write('externalId: $externalId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$V1Database extends GeneratedDatabase {
  _$V1Database(QueryExecutor e) : super(e);
  $V1DatabaseManager get managers => $V1DatabaseManager(this);
  late final $V1ConnectionsMetaTable v1ConnectionsMeta =
      $V1ConnectionsMetaTable(this);
  late final $V1ProjectsTable v1Projects = $V1ProjectsTable(this);
  late final $V1ProjectDomainsTable v1ProjectDomains = $V1ProjectDomainsTable(
    this,
  );
  late final $V1DeploymentsTable v1Deployments = $V1DeploymentsTable(this);
  late final $V1SiteLinksTable v1SiteLinks = $V1SiteLinksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    v1ConnectionsMeta,
    v1Projects,
    v1ProjectDomains,
    v1Deployments,
    v1SiteLinks,
  ];
}

typedef $$V1ConnectionsMetaTableCreateCompanionBuilder =
    V1ConnectionsMetaCompanion Function({
      required String id,
      required String providerId,
      required String displayName,
      Value<String?> accountId,
      Value<DateTime?> fetchedAt,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$V1ConnectionsMetaTableUpdateCompanionBuilder =
    V1ConnectionsMetaCompanion Function({
      Value<String> id,
      Value<String> providerId,
      Value<String> displayName,
      Value<String?> accountId,
      Value<DateTime?> fetchedAt,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$V1ConnectionsMetaTableFilterComposer
    extends Composer<_$V1Database, $V1ConnectionsMetaTable> {
  $$V1ConnectionsMetaTableFilterComposer({
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
}

class $$V1ConnectionsMetaTableOrderingComposer
    extends Composer<_$V1Database, $V1ConnectionsMetaTable> {
  $$V1ConnectionsMetaTableOrderingComposer({
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
}

class $$V1ConnectionsMetaTableAnnotationComposer
    extends Composer<_$V1Database, $V1ConnectionsMetaTable> {
  $$V1ConnectionsMetaTableAnnotationComposer({
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
}

class $$V1ConnectionsMetaTableTableManager
    extends
        RootTableManager<
          _$V1Database,
          $V1ConnectionsMetaTable,
          V1ConnectionsMetaData,
          $$V1ConnectionsMetaTableFilterComposer,
          $$V1ConnectionsMetaTableOrderingComposer,
          $$V1ConnectionsMetaTableAnnotationComposer,
          $$V1ConnectionsMetaTableCreateCompanionBuilder,
          $$V1ConnectionsMetaTableUpdateCompanionBuilder,
          (
            V1ConnectionsMetaData,
            BaseReferences<
              _$V1Database,
              $V1ConnectionsMetaTable,
              V1ConnectionsMetaData
            >,
          ),
          V1ConnectionsMetaData,
          PrefetchHooks Function()
        > {
  $$V1ConnectionsMetaTableTableManager(
    _$V1Database db,
    $V1ConnectionsMetaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$V1ConnectionsMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$V1ConnectionsMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$V1ConnectionsMetaTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<DateTime?> fetchedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => V1ConnectionsMetaCompanion(
                id: id,
                providerId: providerId,
                displayName: displayName,
                accountId: accountId,
                fetchedAt: fetchedAt,
                lastError: lastError,
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
                Value<int> rowid = const Value.absent(),
              }) => V1ConnectionsMetaCompanion.insert(
                id: id,
                providerId: providerId,
                displayName: displayName,
                accountId: accountId,
                fetchedAt: fetchedAt,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$V1ConnectionsMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$V1Database,
      $V1ConnectionsMetaTable,
      V1ConnectionsMetaData,
      $$V1ConnectionsMetaTableFilterComposer,
      $$V1ConnectionsMetaTableOrderingComposer,
      $$V1ConnectionsMetaTableAnnotationComposer,
      $$V1ConnectionsMetaTableCreateCompanionBuilder,
      $$V1ConnectionsMetaTableUpdateCompanionBuilder,
      (
        V1ConnectionsMetaData,
        BaseReferences<
          _$V1Database,
          $V1ConnectionsMetaTable,
          V1ConnectionsMetaData
        >,
      ),
      V1ConnectionsMetaData,
      PrefetchHooks Function()
    >;
typedef $$V1ProjectsTableCreateCompanionBuilder =
    V1ProjectsCompanion Function({
      required String id,
      required String connectionId,
      required String name,
      Value<String?> framework,
      Value<String?> productionBranch,
      Value<DateTime?> updatedAt,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$V1ProjectsTableUpdateCompanionBuilder =
    V1ProjectsCompanion Function({
      Value<String> id,
      Value<String> connectionId,
      Value<String> name,
      Value<String?> framework,
      Value<String?> productionBranch,
      Value<DateTime?> updatedAt,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$V1ProjectsTableFilterComposer
    extends Composer<_$V1Database, $V1ProjectsTable> {
  $$V1ProjectsTableFilterComposer({
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

class $$V1ProjectsTableOrderingComposer
    extends Composer<_$V1Database, $V1ProjectsTable> {
  $$V1ProjectsTableOrderingComposer({
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

class $$V1ProjectsTableAnnotationComposer
    extends Composer<_$V1Database, $V1ProjectsTable> {
  $$V1ProjectsTableAnnotationComposer({
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

class $$V1ProjectsTableTableManager
    extends
        RootTableManager<
          _$V1Database,
          $V1ProjectsTable,
          V1Project,
          $$V1ProjectsTableFilterComposer,
          $$V1ProjectsTableOrderingComposer,
          $$V1ProjectsTableAnnotationComposer,
          $$V1ProjectsTableCreateCompanionBuilder,
          $$V1ProjectsTableUpdateCompanionBuilder,
          (
            V1Project,
            BaseReferences<_$V1Database, $V1ProjectsTable, V1Project>,
          ),
          V1Project,
          PrefetchHooks Function()
        > {
  $$V1ProjectsTableTableManager(_$V1Database db, $V1ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$V1ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$V1ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$V1ProjectsTableAnnotationComposer($db: db, $table: table),
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
              }) => V1ProjectsCompanion(
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
              }) => V1ProjectsCompanion.insert(
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

typedef $$V1ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$V1Database,
      $V1ProjectsTable,
      V1Project,
      $$V1ProjectsTableFilterComposer,
      $$V1ProjectsTableOrderingComposer,
      $$V1ProjectsTableAnnotationComposer,
      $$V1ProjectsTableCreateCompanionBuilder,
      $$V1ProjectsTableUpdateCompanionBuilder,
      (V1Project, BaseReferences<_$V1Database, $V1ProjectsTable, V1Project>),
      V1Project,
      PrefetchHooks Function()
    >;
typedef $$V1ProjectDomainsTableCreateCompanionBuilder =
    V1ProjectDomainsCompanion Function({
      Value<int> rowId,
      required String projectId,
      required String connectionId,
      required String domain,
      required DateTime fetchedAt,
    });
typedef $$V1ProjectDomainsTableUpdateCompanionBuilder =
    V1ProjectDomainsCompanion Function({
      Value<int> rowId,
      Value<String> projectId,
      Value<String> connectionId,
      Value<String> domain,
      Value<DateTime> fetchedAt,
    });

class $$V1ProjectDomainsTableFilterComposer
    extends Composer<_$V1Database, $V1ProjectDomainsTable> {
  $$V1ProjectDomainsTableFilterComposer({
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

class $$V1ProjectDomainsTableOrderingComposer
    extends Composer<_$V1Database, $V1ProjectDomainsTable> {
  $$V1ProjectDomainsTableOrderingComposer({
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

class $$V1ProjectDomainsTableAnnotationComposer
    extends Composer<_$V1Database, $V1ProjectDomainsTable> {
  $$V1ProjectDomainsTableAnnotationComposer({
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

class $$V1ProjectDomainsTableTableManager
    extends
        RootTableManager<
          _$V1Database,
          $V1ProjectDomainsTable,
          V1ProjectDomain,
          $$V1ProjectDomainsTableFilterComposer,
          $$V1ProjectDomainsTableOrderingComposer,
          $$V1ProjectDomainsTableAnnotationComposer,
          $$V1ProjectDomainsTableCreateCompanionBuilder,
          $$V1ProjectDomainsTableUpdateCompanionBuilder,
          (
            V1ProjectDomain,
            BaseReferences<
              _$V1Database,
              $V1ProjectDomainsTable,
              V1ProjectDomain
            >,
          ),
          V1ProjectDomain,
          PrefetchHooks Function()
        > {
  $$V1ProjectDomainsTableTableManager(
    _$V1Database db,
    $V1ProjectDomainsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$V1ProjectDomainsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$V1ProjectDomainsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$V1ProjectDomainsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> rowId = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> connectionId = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
              }) => V1ProjectDomainsCompanion(
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
              }) => V1ProjectDomainsCompanion.insert(
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

typedef $$V1ProjectDomainsTableProcessedTableManager =
    ProcessedTableManager<
      _$V1Database,
      $V1ProjectDomainsTable,
      V1ProjectDomain,
      $$V1ProjectDomainsTableFilterComposer,
      $$V1ProjectDomainsTableOrderingComposer,
      $$V1ProjectDomainsTableAnnotationComposer,
      $$V1ProjectDomainsTableCreateCompanionBuilder,
      $$V1ProjectDomainsTableUpdateCompanionBuilder,
      (
        V1ProjectDomain,
        BaseReferences<_$V1Database, $V1ProjectDomainsTable, V1ProjectDomain>,
      ),
      V1ProjectDomain,
      PrefetchHooks Function()
    >;
typedef $$V1DeploymentsTableCreateCompanionBuilder =
    V1DeploymentsCompanion Function({
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
typedef $$V1DeploymentsTableUpdateCompanionBuilder =
    V1DeploymentsCompanion Function({
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

class $$V1DeploymentsTableFilterComposer
    extends Composer<_$V1Database, $V1DeploymentsTable> {
  $$V1DeploymentsTableFilterComposer({
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

class $$V1DeploymentsTableOrderingComposer
    extends Composer<_$V1Database, $V1DeploymentsTable> {
  $$V1DeploymentsTableOrderingComposer({
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

class $$V1DeploymentsTableAnnotationComposer
    extends Composer<_$V1Database, $V1DeploymentsTable> {
  $$V1DeploymentsTableAnnotationComposer({
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

class $$V1DeploymentsTableTableManager
    extends
        RootTableManager<
          _$V1Database,
          $V1DeploymentsTable,
          V1Deployment,
          $$V1DeploymentsTableFilterComposer,
          $$V1DeploymentsTableOrderingComposer,
          $$V1DeploymentsTableAnnotationComposer,
          $$V1DeploymentsTableCreateCompanionBuilder,
          $$V1DeploymentsTableUpdateCompanionBuilder,
          (
            V1Deployment,
            BaseReferences<_$V1Database, $V1DeploymentsTable, V1Deployment>,
          ),
          V1Deployment,
          PrefetchHooks Function()
        > {
  $$V1DeploymentsTableTableManager(_$V1Database db, $V1DeploymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$V1DeploymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$V1DeploymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$V1DeploymentsTableAnnotationComposer($db: db, $table: table),
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
              }) => V1DeploymentsCompanion(
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
              }) => V1DeploymentsCompanion.insert(
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

typedef $$V1DeploymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$V1Database,
      $V1DeploymentsTable,
      V1Deployment,
      $$V1DeploymentsTableFilterComposer,
      $$V1DeploymentsTableOrderingComposer,
      $$V1DeploymentsTableAnnotationComposer,
      $$V1DeploymentsTableCreateCompanionBuilder,
      $$V1DeploymentsTableUpdateCompanionBuilder,
      (
        V1Deployment,
        BaseReferences<_$V1Database, $V1DeploymentsTable, V1Deployment>,
      ),
      V1Deployment,
      PrefetchHooks Function()
    >;
typedef $$V1SiteLinksTableCreateCompanionBuilder =
    V1SiteLinksCompanion Function({
      required String siteId,
      required String source,
      required String externalId,
      Value<int> rowid,
    });
typedef $$V1SiteLinksTableUpdateCompanionBuilder =
    V1SiteLinksCompanion Function({
      Value<String> siteId,
      Value<String> source,
      Value<String> externalId,
      Value<int> rowid,
    });

class $$V1SiteLinksTableFilterComposer
    extends Composer<_$V1Database, $V1SiteLinksTable> {
  $$V1SiteLinksTableFilterComposer({
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

class $$V1SiteLinksTableOrderingComposer
    extends Composer<_$V1Database, $V1SiteLinksTable> {
  $$V1SiteLinksTableOrderingComposer({
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

class $$V1SiteLinksTableAnnotationComposer
    extends Composer<_$V1Database, $V1SiteLinksTable> {
  $$V1SiteLinksTableAnnotationComposer({
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

class $$V1SiteLinksTableTableManager
    extends
        RootTableManager<
          _$V1Database,
          $V1SiteLinksTable,
          V1SiteLink,
          $$V1SiteLinksTableFilterComposer,
          $$V1SiteLinksTableOrderingComposer,
          $$V1SiteLinksTableAnnotationComposer,
          $$V1SiteLinksTableCreateCompanionBuilder,
          $$V1SiteLinksTableUpdateCompanionBuilder,
          (
            V1SiteLink,
            BaseReferences<_$V1Database, $V1SiteLinksTable, V1SiteLink>,
          ),
          V1SiteLink,
          PrefetchHooks Function()
        > {
  $$V1SiteLinksTableTableManager(_$V1Database db, $V1SiteLinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$V1SiteLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$V1SiteLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$V1SiteLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> siteId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> externalId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => V1SiteLinksCompanion(
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
              }) => V1SiteLinksCompanion.insert(
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

typedef $$V1SiteLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$V1Database,
      $V1SiteLinksTable,
      V1SiteLink,
      $$V1SiteLinksTableFilterComposer,
      $$V1SiteLinksTableOrderingComposer,
      $$V1SiteLinksTableAnnotationComposer,
      $$V1SiteLinksTableCreateCompanionBuilder,
      $$V1SiteLinksTableUpdateCompanionBuilder,
      (V1SiteLink, BaseReferences<_$V1Database, $V1SiteLinksTable, V1SiteLink>),
      V1SiteLink,
      PrefetchHooks Function()
    >;

class $V1DatabaseManager {
  final _$V1Database _db;
  $V1DatabaseManager(this._db);
  $$V1ConnectionsMetaTableTableManager get v1ConnectionsMeta =>
      $$V1ConnectionsMetaTableTableManager(_db, _db.v1ConnectionsMeta);
  $$V1ProjectsTableTableManager get v1Projects =>
      $$V1ProjectsTableTableManager(_db, _db.v1Projects);
  $$V1ProjectDomainsTableTableManager get v1ProjectDomains =>
      $$V1ProjectDomainsTableTableManager(_db, _db.v1ProjectDomains);
  $$V1DeploymentsTableTableManager get v1Deployments =>
      $$V1DeploymentsTableTableManager(_db, _db.v1Deployments);
  $$V1SiteLinksTableTableManager get v1SiteLinks =>
      $$V1SiteLinksTableTableManager(_db, _db.v1SiteLinks);
}

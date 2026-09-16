// Drift v1 → v2 migration (Phase 2 §4/§8). This path has never executed in
// production — Phase 1 only ever created a fresh v2+ file via onCreate. We
// build a real v1 file (schema exactly as Phase 1 shipped it) with drift's
// own SQL generation, then open it with the current AppDatabase and assert
// the upgrade actually ran.

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hivehub/core/storage/db.dart';
import 'package:path/path.dart' as p;

part 'db_migration_test.g.dart';

class V1ConnectionsMeta extends Table {
  @override
  String get tableName => 'connections_meta';
  TextColumn get id => text()();
  TextColumn get providerId => text()();
  TextColumn get displayName => text()();
  TextColumn get accountId => text().nullable()();
  DateTimeColumn get fetchedAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class V1Projects extends Table {
  @override
  String get tableName => 'projects';
  TextColumn get id => text()();
  TextColumn get connectionId => text()();
  TextColumn get name => text()();
  TextColumn get framework => text().nullable()();
  TextColumn get productionBranch => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class V1ProjectDomains extends Table {
  @override
  String get tableName => 'project_domains';
  IntColumn get rowId => integer().autoIncrement()();
  TextColumn get projectId => text()();
  TextColumn get connectionId => text()();
  TextColumn get domain => text()();
  DateTimeColumn get fetchedAt => dateTime()();
}

class V1Deployments extends Table {
  @override
  String get tableName => 'deployments';
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get connectionId => text()();
  TextColumn get status => text()();
  TextColumn get url => text().nullable()();
  TextColumn get branch => text().nullable()();
  TextColumn get environment => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get durationSeconds => integer().nullable()();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get commitMessage => text().nullable()();
  TextColumn get commitSha => text().nullable()();
  TextColumn get commitAuthor => text().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class V1SiteLinks extends Table {
  @override
  String get tableName => 'site_links';
  TextColumn get siteId => text()();
  TextColumn get source => text()();
  TextColumn get externalId => text()();
  @override
  Set<Column<Object>> get primaryKey => {siteId, source};
}

@DriftDatabase(
  tables: [
    V1ConnectionsMeta,
    V1Projects,
    V1ProjectDomains,
    V1Deployments,
    V1SiteLinks,
  ],
)
class V1Database extends _$V1Database {
  V1Database(super.e);
  @override
  int get schemaVersion => 1;
}

void main() {
  test('migration v1 -> v2 adds kind column and registrar cache tables', () async {
    final dir = await Directory.systemTemp.createTemp('hivehub_migration_test');
    final file = File(p.join(dir.path, 'v1.db'));
    addTearDown(() => dir.delete(recursive: true));

    // 1. Create a real v1 file, exactly as Phase 1 shipped it.
    final v1 = V1Database(NativeDatabase(file));
    await v1.into(v1.v1ConnectionsMeta).insert(
          V1ConnectionsMetaCompanion.insert(
            id: 'conn-1',
            providerId: 'vercel',
            displayName: 'My Vercel',
          ),
        );
    await v1.close();

    // 2. Open the SAME file with the current (v2) schema — this is the
    // untested path: drift sees user_version=1 < schemaVersion=2 and must
    // run onUpgrade rather than onCreate.
    final v2 = AppDatabase.forTesting(NativeDatabase(file));

    final rows = await v2.allConnections();
    expect(rows, hasLength(1));
    expect(rows.single.id, 'conn-1');
    // Existing rows get the default with no backfill needed.
    expect(rows.single.kind, 'hosting');

    // The new tables exist and are queryable — would throw "no such table"
    // if onUpgrade had not created them.
    expect(await v2.allRegisteredDomains(), isEmpty);
    expect(await v2.dnsRecordsForDomain('conn-1', 'example.com'), isEmpty);

    await v2.close();
  });
}

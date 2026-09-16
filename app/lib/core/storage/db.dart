

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'db.g.dart';

/// Connection metadata — never the credential itself.
class ConnectionsMeta extends Table {
  TextColumn get id => text()();
  TextColumn get providerId => text()(); // e.g. 'vercel'
  TextColumn get displayName => text()();
  TextColumn get accountId => text().nullable()();
  DateTimeColumn get fetchedAt => dateTime().nullable()();
  TextColumn get lastError =>
      text().nullable()(); // serialised ApiException type

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Cached host projects.
class Projects extends Table {
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

/// Domains associated with a project (from the host's domain list).
class ProjectDomains extends Table {
  IntColumn get rowId => integer().autoIncrement()();
  TextColumn get projectId => text()();
  TextColumn get connectionId => text()();
  TextColumn get domain => text()();
  DateTimeColumn get fetchedAt => dateTime()();
}

/// Cached deployments.
class Deployments extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get connectionId => text()();

  /// Canonical DeployStatus enum name string.
  TextColumn get status => text()();
  TextColumn get url => text().nullable()();
  TextColumn get branch => text().nullable()();
  TextColumn get environment => text().nullable()(); // 'production' | 'preview'
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

/// Manual site ↔ analytics links (Phase 2+, schema defined now as the seam).
class SiteLinks extends Table {
  TextColumn get siteId => text()();
  TextColumn get source => text()(); // 'ga4' | 'clarity' | 'gsc'
  TextColumn get externalId => text()();

  @override
  Set<Column<Object>> get primaryKey => {siteId, source};
}

@DriftDatabase(
  tables: [ConnectionsMeta, Projects, ProjectDomains, Deployments, SiteLinks],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  Future<List<ConnectionsMetaData>> allConnections() =>
      select(connectionsMeta).get();

  Future<void> upsertConnection(ConnectionsMetaCompanion entry) =>
      into(connectionsMeta).insertOnConflictUpdate(entry);

  Future<void> deleteConnection(String id) =>
      (delete(connectionsMeta)..where((t) => t.id.equals(id))).go();

  Future<void> setConnectionError(String id, String? error) =>
      (update(connectionsMeta)..where((t) => t.id.equals(id))).write(
        ConnectionsMetaCompanion(lastError: Value(error)),
      );

  Future<List<Project>> projectsForConnection(String connectionId) => (select(
    projects,
  )..where((t) => t.connectionId.equals(connectionId))).get();

  Future<void> upsertProject(ProjectsCompanion entry) =>
      into(projects).insertOnConflictUpdate(entry);

  Future<void> deleteProjectsForConnection(String connectionId) => (delete(
    projects,
  )..where((t) => t.connectionId.equals(connectionId))).go();

  Future<List<Deployment>> deploymentsForProject(
    String projectId, {
    int limit = 20,
  }) =>
      (select(deployments)
            ..where((t) => t.projectId.equals(projectId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit))
          .get();

  Future<List<Deployment>> allDeployments({int limit = 100}) =>
      (select(deployments)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit))
          .get();

  Future<void> upsertDeployment(DeploymentsCompanion entry) =>
      into(deployments).insertOnConflictUpdate(entry);

  Future<void> deleteDeploymentsForConnection(String connectionId) => (delete(
    deployments,
  )..where((t) => t.connectionId.equals(connectionId))).go();

  Future<void> upsertSiteLink(SiteLinksCompanion entry) =>
      into(siteLinks).insertOnConflictUpdate(entry);

  Future<void> deleteSiteLink(String siteId, String source) => (delete(
    siteLinks,
  )..where((t) => t.siteId.equals(siteId) & t.source.equals(source))).go();

  Future<void> purgeConnection(String connectionId) => transaction(() async {
    await deleteConnection(connectionId);
    await deleteProjectsForConnection(connectionId);
    await deleteDeploymentsForConnection(connectionId);
  });
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'hivehub.db'));
    return NativeDatabase.createInBackground(file);
  });
}

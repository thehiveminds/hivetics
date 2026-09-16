

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'db.g.dart';

/// Connection metadata — never the credential itself.
class ConnectionsMeta extends Table {
  TextColumn get id => text()();
  TextColumn get providerId => text()(); // e.g. 'vercel' or 'godaddy'
  TextColumn get displayName => text()();
  TextColumn get accountId => text().nullable()();
  DateTimeColumn get fetchedAt => dateTime().nullable()();
  TextColumn get lastError =>
      text().nullable()(); // serialised ApiException type

  /// 'hosting' | 'registrar' — distinguishes a HostRef from a RegistrarRef
  /// connection (§3.1). Existing v1 rows migrate to 'hosting' with no
  /// backfill needed.
  TextColumn get kind => text().withDefault(const Constant('hosting'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Cached registrar domains — read-through, since registrar data changes on
/// a scale of months and GoDaddy/Porkbun both cap monthly call volume.
/// Row class renamed to avoid colliding with the `RegisteredDomain` model.
@DataClassName('RegisteredDomainRow')
class RegisteredDomains extends Table {
  TextColumn get domain => text()(); // normalized apex — the join key
  TextColumn get connectionId => text()();
  TextColumn get registrarId => text()();
  TextColumn get rawStatus => text().nullable()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  BoolColumn get autoRenew => boolean().nullable()();
  BoolColumn get locked => boolean().nullable()();
  BoolColumn get privacy => boolean().nullable()();
  TextColumn get nameServers => text()(); // JSON array
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {domain, connectionId};
}

/// Cached DNS records for a registrar-managed domain.
class DnsRecordsCache extends Table {
  TextColumn get id => text()();
  TextColumn get connectionId => text()();
  TextColumn get domain => text()();
  TextColumn get type => text()();
  TextColumn get name => text()();
  TextColumn get content => text()();
  IntColumn get ttl => integer().nullable()();
  IntColumn get priority => integer().nullable()();
  BoolColumn get proxied => boolean().withDefault(const Constant(false))();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id, connectionId};
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
  tables: [
    ConnectionsMeta,
    Projects,
    ProjectDomains,
    Deployments,
    SiteLinks,
    RegisteredDomains,
    DnsRecordsCache,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // The registrar cache is disposable — v1 predates it entirely,
          // and this path has never executed in production, so there is
          // nothing worth preserving beyond a straight additive upgrade.
          if (from < 2) {
            await m.addColumn(connectionsMeta, connectionsMeta.kind);
            await m.createTable(registeredDomains);
            await m.createTable(dnsRecordsCache);
          }
        },
      );

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
    await deleteRegisteredDomainsForConnection(connectionId);
    await deleteDnsRecordsForConnection(connectionId);
  });

  // ── Registrar cache (§4) ──────────────────────────────────────────────

  Future<List<RegisteredDomainRow>> allRegisteredDomains() =>
      select(registeredDomains).get();

  Future<void> upsertRegisteredDomain(RegisteredDomainsCompanion entry) =>
      into(registeredDomains).insertOnConflictUpdate(entry);

  Future<void> deleteRegisteredDomainsForConnection(String connectionId) =>
      (delete(registeredDomains)
            ..where((t) => t.connectionId.equals(connectionId)))
          .go();

  Future<List<DnsRecordsCacheData>> dnsRecordsForDomain(
    String connectionId,
    String domain,
  ) =>
      (select(dnsRecordsCache)
            ..where(
              (t) =>
                  t.connectionId.equals(connectionId) & t.domain.equals(domain),
            ))
          .get();

  Future<void> upsertDnsRecord(DnsRecordsCacheCompanion entry) =>
      into(dnsRecordsCache).insertOnConflictUpdate(entry);

  Future<void> replaceDnsRecordsForDomain(
    String connectionId,
    String domain,
    List<DnsRecordsCacheCompanion> entries,
  ) =>
      transaction(() async {
        await (delete(dnsRecordsCache)
              ..where(
                (t) =>
                    t.connectionId.equals(connectionId) &
                    t.domain.equals(domain),
              ))
            .go();
        for (final entry in entries) {
          await into(dnsRecordsCache).insertOnConflictUpdate(entry);
        }
      });

  Future<void> deleteDnsRecordsForConnection(String connectionId) =>
      (delete(dnsRecordsCache)
            ..where((t) => t.connectionId.equals(connectionId)))
          .go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'hivehub.db'));
    return NativeDatabase.createInBackground(file);
  });
}

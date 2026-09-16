import 'dart:convert';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_exception.dart';
import '../core/network/dns_resolver.dart';
import '../core/storage/db.dart';
import '../core/storage/secure_store.dart';
import '../models/connection.dart';
import '../models/dns_record.dart';
import '../models/registered_domain.dart';
import '../models/registrar_id.dart';
import '../models/service_ref.dart';
import '../providers/provider_registry.dart';
import '../providers/registrar/registrar_status_normalizer.dart';
import 'connections_notifier.dart';

/// Per-connection fetch result for registrars.
class ConnectionDomainsResult {
  const ConnectionDomainsResult({
    required this.connection,
    this.domains = const [],
    this.error,
  });

  final Connection connection;
  final List<RegisteredDomain> domains;
  final ApiException? error;

  bool get hasError => error != null;
}

class DomainsState {
  const DomainsState({
    this.results = const [],
    this.isRefreshing = false,
  });

  final List<ConnectionDomainsResult> results;
  final bool isRefreshing;

  List<RegisteredDomain> get allDomains {
    final list = results.expand((r) => r.domains).toList();
    list.sort((a, b) {
      if (a.isExpired != b.isExpired) return a.isExpired ? -1 : 1;
      if (a.isExpiringSoon != b.isExpiringSoon) {
        return a.isExpiringSoon ? -1 : 1;
      }
      final aDays = a.daysUntilExpiry ?? 9999;
      final bDays = b.daysUntilExpiry ?? 9999;
      if (aDays != bDays) return aDays.compareTo(bDays);
      return a.domain.compareTo(b.domain);
    });
    return list;
  }

  List<RegisteredDomain> get expiringSoonDomains =>
      allDomains.where((d) => d.isExpiringSoon || d.isExpired).toList();

  bool get anyError => results.any((r) => r.hasError);

  DomainsState copyWith({
    List<ConnectionDomainsResult>? results,
    bool? isRefreshing,
  }) =>
      DomainsState(
        results: results ?? this.results,
        isRefreshing: isRefreshing ?? this.isRefreshing,
      );
}

class DomainsNotifier extends AsyncNotifier<DomainsState> {
  @override
  Future<DomainsState> build() async {
    final connections = await ref.watch(connectionsProvider.future);
    final db = ref.read(dbProvider);

    // Cache-first: read existing domains from Drift DB
    final cachedRows = await db.allRegisteredDomains();
    if (cachedRows.isNotEmpty) {
      final cachedDomains = cachedRows.map(_rowToDomain).toList();
      final grouped = <String, List<RegisteredDomain>>{};
      for (final d in cachedDomains) {
        grouped.putIfAbsent(d.connectionId, () => []).add(d);
      }

      final initialResults = connections
          .where((c) => _isRegistrarConnection(c))
          .map((c) => ConnectionDomainsResult(
                connection: c,
                domains: grouped[c.id] ?? const [],
              ))
          .toList();

      if (initialResults.any((r) => r.domains.isNotEmpty)) {
        // Return cached domains immediately; refresh live in background
        Future.microtask(() => _fetchAndPersist(connections));
        return DomainsState(results: initialResults);
      }
    }

    return _fetchAndPersist(connections);
  }

  Future<void> refresh() async {
    final connections = await ref.read(connectionsProvider.future);
    state = AsyncData(
      (state.valueOrNull ?? const DomainsState()).copyWith(isRefreshing: true),
    );
    final updated = await _fetchAndPersist(connections);
    state = AsyncData(updated);
  }

  bool _isRegistrarConnection(Connection c) {
    if (c.service is RegistrarRef) return true;
    // Cloudflare Pages connections also ride as Cloudflare Registrar (§2.3)
    if (c.service is HostRef &&
        (c.service as HostRef).provider == ProviderId.cloudflarepages) {
      return true;
    }
    return false;
  }

  Future<DomainsState> _fetchAndPersist(List<Connection> connections) async {
    final registrarConnections = connections.where(_isRegistrarConnection).toList();
    final results = await Future.wait(
      registrarConnections.map((c) => _fetchConnection(c)),
    );

    final db = ref.read(dbProvider);
    for (final res in results) {
      if (!res.hasError) {
        for (final domain in res.domains) {
          await db.upsertRegisteredDomain(
            RegisteredDomainsCompanion.insert(
              domain: domain.domain,
              connectionId: domain.connectionId,
              registrarId: domain.registrar.id,
              rawStatus: Value(domain.rawStatus),
              expiresAt: Value(domain.expiresAt),
              autoRenew: Value(domain.autoRenew),
              locked: Value(domain.locked),
              privacy: Value(domain.privacy),
              nameServers: jsonEncode(domain.nameServers),
              fetchedAt: domain.fetchedAt,
            ),
          );
        }
      }
    }

    return DomainsState(results: results);
  }

  Future<ConnectionDomainsResult> _fetchConnection(Connection c) async {
    final credential = await SecureStore.instance.loadCredential(c.id);
    if (credential == null) {
      return ConnectionDomainsResult(
        connection: c,
        error: const UnauthorizedException('No token found — reconnect'),
      );
    }

    final RegistrarId registrarId;
    if (c.service is RegistrarRef) {
      registrarId = (c.service as RegistrarRef).registrar;
    } else {
      registrarId = RegistrarId.cloudflareregistrar;
    }

    final provider = registrarProviderFor(registrarId);
    final result = await provider.listDomains(c, credential);

    return result.when(
      ok: (domains) => ConnectionDomainsResult(
        connection: c,
        domains: domains,
      ),
      err: (e) => ConnectionDomainsResult(
        connection: c,
        error: e,
      ),
    );
  }

  static RegisteredDomain _rowToDomain(RegisteredDomainRow row) {
    List<String> ns = const [];
    try {
      final decoded = jsonDecode(row.nameServers);
      if (decoded is List) {
        ns = decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}

    final registrar = RegistrarId.fromId(row.registrarId);
    final status = switch (registrar) {
      RegistrarId.godaddy => normalizeGoDaddyStatus(row.rawStatus),
      RegistrarId.porkbun => normalizePorkbunStatus(row.rawStatus),
      RegistrarId.cloudflareregistrar =>
        normalizeCloudflareRegistrarStatus(row.rawStatus),
      RegistrarId.spaceship => normalizeSpaceshipStatus(row.rawStatus),
      RegistrarId.namecom => normalizeNamecomStatus(row.rawStatus),
      RegistrarId.gandi => normalizeGandiStatus(row.rawStatus),
      RegistrarId.namesilo => normalizeNameSiloStatus(row.rawStatus),
      RegistrarId.dynadot => normalizeDynadotStatus(row.rawStatus),
    };

    return RegisteredDomain(
      domain: row.domain,
      connectionId: row.connectionId,
      registrar: registrar,
      status: status,
      rawStatus: row.rawStatus,
      expiresAt: row.expiresAt,
      autoRenew: row.autoRenew,
      locked: row.locked,
      privacy: row.privacy,
      nameServers: ns,
      fetchedAt: row.fetchedAt,
    );
  }
}

final domainsProvider =
    AsyncNotifierProvider<DomainsNotifier, DomainsState>(DomainsNotifier.new);

// ── DNS records provider (cache-first read-through) ──────────────────────────

final dnsRecordsProvider = FutureProvider.family<
    List<DnsRecord>,
    ({String connectionId, String domain, RegistrarId registrar})>((
  ref,
  args,
) async {
  final db = ref.read(dbProvider);

  // 1. Check local cache
  final cached = await db.dnsRecordsForDomain(args.connectionId, args.domain);
  if (cached.isNotEmpty) {
    return cached
        .map((r) => DnsRecord(
              id: r.id,
              domain: r.domain,
              type: r.type,
              name: r.name,
              content: r.content,
              ttl: r.ttl,
              priority: r.priority,
              proxied: r.proxied,
            ))
        .toList();
  }

  // 2. Fetch live
  final connections = await ref.watch(connectionsProvider.future);
  final connection = connections.firstWhere(
    (c) => c.id == args.connectionId,
    orElse: () => Connection(
      id: args.connectionId,
      service: RegistrarRef(args.registrar),
      displayName: args.registrar.displayName,
    ),
  );
  final credential = await SecureStore.instance.loadCredential(args.connectionId);

  List<DnsRecord> records = [];

  if (credential != null) {
    final provider = registrarProviderFor(args.registrar);
    final res = await provider.listDnsRecords(connection, credential, args.domain);
    records = res.when(
      ok: (r) => r,
      err: (_) => [],
    );
  }

  // If registrar returned empty or failed (e.g. external nameservers or no DNS zone on registrar),
  // query live DNS-over-HTTPS (DoH) so user sees real live records!
  if (records.isEmpty) {
    try {
      final live = await DnsResolver().resolveLiveRecords(args.domain);
      if (live.isNotEmpty) {
        records = live;
      }
    } catch (_) {}
  }

  if (records.isNotEmpty) {
    // Update cache
    final companions = records
        .map((r) => DnsRecordsCacheCompanion.insert(
              id: r.id,
              connectionId: args.connectionId,
              domain: args.domain,
              type: r.type,
              name: r.name,
              content: r.content,
              ttl: Value(r.ttl),
              priority: Value(r.priority),
              proxied: Value(r.proxied),
              fetchedAt: DateTime.now().toUtc(),
            ))
        .toList();
    await db.replaceDnsRecordsForDomain(
      args.connectionId,
      args.domain,
      companions,
    );
  }

  return records;
});

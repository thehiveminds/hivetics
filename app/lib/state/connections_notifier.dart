import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/storage/db.dart';
import '../core/storage/secure_store.dart';
import '../core/result.dart';
import '../models/connection.dart';
import '../providers/provider_registry.dart';

class ConnectionsNotifier extends AsyncNotifier<List<Connection>> {
  static const _uuid = Uuid();

  @override
  Future<List<Connection>> build() async {
    return _loadFromDb();
  }

  Future<List<Connection>> _loadFromDb() async {
    final db = ref.read(dbProvider);
    final rows = await db.allConnections();
    return rows.map(_rowToConnection).toList();
  }

  /// Validate the token, then persist to drift + secure storage.
  /// Returns Ok(connection) or Err with the specific failure reason.
  Future<Result<Connection>> addConnection({
    required ProviderId providerId,
    required String token,
    String? selectedAccountId,
  }) async {
    final provider = providerFor(providerId);
    final validationResult = await provider.validate(
      token,
      selectedAccountId: selectedAccountId,
    );

    return validationResult.when(
      ok: (account) async {
        final id = _uuid.v4();
        final connection = Connection(
          id: id,
          providerId: providerId,
          displayName: account.displayName,
          accountId: account.accountId,
          accountName: account.displayName,
        );

        final db = ref.read(dbProvider);
        await db.upsertConnection(_connectionToCompanion(connection));
        await SecureStore.instance.saveToken(id, token);

        // Rebuild state.
        final updated = await _loadFromDb();
        state = AsyncData(updated);

        return Ok(connection);
      },
      err: (e) => Err(e),
    );
  }

  /// Purges token from SecureStore and all rows from drift in one transaction.
  Future<void> deleteConnection(String connectionId) async {
    final db = ref.read(dbProvider);
    await Future.wait([
      db.purgeConnection(connectionId),
      SecureStore.instance.deleteCredential(connectionId),
    ]);
    final updated = await _loadFromDb();
    state = AsyncData(updated);
  }

  Future<void> setError(String connectionId, String? errorTypeName) async {
    final db = ref.read(dbProvider);
    await db.setConnectionError(connectionId, errorTypeName);
    final updated = await _loadFromDb();
    state = AsyncData(updated);
  }

  Future<void> clearError(String connectionId) async {
    await setError(connectionId, null);
  }

  Future<void> updateDisplayName(String connectionId, String newName) async {
    final list = state.valueOrNull ?? await _loadFromDb();
    final index = list.indexWhere((c) => c.id == connectionId);
    if (index != -1) {
      final updated = list[index].copyWith(displayName: newName);
      final db = ref.read(dbProvider);
      await db.upsertConnection(_connectionToCompanion(updated));
      final rows = await _loadFromDb();
      state = AsyncData(rows);
    }
  }

  static Connection _rowToConnection(ConnectionsMetaData row) => Connection(
        id: row.id,
        providerId: ProviderId.fromId(row.providerId),
        displayName: row.displayName,
        accountId: row.accountId,
        lastSyncedAt: row.fetchedAt,
        lastError: row.lastError,
      );

  static ConnectionsMetaCompanion _connectionToCompanion(Connection c) =>
      ConnectionsMetaCompanion.insert(
        id: c.id,
        providerId: c.providerId.id,
        displayName: c.displayName,
        accountId: Value(c.accountId),
        fetchedAt: Value(c.lastSyncedAt),
        lastError: Value(c.lastError),
      );
}

final connectionsProvider =
    AsyncNotifierProvider<ConnectionsNotifier, List<Connection>>(
  ConnectionsNotifier.new,
);

// ── DB + credential providers ──────────────────────────────────────────────────

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

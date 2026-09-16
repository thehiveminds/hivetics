import '../../models/deploy_status.dart';

/// Map a Vercel `readyState` (or `state`) string to [DeployStatus].
/// API-RESEARCH §1.3.
DeployStatus normalizeVercelStatus(String? raw) {
  if (raw == null) return DeployStatus.unknown;
  return switch (raw.toUpperCase()) {
    'READY'                          => DeployStatus.ready,
    'BUILDING'                       => DeployStatus.building,
    'QUEUED' || 'INITIALIZING'       => DeployStatus.queued,
    'ERROR'                          => DeployStatus.failed,
    'CANCELED' || 'BLOCKED' || 'DELETED' => DeployStatus.cancelled,
    _                                => DeployStatus.unknown,
  };
}

/// Map a Netlify `state` string to [DeployStatus].
/// API-RESEARCH §2.3.
DeployStatus normalizeNetlifyStatus(String? raw) {
  if (raw == null) return DeployStatus.unknown;
  return switch (raw.toLowerCase()) {
    'ready'                                                              => DeployStatus.ready,
    'building' ||
    'uploading' ||
    'uploaded' ||
    'preparing' ||
    'prepared' ||
    'processing' ||
    'retrying'                                                           => DeployStatus.building,
    'new' ||
    'enqueued' ||
    'pending_review' ||
    'accepted'                                                           => DeployStatus.queued,
    'error'                                                              => DeployStatus.failed,
    'canceled' || 'skipped' || 'deleted'                                => DeployStatus.cancelled,
    _                                                                    => DeployStatus.unknown,
  };
}

/// Map a Cloudflare Pages `latest_stage` object to [DeployStatus].
/// API-RESEARCH §3.5.
///
/// [stageName] — e.g. 'deploy', 'build', 'queued'
/// [stageStatus] — e.g. 'success', 'failure', 'active', 'idle', 'canceled'
DeployStatus normalizeCloudflarePagesStatus({
  required String? stageName,
  required String? stageStatus,
}) {
  if (stageName == null || stageStatus == null) return DeployStatus.unknown;

  final name   = stageName.toLowerCase();
  final status = stageStatus.toLowerCase();

  return switch (status) {
    'failure'  => DeployStatus.failed,
    'canceled' => DeployStatus.cancelled,
    'success'  => name == 'deploy'
        ? DeployStatus.ready       // ✅ Fully deployed
        : DeployStatus.building,   // ⚠️ Still mid-pipeline — NOT done
    'active'   => name == 'queued'
        ? DeployStatus.queued
        : DeployStatus.building,
    'idle'     => DeployStatus.queued,
    _          => DeployStatus.unknown,
  };
}

/// Convenience overload that accepts a raw Map (from JSON decode).
DeployStatus normalizeCloudflarePagesStageMap(Map<String, dynamic>? latestStage) {
  if (latestStage == null) return DeployStatus.unknown;
  return normalizeCloudflarePagesStatus(
    stageName:   latestStage['name']   as String?,
    stageStatus: latestStage['status'] as String?,
  );
}

/// Parse a Vercel timestamp (ms epoch integer or string) → UTC DateTime.
DateTime? parseVercelTimestamp(dynamic raw) {
  if (raw == null) return null;
  final ms = raw is int ? raw : int.tryParse(raw.toString());
  if (ms == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
}

/// Parse a Netlify or Cloudflare ISO8601 string → UTC DateTime.
DateTime? parseIso8601Timestamp(dynamic raw) {
  if (raw == null) return null;
  final s = raw.toString();
  if (s.isEmpty) return null;
  return DateTime.tryParse(s)?.toUtc();
}

/// Ensure [raw] has a scheme. Vercel URLs have no scheme and are nullable.
String? normalizeUrl(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
  return 'https://$raw';
}

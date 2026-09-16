import '../../models/registered_domain.dart';
import '../../models/site_alert.dart';

/// Map a GoDaddy status string to [DomainStatus] (§2.1).
/// Uses prefix matching because GoDaddy status codes include detailed sub-states
/// (e.g. 'EXPIRED_REASSIGNED', 'CANCELLED_HELD', 'HELD_SHOPPER', 'PENDING_TRANSFER_IN').
DomainStatus normalizeGoDaddyStatus(String? raw) {
  if (raw == null || raw.trim().isEmpty) return DomainStatus.unknown;
  final upper = raw.toUpperCase().trim();

  if (upper.startsWith('ACTIVE')) {
    return DomainStatus.active;
  }
  if (upper.startsWith('EXPIRED')) {
    return DomainStatus.expired;
  }
  if (upper.startsWith('CANCELLED') || upper.startsWith('CANCELED')) {
    return DomainStatus.cancelled;
  }
  if (upper.startsWith('HELD') ||
      upper == 'RESERVED' ||
      upper == 'DISABLED' ||
      upper == 'FAILED' ||
      upper == 'REVERTED' ||
      upper == 'TRANSFERRED') {
    return DomainStatus.suspended;
  }
  if (upper.startsWith('PENDING') || upper.startsWith('AWAITING')) {
    return DomainStatus.pending;
  }
  return DomainStatus.unknown;
}

/// Map a Cloudflare Registrar status string to [DomainStatus] (§2.3).
DomainStatus normalizeCloudflareRegistrarStatus(String? raw) {
  if (raw == null || raw.trim().isEmpty) return DomainStatus.unknown;
  final lower = raw.toLowerCase().trim();

  return switch (lower) {
    'active' => DomainStatus.active,
    'expired' => DomainStatus.expired,
    'cancelled' || 'canceled' => DomainStatus.cancelled,
    'suspended' => DomainStatus.suspended,
    'pending_transfer' || 'pending' => DomainStatus.pending,
    _ => DomainStatus.unknown,
  };
}

/// Map a Porkbun status string to [DomainStatus] (§2.2).
DomainStatus normalizePorkbunStatus(String? raw) {
  if (raw == null || raw.trim().isEmpty) return DomainStatus.unknown;
  final upper = raw.toUpperCase().trim();

  return switch (upper) {
    'ACTIVE' => DomainStatus.active,
    'EXPIRED' => DomainStatus.expired,
    'DELETED' || 'CANCELLED' || 'CANCELED' => DomainStatus.cancelled,
    'SUSPENDED' => DomainStatus.suspended,
    'PENDING' => DomainStatus.pending,
    _ => DomainStatus.unknown,
  };
}

/// Map a Spaceship status string to [DomainStatus] (Reference §2.4).
DomainStatus normalizeSpaceshipStatus(String? raw) {
  if (raw == null || raw.trim().isEmpty) return DomainStatus.unknown;
  final lower = raw.toLowerCase().trim();

  if (lower.contains('active') || lower == 'ok') return DomainStatus.active;
  if (lower.contains('expired')) return DomainStatus.expired;
  if (lower.contains('cancel') || lower.contains('deleted')) return DomainStatus.cancelled;
  if (lower.contains('suspend') || lower.contains('hold')) return DomainStatus.suspended;
  if (lower.contains('pending')) return DomainStatus.pending;
  return DomainStatus.unknown;
}

/// Map a Name.com status string to [DomainStatus] (Reference §2.1).
DomainStatus normalizeNamecomStatus(String? raw) {
  if (raw == null || raw.trim().isEmpty) return DomainStatus.unknown;
  final lower = raw.toLowerCase().trim();

  if (lower.contains('active') || lower == 'ok' || lower == 'registered') return DomainStatus.active;
  if (lower.contains('expired')) return DomainStatus.expired;
  if (lower.contains('cancel') || lower.contains('delete')) return DomainStatus.cancelled;
  if (lower.contains('suspend') || lower.contains('hold') || lower.contains('lock')) return DomainStatus.suspended;
  if (lower.contains('pending')) return DomainStatus.pending;
  return DomainStatus.unknown;
}

/// Map Gandi status array or string to [DomainStatus] (Reference §2.7).
DomainStatus normalizeGandiStatus(dynamic raw) {
  if (raw == null) return DomainStatus.unknown;
  final statuses = <String>[];
  if (raw is List) {
    statuses.addAll(raw.map((e) => e.toString().toLowerCase()));
  } else {
    statuses.add(raw.toString().toLowerCase());
  }

  if (statuses.isEmpty) return DomainStatus.unknown;
  final combined = statuses.join(' ');

  if (combined.contains('clienthold') || combined.contains('serverhold') || combined.contains('inactive')) {
    return DomainStatus.suspended;
  }
  if (combined.contains('pending')) {
    return DomainStatus.pending;
  }
  if (combined.contains('expired')) {
    return DomainStatus.expired;
  }
  if (combined.contains('clientdeleteprohibited') || combined.contains('ok') || combined.contains('active')) {
    return DomainStatus.active;
  }
  return DomainStatus.unknown;
}

/// Map NameSilo status string to [DomainStatus] (Reference §2.6).
DomainStatus normalizeNameSiloStatus(String? raw) {
  if (raw == null || raw.trim().isEmpty) return DomainStatus.unknown;
  final lower = raw.toLowerCase().trim();

  if (lower.contains('active')) return DomainStatus.active;
  if (lower.contains('expired')) return DomainStatus.expired;
  if (lower.contains('cancel') || lower.contains('deleted')) return DomainStatus.cancelled;
  if (lower.contains('suspend') || lower.contains('hold') || lower.contains('quarantine')) return DomainStatus.suspended;
  if (lower.contains('pending')) return DomainStatus.pending;
  return DomainStatus.unknown;
}

/// Map Dynadot status string to [DomainStatus] (Reference §2.5).
DomainStatus normalizeDynadotStatus(String? raw) {
  if (raw == null || raw.trim().isEmpty) return DomainStatus.unknown;
  final lower = raw.toLowerCase().trim();

  if (lower.contains('active') || lower == 'registered') return DomainStatus.active;
  if (lower.contains('expired')) return DomainStatus.expired;
  if (lower.contains('deleted') || lower.contains('cancelled')) return DomainStatus.cancelled;
  if (lower.contains('hold') || lower.contains('locked')) return DomainStatus.suspended;
  if (lower.contains('pending')) return DomainStatus.pending;
  return DomainStatus.unknown;
}

/// Universal date parser for standard ISO8601, UNIX timestamp numbers, and date strings.
DateTime? parseFlexibleDate(dynamic raw) {
  if (raw == null) return null;
  if (raw is num) {
    final n = raw.toInt();
    // Seconds vs milliseconds
    if (n > 100000000000) {
      return DateTime.fromMillisecondsSinceEpoch(n, isUtc: true);
    }
    return DateTime.fromMillisecondsSinceEpoch(n * 1000, isUtc: true);
  }
  final s = raw.toString().trim();
  if (s.isEmpty) return null;

  // Check if string is integer timestamp
  final asInt = int.tryParse(s);
  if (asInt != null) {
    if (asInt > 100000000000) {
      return DateTime.fromMillisecondsSinceEpoch(asInt, isUtc: true);
    }
    return DateTime.fromMillisecondsSinceEpoch(asInt * 1000, isUtc: true);
  }

  // Porkbun format YYYY-MM-DD HH:MM:SS
  if (s.contains(' ') && !s.contains('T')) {
    return parsePorkbunDate(s);
  }

  final parsed = DateTime.tryParse(s);
  return parsed?.toUtc();
}

/// Parse a Porkbun date string ("YYYY-MM-DD HH:MM:SS") into a UTC [DateTime] (§2.2).
/// ⚠️ DateTime.tryParse treats "YYYY-MM-DD HH:MM:SS" as local time.
/// This parser explicitly forces UTC to prevent timezone offsets from
/// altering expiry alerts.
DateTime? parsePorkbunDate(dynamic raw) {
  if (raw == null) return null;
  final s = raw.toString().trim();
  if (s.isEmpty) return null;

  try {
    // If it is already ISO8601, parse and convert to UTC
    if (s.contains('T')) {
      final parsed = DateTime.tryParse(s);
      return parsed?.toUtc();
    }

    // Porkbun format: "YYYY-MM-DD HH:MM:SS"
    final parts = s.split(' ');
    if (parts.length != 2) {
      final parsed = DateTime.tryParse(s);
      return parsed?.toUtc();
    }

    final dateParts = parts[0].split('-');
    final timeParts = parts[1].split(':');
    if (dateParts.length == 3 && timeParts.length >= 2) {
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final second = timeParts.length > 2 ? int.parse(timeParts[2].split('.').first) : 0;
      return DateTime.utc(year, month, day, hour, minute, second);
    }
  } catch (_) {
    // Fall back to standard parser if manual parse fails
  }

  final fallback = DateTime.tryParse(s);
  return fallback?.toUtc();
}

/// Parse Porkbun 1/0 integer booleans or boolean strings (§2.2).
bool? parsePorkbunBool(dynamic raw) {
  if (raw == null) return null;
  if (raw is bool) return raw;
  if (raw is num) return raw == 1;
  final s = raw.toString().trim().toLowerCase();
  if (s == '1' || s == 'true') return true;
  if (s == '0' || s == 'false') return false;
  return null;
}

/// Parse a DNS TTL value (Porkbun returns strings like "600", Cloudflare returns ints).
int? parseDnsTtl(dynamic raw) {
  if (raw == null) return null;
  if (raw is int) return raw;
  return int.tryParse(raw.toString().trim());
}

/// Parse a DNS Priority value (Porkbun returns strings like "10", Cloudflare returns ints).
int? parseDnsPriority(dynamic raw) {
  if (raw == null) return null;
  if (raw is int) return raw;
  return int.tryParse(raw.toString().trim());
}

/// Compute domain alerts according to §6.2 rules.
///
/// Rules:
/// - daysUntilExpiry <= 0 → error "Domain expired"
/// - daysUntilExpiry <= 30 → warning "Expires in N days" (mutually exclusive with <= 0)
/// - autoRenew == false && <= 60 days → warning "Auto-renew is off"
List<SiteAlert> computeDomainAlerts({
  required RegisteredDomain domain,
}) {
  final alerts = <SiteAlert>[];

  if (domain.isExpired) {
    alerts.add(SiteAlert.domainExpired);
  } else if (domain.isExpiringSoon) {
    final days = domain.daysUntilExpiry ?? 0;
    alerts.add(SiteAlert.domainExpiring(days));
  }

  if (domain.autoRenew == false &&
      domain.daysUntilExpiry != null &&
      domain.daysUntilExpiry! <= 60) {
    alerts.add(SiteAlert.autoRenewOff);
  }

  return alerts;
}

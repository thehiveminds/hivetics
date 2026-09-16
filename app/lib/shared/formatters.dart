

import 'package:intl/intl.dart';

/// Relative time string — \"2h ago\", \"just now\", \"3d ago\".
/// Used on SiteCard and deploy rows.
String relativeTime(DateTime? dt) {
  if (dt == null) return '—';
  final diff = DateTime.now().difference(dt.toLocal());
  if (diff.inSeconds < 60)  return 'just now';
  if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
  if (diff.inHours   < 24)  return '${diff.inHours}h ago';
  if (diff.inDays    < 30)  return '${diff.inDays}d ago';
  return DateFormat('d MMM').format(dt.toLocal());
}

/// Formatted calendar date — e.g. \"15 Oct 2026\".
String formatDate(DateTime dt) => DateFormat('d MMM y').format(dt.toLocal());

/// Absolute date for deploy groups — \"Today\", \"Yesterday\", \"15 Sep\".
String deployGroupLabel(DateTime dt) {
  final now = DateTime.now();
  final local = dt.toLocal();
  if (_isSameDay(local, now))                           return 'Today';
  if (_isSameDay(local, now.subtract(const Duration(days: 1)))) return 'Yesterday';
  return DateFormat('d MMM').format(local);
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// \"through 13 Sep\" — for GSC lagging data label.
String throughDate(DateTime dt) =>
    'through ${DateFormat('d MMM').format(dt.toLocal())}';

/// Format a Duration as \"2m 34s\" or \"45s\".
String formatDuration(Duration? d) {
  if (d == null || d.inSeconds <= 0) return '—';
  if (d.inSeconds < 60) return '${d.inSeconds}s';
  final m = d.inMinutes;
  final s = d.inSeconds.remainder(60);
  return s > 0 ? '${m}m ${s}s' : '${m}m';
}

/// First 7 chars of a commit SHA.
String shortSha(String? sha) {
  if (sha == null || sha.length < 7) return sha ?? '—';
  return sha.substring(0, 7);
}

/// Domain expiry text — \"12 days\", \"1 day\", \"Expired\".
String daysUntilExpiry(int days) {
  if (days <= 0)  return 'Expired';
  if (days == 1)  return '1 day';
  return '$days days';
}

/// Large numbers: \"1,240\", \"12.4k\".
String formatCount(int? n) {
  if (n == null) return '—';
  if (n >= 10000) return '${(n / 1000).toStringAsFixed(1)}k';
  return NumberFormat('#,###').format(n);
}

/// Signed delta string with arrow: \"+12%\", \"-3%\".
String formatDelta(double? delta) {
  if (delta == null) return '—';
  final sign = delta >= 0 ? '+' : '';
  return '$sign${delta.toStringAsFixed(1)}%';
}



/// Normalise a raw domain/URL string to a bare apex domain.
///
/// Examples:
///   normalizeDomain('https://www.thehiveminds.in/blog') → 'thehiveminds.in'
///   normalizeDomain('sc-domain:thehiveminds.in')        → 'thehiveminds.in'
///   normalizeDomain('www.thehiveminds.in')              → 'thehiveminds.in'
///   normalizeDomain('thehiveminds.in')                  → 'thehiveminds.in'
///   normalizeDomain('THEHIVEMINDS.IN')                  → 'thehiveminds.in'
String normalizeDomain(String raw) => raw
    .trim()
    .replaceFirst('sc-domain:', '')
    .replaceFirst(RegExp(r'^https?://'), '')
    .replaceFirst(RegExp(r'^www\.'), '')
    .split('/').first
    .split('?').first
    .split('#').first
    .toLowerCase();

/// Whether two raw domain strings refer to the same apex domain.
bool sameDomain(String a, String b) =>
    normalizeDomain(a) == normalizeDomain(b);

/// Extract the apex domain from a full URL (for display as a card title).
/// Returns null if [raw] is empty or unparseable.
String? apexDomainOrNull(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final normalized = normalizeDomain(raw);
  return normalized.isEmpty ? null : normalized;
}

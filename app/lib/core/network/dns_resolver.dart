import 'package:dio/dio.dart';
import '../../models/dns_record.dart';

class DnsResolver {
  DnsResolver({Dio? dio}) : _dio = dio ?? Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 8),
      headers: {'Accept': 'application/dns-json'},
    ),
  );

  final Dio _dio;

  static const _recordTypes = ['A', 'AAAA', 'CNAME', 'MX', 'TXT', 'NS'];

  /// Resolves live DNS records for [domain] using public DNS-over-HTTPS (DoH).
  Future<List<DnsRecord>> resolveLiveRecords(String domain) async {
    final cleanDomain = domain.trim().replaceAll(RegExp(r'^https?://'), '').split('/').first;
    if (cleanDomain.isEmpty) return [];

    final results = <DnsRecord>[];
    final seen = <String>{};

    Future<void> queryType(String qname, String type) async {
      try {
        final res = await _dio.get<Map<String, dynamic>>(
          'https://cloudflare-dns.com/dns-query',
          queryParameters: {
            'name': qname,
            'type': type,
          },
        );

        final data = res.data;
        if (data == null) return;

        final answers = data['Answer'] as List?;
        if (answers == null || answers.isEmpty) return;

        for (final raw in answers) {
          final m = raw as Map<String, dynamic>;
          final typeNum = m['type'] as int?;
          final typeStr = _typeNumToString(typeNum) ?? type;
          final rawName = (m['name'] as String? ?? qname).replaceAll(RegExp(r'\.$'), '');
          final rawData = (m['data'] as String? ?? '').trim();
          final ttl = m['TTL'] as int?;

          int? priority;
          String content = rawData;

          // Handle MX records formatted as "10 mail.example.com"
          if (typeStr == 'MX' && rawData.contains(' ')) {
            final parts = rawData.split(RegExp(r'\s+'));
            if (parts.length >= 2) {
              priority = int.tryParse(parts[0]);
              content = parts.sublist(1).join(' ');
            }
          }

          // Remove trailing dot and outer quotes from TXT records
          if (typeStr == 'TXT') {
            if (content.startsWith('"') && content.endsWith('"')) {
              content = content.substring(1, content.length - 1);
            }
          } else if (content.endsWith('.')) {
            content = content.substring(0, content.length - 1);
          }

          final key = '$typeStr-$rawName-$content';
          if (seen.contains(key)) continue;
          seen.add(key);

          final shortName = rawName == cleanDomain
              ? '@'
              : (rawName.endsWith('.$cleanDomain')
                  ? rawName.substring(0, rawName.length - cleanDomain.length - 1)
                  : rawName);

          results.add(
            DnsRecord(
              id: 'doh_${typeStr}_${shortName}_${content.hashCode.abs()}',
              domain: cleanDomain,
              type: typeStr,
              name: shortName,
              content: content,
              ttl: ttl,
              priority: priority,
              proxied: false,
            ),
          );
        }
      } catch (_) {
        // Ignore individual query failures
      }
    }

    final futures = <Future<void>>[];

    for (final type in _recordTypes) {
      futures.add(queryType(cleanDomain, type));
    }

    // Also query www subdomain for A and CNAME
    futures.add(queryType('www.$cleanDomain', 'A'));
    futures.add(queryType('www.$cleanDomain', 'CNAME'));

    await Future.wait(futures);

    // Sort cleanly by type (A, AAAA, CNAME, MX, TXT, NS) then name
    results.sort((a, b) {
      const order = {'A': 1, 'AAAA': 2, 'CNAME': 3, 'MX': 4, 'TXT': 5, 'NS': 6};
      final oA = order[a.type] ?? 99;
      final oB = order[b.type] ?? 99;
      if (oA != oB) return oA.compareTo(oB);
      return a.name.compareTo(b.name);
    });

    return results;
  }

  static String? _typeNumToString(int? type) => switch (type) {
        1 => 'A',
        28 => 'AAAA',
        5 => 'CNAME',
        15 => 'MX',
        16 => 'TXT',
        2 => 'NS',
        6 => 'SOA',
        _ => null,
      };
}

class DnsRecord {
  const DnsRecord({
    required this.id,
    required this.domain,
    required this.type,
    required this.name,
    required this.content,
    this.ttl,
    this.priority,
    this.proxied = false,
  });

  final String id;
  final String domain;

  /// Record type, e.g. A, AAAA, CNAME, MX, TXT, NS, SOA, SRV, CAA.
  final String type;

  /// Record name (e.g. '@' or subdomain or FQDN).
  final String name;

  /// Content/value of the DNS record (e.g. IP address, target hostname).
  final String content;

  /// TTL in seconds. 1 means "Auto" (§5.3).
  final int? ttl;

  /// Priority for MX/SRV records.
  final int? priority;

  /// Cloudflare proxy flag. False for other providers.
  final bool proxied;

  /// Whether the TTL represents "Auto" (Cloudflare/GoDaddy standard).
  bool get isAutoTtl => ttl == 1;

  DnsRecord copyWith({
    String? id,
    String? domain,
    String? type,
    String? name,
    String? content,
    int? ttl,
    int? priority,
    bool? proxied,
  }) => DnsRecord(
    id: id ?? this.id,
    domain: domain ?? this.domain,
    type: type ?? this.type,
    name: name ?? this.name,
    content: content ?? this.content,
    ttl: ttl ?? this.ttl,
    priority: priority ?? this.priority,
    proxied: proxied ?? this.proxied,
  );
}

import 'project_analytics.dart';

enum GscSearchType {
  web('web', 'Web'),
  image('image', 'Image'),
  video('video', 'Video'),
  news('news', 'News'),
  discover('discover', 'Discover');

  const GscSearchType(this.id, this.displayName);
  final String id;
  final String displayName;
}

enum GscAggregationType {
  auto('auto', 'Auto'),
  byProperty('byProperty', 'By Property'),
  byPage('byPage', 'By Page');

  const GscAggregationType(this.id, this.displayName);
  final String id;
  final String displayName;
}

class GscSite {
  const GscSite({
    required this.siteUrl,
    required this.permissionLevel,
  });

  final String siteUrl;
  final String permissionLevel;

  String get cleanDomain {
    var s = siteUrl;
    if (s.startsWith('sc-domain:')) s = s.substring(10);
    final uri = Uri.tryParse(s);
    if (uri != null && uri.host.isNotEmpty) return uri.host;
    return s.replaceAll(RegExp(r'^https?://'), '').replaceAll(RegExp(r'/.*$'), '');
  }

  bool get isOwner =>
      permissionLevel == 'siteOwner' ||
      permissionLevel == 'siteFullUser' ||
      permissionLevel == 'siteOwnerUser';

  factory GscSite.fromJson(Map<String, dynamic> json) {
    return GscSite(
      siteUrl: (json['siteUrl'] as String? ?? '').trim(),
      permissionLevel: (json['permissionLevel'] as String? ?? 'siteRestrictedUser').trim(),
    );
  }
}

class GscPerformanceRow {
  const GscPerformanceRow({
    this.keys = const [],
    required this.clicks,
    required this.impressions,
    required this.ctr,
    required this.position,
    String? query,
    String? page,
    String? country,
    String? device,
    DateTime? date,
  })  : _query = query,
        _page = page,
        _country = country,
        _device = device,
        _date = date;

  final List<String> keys;
  final int clicks;
  final int impressions;
  final double ctr;
  final double position;
  final String? _query;
  final String? _page;
  final String? _country;
  final String? _device;
  final DateTime? _date;

  String get primaryKey => keys.isNotEmpty
      ? keys.first
      : (_query ?? _page ?? _country ?? _device ?? '');

  String? get query => _query ?? (keys.isNotEmpty ? keys[0] : null);
  String? get page => _page ?? (keys.length > 1 ? keys[1] : (keys.isNotEmpty ? keys[0] : null));
  String? get country => _country ?? (keys.isNotEmpty ? keys[0] : null);
  String? get device => _device ?? (keys.isNotEmpty ? keys[0] : null);
  DateTime? get date => _date ?? (keys.isNotEmpty ? DateTime.tryParse(keys[0]) : null);

  factory GscPerformanceRow.fromJson(Map<String, dynamic> json) {
    final rawKeys = json['keys'] as List?;
    final kList = rawKeys?.map((k) => k.toString()).toList() ?? const <String>[];
    return GscPerformanceRow(
      keys: kList,
      clicks: (json['clicks'] as num?)?.toInt() ?? 0,
      impressions: (json['impressions'] as num?)?.toInt() ?? 0,
      ctr: (json['ctr'] as num?)?.toDouble() ?? 0.0,
      position: (json['position'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class GscPerformanceReport {
  const GscPerformanceReport({
    required this.siteUrl,
    int? totalClicks,
    int? totalImpressions,
    double? avgCtr,
    double? avgPosition,
    List<TimeSeriesPoint>? clicksTimeseries,
    List<TimeSeriesPoint>? impressionsTimeseries,
    List<TimeSeriesPoint>? ctrTimeseries,
    List<TimeSeriesPoint>? positionTimeseries,
    List<GscPerformanceRow> topQueries = const [],
    List<GscPerformanceRow> topPages = const [],
    List<GscPerformanceRow> topCountries = const [],
    List<GscPerformanceRow> topDevices = const [],
    this.clicksDelta,
    this.impressionsDelta,
    this.fetchedAt,
    this.rows = const [],
    this.startDate,
    this.endDate,
    this.searchType,
    this.aggregationType,
  })  : _totalClicks = totalClicks,
        _totalImpressions = totalImpressions,
        _avgCtr = avgCtr,
        _avgPosition = avgPosition,
        clicksTimeseries = clicksTimeseries ?? const [],
        impressionsTimeseries = impressionsTimeseries ?? const [],
        ctrTimeseries = ctrTimeseries ?? const [],
        positionTimeseries = positionTimeseries ?? const [],
        _topQueries = topQueries,
        _topPages = topPages,
        _topCountries = topCountries,
        _topDevices = topDevices;

  final String siteUrl;
  final int? _totalClicks;
  final int? _totalImpressions;
  final double? _avgCtr;
  final double? _avgPosition;
  final List<TimeSeriesPoint> clicksTimeseries;
  final List<TimeSeriesPoint> impressionsTimeseries;
  final List<TimeSeriesPoint> ctrTimeseries;
  final List<TimeSeriesPoint> positionTimeseries;
  final List<GscPerformanceRow> _topQueries;
  final List<GscPerformanceRow> _topPages;
  final List<GscPerformanceRow> _topCountries;
  final List<GscPerformanceRow> _topDevices;
  final double? clicksDelta;
  final double? impressionsDelta;
  final DateTime? fetchedAt;
  final List<GscPerformanceRow> rows;
  final DateTime? startDate;
  final DateTime? endDate;
  final GscSearchType? searchType;
  final GscAggregationType? aggregationType;

  List<GscPerformanceRow> get topQueries => _topQueries.isNotEmpty
      ? _topQueries
      : rows.where((r) => r.query != null).toList();

  List<GscPerformanceRow> get topPages => _topPages.isNotEmpty
      ? _topPages
      : rows.where((r) => r.page != null).toList();

  List<GscPerformanceRow> get topCountries => _topCountries.isNotEmpty
      ? _topCountries
      : rows.where((r) => r.country != null).toList();

  List<GscPerformanceRow> get topDevices => _topDevices.isNotEmpty
      ? _topDevices
      : rows.where((r) => r.device != null).toList();

  int get totalClicks =>
      _totalClicks ??
      (rows.isNotEmpty
          ? rows.fold<int>(0, (sum, r) => sum + r.clicks)
          : 0);

  int get totalImpressions =>
      _totalImpressions ??
      (rows.isNotEmpty
          ? rows.fold<int>(0, (sum, r) => sum + r.impressions)
          : 0);

  double get avgCtr =>
      _avgCtr ??
      (totalImpressions > 0 ? (totalClicks / totalImpressions) : 0.0);

  double get averageCtr => avgCtr;

  double get avgPosition =>
      _avgPosition ??
      (rows.isNotEmpty
          ? (rows.fold<double>(0.0, (sum, r) => sum + r.position) / rows.length)
          : 0.0);

  double get averagePosition => avgPosition;
}

class GscSitemap {
  const GscSitemap({
    required this.path,
    this.lastSubmitted,
    this.status,
    required this.totalUrls,
    required this.indexedUrls,
    required this.warnings,
    required this.errors,
    this.isSitemapsIndex = false,
    String? type,
    bool? isPending,
  })  : _type = type,
        _isPending = isPending;

  final String path;
  final DateTime? lastSubmitted;
  final String? status;
  final int totalUrls;
  final int indexedUrls;
  final int warnings;
  final int errors;
  final bool isSitemapsIndex;
  final String? _type;
  final bool? _isPending;

  bool get hasErrors => errors > 0;
  bool get isPending => _isPending ?? (status?.toLowerCase() == 'pending');
  String get type => _type ?? (isSitemapsIndex ? 'index' : 'sitemap');

  factory GscSitemap.fromJson(Map<String, dynamic> json) {
    final contents = (json['contents'] as List?) ?? [];
    int total = 0;
    int indexed = 0;
    for (final c in contents) {
      if (c is Map) {
        total += (c['submitted'] as num?)?.toInt() ?? 0;
        indexed += (c['indexed'] as num?)?.toInt() ?? 0;
      }
    }

    return GscSitemap(
      path: json['path'] as String? ?? '',
      lastSubmitted: json['lastSubmitted'] != null
          ? DateTime.tryParse(json['lastSubmitted'].toString())
          : null,
      status: json['status'] as String? ?? 'UNKNOWN',
      totalUrls: total,
      indexedUrls: indexed,
      warnings: (json['warnings'] as num?)?.toInt() ?? 0,
      errors: (json['errors'] as num?)?.toInt() ?? 0,
      isSitemapsIndex: json['isSitemapsIndex'] as bool? ?? false,
      type: json['type'] as String?,
      isPending: json['isPending'] as bool?,
    );
  }
}

class GscInspectionResult {
  const GscInspectionResult({
    required this.inspectedUrl,
    required this.verdict,
    required this.coverageState,
    required this.indexingState,
    this.lastCrawlTime,
    this.pageFetchState,
    this.googleCanonical,
    this.userCanonical,
    this.crawledAs = 'MOBILE',
    this.robotsTxtState = 'ALLOWED',
    this.mobileUsabilityVerdict = 'PASS',
  });

  final String inspectedUrl;
  final String verdict; // PASS, NEUTRAL, FAIL
  final String coverageState;
  final String indexingState;
  final DateTime? lastCrawlTime;
  final String? pageFetchState;
  final String? googleCanonical;
  final String? userCanonical;
  final String crawledAs;
  final String robotsTxtState;
  final String mobileUsabilityVerdict;

  String get inspectionUrl => inspectedUrl;

  bool get isIndexed =>
      verdict == 'PASS' ||
      coverageState.toLowerCase().contains('indexed') ||
      indexingState.toLowerCase().contains('indexed');

  factory GscInspectionResult.fromJson(dynamic p1, [dynamic p2]) {
    final Map<String, dynamic> json;
    final String url;
    if (p1 is Map<String, dynamic>) {
      json = p1;
      url = p2 is String ? p2 : '';
    } else {
      url = p1 is String ? p1 : '';
      json = p2 is Map<String, dynamic> ? p2 : const {};
    }

    final inspectResult = json['inspectionResult'] as Map<String, dynamic>? ?? json;
    final indexStatusResult =
        inspectResult['indexStatusResult'] as Map<String, dynamic>? ?? {};
    final mobileResult =
        inspectResult['mobileUsabilityResult'] as Map<String, dynamic>? ?? {};

    return GscInspectionResult(
      inspectedUrl: url,
      verdict: (indexStatusResult['verdict'] as String? ?? 'NEUTRAL').toUpperCase(),
      coverageState: indexStatusResult['coverageState'] as String? ?? 'Not inspected',
      indexingState: indexStatusResult['indexingState'] as String? ?? 'UNKNOWN',
      lastCrawlTime: indexStatusResult['lastCrawlTime'] != null
          ? DateTime.tryParse(indexStatusResult['lastCrawlTime'].toString())
          : null,
      pageFetchState: indexStatusResult['pageFetchState'] as String? ?? 'SUCCESSFUL',
      googleCanonical: indexStatusResult['googleCanonical'] as String?,
      userCanonical: indexStatusResult['userCanonical'] as String?,
      crawledAs: indexStatusResult['crawledAs'] as String? ?? 'MOBILE',
      robotsTxtState: indexStatusResult['robotsTxtState'] as String? ?? 'ALLOWED',
      mobileUsabilityVerdict: mobileResult['verdict'] as String? ?? 'PASS',
    );
  }
}

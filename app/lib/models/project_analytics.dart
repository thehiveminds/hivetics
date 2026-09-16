import 'dart:math' as math;

enum AnalyticsTimeframe {
  day('24h', 'Last 24 Hours', Duration(hours: 24)),
  week('7d', 'Last 7 Days', Duration(days: 7)),
  month('28d', 'Last 28 Days', Duration(days: 28)),
  quarter('90d', 'Last 90 Days', Duration(days: 90));

  const AnalyticsTimeframe(this.label, this.displayName, this.duration);
  final String label;
  final String displayName;
  final Duration duration;
}

enum AnalyticsMetricType {
  pageViews('Page Views', 'Views', true),
  visitors('Visitors', 'Uniques', true),
  requests('Requests', 'Hits', true),
  cacheHitRate('Cache Hit', 'Ratio', true);

  const AnalyticsMetricType(this.displayName, this.shortName, this.higherIsBetter);
  final String displayName;
  final String shortName;
  final bool higherIsBetter;
}

class TimeSeriesPoint {
  const TimeSeriesPoint({
    required this.timestamp,
    required this.value,
    this.label,
  });

  final DateTime timestamp;
  final double value;
  final String? label;

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'value': value,
        if (label != null) 'label': label,
      };

  factory TimeSeriesPoint.fromJson(Map<String, dynamic> json) {
    return TimeSeriesPoint(
      timestamp: DateTime.parse(json['timestamp'] as String),
      value: (json['value'] as num).toDouble(),
      label: json['label'] as String?,
    );
  }
}

class CacheBreakdown {
  const CacheBreakdown({
    required this.hits,
    required this.misses,
    required this.bypasses,
  });

  final int hits;
  final int misses;
  final int bypasses;

  int get total => hits + misses + bypasses;

  double get hitRate => total > 0 ? (hits / total) * 100 : 0.0;
  double get missRate => total > 0 ? (misses / total) * 100 : 0.0;
  double get bypassRate => total > 0 ? (bypasses / total) * 100 : 0.0;

  Map<String, dynamic> toJson() => {
        'hits': hits,
        'misses': misses,
        'bypasses': bypasses,
        'hitRate': hitRate,
      };

  factory CacheBreakdown.fromJson(Map<String, dynamic> json) {
    return CacheBreakdown(
      hits: (json['hits'] as num?)?.toInt() ?? 0,
      misses: (json['misses'] as num?)?.toInt() ?? 0,
      bypasses: (json['bypasses'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProjectAnalytics {
  const ProjectAnalytics({
    required this.projectId,
    required this.timeframe,
    required this.totalPageViews,
    required this.totalVisitors,
    required this.totalRequests,
    required this.totalBandwidthBytes,
    required this.cache,
    required this.pageViewsTimeseries,
    required this.visitorsTimeseries,
    required this.requestsTimeseries,
    required this.cacheHitRateTimeseries,
    this.pageViewsDelta,
    this.visitorsDelta,
    this.requestsDelta,
    this.isWebAnalyticsEnabled = true,
    required this.fetchedAt,
  });

  final String projectId;
  final AnalyticsTimeframe timeframe;
  final int totalPageViews;
  final int totalVisitors;
  final int totalRequests;
  final int totalBandwidthBytes;
  final CacheBreakdown cache;
  final List<TimeSeriesPoint> pageViewsTimeseries;
  final List<TimeSeriesPoint> visitorsTimeseries;
  final List<TimeSeriesPoint> requestsTimeseries;
  final List<TimeSeriesPoint> cacheHitRateTimeseries;
  final double? pageViewsDelta; // e.g. +14.2%
  final double? visitorsDelta;  // e.g. -2.1%
  final double? requestsDelta;  // e.g. +8.7%
  final bool isWebAnalyticsEnabled;
  final DateTime fetchedAt;

  List<TimeSeriesPoint> getTimeseriesForMetric(AnalyticsMetricType metric) {
    switch (metric) {
      case AnalyticsMetricType.pageViews:
        return pageViewsTimeseries;
      case AnalyticsMetricType.visitors:
        return visitorsTimeseries;
      case AnalyticsMetricType.requests:
        return requestsTimeseries;
      case AnalyticsMetricType.cacheHitRate:
        return cacheHitRateTimeseries;
    }
  }

  double getValueForMetric(AnalyticsMetricType metric) {
    switch (metric) {
      case AnalyticsMetricType.pageViews:
        return totalPageViews.toDouble();
      case AnalyticsMetricType.visitors:
        return totalVisitors.toDouble();
      case AnalyticsMetricType.requests:
        return totalRequests.toDouble();
      case AnalyticsMetricType.cacheHitRate:
        return cache.hitRate;
    }
  }

  double? getDeltaForMetric(AnalyticsMetricType metric) {
    switch (metric) {
      case AnalyticsMetricType.pageViews:
        return pageViewsDelta;
      case AnalyticsMetricType.visitors:
        return visitorsDelta;
      case AnalyticsMetricType.requests:
        return requestsDelta;
      case AnalyticsMetricType.cacheHitRate:
        return null;
    }
  }

  String formatValue(AnalyticsMetricType metric) {
    switch (metric) {
      case AnalyticsMetricType.pageViews:
        return _formatCompactNumber(totalPageViews);
      case AnalyticsMetricType.visitors:
        return _formatCompactNumber(totalVisitors);
      case AnalyticsMetricType.requests:
        return _formatCompactNumber(totalRequests);
      case AnalyticsMetricType.cacheHitRate:
        return '${cache.hitRate.toStringAsFixed(1)}%';
    }
  }

  String formatBandwidth() {
    if (totalBandwidthBytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int digitGroups = (math.log(totalBandwidthBytes) / math.log(1024)).floor();
    digitGroups = digitGroups.clamp(0, units.length - 1);
    final count = totalBandwidthBytes / math.pow(1024, digitGroups);
    return '${count.toStringAsFixed(count >= 10 ? 1 : 2)} ${units[digitGroups]}';
  }

  static String _formatCompactNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}

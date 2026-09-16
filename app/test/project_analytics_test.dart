import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hivehub/models/project_analytics.dart';
import 'package:hivehub/shared/theme.dart';
import 'package:hivehub/widgets/charts/cache_hit_bar.dart';
import 'package:hivehub/widgets/charts/ios_trend_chart.dart';

void main() {
  group('ProjectAnalytics Models & Metrics', () {
    test('CacheBreakdown calculates hit, miss, and bypass rates correctly', () {
      const cache = CacheBreakdown(hits: 900, misses: 50, bypasses: 50);
      expect(cache.total, equals(1000));
      expect(cache.hitRate, equals(90.0));
      expect(cache.missRate, equals(5.0));
      expect(cache.bypassRate, equals(5.0));
    });

    test('ProjectAnalytics formats metric values and bandwidth', () {
      final now = DateTime.now();
      final analytics = ProjectAnalytics(
        projectId: 'prj_test_123',
        timeframe: AnalyticsTimeframe.month,
        totalPageViews: 14500,
        totalVisitors: 8200,
        totalRequests: 48900,
        totalBandwidthBytes: 15728640, // 15 MB
        cache: const CacheBreakdown(hits: 45000, misses: 2500, bypasses: 1400),
        pageViewsTimeseries: [
          TimeSeriesPoint(timestamp: now, value: 14500),
        ],
        visitorsTimeseries: [
          TimeSeriesPoint(timestamp: now, value: 8200),
        ],
        requestsTimeseries: [
          TimeSeriesPoint(timestamp: now, value: 48900),
        ],
        cacheHitRateTimeseries: [
          TimeSeriesPoint(timestamp: now, value: 92.0),
        ],
        pageViewsDelta: 14.5,
        visitorsDelta: 8.2,
        requestsDelta: -2.1,
        fetchedAt: now,
      );

      expect(analytics.formatValue(AnalyticsMetricType.pageViews), equals('14.5k'));
      expect(analytics.formatValue(AnalyticsMetricType.visitors), equals('8.2k'));
      expect(analytics.formatValue(AnalyticsMetricType.requests), equals('48.9k'));
      expect(analytics.formatBandwidth(), contains('MB'));
      expect(analytics.getDeltaForMetric(AnalyticsMetricType.pageViews), equals(14.5));
      expect(analytics.getDeltaForMetric(AnalyticsMetricType.requests), equals(-2.1));
    });

    test('AnalyticsTimeframe durations are accurate', () {
      expect(AnalyticsTimeframe.day.duration, equals(const Duration(hours: 24)));
      expect(AnalyticsTimeframe.week.duration, equals(const Duration(days: 7)));
      expect(AnalyticsTimeframe.month.duration, equals(const Duration(days: 28)));
      expect(AnalyticsTimeframe.quarter.duration, equals(const Duration(days: 90)));
    });
  });

  group('Chart Widgets Rendering', () {
    testWidgets('IosTrendChart renders and displays points and trend', (tester) async {
      final now = DateTime.now();
      final points = List.generate(
        10,
        (i) => TimeSeriesPoint(
          timestamp: now.subtract(Duration(days: 9 - i)),
          value: (100 + i * 20).toDouble(),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
        theme: HHTheme.dark().withHHExtension(),
          home: Scaffold(
            body: IosTrendChart(
              points: points,
              lineColor: const Color(0xFFF5A623),
            ),
          ),
        ),
      );

      expect(find.byType(IosTrendChart), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('Touch & drag to inspect'), findsOneWidget);
    });

    testWidgets('CacheHitBar renders metrics and legend items', (tester) async {
      const cache = CacheBreakdown(hits: 920, misses: 50, bypasses: 30);

      await tester.pumpWidget(
        MaterialApp(
        theme: HHTheme.dark().withHHExtension(),
          home: const Scaffold(
            body: CacheHitBar(
              cache: cache,
              formattedBandwidth: '4.2 GB',
            ),
          ),
        ),
      );

      expect(find.text('Edge Cache Efficiency'), findsOneWidget);
      expect(find.text('92.0%'), findsOneWidget);
      expect(find.text('4.2 GB'), findsOneWidget);
      expect(find.text('Data Transfer'), findsOneWidget);
      expect(find.text('OPTIMIZED'), findsOneWidget);
    });
  });
}

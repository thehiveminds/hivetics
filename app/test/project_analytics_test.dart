import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hivehub/features/sites/widgets/site_analytics_section.dart';
import 'package:hivehub/models/connection.dart';
import 'package:hivehub/models/project.dart';
import 'package:hivehub/models/project_analytics.dart';
import 'package:hivehub/models/service_ref.dart';
import 'package:hivehub/models/site.dart';
import 'package:hivehub/providers/hosting/vercel_provider.dart';
import 'package:hivehub/shared/theme.dart';
import 'package:hivehub/state/project_analytics_notifier.dart';
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

    test('VercelProvider produces distinctive curve profiles for each metric', () async {
      final provider = VercelProvider();
      const conn = Connection(
        id: 'conn_vercel_1',
        displayName: 'Vercel Prod',
        service: HostRef(ProviderId.vercel),
      );

      final result = await provider.getProjectAnalytics(
        conn,
        'dummy_token',
        'prj_distinctive_test',
        timeframe: AnalyticsTimeframe.month,
      );

      expect(result.isOk, isTrue);
      final analytics = result.valueOrThrow;

      final views = analytics.pageViewsTimeseries;
      final visitors = analytics.visitorsTimeseries;
      final requests = analytics.requestsTimeseries;
      final cache = analytics.cacheHitRateTimeseries;

      expect(views.isNotEmpty, isTrue);
      expect(visitors.isNotEmpty, isTrue);
      expect(requests.isNotEmpty, isTrue);
      expect(cache.isNotEmpty, isTrue);

      // Verify that curves are not simply constant-scaled multiples of each other
      final ratios = <double>[];
      for (int i = 0; i < views.length; i++) {
        if (views[i].value > 0) {
          ratios.add(visitors[i].value / views[i].value);
        }
      }

      // Check ratio variance exists (not an identical scalar)
      final minRatio = ratios.reduce((a, b) => a < b ? a : b);
      final maxRatio = ratios.reduce((a, b) => a > b ? a : b);
      expect(maxRatio - minRatio, greaterThan(0.05),
          reason: 'Visitors curve must dynamically deviate from Views curve');

      // Check Cache Hit Rate stays strictly in percentage domain
      for (final pt in cache) {
        expect(pt.value, inInclusiveRange(80.0, 100.0));
      }
    });

    testWidgets('SiteAnalyticsSection returns empty SizedBox for Netlify sites', (tester) async {
      const netlifySite = Site(
        id: 'site_netlify_1',
        displayName: 'My Netlify Site',
        domain: 'example-netlify.com',
        hostProject: Project(
          id: 'net_prj_1',
          connectionId: 'conn_net_1',
          name: 'netlify-site',
          providerId: ProviderId.netlify,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: HHTheme.dark().withHHExtension(),
            home: const Scaffold(
              body: SiteAnalyticsSection(
                connectionId: 'conn_net_1',
                projectId: 'net_prj_1',
                site: netlifySite,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Ensure no TRAFFIC & ANALYTICS header or timeframe filters are rendered
      expect(find.text('TRAFFIC & ANALYTICS'), findsNothing);
      expect(find.text('24h'), findsNothing);
      expect(find.text('7d'), findsNothing);
      expect(find.text('28d'), findsNothing);
      expect(find.text('90d'), findsNothing);
    });

    testWidgets('SiteAnalyticsSection renders title above full-width days segmented control', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const vercelSite = Site(
        id: 'site_vercel_1',
        displayName: 'My Vercel Site',
        domain: 'example-vercel.com',
        hostProject: Project(
          id: 'prj_vercel_1',
          connectionId: 'conn_vercel_1',
          name: 'vercel-site',
          providerId: ProviderId.vercel,
        ),
      );

      final testAnalytics = ProjectAnalytics(
        projectId: 'prj_vercel_1',
        timeframe: AnalyticsTimeframe.month,
        totalPageViews: 1000,
        totalVisitors: 500,
        totalRequests: 2000,
        totalBandwidthBytes: 1024,
        cache: const CacheBreakdown(hits: 90, misses: 10, bypasses: 0),
        pageViewsTimeseries: [],
        visitorsTimeseries: [],
        requestsTimeseries: [],
        cacheHitRateTimeseries: [],
        fetchedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            projectAnalyticsProvider((
              connectionId: 'conn_vercel_1',
              projectId: 'prj_vercel_1',
              timeframe: AnalyticsTimeframe.month,
            )).overrideWith((ref) => testAnalytics),
          ],
          child: MaterialApp(
            theme: HHTheme.dark().withHHExtension(),
            home: const Scaffold(
              body: SiteAnalyticsSection(
                connectionId: 'conn_vercel_1',
                projectId: 'prj_vercel_1',
                site: vercelSite,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final titleFinder = find.text('TRAFFIC & ANALYTICS');
      final segmentedFinder = find.byType(CupertinoSlidingSegmentedControl<AnalyticsTimeframe>);

      expect(titleFinder, findsOneWidget);
      expect(segmentedFinder, findsOneWidget);

      // Verify Title is strictly ABOVE the segmented control (stacked layout, not same row)
      final titleBottom = tester.getBottomLeft(titleFinder).dy;
      final segmentedTop = tester.getTopLeft(segmentedFinder).dy;
      expect(segmentedTop, greaterThan(titleBottom));

      // Verify Segmented Control occupies the full content width (400 - 32 screenPadding = 368)
      final segmentedWidth = tester.getSize(segmentedFinder).width;
      expect(segmentedWidth, equals(368.0));
    });
  });
}

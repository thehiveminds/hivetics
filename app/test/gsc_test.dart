import 'package:flutter_test/flutter_test.dart';
import 'package:hivehub/models/credential.dart';
import 'package:hivehub/models/gsc_models.dart';
import 'package:hivehub/models/service_ref.dart';
import 'package:hivehub/providers/analytics/gsc_provider.dart';
import 'package:hivehub/providers/provider_registry.dart';

void main() {
  group('Google Search Console Models', () {
    test('GscSite deserializes correctly', () {
      final json = {
        'siteUrl': 'sc-domain:thehiveminds.in',
        'permissionLevel': 'siteOwner',
      };
      final site = GscSite.fromJson(json);
      expect(site.siteUrl, equals('sc-domain:thehiveminds.in'));
      expect(site.permissionLevel, equals('siteOwner'));
      expect(site.isOwner, isTrue);
    });

    test('GscPerformanceRow deserializes keys and metrics', () {
      final json = {
        'keys': ['the hive minds', 'https://thehiveminds.in/blog'],
        'clicks': 42,
        'impressions': 1200,
        'ctr': 0.035,
        'position': 8.4,
      };
      final row = GscPerformanceRow.fromJson(json);
      expect(row.clicks, equals(42));
      expect(row.impressions, equals(1200));
      expect(row.ctr, closeTo(0.035, 0.0001));
      expect(row.position, equals(8.4));
      expect(row.query, equals('the hive minds'));
      expect(row.page, equals('https://thehiveminds.in/blog'));
    });

    test('GscPerformanceReport computes totals, averages and breakdowns', () {
      final rows = [
        const GscPerformanceRow(
          clicks: 100,
          impressions: 2000,
          ctr: 0.05,
          position: 5.0,
          query: 'hive hub',
          page: 'https://thehiveminds.in/',
          country: 'usa',
          device: 'mobile',
        ),
        const GscPerformanceRow(
          clicks: 50,
          impressions: 1000,
          ctr: 0.05,
          position: 15.0,
          query: 'hivetics flutter',
          page: 'https://thehiveminds.in/docs',
          country: 'ind',
          device: 'desktop',
        ),
      ];

      final report = GscPerformanceReport(
        siteUrl: 'sc-domain:thehiveminds.in',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 28),
        searchType: GscSearchType.web,
        aggregationType: GscAggregationType.auto,
        rows: rows,
      );

      expect(report.totalClicks, equals(150));
      expect(report.totalImpressions, equals(3000));
      expect(report.averageCtr, closeTo(0.05, 0.001));
      expect(report.averagePosition, equals(10.0));
      expect(report.topQueries.length, equals(2));
      expect(report.topQueries.first.query, equals('hive hub'));
      expect(report.topPages.length, equals(2));
      expect(report.topCountries.length, equals(2));
      expect(report.topDevices.length, equals(2));
    });

    test('GscSitemap parses index status and error state', () {
      final json = {
        'path': 'https://thehiveminds.in/sitemap.xml',
        'type': 'sitemap',
        'lastSubmitted': '2026-08-15T12:00:00Z',
        'isPending': false,
        'isSitemapsIndex': false,
        'errors': 0,
        'warnings': 0,
      };

      final sitemap = GscSitemap.fromJson(json);
      expect(sitemap.path, equals('https://thehiveminds.in/sitemap.xml'));
      expect(sitemap.type, equals('sitemap'));
      expect(sitemap.hasErrors, isFalse);
      expect(sitemap.isPending, isFalse);
    });

    test('GscInspectionResult parses indexing verdict and coverage', () {
      final json = {
        'inspectionResult': {
          'indexStatusResult': {
            'verdict': 'PASS',
            'coverageState': 'Submitted and indexed',
            'crawledAs': 'MOBILE',
            'pageFetchState': 'SUCCESSFUL',
            'robotsTxtState': 'ALLOWED',
            'lastCrawlTime': '2026-09-01T10:00:00Z',
          },
          'mobileUsabilityResult': {
            'verdict': 'PASS',
          },
        },
      };

      final result = GscInspectionResult.fromJson(
        'https://thehiveminds.in/about',
        json,
      );
      expect(result.inspectionUrl, equals('https://thehiveminds.in/about'));
      expect(result.verdict, equals('PASS'));
      expect(result.coverageState, equals('Submitted and indexed'));
      expect(result.crawledAs, equals('MOBILE'));
      expect(result.mobileUsabilityVerdict, equals('PASS'));
    });
  });

  group('Analytics Provider Registry & GscProvider', () {
    test('Registry resolves GscProvider for gsc provider id', () {
      final provider = analyticsProviderFor(AnalyticsProviderId.gsc);
      expect(provider, isA<GscProvider>());
      expect(provider.id, equals(AnalyticsProviderId.gsc));
      expect(allAnalyticsProviders.length, equals(5));
    });

    test('GscProvider validates demo token without network', () async {
      final provider = GscProvider();
      final res = await provider.validate(
        const BearerCredential(token: 'demo-gsc-token-12345'),
      );
      expect(res.isOk, isTrue);
      res.when(
        ok: (acc) {
          expect(acc.displayName, contains('Search Console'));
        },
        err: (e) => fail('Validation should succeed for demo token'),
      );
    });

    test('GscProvider generates deterministic offline performance report', () async {
      final provider = GscProvider();
      final report = provider.generateSampleReport(
        siteUrl: 'sc-domain:thehiveminds.in',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 28),
        searchType: GscSearchType.web,
        aggregationType: GscAggregationType.auto,
      );

      expect(report.siteUrl, equals('sc-domain:thehiveminds.in'));
      expect(report.rows.isNotEmpty, isTrue);
      expect(report.totalClicks, greaterThan(0));
      expect(report.totalImpressions, greaterThan(report.totalClicks));
      expect(report.averagePosition, inInclusiveRange(1.0, 50.0));
    });

    test('AnalyticsRef identity and kind', () {
      const ref = AnalyticsRef(AnalyticsProviderId.gsc);
      expect(ref.id, equals('gsc'));
      expect(ref.displayName, equals('Google Search Console'));
      expect(ref.analytics, equals(AnalyticsProviderId.gsc));
    });
  });
}

// MIT Licence — TheHiveMinds / Hivetics
import 'package:flutter_test/flutter_test.dart';
import 'package:hivehub/models/deploy_status.dart';
import 'package:hivehub/models/deployment.dart';
import 'package:hivehub/models/connection.dart';
import 'package:hivehub/models/service_ref.dart';
import 'package:hivehub/models/site.dart';
import 'package:hivehub/models/site_alert.dart';

void main() {
  group('SiteAlert model', () {
    test('buildFailed produces an error alert with correct message', () {
      const alert = SiteAlert.buildFailed;
      expect(alert.severity, AlertSeverity.error);
      expect(alert.isError, isTrue);
      expect(alert.isWarning, isFalse);
      expect(alert.message, 'Last build failed');
    });

    test('tokenExpired produces a warning alert with provider name', () {
      final alertVercel = SiteAlert.tokenExpired('Vercel');
      expect(alertVercel.severity, AlertSeverity.warning);
      expect(alertVercel.isError, isFalse);
      expect(alertVercel.isWarning, isTrue);
      expect(alertVercel.message, 'Reconnect Vercel');

      final alertNetlify = SiteAlert.tokenExpired('Netlify');
      expect(alertNetlify.message, 'Reconnect Netlify');

      final alertCloudflare = SiteAlert.tokenExpired('Cloudflare Pages');
      expect(alertCloudflare.message, 'Reconnect Cloudflare Pages');
    });
  });

  group('Site alert computation & aggregation', () {
    test('Site without alerts reports hasAlerts=false and hasError=false', () {
      const site = Site(
        id: 'host:proj-1',
        displayName: 'My Project',
        alerts: [],
      );
      expect(site.hasAlerts, isFalse);
      expect(site.hasError, isFalse);
    });

    test('Site with warning alert reports hasAlerts=true, hasError=false', () {
      final site = Site(
        id: 'host:proj-1',
        displayName: 'My Project',
        alerts: [SiteAlert.tokenExpired('Vercel')],
      );
      expect(site.hasAlerts, isTrue);
      expect(site.hasError, isFalse);
    });

    test('Site with error alert reports hasAlerts=true, hasError=true', () {
      const site = Site(
        id: 'host:proj-1',
        displayName: 'My Project',
        alerts: [SiteAlert.buildFailed],
      );
      expect(site.hasAlerts, isTrue);
      expect(site.hasError, isTrue);
    });

    test('Alert computation: connection unauthorized produces tokenExpired alert', () {
      const unauthConnection = Connection(
        id: 'conn-1',
        service: HostRef(ProviderId.vercel),
        displayName: 'Vercel Team',
        lastError: 'UnauthorizedException',
      );
      expect(unauthConnection.isUnauthorized, isTrue);

      final alerts = <SiteAlert>[];
      if (unauthConnection.isUnauthorized) {
        alerts.add(SiteAlert.tokenExpired(
          (unauthConnection.service as HostRef).provider.displayName,
        ));
      }

      expect(alerts.length, 1);
      expect(alerts.first.message, 'Reconnect Vercel');
      expect(alerts.first.isWarning, isTrue);
    });

    test('Alert computation: failed deployment produces buildFailed alert', () {
      final failedDeploy = Deployment(
        id: 'dep-1',
        projectId: 'proj-1',
        connectionId: 'conn-1',
        status: DeployStatus.failed,
        createdAt: DateTime.now().toUtc(),
      );

      final alerts = <SiteAlert>[];
      if (failedDeploy.status == DeployStatus.failed) {
        alerts.add(SiteAlert.buildFailed);
      }

      expect(alerts.length, 1);
      expect(alerts.first.isError, isTrue);
      expect(alerts.first.message, 'Last build failed');
    });

    test('Alert computation: successful deployment produces no alert', () {
      final readyDeploy = Deployment(
        id: 'dep-2',
        projectId: 'proj-1',
        connectionId: 'conn-1',
        status: DeployStatus.ready,
        createdAt: DateTime.now().toUtc(),
      );

      final alerts = <SiteAlert>[];
      if (readyDeploy.status == DeployStatus.failed) {
        alerts.add(SiteAlert.buildFailed);
      }

      expect(alerts, isEmpty);
    });

    test('Site sorting: sites with alerts come before sites without alerts', () {
      final now = DateTime.now().toUtc();

      final normalSiteRecent = Site(
        id: 'site-recent',
        displayName: 'Recent Deploy',
        latestDeployment: Deployment(
          id: 'd1',
          projectId: 'p1',
          connectionId: 'conn-1',
          status: DeployStatus.ready,
          createdAt: now,
        ),
        alerts: const [],
      );

      final alertedSiteOlder = Site(
        id: 'site-alerted',
        displayName: 'Alerted Older',
        latestDeployment: Deployment(
          id: 'd2',
          projectId: 'p2',
          connectionId: 'conn-1',
          status: DeployStatus.failed,
          createdAt: now.subtract(const Duration(days: 2)),
        ),
        alerts: const [SiteAlert.buildFailed],
      );

      final list = [normalSiteRecent, alertedSiteOlder];
      // Sort logic from sites screen: alerts first, then newest deploy
      list.sort((a, b) {
        if (a.hasAlerts && !b.hasAlerts) return -1;
        if (!a.hasAlerts && b.hasAlerts) return 1;
        return b.sortKey.compareTo(a.sortKey);
      });

      expect(list.first.id, 'site-alerted');
      expect(list.last.id, 'site-recent');
    });
  });
}

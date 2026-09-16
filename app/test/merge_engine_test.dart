import 'package:flutter_test/flutter_test.dart';
import 'package:hivehub/models/connection.dart';
import 'package:hivehub/models/project.dart';
import 'package:hivehub/models/registered_domain.dart';
import 'package:hivehub/models/registrar_id.dart';
import 'package:hivehub/models/site.dart';
import 'package:hivehub/models/site_alert.dart';
import 'package:hivehub/providers/registrar/registrar_status_normalizer.dart';
import 'package:hivehub/shared/domain_utils.dart';

void main() {
  group('Site Merge Engine (§6.1)', () {
    test('Host + registrar match -> one Site, registration attached', () {
      const project = Project(
        id: 'proj-1',
        connectionId: 'conn-vercel',
        providerId: ProviderId.vercel,
        name: 'my-site',
        domains: ['thehiveminds.in'],
      );

      final domain = RegisteredDomain(
        domain: 'thehiveminds.in',
        connectionId: 'conn-godaddy',
        registrar: RegistrarId.godaddy,
        status: DomainStatus.active,
        expiresAt: DateTime.utc(2027, 1, 1),
        autoRenew: true,
        fetchedAt: DateTime.now().toUtc(),
      );

      final normalizedProjDomain = normalizeDomain(project.primaryDomain!);
      expect(normalizedProjDomain, equals(domain.domain));

      final site = Site(
        id: normalizedProjDomain,
        displayName: normalizedProjDomain,
        domain: project.primaryDomain,
        hostProject: project,
        registration: domain,
      );

      expect(site.domain, equals('thehiveminds.in'));
      expect(site.registration, isNotNull);
      expect(site.registration?.registrar, equals(RegistrarId.godaddy));
      expect(site.hasAlerts, isFalse);
    });

    test('Host with no registrar match -> Site without registration', () {
      const project = Project(
        id: 'proj-unlinked',
        connectionId: 'conn-netlify',
        providerId: ProviderId.netlify,
        name: 'unlinked-app',
      );

      const site = Site(
        id: 'host:proj-unlinked',
        displayName: 'unlinked-app',
        hostProject: project,
      );

      expect(site.registration, isNull);
      expect(site.domain, isNull);
      expect(site.displayName, equals('unlinked-app'));
    });

    test('Same domain at two registrars -> later expiresAt is kept (§6.1)', () {
      final earlier = RegisteredDomain(
        domain: 'transferring.com',
        connectionId: 'conn-old',
        registrar: RegistrarId.godaddy,
        status: DomainStatus.active,
        expiresAt: DateTime.utc(2026, 12, 1),
        fetchedAt: DateTime.now().toUtc(),
      );

      final later = RegisteredDomain(
        domain: 'transferring.com',
        connectionId: 'conn-new',
        registrar: RegistrarId.porkbun,
        status: DomainStatus.active,
        expiresAt: DateTime.utc(2028, 12, 1),
        fetchedAt: DateTime.now().toUtc(),
      );

      final candidates = [earlier, later]..sort((a, b) {
          final aExp = a.expiresAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bExp = b.expiresAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bExp.compareTo(aExp);
        });

      final picked = candidates.first;
      expect(picked.registrar, equals(RegistrarId.porkbun));
      expect(picked.expiresAt?.year, equals(2028));
    });

    test('Merge attaches domain alerts to Site', () {
      const project = Project(
        id: 'proj-alert',
        connectionId: 'conn-cf',
        providerId: ProviderId.cloudflarepages,
        name: 'expiring-project',
        domains: ['expiring.com'],
      );

      final now = DateTime.now().toUtc();
      final expiringDomain = RegisteredDomain(
        domain: 'expiring.com',
        connectionId: 'conn-pb',
        registrar: RegistrarId.porkbun,
        status: DomainStatus.active,
        expiresAt: DateTime.utc(now.year, now.month, now.day + 12),
        autoRenew: false,
        fetchedAt: now,
      );

      final alerts = computeDomainAlerts(domain: expiringDomain);
      final site = Site(
        id: 'expiring.com',
        displayName: 'expiring.com',
        domain: 'expiring.com',
        hostProject: project,
        registration: expiringDomain,
        alerts: alerts,
      );

      expect(site.hasAlerts, isTrue);
      expect(site.hasError, isFalse); // warning only
      expect(
        site.alerts.any((a) => a.message == 'Expires in 12 days'),
        isTrue,
      );
      expect(
        site.alerts.any((a) => a == SiteAlert.autoRenewOff),
        isTrue,
      );
    });
  });
}

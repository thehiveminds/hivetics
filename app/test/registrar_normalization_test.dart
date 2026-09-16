// MIT Licence — TheHiveMinds / Hivetics
import 'package:flutter_test/flutter_test.dart';
import 'package:hivehub/models/registered_domain.dart';
import 'package:hivehub/models/registrar_id.dart';
import 'package:hivehub/models/site_alert.dart';
import 'package:hivehub/providers/registrar/registrar_status_normalizer.dart';

void main() {
  group('GoDaddy Status Normalization', () {
    test('ACTIVE → active', () {
      expect(normalizeGoDaddyStatus('ACTIVE'), equals(DomainStatus.active));
      expect(normalizeGoDaddyStatus('active'), equals(DomainStatus.active));
    });

    test('EXPIRED prefixes → expired', () {
      expect(
        normalizeGoDaddyStatus('EXPIRED'),
        equals(DomainStatus.expired),
      );
      expect(
        normalizeGoDaddyStatus('EXPIRED_REASSIGNED'),
        equals(DomainStatus.expired),
      );
      expect(
        normalizeGoDaddyStatus('EXPIRED_PARKED'),
        equals(DomainStatus.expired),
      );
    });

    test('CANCELLED prefixes → cancelled', () {
      expect(
        normalizeGoDaddyStatus('CANCELLED'),
        equals(DomainStatus.cancelled),
      );
      expect(
        normalizeGoDaddyStatus('CANCELLED_HELD'),
        equals(DomainStatus.cancelled),
      );
      expect(
        normalizeGoDaddyStatus('CANCELED_REDEEMABLE'),
        equals(DomainStatus.cancelled),
      );
    });

    test('HELD, RESERVED, DISABLED, FAILED, REVERTED, TRANSFERRED → suspended', () {
      expect(
        normalizeGoDaddyStatus('HELD_SHOPPER'),
        equals(DomainStatus.suspended),
      );
      expect(
        normalizeGoDaddyStatus('RESERVED'),
        equals(DomainStatus.suspended),
      );
      expect(
        normalizeGoDaddyStatus('DISABLED'),
        equals(DomainStatus.suspended),
      );
      expect(
        normalizeGoDaddyStatus('FAILED'),
        equals(DomainStatus.suspended),
      );
      expect(
        normalizeGoDaddyStatus('REVERTED'),
        equals(DomainStatus.suspended),
      );
      expect(
        normalizeGoDaddyStatus('TRANSFERRED'),
        equals(DomainStatus.suspended),
      );
    });

    test('PENDING and AWAITING prefixes → pending', () {
      expect(
        normalizeGoDaddyStatus('PENDING_TRANSFER_IN'),
        equals(DomainStatus.pending),
      );
      expect(
        normalizeGoDaddyStatus('AWAITING_VERIFICATION'),
        equals(DomainStatus.pending),
      );
    });

    test('Null, empty, and unknown statuses fallback to unknown (never error)', () {
      expect(normalizeGoDaddyStatus(null), equals(DomainStatus.unknown));
      expect(normalizeGoDaddyStatus(''), equals(DomainStatus.unknown));
      expect(
        normalizeGoDaddyStatus('SOMETHING_NEW_IN_2026'),
        equals(DomainStatus.unknown),
      );
    });
  });

  group('Porkbun Status & Parsers', () {
    test('Porkbun status normalization', () {
      expect(normalizePorkbunStatus('ACTIVE'), equals(DomainStatus.active));
      expect(normalizePorkbunStatus('EXPIRED'), equals(DomainStatus.expired));
      expect(normalizePorkbunStatus('DELETED'), equals(DomainStatus.cancelled));
      expect(normalizePorkbunStatus('SUSPENDED'), equals(DomainStatus.suspended));
      expect(normalizePorkbunStatus('PENDING'), equals(DomainStatus.pending));
      expect(normalizePorkbunStatus(null), equals(DomainStatus.unknown));
      expect(normalizePorkbunStatus('UNKNOWN'), equals(DomainStatus.unknown));
    });

    test('Porkbun date parser enforces strict UTC', () {
      final date = parsePorkbunDate('2027-01-15 10:00:00');
      expect(date, isNotNull);
      expect(date!.isUtc, isTrue);
      expect(date.year, equals(2027));
      expect(date.month, equals(1));
      expect(date.day, equals(15));
      expect(date.hour, equals(10));
      expect(date.minute, equals(0));
      expect(date.second, equals(0));

      expect(parsePorkbunDate(null), isNull);
      expect(parsePorkbunDate(''), isNull);
      expect(parsePorkbunDate('invalid-date'), isNull);
    });

    test('Porkbun boolean parser handles ints, strings, bools', () {
      expect(parsePorkbunBool(1), isTrue);
      expect(parsePorkbunBool(0), isFalse);
      expect(parsePorkbunBool('1'), isTrue);
      expect(parsePorkbunBool('0'), isFalse);
      expect(parsePorkbunBool(true), isTrue);
      expect(parsePorkbunBool(false), isFalse);
      expect(parsePorkbunBool(null), isNull);
    });

    test('DNS TTL and priority parser handles string and int inputs', () {
      expect(parseDnsTtl('600'), equals(600));
      expect(parseDnsTtl(300), equals(300));
      expect(parseDnsTtl('1'), equals(1)); // Auto
      expect(parseDnsTtl(null), isNull);

      expect(parseDnsPriority('10'), equals(10));
      expect(parseDnsPriority(20), equals(20));
      expect(parseDnsPriority(null), isNull);
    });
  });

  group('Cloudflare Registrar Status Normalization', () {
    test('Cloudflare enum values', () {
      expect(
        normalizeCloudflareRegistrarStatus('active'),
        equals(DomainStatus.active),
      );
      expect(
        normalizeCloudflareRegistrarStatus('expired'),
        equals(DomainStatus.expired),
      );
      expect(
        normalizeCloudflareRegistrarStatus('cancelled'),
        equals(DomainStatus.cancelled),
      );
      expect(
        normalizeCloudflareRegistrarStatus('canceled'),
        equals(DomainStatus.cancelled),
      );
      expect(
        normalizeCloudflareRegistrarStatus('suspended'),
        equals(DomainStatus.suspended),
      );
      expect(
        normalizeCloudflareRegistrarStatus('pending_transfer'),
        equals(DomainStatus.pending),
      );
      expect(
        normalizeCloudflareRegistrarStatus(null),
        equals(DomainStatus.unknown),
      );
      expect(
        normalizeCloudflareRegistrarStatus('custom_state'),
        equals(DomainStatus.unknown),
      );
    });
  });

  group('RegisteredDomain Expiry Derivation & Alert Rules', () {
    RegisteredDomain buildDomain({
      DateTime? expiresAt,
      bool? autoRenew,
    }) {
      return RegisteredDomain(
        domain: 'https://www.example.com/path',
        connectionId: 'conn-1',
        registrar: RegistrarId.godaddy,
        status: DomainStatus.active,
        expiresAt: expiresAt,
        autoRenew: autoRenew,
        fetchedAt: DateTime.now().toUtc(),
      );
    }

    test('Domain normalization occurs on construction', () {
      final domain = buildDomain();
      expect(domain.domain, equals('example.com'));
    });

    test('Null expiresAt has no expiry countdown and is not expiring or expired', () {
      final domain = buildDomain(expiresAt: null);
      expect(domain.daysUntilExpiry, isNull);
      expect(domain.isExpiringSoon, isFalse);
      expect(domain.isExpired, isFalse);
    });

    test('45 days remaining is neither expiring soon nor expired', () {
      final now = DateTime.now().toUtc();
      final domain = buildDomain(
        expiresAt: DateTime.utc(now.year, now.month, now.day + 45),
      );
      expect(domain.daysUntilExpiry, equals(45));
      expect(domain.isExpiringSoon, isFalse);
      expect(domain.isExpired, isFalse);
    });

    test('30 days remaining is expiring soon, not expired', () {
      final now = DateTime.now().toUtc();
      final domain = buildDomain(
        expiresAt: DateTime.utc(now.year, now.month, now.day + 30),
      );
      expect(domain.daysUntilExpiry, equals(30));
      expect(domain.isExpiringSoon, isTrue);
      expect(domain.isExpired, isFalse);
    });

    test('1 day remaining is expiring soon, not expired', () {
      final now = DateTime.now().toUtc();
      final domain = buildDomain(
        expiresAt: DateTime.utc(now.year, now.month, now.day + 1),
      );
      expect(domain.daysUntilExpiry, equals(1));
      expect(domain.isExpiringSoon, isTrue);
      expect(domain.isExpired, isFalse);
    });

    test('0 days remaining is expired, NOT expiring soon (mutually exclusive)', () {
      final now = DateTime.now().toUtc();
      final domain = buildDomain(
        expiresAt: DateTime.utc(now.year, now.month, now.day),
      );
      expect(domain.daysUntilExpiry, equals(0));
      expect(domain.isExpired, isTrue);
      expect(domain.isExpiringSoon, isFalse);
    });

    test('-5 days remaining is expired, NOT expiring soon', () {
      final now = DateTime.now().toUtc();
      final domain = buildDomain(
        expiresAt: DateTime.utc(now.year, now.month, now.day - 5),
      );
      expect(domain.daysUntilExpiry, equals(-5));
      expect(domain.isExpired, isTrue);
      expect(domain.isExpiringSoon, isFalse);
    });

    test('computeDomainAlerts generates correct alerts', () {
      final now = DateTime.now().toUtc();

      // Expired domain
      final expired = buildDomain(
        expiresAt: DateTime.utc(now.year, now.month, now.day - 2),
      );
      final expiredAlerts = computeDomainAlerts(domain: expired);
      expect(expiredAlerts.any((a) => a == SiteAlert.domainExpired), isTrue);
      expect(expiredAlerts.any((a) => a.isWarning), isFalse);

      // Expiring in 10 days, autoRenew on
      final expiring = buildDomain(
        expiresAt: DateTime.utc(now.year, now.month, now.day + 10),
        autoRenew: true,
      );
      final expiringAlerts = computeDomainAlerts(domain: expiring);
      expect(expiringAlerts.length, equals(1));
      expect(expiringAlerts.first.message, equals('Expires in 10 days'));
      expect(expiringAlerts.first.isWarning, isTrue);

      // Expiring in 1 day
      final expiringTomorrow = buildDomain(
        expiresAt: DateTime.utc(now.year, now.month, now.day + 1),
        autoRenew: true,
      );
      final tomorrowAlerts = computeDomainAlerts(domain: expiringTomorrow);
      expect(tomorrowAlerts.first.message, equals('Expires in 1 day'));

      // 59 days remaining, autoRenew off -> auto-renew warning
      final autoRenewOff59 = buildDomain(
        expiresAt: DateTime.utc(now.year, now.month, now.day + 59),
        autoRenew: false,
      );
      final off59Alerts = computeDomainAlerts(domain: autoRenewOff59);
      expect(off59Alerts.length, equals(1));
      expect(off59Alerts.first, equals(SiteAlert.autoRenewOff));

      // 61 days remaining, autoRenew off -> silent
      final autoRenewOff61 = buildDomain(
        expiresAt: DateTime.utc(now.year, now.month, now.day + 61),
        autoRenew: false,
      );
      final off61Alerts = computeDomainAlerts(domain: autoRenewOff61);
      expect(off61Alerts.isEmpty, isTrue);
    });
  });
}

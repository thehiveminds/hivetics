import 'package:flutter_test/flutter_test.dart';
import 'package:hivehub/models/credential.dart';
import 'package:hivehub/models/registered_domain.dart';
import 'package:hivehub/models/registrar_id.dart';
import 'package:hivehub/providers/provider_registry.dart';
import 'package:hivehub/providers/registrar/dynadot_provider.dart';
import 'package:hivehub/providers/registrar/gandi_provider.dart';
import 'package:hivehub/providers/registrar/namecom_provider.dart';
import 'package:hivehub/providers/registrar/namesilo_provider.dart';
import 'package:hivehub/providers/registrar/registrar_status_normalizer.dart';
import 'package:hivehub/providers/registrar/spaceship_provider.dart';

void main() {
  group('Registrar Status Normalizers & Date Parsing', () {
    test('normalizeSpaceshipStatus maps correctly', () {
      expect(normalizeSpaceshipStatus('active'), DomainStatus.active);
      expect(normalizeSpaceshipStatus('OK'), DomainStatus.active);
      expect(normalizeSpaceshipStatus('expired'), DomainStatus.expired);
      expect(normalizeSpaceshipStatus('cancelled'), DomainStatus.cancelled);
      expect(normalizeSpaceshipStatus('deleted'), DomainStatus.cancelled);
      expect(normalizeSpaceshipStatus('suspended'), DomainStatus.suspended);
      expect(normalizeSpaceshipStatus('clientHold'), DomainStatus.suspended);
      expect(normalizeSpaceshipStatus('pending'), DomainStatus.pending);
      expect(normalizeSpaceshipStatus(''), DomainStatus.unknown);
      expect(normalizeSpaceshipStatus(null), DomainStatus.unknown);
    });

    test('normalizeNamecomStatus maps correctly', () {
      expect(normalizeNamecomStatus('active'), DomainStatus.active);
      expect(normalizeNamecomStatus('registered'), DomainStatus.active);
      expect(normalizeNamecomStatus('expired'), DomainStatus.expired);
      expect(normalizeNamecomStatus('cancelled'), DomainStatus.cancelled);
      expect(normalizeNamecomStatus('deleted'), DomainStatus.cancelled);
      expect(normalizeNamecomStatus('locked'), DomainStatus.suspended);
      expect(normalizeNamecomStatus('pending_transfer'), DomainStatus.pending);
      expect(normalizeNamecomStatus(null), DomainStatus.unknown);
    });

    test('normalizeGandiStatus maps correctly', () {
      expect(normalizeGandiStatus(['clientTransferProhibited', 'ok']), DomainStatus.active);
      expect(normalizeGandiStatus(['clientHold']), DomainStatus.suspended);
      expect(normalizeGandiStatus(['serverHold']), DomainStatus.suspended);
      expect(normalizeGandiStatus(['pendingTransfer']), DomainStatus.pending);
      expect(normalizeGandiStatus(['expired']), DomainStatus.expired);
      expect(normalizeGandiStatus('active'), DomainStatus.active);
      expect(normalizeGandiStatus(null), DomainStatus.unknown);
    });

    test('normalizeNameSiloStatus maps correctly', () {
      expect(normalizeNameSiloStatus('Active'), DomainStatus.active);
      expect(normalizeNameSiloStatus('Expired'), DomainStatus.expired);
      expect(normalizeNameSiloStatus('Cancelled'), DomainStatus.cancelled);
      expect(normalizeNameSiloStatus('Quarantine'), DomainStatus.suspended);
      expect(normalizeNameSiloStatus('Pending'), DomainStatus.pending);
      expect(normalizeNameSiloStatus(null), DomainStatus.unknown);
    });

    test('normalizeDynadotStatus maps correctly', () {
      expect(normalizeDynadotStatus('active'), DomainStatus.active);
      expect(normalizeDynadotStatus('registered'), DomainStatus.active);
      expect(normalizeDynadotStatus('expired'), DomainStatus.expired);
      expect(normalizeDynadotStatus('deleted'), DomainStatus.cancelled);
      expect(normalizeDynadotStatus('locked'), DomainStatus.suspended);
      expect(normalizeDynadotStatus('hold'), DomainStatus.suspended);
      expect(normalizeDynadotStatus('pending'), DomainStatus.pending);
      expect(normalizeDynadotStatus(null), DomainStatus.unknown);
    });

    test('parseFlexibleDate handles numeric timestamps, ISO8601, and Porkbun format', () {
      final iso = parseFlexibleDate('2026-10-15T12:00:00Z');
      expect(iso, DateTime.utc(2026, 10, 15, 12, 0, 0));

      final porkbun = parseFlexibleDate('2026-10-15 12:00:00');
      expect(porkbun, DateTime.utc(2026, 10, 15, 12, 0, 0));

      // Seconds timestamp
      final seconds = parseFlexibleDate(1792065600);
      expect(seconds, isNotNull);

      // Milliseconds timestamp
      final millis = parseFlexibleDate(1792065600000);
      expect(millis, isNotNull);

      expect(parseFlexibleDate(null), isNull);
      expect(parseFlexibleDate(''), isNull);
    });
  });

  group('Registrar Providers Registry & Instances', () {
    test('all 8 registrars are registered in provider registry', () {
      expect(allRegistrarProviders.length, 8);

      expect(registrarProviderFor(RegistrarId.godaddy).displayName, 'GoDaddy');
      expect(registrarProviderFor(RegistrarId.porkbun).displayName, 'Porkbun');
      expect(registrarProviderFor(RegistrarId.cloudflareregistrar).displayName, 'Cloudflare Registrar');
      expect(registrarProviderFor(RegistrarId.spaceship).displayName, 'Spaceship');
      expect(registrarProviderFor(RegistrarId.namecom).displayName, 'Name.com');
      expect(registrarProviderFor(RegistrarId.namesilo).displayName, 'NameSilo');
      expect(registrarProviderFor(RegistrarId.gandi).displayName, 'Gandi');
      expect(registrarProviderFor(RegistrarId.dynadot).displayName, 'Dynadot');
    });

    test('SpaceshipProvider has correct id and displayName', () {
      final p = SpaceshipProvider();
      expect(p.id, RegistrarId.spaceship);
      expect(p.displayName, 'Spaceship');
    });

    test('NameComProvider has correct id and displayName', () {
      final p = NameComProvider();
      expect(p.id, RegistrarId.namecom);
      expect(p.displayName, 'Name.com');
    });

    test('GandiProvider has correct id and displayName', () {
      final p = GandiProvider();
      expect(p.id, RegistrarId.gandi);
      expect(p.displayName, 'Gandi');
    });

    test('NameSiloProvider has correct id and displayName', () {
      final p = NameSiloProvider();
      expect(p.id, RegistrarId.namesilo);
      expect(p.displayName, 'NameSilo');
    });

    test('DynadotProvider has correct id and displayName', () {
      final p = DynadotProvider();
      expect(p.id, RegistrarId.dynadot);
      expect(p.displayName, 'Dynadot');
    });
  });
}

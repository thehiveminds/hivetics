import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hivehub/features/domains/domains_screen.dart';
import 'package:hivehub/models/connection.dart';
import 'package:hivehub/models/registered_domain.dart';
import 'package:hivehub/models/registrar_id.dart';
import 'package:hivehub/models/service_ref.dart';
import 'package:hivehub/shared/theme.dart';
import 'package:hivehub/state/domains_notifier.dart';

class _FakeDomainsNotifier extends AsyncNotifier<DomainsState>
    implements DomainsNotifier {
  _FakeDomainsNotifier(this._state);
  final DomainsState _state;

  @override
  Future<DomainsState> build() async => _state;

  @override
  Future<void> refresh() async {}
}

void main() {
  const godaddyConn = Connection(
    id: 'conn-godaddy',
    service: RegistrarRef(RegistrarId.godaddy),
    displayName: 'My GoDaddy',
  );

  const porkbunConn = Connection(
    id: 'conn-porkbun',
    service: RegistrarRef(RegistrarId.porkbun),
    displayName: 'My Porkbun',
  );

  final activeDomain = RegisteredDomain(
    domain: 'active-domain.com',
    connectionId: 'conn-godaddy',
    registrar: RegistrarId.godaddy,
    status: DomainStatus.active,
    expiresAt: DateTime.now().toUtc().add(const Duration(days: 120)),
    autoRenew: true,
    fetchedAt: DateTime.now().toUtc(),
  );

  final expiringDomain = RegisteredDomain(
    domain: 'expiring-soon.org',
    connectionId: 'conn-godaddy',
    registrar: RegistrarId.godaddy,
    status: DomainStatus.expiring,
    expiresAt: DateTime.now().toUtc().add(const Duration(days: 12)),
    autoRenew: false,
    fetchedAt: DateTime.now().toUtc(),
  );

  Widget createSubject(DomainsState state) {
    return ProviderScope(
      overrides: [
        domainsProvider.overrideWith(() => _FakeDomainsNotifier(state)),
      ],
      child: MaterialApp(
        theme: HHTheme.dark().withHHExtension(),
        home: const DomainsScreen(),
      ),
    );
  }

  group('DomainsScreen', () {
    testWidgets('renders domain list with cards and alerts',
        (tester) async {
      final state = DomainsState(
        results: [
          ConnectionDomainsResult(
            connection: godaddyConn,
            domains: [activeDomain, expiringDomain],
          ),
        ],
      );

      await tester.pumpWidget(createSubject(state));
      await tester.pumpAndSettle();

      // Verified screen elements
      expect(find.text('Domains'), findsWidgets);
      expect(find.text('expiring-soon.org'), findsWidgets);
      expect(find.text('active-domain.com'), findsOneWidget);
      expect(find.text('Expires in 12 days'), findsWidgets);
      expect(find.text('Auto-renew off'), findsOneWidget);
    });

    testWidgets('chips filter domains list', (tester) async {
      final state = DomainsState(
        results: [
          ConnectionDomainsResult(
            connection: godaddyConn,
            domains: [activeDomain, expiringDomain],
          ),
        ],
      );

      await tester.pumpWidget(createSubject(state));
      await tester.pumpAndSettle();

      // Tap 'Needs attention' chip
      await tester.tap(find.text('Needs attention'));
      await tester.pumpAndSettle();

      // active-domain.com is not expiring soon so it should be filtered out
      expect(find.text('active-domain.com'), findsNothing);
      expect(find.text('expiring-soon.org'), findsOneWidget);
    });

    testWidgets('displays Porkbun specific copy when no domains found',
        (tester) async {
      const state = DomainsState(
        results: [
          ConnectionDomainsResult(
            connection: porkbunConn,
            domains: [],
          ),
        ],
      );

      await tester.pumpWidget(createSubject(state));
      await tester.pumpAndSettle();

      expect(find.text('No domains found'), findsOneWidget);
      expect(
        find.textContaining('Porkbun requires API access to be enabled per domain'),
        findsOneWidget,
      );
    });
  });
}

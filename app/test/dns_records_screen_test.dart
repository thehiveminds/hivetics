// MIT Licence — TheHiveMinds / Hivetics
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hivehub/features/dns/dns_records_screen.dart';
import 'package:hivehub/models/dns_record.dart';
import 'package:hivehub/models/registrar_id.dart';
import 'package:hivehub/shared/theme.dart';
import 'package:hivehub/state/domains_notifier.dart';

void main() {
  const records = [
    DnsRecord(
      id: 'rec-1',
      domain: 'thehiveminds.in',
      type: 'A',
      name: '@',
      content: '76.76.21.21',
      ttl: 1, // Auto
      proxied: false,
    ),
    DnsRecord(
      id: 'rec-2',
      domain: 'thehiveminds.in',
      type: 'CNAME',
      name: 'www',
      content: 'cname.vercel-dns.com',
      ttl: 3600,
      proxied: true,
    ),
    DnsRecord(
      id: 'rec-3',
      domain: 'thehiveminds.in',
      type: 'TXT',
      name: '@',
      content: 'v=spf1 include:_spf.google.com ~all',
      ttl: 300,
      proxied: false,
    ),
  ];

  Widget createSubject() {
    return ProviderScope(
      overrides: [
        dnsRecordsProvider((
          connectionId: 'conn-1',
          domain: 'thehiveminds.in',
          registrar: RegistrarId.godaddy,
        )).overrideWith((ref) async => records),
      ],
      child: MaterialApp(
        theme: HHTheme.dark().withHHExtension(),
        home: const DnsRecordsScreen(
          connectionId: 'conn-1',
          domain: 'thehiveminds.in',
          registrar: RegistrarId.godaddy,
        ),
      ),
    );
  }

  group('DnsRecordsScreen', () {
    testWidgets('renders records and displays Auto for ttl==1', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('thehiveminds.in'), findsOneWidget);
      expect(find.text('76.76.21.21'), findsOneWidget);
      expect(find.text('cname.vercel-dns.com'), findsOneWidget);

      // Auto TTL verification (ttl=1 rendered as 'Auto')
      expect(find.text('Auto'), findsWidgets);
      expect(find.text('3600s'), findsOneWidget);
    });

    testWidgets('filters by record type chip', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Tap 'CNAME' chip
      await tester.tap(find.text('CNAME').first);
      await tester.pumpAndSettle();

      expect(find.text('cname.vercel-dns.com'), findsOneWidget);
      expect(find.text('76.76.21.21'), findsNothing);
      expect(find.text('v=spf1 include:_spf.google.com ~all'), findsNothing);
    });

    testWidgets('tap record opens bottom sheet with details', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Tap first row
      await tester.tap(find.text('76.76.21.21'));
      await tester.pumpAndSettle();

      expect(find.text('CONTENT'), findsOneWidget);
      expect(find.text('TTL'), findsOneWidget);
    });
  });
}

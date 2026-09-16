// MIT Licence — TheHiveMinds / Hivetics
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:hivehub/features/connect/add_connection_sheet.dart';
import 'package:hivehub/shared/theme.dart';

void main() {
  Widget createSubject() {
    return ProviderScope(
      child: MaterialApp(
        theme: HHTheme.dark().withHHExtension(),
        home: const Scaffold(
          body: AddConnectionSheet(),
        ),
      ),
    );
  }

  group('AddConnectionSheet (§5.5)', () {
    testWidgets('shows Category picker first (Hosting vs Registrar)', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Add Connection'), findsOneWidget);
      expect(find.text('Hosting Platform'), findsOneWidget);
      expect(find.text('Domain Registrar'), findsOneWidget);
    });

    testWidgets('navigates to Registrar provider picker and shows Porkbun two-field entry',
        (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Tap 'Domain Registrar'
      await tester.tap(find.text('Domain Registrar'));
      await tester.pumpAndSettle();

      expect(find.text('Domain Registrar'), findsOneWidget);
      expect(find.text('GoDaddy'), findsOneWidget);
      expect(find.text('Porkbun'), findsOneWidget);
      expect(find.text('Cloudflare Registrar'), findsWidgets);

      // Tap 'Porkbun'
      await tester.tap(find.text('Porkbun'));
      await tester.pumpAndSettle();

      // Porkbun requires 2 fields: API Key & Secret API Key
      expect(find.text('API KEY'), findsOneWidget);
      expect(find.text('SECRET API KEY'), findsOneWidget);
      expect(find.text('Enter API Key (pk1_...)'), findsOneWidget);
      expect(find.text('Enter Secret API Key (sk1_...)'), findsOneWidget);
    });

    testWidgets('shows single token field for GoDaddy and back button works',
        (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Pick Registrar -> GoDaddy
      await tester.tap(find.text('Domain Registrar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('GoDaddy'));
      await tester.pumpAndSettle();

      // Single token field for GoDaddy
      expect(find.text('Paste your GoDaddy token'), findsOneWidget);
      expect(find.text('SECRET API KEY'), findsNothing);

      // Tap back button
      await tester.tap(find.byIcon(LucideIcons.arrowLeft).first);
      await tester.pumpAndSettle();

      expect(find.text('GoDaddy'), findsOneWidget);
      expect(find.text('Porkbun'), findsOneWidget);
    });
  });
}

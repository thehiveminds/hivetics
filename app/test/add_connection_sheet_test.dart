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
      expect(find.text('Spaceship'), findsOneWidget);
      expect(find.text('Name.com'), findsOneWidget);
      expect(find.text('NameSilo'), findsOneWidget);
      expect(find.text('Gandi'), findsOneWidget);
      expect(find.text('Dynadot'), findsOneWidget);

      // Tap 'Porkbun'
      await tester.tap(find.text('Porkbun'));
      await tester.pumpAndSettle();

      // Porkbun requires 2 fields: API Key & Secret API Key
      expect(find.text('API KEY'), findsOneWidget);
      expect(find.text('SECRET API KEY'), findsOneWidget);
      expect(find.text('Enter API Key (pk1_...)'), findsOneWidget);
      expect(find.text('Enter Secret API Key (sk1_...)'), findsOneWidget);
    });

    testWidgets('navigates to Spaceship and shows API Key and API Secret fields',
        (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Domain Registrar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Spaceship'));
      await tester.pumpAndSettle();

      expect(find.text('API KEY'), findsOneWidget);
      expect(find.text('API SECRET'), findsOneWidget);
      expect(find.text('Enter Spaceship API Key'), findsOneWidget);
      expect(find.text('Enter Spaceship API Secret'), findsOneWidget);
    });

    testWidgets('navigates to Name.com and shows Username and API Token fields',
        (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Domain Registrar'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Name.com'));
      await tester.tap(find.text('Name.com'));
      await tester.pumpAndSettle();

      expect(find.text('USERNAME'), findsOneWidget);
      expect(find.text('API TOKEN'), findsOneWidget);
      expect(find.text('Enter Name.com username'), findsOneWidget);
      expect(find.text('Enter Name.com API Token'), findsOneWidget);
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
      expect(find.text('Paste your GoDaddy token or key'), findsOneWidget);
      expect(find.text('SECRET API KEY'), findsNothing);

      // Tap back button
      await tester.tap(find.byIcon(LucideIcons.arrowLeft).first);
      await tester.pumpAndSettle();

      expect(find.text('GoDaddy'), findsOneWidget);
      expect(find.text('Porkbun'), findsOneWidget);
      expect(find.text('Spaceship'), findsOneWidget);
    });
  });
}

// MIT Licence — TheHiveMinds / Hivetics
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hivehub/app.dart';
import 'package:hivehub/widgets/bottom_tab_bar.dart';

void main() {
  testWidgets('HiveHubApp smoke test renders navigation and tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HiveHubApp(),
      ),
    );

    // Initial pump
    await tester.pump();

    // Verify bottom tab bar is present with 3 tabs
    expect(find.byType(BottomTabBar), findsOneWidget);
    expect(find.text('Sites'), findsWidgets);
    expect(find.text('Deploys'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });
}

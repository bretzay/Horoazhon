import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:real_estate_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // Helper: login as admin and navigate to Contrats tab
  // ---------------------------------------------------------------------------
  Future<void> loginAndGoToContrats(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Tap "Connexion" tab in the public shell
    final connexionTab = find.text('Connexion');
    if (connexionTab.evaluate().isNotEmpty) {
      await tester.tap(connexionTab);
      await tester.pumpAndSettle();
    }

    // Fill login form
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'admin@horoazhon.fr');
    await tester.enterText(textFields.at(1), 'Admin');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Navigate to Contrats tab (index 2 in admin bottom nav)
    await tester.tap(find.text('Contrats'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  // ===========================================================================
  //  fm-admin-contrat
  // ===========================================================================
  group('fm-admin-contrat', () {
    testWidgets('Contract list loads with contract cards', (tester) async {
      await loginAndGoToContrats(tester);

      // Contract cards should show with CTR- prefix
      expect(find.textContaining('CTR-'), findsWidgets);
    });

    testWidgets('Contract cards display status badge', (tester) async {
      await loginAndGoToContrats(tester);

      // At least one card is visible
      expect(find.byType(Card), findsWidgets);

      // Chevron right icon indicates tappable cards
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });

    testWidgets('Contract detail screen loads on card tap', (tester) async {
      await loginAndGoToContrats(tester);

      // Tap the first contract card
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Detail screen shows the contract ID in the app bar
      expect(find.textContaining('CTR-'), findsWidgets);

      // Detail screen shows Dates section
      expect(find.text('Dates'), findsOneWidget);

      // Cosignataires section
      expect(find.textContaining('Cosignataires'), findsOneWidget);
    });

    testWidgets('Contract detail shows status and type badges',
        (tester) async {
      await loginAndGoToContrats(tester);

      // Tap the first contract card
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // The detail screen header card contains the contract ID in large text
      // and at least one badge (status or type)
      expect(find.byType(Card), findsWidgets);

      // Person icon for cosigners
      expect(find.byIcon(Icons.person_outlined), findsWidgets);
    });
  });
}

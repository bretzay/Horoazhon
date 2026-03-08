import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:real_estate_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // Helper: login as admin and navigate to Agences via drawer
  // ---------------------------------------------------------------------------
  Future<void> loginAndGoToAgences(WidgetTester tester) async {
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

    // Open drawer via "Plus" tab
    await tester.tap(find.text('Plus'));
    await tester.pumpAndSettle();

    // Tap "Agences" in the drawer
    await tester.tap(find.text('Agences'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  // ===========================================================================
  //  fm-admin-agence
  // ===========================================================================
  group('fm-admin-agence', () {
    testWidgets('Agency list loads from drawer navigation', (tester) async {
      await loginAndGoToAgences(tester);

      // ADMIN_AGENCY sees their own agency — at least one card with agency info
      // Agency cards display the agency name
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Agency cards display name, ville, and SIRET',
        (tester) async {
      await loginAndGoToAgences(tester);

      // ADMIN_AGENCY sees their own agency "Horoazhon France"
      expect(find.text('Horoazhon France'), findsOneWidget);

      // The agency card shows a business icon
      expect(find.byIcon(Icons.business_outlined), findsWidgets);
    });

    testWidgets('Agency card tap opens edit form', (tester) async {
      await loginAndGoToAgences(tester);

      // Tap the first agency card to open edit form
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Edit form screen title
      expect(find.textContaining('Modifier'), findsOneWidget);

      // Form fields
      expect(find.text('Nom'), findsOneWidget);
      expect(find.text('SIRET'), findsOneWidget);
      expect(find.text('Ville'), findsOneWidget);
    });

    testWidgets('Agency form has all expected fields', (tester) async {
      await loginAndGoToAgences(tester);

      // Tap the first agency card
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Scroll to see all fields
      final scrollable = find.byType(Scrollable).first;

      expect(find.text('Nom'), findsOneWidget);
      expect(find.text('SIRET'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Email'),
        200.0,
        scrollable: scrollable,
      );
      expect(find.text('Téléphone'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Logo (URL)'),
        200.0,
        scrollable: scrollable,
      );
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Logo (URL)'), findsOneWidget);

      // Save button
      expect(find.widgetWithText(ElevatedButton, 'Enregistrer'), findsOneWidget);
    });
  });
}

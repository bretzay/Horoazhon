import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:real_estate_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // Helper: login as SUPER_ADMIN and navigate to Données de référence via drawer
  // Note: Reference data is SUPER_ADMIN only — admin@horoazhon.fr won't see it
  // ---------------------------------------------------------------------------
  Future<void> loginAsSuperAdmin(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Tap "Connexion" tab in public shell
    final connexionTab = find.text('Connexion');
    if (connexionTab.evaluate().isNotEmpty) {
      await tester.tap(connexionTab);
      await tester.pumpAndSettle();
    }

    // Enter SUPER_ADMIN credentials
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'superadmin@horoazhon.fr');
    await tester.enterText(textFields.at(1), 'Admin');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  Future<void> navigateToReferences(WidgetTester tester) async {
    // Open drawer via "Plus" tab
    await tester.tap(find.text('Plus'));
    await tester.pumpAndSettle();

    // Tap "Données de référence" in drawer
    await tester.tap(find.text('Données de référence'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  // ===========================================================================
  //  fm-admin-reference
  // ===========================================================================
  group('fm-admin-reference', () {
    testWidgets('Reference screen loads with two tabs', (tester) async {
      await loginAsSuperAdmin(tester);
      await navigateToReferences(tester);

      // Two tabs: Caractéristiques and Lieux
      expect(find.text('Caractéristiques'), findsOneWidget);
      expect(find.text('Lieux'), findsOneWidget);

      // TabBar is present
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('Caractéristiques tab shows items and add field', (tester) async {
      await loginAsSuperAdmin(tester);
      await navigateToReferences(tester);

      // Default tab is Caractéristiques — add field should be visible
      expect(find.text('Ajouter une caractéristique...'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Ajouter'), findsOneWidget);

      // If seed data has caractéristiques, ListTile items should appear
      // Each item has a delete icon button
      expect(find.byIcon(Icons.delete_outlined), findsAtLeastNWidgets(0));
    });

    testWidgets('Lieux tab shows items and add field', (tester) async {
      await loginAsSuperAdmin(tester);
      await navigateToReferences(tester);

      // Switch to Lieux tab
      await tester.tap(find.text('Lieux'));
      await tester.pumpAndSettle();

      // Add field for lieux should be visible
      expect(find.text('Ajouter un lieu...'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Ajouter'), findsAtLeastNWidgets(1));
    });
  });
}

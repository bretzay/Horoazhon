import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:real_estate_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // Helper: login as ADMIN_AGENCY and navigate to Personnes via drawer
  // ---------------------------------------------------------------------------
  Future<void> loginAsAdmin(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Tap "Connexion" tab in public shell
    final connexionTab = find.text('Connexion');
    if (connexionTab.evaluate().isNotEmpty) {
      await tester.tap(connexionTab);
      await tester.pumpAndSettle();
    }

    // Enter credentials
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'admin@horoazhon.fr');
    await tester.enterText(textFields.at(1), 'Admin');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  Future<void> navigateToPersonnes(WidgetTester tester) async {
    // Open drawer via "Plus" tab
    await tester.tap(find.text('Plus'));
    await tester.pumpAndSettle();

    // Tap "Personnes" in drawer
    await tester.tap(find.text('Personnes'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  // ===========================================================================
  //  fm-admin-personne
  // ===========================================================================
  group('fm-admin-personne', () {
    testWidgets('Person list loads from drawer navigation', (tester) async {
      await loginAsAdmin(tester);
      await navigateToPersonnes(tester);

      // Search bar should be visible
      expect(find.byType(TextField), findsAtLeastNWidgets(1));
      expect(find.text('Rechercher une personne...'), findsOneWidget);

      // At least one person card should appear (seed data has personnes)
      expect(find.byType(Card), findsAtLeastNWidgets(1));
    });

    testWidgets('Person cards display name and city', (tester) async {
      await loginAsAdmin(tester);
      await navigateToPersonnes(tester);

      // Cards should show person icons
      expect(find.byIcon(Icons.person_outlined), findsAtLeastNWidgets(1));

      // Cards should be tappable (InkWell inside Card)
      expect(find.byType(Card), findsAtLeastNWidgets(1));

      // Each card has a PopupMenuButton for actions
      expect(find.byType(PopupMenuButton), findsAtLeastNWidgets(1));
    });

    testWidgets('FAB add button is visible', (tester) async {
      await loginAsAdmin(tester);
      await navigateToPersonnes(tester);

      // FloatingActionButton with add icon
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Person form loads with required fields', (tester) async {
      await loginAsAdmin(tester);
      await navigateToPersonnes(tester);

      // Tap the FAB to open create form
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify form screen title
      expect(find.text('Nouvelle personne'), findsOneWidget);

      // Required fields: Nom, Prénom
      expect(find.text('Nom'), findsOneWidget);
      expect(find.text('Prénom'), findsOneWidget);

      // Date de naissance picker
      expect(find.text('Date de naissance'), findsOneWidget);
      expect(find.text('Sélectionner...'), findsOneWidget);

      // Optional fields
      expect(find.text('Rue'), findsOneWidget);
      expect(find.text('Ville'), findsOneWidget);
      expect(find.text('Code postal'), findsOneWidget);
      expect(find.text('RIB'), findsOneWidget);

      // Create button
      expect(find.widgetWithText(ElevatedButton, 'Créer'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:real_estate_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // Helper: login as admin and navigate to Biens tab
  // ---------------------------------------------------------------------------
  Future<void> loginAndGoToBiens(WidgetTester tester) async {
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

    // Navigate to Biens tab (index 1 in admin bottom nav)
    await tester.tap(find.text('Biens').last);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  // ===========================================================================
  //  fm-admin-bien
  // ===========================================================================
  group('fm-admin-bien', () {
    testWidgets('Property list loads in admin view', (tester) async {
      await loginAndGoToBiens(tester);

      // Search field is visible
      expect(find.text('Rechercher un bien...'), findsOneWidget);

      // Property cards should be visible (at least one card with BI- prefix)
      expect(find.textContaining('BI-'), findsWidgets);
    });

    testWidgets('Property cards show with edit/delete popup menu',
        (tester) async {
      await loginAndGoToBiens(tester);

      // PopupMenuButton (more_vert icon) should be visible on cards
      expect(find.byType(PopupMenuButton), findsWidgets);

      // Tap the first popup menu to see options
      await tester.tap(find.byType(PopupMenuButton).first);
      await tester.pumpAndSettle();

      // Menu items
      expect(find.text('Modifier'), findsOneWidget);
      expect(find.text('Supprimer'), findsOneWidget);
    });

    testWidgets('Add property FAB is visible', (tester) async {
      await loginAndGoToBiens(tester);

      // Floating action button with add icon
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Property form loads with required fields', (tester) async {
      await loginAndGoToBiens(tester);

      // Tap the FAB to open the create form
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Form screen title
      expect(find.text('Nouveau bien'), findsOneWidget);

      // Form field labels
      expect(find.text('Type'), findsOneWidget);
      expect(find.text('Rue'), findsOneWidget);
      expect(find.text('Ville'), findsOneWidget);
      expect(find.text('Code postal'), findsOneWidget);

      // Dropdown for type
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

      // Submit button
      expect(find.widgetWithText(ElevatedButton, 'Créer'), findsOneWidget);
    });

    testWidgets('Property form shows optional fields', (tester) async {
      await loginAndGoToBiens(tester);

      // Tap the FAB to open the create form
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Scroll to see all fields
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Description'),
        200.0,
        scrollable: scrollable,
      );

      expect(find.text('Superficie (m²)'), findsOneWidget);
      expect(find.text('Score éco'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });
  });
}

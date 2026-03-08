import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:real_estate_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();

  // ---------------------------------------------------------------------------
  // Helper: login as ADMIN_AGENCY and navigate to Utilisateurs via drawer
  // ---------------------------------------------------------------------------
  Future<void> loginAsAdmin(WidgetTester tester) async {
    await storage.deleteAll();
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

  Future<void> navigateToUtilisateurs(WidgetTester tester) async {
    // Open drawer via "Plus" tab
    await tester.tap(find.text('Plus'));
    await tester.pumpAndSettle();

    // Tap "Utilisateurs" in drawer
    await tester.tap(find.text('Utilisateurs'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  // ===========================================================================
  //  fm-admin-user
  // ===========================================================================
  group('fm-admin-user', () {
    testWidgets('User list loads from drawer navigation', (tester) async {
      await loginAsAdmin(tester);
      await navigateToUtilisateurs(tester);

      // At least one user card should appear (seed data has users)
      expect(find.byType(Card), findsAtLeastNWidgets(1));

      // User cards show person icon
      expect(find.byIcon(Icons.person_outlined), findsAtLeastNWidgets(1));
    });

    testWidgets('User cards display email and role', (tester) async {
      await loginAsAdmin(tester);
      await navigateToUtilisateurs(tester);

      // Cards should show email addresses from seed data
      // admin@horoazhon.fr and agent@horoazhon.fr are in agency 1
      expect(find.textContaining('@'), findsAtLeastNWidgets(1));

      // Role badges are Container widgets with role text
      // At least one role should be visible (ADMIN_AGENCY, AGENT, etc.)
      final roleTexts = ['SUPER_ADMIN', 'ADMIN_AGENCY', 'AGENT', 'CLIENT'];
      bool foundRole = false;
      for (final role in roleTexts) {
        if (find.text(role).evaluate().isNotEmpty) {
          foundRole = true;
          break;
        }
      }
      expect(foundRole, isTrue, reason: 'At least one role badge should be visible');
    });

    testWidgets('User cards have action menu', (tester) async {
      await loginAsAdmin(tester);
      await navigateToUtilisateurs(tester);

      // Each user card has a PopupMenuButton
      expect(find.byType(PopupMenuButton), findsAtLeastNWidgets(1));
    });

    testWidgets('User list supports pull-to-refresh', (tester) async {
      await loginAsAdmin(tester);
      await navigateToUtilisateurs(tester);

      // RefreshIndicator wraps the list
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:real_estate_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();

  // ---------------------------------------------------------------------------
  // Helper: login as admin and land on the admin dashboard
  // ---------------------------------------------------------------------------
  Future<void> loginAsAdmin(WidgetTester tester) async {
    await storage.deleteAll();
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
  }

  // ===========================================================================
  //  fm-admin-dashboard
  // ===========================================================================
  group('fm-admin-dashboard', () {
    testWidgets('Dashboard loads after admin login with welcome header',
        (tester) async {
      await loginAsAdmin(tester);

      // Admin shell should show "Tableau de bord" in bottom nav
      expect(find.text('Tableau de bord'), findsOneWidget);

      // Welcome header with user first name
      expect(find.textContaining('Bonjour'), findsOneWidget);

      // Role chip visible
      expect(find.text('Admin'), findsWidgets);
    });

    testWidgets('Stat cards are visible (Biens, Contrats, Personnes)',
        (tester) async {
      await loginAsAdmin(tester);

      // Stat card labels
      expect(find.text('Biens'), findsWidgets);
      expect(find.text('Contrats'), findsWidgets);
      expect(find.text('Personnes'), findsOneWidget);
    });

    testWidgets('Quick action buttons are visible', (tester) async {
      await loginAsAdmin(tester);

      // Quick actions section header
      expect(find.text('Actions rapides'), findsOneWidget);

      // Quick action labels
      expect(find.text('Nouveau bien'), findsOneWidget);
      expect(find.text('Nouveau contrat'), findsOneWidget);
      expect(find.text('Nouvelle personne'), findsOneWidget);
    });

    testWidgets('Recent activity sections are visible', (tester) async {
      await loginAsAdmin(tester);

      // Scroll down to see recent activity sections
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Biens récents'),
        200.0,
        scrollable: scrollable,
      );
      expect(find.text('Biens récents'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Contrats récents'),
        200.0,
        scrollable: scrollable,
      );
      expect(find.text('Contrats récents'), findsOneWidget);
    });
  });
}

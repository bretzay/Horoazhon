import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:real_estate_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();

  // ---------------------------------------------------------------------------
  // Helper: login as client
  // ---------------------------------------------------------------------------
  Future<void> loginAsClient(WidgetTester tester) async {
    await storage.deleteAll();
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Tap "Connexion" tab
    final connexionTab = find.text('Connexion');
    if (connexionTab.evaluate().isNotEmpty) {
      await tester.tap(connexionTab);
      await tester.pumpAndSettle();
    }

    // Enter client credentials
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'client@horoazhon.fr');
    await tester.enterText(textFields.at(1), 'Client');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  // ===========================================================================
  //  fm-client-dashboard: Dashboard loads and displays content
  // ===========================================================================
  group('fm-client-dashboard: Dashboard content', () {
    testWidgets('Client dashboard loads after login with welcome message',
        (tester) async {
      await loginAsClient(tester);

      // Welcome header with "Bonjour, {prenom}"
      expect(find.textContaining('Bonjour,'), findsOneWidget);
      // Subheader
      expect(find.text('Votre espace client'), findsOneWidget);
    });

    testWidgets('Client dashboard shows stat cards', (tester) async {
      await loginAsClient(tester);

      // Stat cards: Biens, Contrats, Actifs
      expect(find.text('Biens'), findsWidgets); // bottom nav + stat card
      expect(find.text('Contrats'), findsOneWidget);
      expect(find.text('Actifs'), findsOneWidget);
    });

    testWidgets('Client dashboard shows Mes biens recents section',
        (tester) async {
      await loginAsClient(tester);

      // Scroll down to find the sections
      final listView = find.byType(ListView).first;

      await tester.scrollUntilVisible(
        find.text('Mes biens récents'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Mes biens récents'), findsOneWidget);
    });

    testWidgets('Client dashboard shows Mes contrats recents section',
        (tester) async {
      await loginAsClient(tester);

      await tester.scrollUntilVisible(
        find.text('Mes contrats récents'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Mes contrats récents'), findsOneWidget);
    });

    testWidgets('Client dashboard shows empty states or data for biens',
        (tester) async {
      await loginAsClient(tester);

      // Either there are bien cards or the empty state "Aucun bien"
      await tester.scrollUntilVisible(
        find.text('Mes biens récents'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );

      // One of these should be true
      final hasBiens = find.byIcon(Icons.chevron_right).evaluate().isNotEmpty;
      final hasEmptyState = find.text('Aucun bien').evaluate().isNotEmpty;
      expect(hasBiens || hasEmptyState, isTrue);
    });

    testWidgets('Client dashboard shows empty states or data for contrats',
        (tester) async {
      await loginAsClient(tester);

      await tester.scrollUntilVisible(
        find.text('Mes contrats récents'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );

      // One of these should be true
      final hasContrats = find.textContaining('CTR-').evaluate().isNotEmpty;
      final hasEmptyState = find.text('Aucun contrat').evaluate().isNotEmpty;
      expect(hasContrats || hasEmptyState, isTrue);
    });
  });

  // ===========================================================================
  //  fm-client-dashboard: Navigation context
  // ===========================================================================
  group('fm-client-dashboard: Navigation context', () {
    testWidgets('Client sees public nav, not admin nav', (tester) async {
      await loginAsClient(tester);

      // Public nav tabs
      expect(find.text('Accueil'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      // Admin-only tabs should NOT be present
      expect(find.text('Tableau de bord'), findsNothing);
      expect(find.text('Plus'), findsNothing);
    });

    testWidgets('Client can switch to Accueil and back to dashboard',
        (tester) async {
      await loginAsClient(tester);

      // Switch to Accueil
      await tester.tap(find.text('Accueil'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should no longer see client dashboard content
      expect(find.text('Votre espace client'), findsNothing);

      // Switch back to Profil (which shows client dashboard)
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Votre espace client'), findsOneWidget);
    });
  });
}

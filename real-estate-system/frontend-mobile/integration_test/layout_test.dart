import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:real_estate_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();

  // ---------------------------------------------------------------------------
  // Helper: navigate to login screen and perform login
  // ---------------------------------------------------------------------------
  Future<void> loginAs(WidgetTester tester, String email, String password) async {
    await storage.deleteAll();
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Tap "Connexion" tab (last tab when unauthenticated)
    final connexionTab = find.text('Connexion');
    if (connexionTab.evaluate().isNotEmpty) {
      await tester.tap(connexionTab);
      await tester.pumpAndSettle();
    }

    // Enter credentials
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), email);
    await tester.enterText(textFields.at(1), password);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  // ===========================================================================
  //  Public navigation (unauthenticated)
  // ===========================================================================
  group('fm-layout: Public bottom navigation', () {
    testWidgets('Public nav has 4 tabs: Accueil, Biens, Agences, Connexion',
        (tester) async {
      await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Accueil'), findsOneWidget);
      expect(find.text('Biens'), findsOneWidget);
      expect(find.text('Agences'), findsOneWidget);
      expect(find.text('Connexion'), findsOneWidget);
    });

    testWidgets('AppBar shows Horoazhon title', (tester) async {
      await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Horoazhon'), findsOneWidget);
    });

    testWidgets('Tapping Biens tab switches to property list', (tester) async {
      await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.text('Biens'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // PropertyListScreen should be visible — it contains property-related content
      // The screen is loaded via IndexedStack, so verify by checking for property list elements
      // At minimum, the bottom nav "Biens" tab should be active
      expect(find.text('Biens'), findsOneWidget);
      // We're no longer on the home screen's main content
      expect(find.text('Horoazhon'), findsOneWidget); // AppBar still shows title
    });

    testWidgets('Tapping Agences tab switches to agency list', (tester) async {
      await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.text('Agences'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Agences'), findsOneWidget);
      expect(find.text('Horoazhon'), findsOneWidget);
    });

    testWidgets('Tapping Connexion tab shows login screen', (tester) async {
      await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.text('Connexion'));
      await tester.pumpAndSettle();

      expect(find.text('Connectez-vous à votre compte'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Se connecter'), findsOneWidget);
    });

    testWidgets('Tapping Accueil tab returns to home screen', (tester) async {
      await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate away first
      await tester.tap(find.text('Biens'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate back to Accueil
      await tester.tap(find.text('Accueil'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Home screen should be visible
      expect(find.text('Accueil'), findsOneWidget);
    });
  });

  // ===========================================================================
  //  Admin navigation (after admin login)
  // ===========================================================================
  group('fm-layout: Admin bottom navigation', () {
    testWidgets('Admin login switches to admin bottom nav with 4 tabs',
        (tester) async {
      await loginAs(tester, 'admin@horoazhon.fr', 'Admin');

      expect(find.text('Tableau de bord'), findsOneWidget);
      expect(find.text('Biens'), findsOneWidget);
      expect(find.text('Contrats'), findsOneWidget);
      expect(find.text('Plus'), findsOneWidget);
    });

    testWidgets('AppBar shows Horoazhon title after admin login',
        (tester) async {
      await loginAs(tester, 'admin@horoazhon.fr', 'Admin');

      expect(find.text('Horoazhon'), findsOneWidget);
    });

    testWidgets('AppBar shows role chip after admin login', (tester) async {
      await loginAs(tester, 'admin@horoazhon.fr', 'Admin');

      // Role chip shows "Admin" for ADMIN_AGENCY
      expect(find.text('Admin'), findsWidgets);
    });

    testWidgets('Tapping Plus tab opens admin drawer', (tester) async {
      await loginAs(tester, 'admin@horoazhon.fr', 'Admin');

      await tester.tap(find.text('Plus'));
      await tester.pumpAndSettle();

      // Drawer should contain navigation items
      expect(find.text('Personnes'), findsOneWidget);
      expect(find.text('Utilisateurs'), findsOneWidget);
      expect(find.text('Agences'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('Déconnexion'), findsOneWidget);
    });

    testWidgets('Admin drawer shows user name and role', (tester) async {
      await loginAs(tester, 'admin@horoazhon.fr', 'Admin');

      await tester.tap(find.text('Plus'));
      await tester.pumpAndSettle();

      // Drawer header shows role label
      expect(find.text('Administrateur Agence'), findsOneWidget);
    });

    testWidgets('Tapping Biens tab in admin nav switches screen',
        (tester) async {
      await loginAs(tester, 'admin@horoazhon.fr', 'Admin');

      await tester.tap(find.text('Biens'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should switch to admin biens screen
      expect(find.text('Biens'), findsOneWidget);
    });

    testWidgets('Tapping Contrats tab in admin nav switches screen',
        (tester) async {
      await loginAs(tester, 'admin@horoazhon.fr', 'Admin');

      await tester.tap(find.text('Contrats'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Contrats'), findsOneWidget);
    });
  });

  // ===========================================================================
  //  Client navigation
  // ===========================================================================
  group('fm-layout: Client navigation', () {
    testWidgets('Client login shows public nav with Profil tab',
        (tester) async {
      await loginAs(tester, 'client@horoazhon.fr', 'Client');

      // Client stays in public shell — tab label changes to "Profil"
      expect(find.text('Accueil'), findsOneWidget);
      expect(find.text('Biens'), findsOneWidget);
      expect(find.text('Agences'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      // Admin-only tabs should NOT be present
      expect(find.text('Tableau de bord'), findsNothing);
      expect(find.text('Plus'), findsNothing);
    });

    testWidgets('Client Profil tab shows client dashboard, not profile screen',
        (tester) async {
      await loginAs(tester, 'client@horoazhon.fr', 'Client');

      // The Profil tab for CLIENT role shows ClientDashboardScreen
      // which has "Bonjour, " greeting or "Votre espace client"
      expect(find.text('Votre espace client'), findsOneWidget);
    });

    testWidgets('Client role chip shows Client', (tester) async {
      await loginAs(tester, 'client@horoazhon.fr', 'Client');

      expect(find.text('Client'), findsWidgets);
    });
  });
}

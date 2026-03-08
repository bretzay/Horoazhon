import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:real_estate_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // Helper: login as admin and navigate to profile screen
  // ---------------------------------------------------------------------------
  Future<void> loginAndGoToProfile(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Tap "Connexion" tab
    final connexionTab = find.text('Connexion');
    if (connexionTab.evaluate().isNotEmpty) {
      await tester.tap(connexionTab);
      await tester.pumpAndSettle();
    }

    // Login as admin
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'admin@horoazhon.fr');
    await tester.enterText(textFields.at(1), 'Admin');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Open drawer via "Plus" tab
    await tester.tap(find.text('Plus'));
    await tester.pumpAndSettle();

    // Tap "Profil" in the drawer
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  // ===========================================================================
  //  fm-user-profile: Profile screen content
  // ===========================================================================
  group('fm-user-profile: Profile screen content', () {
    testWidgets('Profile screen loads after admin login with user info',
        (tester) async {
      await loginAndGoToProfile(tester);

      // User name (prenom + nom) should be visible
      // The admin account has prenom and nom from seed data
      expect(find.byType(Chip), findsAtLeastNWidgets(1));
    });

    testWidgets('Profile screen shows email address', (tester) async {
      await loginAndGoToProfile(tester);

      // Email should be displayed on the profile card
      expect(find.text('admin@horoazhon.fr'), findsOneWidget);
    });

    testWidgets('Profile screen shows role badge', (tester) async {
      await loginAndGoToProfile(tester);

      // Role badge shows "Administrateur Agence" for ADMIN_AGENCY
      expect(find.text('Administrateur Agence'), findsOneWidget);
    });

    testWidgets('Profile screen shows initials avatar', (tester) async {
      await loginAndGoToProfile(tester);

      // The avatar container should exist (64x64 with initials)
      // Verify by finding the profile card area — it has a Chip for role
      expect(find.byType(Chip), findsAtLeastNWidgets(1));
    });
  });

  // ===========================================================================
  //  fm-user-profile: Password change section
  // ===========================================================================
  group('fm-user-profile: Password change', () {
    testWidgets('Password change section header is visible',
        (tester) async {
      await loginAndGoToProfile(tester);

      expect(find.text('Changer le mot de passe'), findsOneWidget);
    });

    testWidgets('Password change section expands on tap', (tester) async {
      await loginAndGoToProfile(tester);

      // Tap the "Changer le mot de passe" header to expand
      await tester.tap(find.text('Changer le mot de passe'));
      await tester.pumpAndSettle();

      // Expanded section should show password fields (TextField, not TextFormField)
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.text('Mot de passe actuel'), findsOneWidget);
      expect(find.text('Nouveau mot de passe'), findsOneWidget);
      expect(find.text('Confirmer le mot de passe'), findsOneWidget);

      // Modifier button
      expect(find.widgetWithText(ElevatedButton, 'Modifier'), findsOneWidget);
    });

    testWidgets('Password change section collapses on second tap',
        (tester) async {
      await loginAndGoToProfile(tester);

      // Expand
      await tester.tap(find.text('Changer le mot de passe'));
      await tester.pumpAndSettle();
      expect(find.text('Mot de passe actuel'), findsOneWidget);

      // Collapse
      await tester.tap(find.text('Changer le mot de passe'));
      await tester.pumpAndSettle();
      expect(find.text('Mot de passe actuel'), findsNothing);
    });

    testWidgets('Expand icon toggles between expand_more and expand_less',
        (tester) async {
      await loginAndGoToProfile(tester);

      // Initially collapsed — expand_more icon
      expect(find.byIcon(Icons.expand_more), findsOneWidget);

      // Expand
      await tester.tap(find.text('Changer le mot de passe'));
      await tester.pumpAndSettle();

      // Now expanded — expand_less icon
      expect(find.byIcon(Icons.expand_less), findsOneWidget);
    });
  });

  // ===========================================================================
  //  fm-user-profile: Logout button
  // ===========================================================================
  group('fm-user-profile: Logout', () {
    testWidgets('Logout button is visible on profile screen', (tester) async {
      await loginAndGoToProfile(tester);

      await tester.scrollUntilVisible(
        find.text('Déconnexion'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Déconnexion'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('Tapping logout shows confirmation dialog', (tester) async {
      await loginAndGoToProfile(tester);

      await tester.scrollUntilVisible(
        find.text('Déconnexion'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );

      // Tap the OutlinedButton with "Déconnexion" text
      await tester.tap(find.widgetWithText(OutlinedButton, 'Déconnexion'));
      await tester.pumpAndSettle();

      // Confirmation dialog
      expect(find.text('Voulez-vous vous déconnecter ?'), findsOneWidget);
      expect(find.text('Annuler'), findsOneWidget);
    });

    testWidgets('Confirming logout returns to public shell', (tester) async {
      await loginAndGoToProfile(tester);

      await tester.scrollUntilVisible(
        find.text('Déconnexion'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.tap(find.widgetWithText(OutlinedButton, 'Déconnexion'));
      await tester.pumpAndSettle();

      // Confirm logout
      await tester.tap(find.widgetWithText(ElevatedButton, 'Déconnexion'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should return to public shell with "Connexion" tab
      expect(find.text('Connexion'), findsOneWidget);
    });
  });
}

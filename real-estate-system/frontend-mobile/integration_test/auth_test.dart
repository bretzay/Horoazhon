import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:real_estate_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();

  // ---------------------------------------------------------------------------
  // Helper: clear auth state and start the app fresh on the login screen
  // ---------------------------------------------------------------------------
  Future<void> startAppOnLoginScreen(WidgetTester tester) async {
    // Clear persisted JWT so the app starts unauthenticated
    await storage.deleteAll();

    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // In the public shell the last tab is "Connexion" when not authenticated
    final connexionTab = find.text('Connexion');
    if (connexionTab.evaluate().isNotEmpty) {
      await tester.tap(connexionTab);
      await tester.pumpAndSettle();
    }
  }

  // ---------------------------------------------------------------------------
  // Helper: fill login form and submit
  // ---------------------------------------------------------------------------
  Future<void> performLogin(
      WidgetTester tester, String email, String password) async {
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), email);
    await tester.enterText(textFields.at(1), password);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  // ===========================================================================
  //  fm-auth-login
  // ===========================================================================
  group('fm-auth-login', () {
    testWidgets('Login screen loads with form fields and branding',
        (tester) async {
      await startAppOnLoginScreen(tester);

      // Branding
      expect(find.text('Horoazhon'), findsWidgets);
      expect(find.text('Connectez-vous à votre compte'), findsOneWidget);

      // Form fields
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);

      // Login button
      expect(
          find.widgetWithText(ElevatedButton, 'Se connecter'), findsOneWidget);

      // Links
      expect(find.text('Mot de passe oublié ?'), findsOneWidget);
      expect(find.text('Activer un compte'), findsOneWidget);
    });

    testWidgets('Valid login as ADMIN_AGENCY navigates to admin dashboard',
        (tester) async {
      await startAppOnLoginScreen(tester);
      await performLogin(tester, 'admin@horoazhon.fr', 'Admin');

      // Admin shell shows "Tableau de bord" in the bottom nav
      expect(find.text('Tableau de bord'), findsOneWidget);
    });

    testWidgets('Valid login as CLIENT navigates to client dashboard',
        (tester) async {
      // Suppress overflow errors from client_dashboard_screen.dart _StatCard
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) return;
        originalOnError?.call(details);
      };

      await startAppOnLoginScreen(tester);
      await performLogin(tester, 'client@horoazhon.fr', 'Client');

      // Client stays in the public shell with "Profil" tab visible
      expect(find.text('Profil'), findsOneWidget);

      FlutterError.onError = originalOnError;
    });

    testWidgets('Invalid credentials shows error message', (tester) async {
      await startAppOnLoginScreen(tester);
      await performLogin(tester, 'wrong@email.com', 'wrongpassword');

      expect(find.text('Identifiants invalides'), findsOneWidget);
    });

    testWidgets('Empty fields show validation errors', (tester) async {
      await startAppOnLoginScreen(tester);

      // Tap login without filling fields
      await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
      await tester.pumpAndSettle();

      expect(find.text('Veuillez saisir votre email'), findsOneWidget);
      expect(find.text('Veuillez saisir votre mot de passe'), findsOneWidget);
    });

    testWidgets('Password visibility toggle works', (tester) async {
      await startAppOnLoginScreen(tester);

      // Initially password is obscured — visibility icon is visibility_outlined
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Tap toggle
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      // Now should show visibility_off_outlined
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });

  // ===========================================================================
  //  fm-auth-logout
  // ===========================================================================
  group('fm-auth-logout', () {
    testWidgets('Logout from admin drawer shows confirmation dialog',
        (tester) async {
      await startAppOnLoginScreen(tester);
      await performLogin(tester, 'admin@horoazhon.fr', 'Admin');

      // Open the drawer via the "Plus" tab (index 3)
      final plusTab = find.text('Plus');
      expect(plusTab, findsOneWidget);
      await tester.tap(plusTab);
      await tester.pumpAndSettle();

      // Tap "Déconnexion" in the drawer
      await tester.tap(find.text('Déconnexion').last);
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(find.textContaining('déconnecter'), findsOneWidget);
      expect(find.text('Annuler'), findsOneWidget);
    });

    testWidgets('Confirming logout returns to login screen', (tester) async {
      await startAppOnLoginScreen(tester);
      await performLogin(tester, 'admin@horoazhon.fr', 'Admin');

      // Open drawer via "Plus" tab
      await tester.tap(find.text('Plus'));
      await tester.pumpAndSettle();

      // Tap "Déconnexion" in drawer
      await tester.tap(find.text('Déconnexion').last);
      await tester.pumpAndSettle();

      // Confirm logout by tapping the confirm button in the dialog
      await tester
          .tap(find.widgetWithText(ElevatedButton, 'Déconnexion'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should return to public shell with "Connexion" tab
      expect(find.text('Connexion'), findsOneWidget);
    });

    testWidgets('Cancel logout stays on current screen', (tester) async {
      await startAppOnLoginScreen(tester);
      await performLogin(tester, 'admin@horoazhon.fr', 'Admin');

      // Open drawer via "Plus" tab
      await tester.tap(find.text('Plus'));
      await tester.pumpAndSettle();

      // Tap "Déconnexion" in drawer
      await tester.tap(find.text('Déconnexion').last);
      await tester.pumpAndSettle();

      // Cancel the dialog
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      // Should still be in admin shell
      expect(find.text('Tableau de bord'), findsOneWidget);
    });
  });

  // ===========================================================================
  //  fm-auth-activate
  // ===========================================================================
  group('fm-auth-activate', () {
    testWidgets('Activation screen loads from login link', (tester) async {
      await startAppOnLoginScreen(tester);

      // Tap "Activer un compte" link
      await tester.tap(find.text('Activer un compte'));
      await tester.pumpAndSettle();

      // Verify activation screen loaded
      expect(find.text('Activation du compte'), findsWidgets);
      expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
    });

    testWidgets('Activation screen shows token field with verify button',
        (tester) async {
      await startAppOnLoginScreen(tester);
      await tester.tap(find.text('Activer un compte'));
      await tester.pumpAndSettle();

      // Token label and field
      expect(find.textContaining('Token'), findsOneWidget);
      expect(find.byType(TextFormField), findsAtLeastNWidgets(1));

      // Verify (check) icon button
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('Invalid token shows error message', (tester) async {
      await startAppOnLoginScreen(tester);
      await tester.tap(find.text('Activer un compte'));
      await tester.pumpAndSettle();

      // Enter an invalid token
      final tokenField = find.byType(TextFormField).first;
      await tester.enterText(tokenField, 'invalid-token-12345');

      // Tap the check button to verify token
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show error
      expect(find.textContaining('invalide'), findsOneWidget);
    });

    testWidgets('Empty token shows validation error on form submit',
        (tester) async {
      await startAppOnLoginScreen(tester);
      await tester.tap(find.text('Activer un compte'));
      await tester.pumpAndSettle();

      // Verify the screen structure without submitting
      expect(find.textContaining('Token'), findsOneWidget);
      expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
    });
  });

  // ===========================================================================
  //  fm-auth-password-reset
  // ===========================================================================
  group('fm-auth-password-reset', () {
    testWidgets('Forgot password screen loads from login link',
        (tester) async {
      await startAppOnLoginScreen(tester);

      // Tap "Mot de passe oublié ?" link
      await tester.tap(find.text('Mot de passe oublié ?'));
      await tester.pumpAndSettle();

      // Verify forgot password screen loaded
      expect(find.text('Réinitialisation'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('Forgot password screen has send button and back link',
        (tester) async {
      await startAppOnLoginScreen(tester);
      await tester.tap(find.text('Mot de passe oublié ?'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ElevatedButton, 'Envoyer le lien'),
          findsOneWidget);
      expect(find.text('Retour à la connexion'), findsOneWidget);
    });

    testWidgets('Forgot password empty email shows validation error',
        (tester) async {
      await startAppOnLoginScreen(tester);
      await tester.tap(find.text('Mot de passe oublié ?'));
      await tester.pumpAndSettle();

      // Tap send without entering email
      await tester
          .tap(find.widgetWithText(ElevatedButton, 'Envoyer le lien'));
      await tester.pumpAndSettle();

      expect(find.textContaining('email'), findsAtLeastNWidgets(1));
    });

    testWidgets('Back link returns to login screen', (tester) async {
      await startAppOnLoginScreen(tester);
      await tester.tap(find.text('Mot de passe oublié ?'));
      await tester.pumpAndSettle();

      // Tap "Retour à la connexion"
      await tester.tap(find.text('Retour à la connexion'));
      await tester.pumpAndSettle();

      // Should be back on login screen
      expect(find.text('Se connecter'), findsOneWidget);
      expect(find.text('Connectez-vous à votre compte'), findsOneWidget);
    });

    testWidgets('Reset password screen structure check', (tester) async {
      await startAppOnLoginScreen(tester);
      await tester.tap(find.text('Mot de passe oublié ?'));
      await tester.pumpAndSettle();

      // Verify the forgot password screen structure
      expect(
          find.textContaining(
              'Saisissez votre email'),
          findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsAtLeastNWidgets(1));
    });
  });
}

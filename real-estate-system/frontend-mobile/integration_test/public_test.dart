import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:real_estate_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();

  // ============================================================
  // fm-public-homepage: Home screen
  // ============================================================
  group('fm-public-homepage', () {
    testWidgets('Home screen loads with branding and tagline', (tester) async {
      await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Hero area: branding text
      expect(find.text('Horoazhon'), findsWidgets);
      // Tagline
      expect(find.text('Gestion immobilière simplifiée'), findsOneWidget);
    });

    testWidgets('Featured properties section loads', (tester) async {
      await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Section header for featured properties
      expect(find.text('Biens en vedette'), findsOneWidget);
      // "Voir tout" action text (appears for both sections)
      expect(find.text('Voir tout'), findsWidgets);
    });

    testWidgets('Agency showcase section loads', (tester) async {
      await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Scroll down to see the agency section
      await tester.scrollUntilVisible(
        find.text('Nos agences'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Nos agences'), findsOneWidget);
    });

    testWidgets('Search bar is visible', (tester) async {
      await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Search bar with hint text
      expect(find.text('Rechercher un bien...'), findsOneWidget);
      // Search icon
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('Quick action cards are visible', (tester) async {
      await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Scroll down to quick actions
      await tester.scrollUntilVisible(
        find.text('Voir les biens'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Voir les biens'), findsOneWidget);
      expect(find.text('Voir les agences'), findsOneWidget);
      // Quick action icons
      expect(find.byIcon(Icons.apartment), findsWidgets);
      expect(find.byIcon(Icons.location_on_outlined), findsWidgets);
    });
  });

  // ============================================================
  // fm-public-property: Property listing and detail screens
  // ============================================================
  group('fm-public-property', () {
    testWidgets('Property list screen loads via bottom nav', (tester) async {
      await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap the "Biens" tab in bottom navigation
      await tester.tap(find.text('Biens'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Filter bar search field should be visible
      expect(find.text('Rechercher...'), findsOneWidget);
    });

    testWidgets('Filter bar with search and type chip is visible',
        (tester) async {
      await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Biens tab
      await tester.tap(find.text('Biens'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Search field
      expect(find.text('Rechercher...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsWidgets);

      // Filter chips: Type, Vente, Location
      expect(find.text('Type'), findsOneWidget);
      expect(find.text('Vente'), findsWidgets);
      expect(find.text('Location'), findsWidgets);
    });

    testWidgets('Property cards display with price and location info',
        (tester) async {
      await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Biens tab
      await tester.tap(find.text('Biens'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Property cards should be present (Card widgets in the list)
      expect(find.byType(Card), findsWidgets);

      // Location icons should appear on property cards
      expect(find.byIcon(Icons.location_on_outlined), findsWidgets);

      // Chevron right icons indicate tappable cards
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });

    testWidgets('Tapping a property navigates to detail screen',
        (tester) async {
      await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Biens tab
      await tester.tap(find.text('Biens'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap the first property card (InkWell inside Card)
      final cards = find.byIcon(Icons.chevron_right);
      expect(cards, findsWidgets);
      await tester.tap(cards.first);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // On detail screen: should see "Vente" or "Location" badge
      // and the property type (e.g., APPARTEMENT, MAISON)
      // The property ID format "BI-X" appears in AppBar and/or body
      expect(find.textContaining('BI-'), findsWidgets);
    });
  });

  // ============================================================
  // fm-public-agence: Agency listing and profile screens
  // ============================================================
  group('fm-public-agence', () {
    testWidgets('Agency list screen loads via bottom nav', (tester) async {
      await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap the "Agences" tab in bottom navigation
      await tester.tap(find.text('Agences'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Search bar should be visible
      expect(find.text('Rechercher une agence...'), findsOneWidget);
    });

    testWidgets('Search bar is visible on agency list', (tester) async {
      await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Agences tab
      await tester.tap(find.text('Agences'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Search field with hint text and icon
      expect(find.text('Rechercher une agence...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsWidgets);
    });

    testWidgets('Agency cards display with name and contact info',
        (tester) async {
      await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Agences tab
      await tester.tap(find.text('Agences'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Agency cards should be present
      expect(find.byType(Card), findsWidgets);

      // Business icon (used as agency logo placeholder)
      expect(find.byIcon(Icons.business_outlined), findsWidgets);

      // Chevron icons indicate tappable cards
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });

    testWidgets('Tapping an agency navigates to detail screen',
        (tester) async {
      await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Agences tab
      await tester.tap(find.text('Agences'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap the first agency card
      final chevrons = find.byIcon(Icons.chevron_right);
      expect(chevrons, findsWidgets);
      await tester.tap(chevrons.first);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // On detail screen: should see "Contact" section header
      expect(find.text('Contact'), findsOneWidget);

      // Should see the agency properties section
      expect(find.textContaining('Biens de l'), findsOneWidget);
    });
  });
}

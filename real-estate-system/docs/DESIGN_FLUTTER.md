# Horoazhon Design System — Flutter / Dart

> Flutter-specific mapping of shared tokens from [`DESIGN_SYSTEM.md`](DESIGN_SYSTEM.md).
> Copy-paste these constants directly into your codebase under `lib/config/`.

---

## 1. Color Constants

```dart
// lib/config/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- 16 palette tokens ---
  static const Color blue500    = Color(0xFF2563EB); // buttons, links, active states, focus borders
  static const Color blue600    = Color(0xFF1D4ED8); // button hover, link hover
  static const Color blue400    = Color(0xFF3B82F6); // gradient start, lighter accent
  static const Color blue100    = Color(0xFFDBEAFE); // icon backgrounds, highlight surfaces
  static const Color blue50     = Color(0xFFEFF6FF); // info background, sale headers
  static const Color slate900   = Color(0xFF0F172A); // headings, strong labels, card titles
  static const Color slate700   = Color(0xFF334155); // body text, form labels, nav items
  static const Color slate500   = Color(0xFF64748B); // subtitles, descriptions, secondary text
  static const Color slate400   = Color(0xFF94A3B8); // muted text, placeholders, disabled icons
  static const Color slate200   = Color(0xFFE2E8F0); // borders, dividers, input outlines
  static const Color slate100   = Color(0xFFF1F5F9); // table separators, secondary hover bg
  static const Color slate50    = Color(0xFFF8FAFC); // page background, subtle surface
  static const Color white      = Color(0xFFFFFFFF); // cards, navbar, footer, inputs, modals
  static const Color blueRing   = Color(0x192563EB); // focus ring (10% opacity)
  static const Color shadowColor = Color(0x0F0F172A); // card shadows (6%)
  static const Color shadowHeavy = Color(0x1A0F172A); // prominent elevation (10%)

  // --- Semantic mapping ---
  static const Color defaultText   = slate700;
  static const Color defaultBg     = white;
  static const Color defaultBorder = slate200;

  static const Color successText   = blue600;
  static const Color successBg     = blue50;
  static const Color successBorder = blue400;

  static const Color errorText     = slate900;
  static const Color errorBg       = blue100;
  static const Color errorBorder   = blue500;

  static const Color warningText   = slate700;
  static const Color warningBg     = slate50;
  static const Color warningBorder = slate200;

  static const Color infoText      = blue500;
  static const Color infoBg        = blue50;
  static const Color infoBorder    = blue100;

  static const Color disabledText   = slate400;
  static const Color disabledBg     = slate50;
  static const Color disabledBorder = slate200;

  // --- Text color hierarchy ---
  static const Color textPrimary   = slate900;
  static const Color textSecondary = slate700;
  static const Color textTertiary  = slate500;
  static const Color textMuted     = slate400;
  static const Color textAccent    = blue500;

  // --- Badge colors ---
  static Color badgeBg(String type) => _badgeBg[type] ?? slate200;
  static Color badgeText(String type) => _badgeText[type] ?? slate700;

  static const Map<String, Color> _badgeBg = {
    'vente':    blue500,
    'location': slate900,
    'en_cours': blue100,
    'signe':    slate100,
    'annule':   slate200,
    'termine':  blue50,
  };

  static const Map<String, Color> _badgeText = {
    'vente':    white,
    'location': white,
    'en_cours': blue600,
    'signe':    slate900,
    'annule':   slate700,
    'termine':  blue500,
  };

  // --- Stat card variants ---
  static const List<StatCardColors> statVariants = [
    StatCardColors(leftBorder: blue500,  iconBg: blue100,  numberColor: blue600),  // primary
    StatCardColors(leftBorder: slate900, iconBg: slate100, numberColor: slate900), // secondary
    StatCardColors(leftBorder: blue400,  iconBg: blue50,   numberColor: blue500),  // tertiary
    StatCardColors(leftBorder: slate500, iconBg: slate50,  numberColor: slate700), // quaternary
  ];

  // --- Role shield colors ---
  static Color roleColor(String role) => _roleColors[role] ?? slate400;

  static const Map<String, Color> _roleColors = {
    'SUPER_ADMIN':  slate900,
    'ADMIN_AGENCY': blue500,
    'AGENT':        blue400,
    'CLIENT':       slate400,
  };

  // --- Brand gradient ---
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue400, blue500],
  );
}

class StatCardColors {
  final Color leftBorder;
  final Color iconBg;
  final Color numberColor;

  const StatCardColors({
    required this.leftBorder,
    required this.iconBg,
    required this.numberColor,
  });
}
```

---

## 2. Typography

```dart
// lib/config/app_text_styles.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // --- Base sizes (system font stack handled by Flutter defaults) ---

  static const TextStyle textXl = TextStyle(
    fontSize: 24,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.slate900,
  );

  static const TextStyle textLg = TextStyle(
    fontSize: 18,
    letterSpacing: -0.25,
    height: 1.3,
    color: AppColors.slate900,
  );

  static const TextStyle textMd = TextStyle(
    fontSize: 14,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.slate700,
  );

  static const TextStyle textSm = TextStyle(
    fontSize: 12,
    letterSpacing: 0.25,
    height: 1.5,
    color: AppColors.slate500,
  );

  // --- Weight variants ---
  // Usage: AppTextStyles.textXl.w700  or  AppTextStyles.textMd.w600

  // --- Color variants ---
  // Usage: AppTextStyles.textMd.withColor(AppColors.blue500)
}

/// Extension for weight and color shortcuts on TextStyle.
extension TextStyleX on TextStyle {
  TextStyle get w400 => copyWith(fontWeight: FontWeight.w400);
  TextStyle get w500 => copyWith(fontWeight: FontWeight.w500);
  TextStyle get w600 => copyWith(fontWeight: FontWeight.w600);
  TextStyle get w700 => copyWith(fontWeight: FontWeight.w700);
  TextStyle get w800 => copyWith(fontWeight: FontWeight.w800);

  TextStyle withColor(Color c) => copyWith(color: c);
}

/// Common composed styles (convenience).
class AppTextComposed {
  AppTextComposed._();

  // Hero / brand
  static final TextStyle heroTitle     = AppTextStyles.textXl.w800;
  static final TextStyle statNumber    = AppTextStyles.textXl.w700;

  // Headings
  static final TextStyle pageHeading   = AppTextStyles.textLg.w700;
  static final TextStyle sectionHeading = AppTextStyles.textLg.w600;
  static final TextStyle cardTitle     = AppTextStyles.textMd.w600;

  // Body
  static final TextStyle body          = AppTextStyles.textMd.w400;
  static final TextStyle label         = AppTextStyles.textMd.w500;
  static final TextStyle button        = AppTextStyles.textMd.w500;
  static final TextStyle navLink       = AppTextStyles.textMd.w500;

  // Small
  static final TextStyle badge         = AppTextStyles.textSm.w600;
  static final TextStyle tableHeader   = AppTextStyles.textSm.w600;
  static final TextStyle caption       = AppTextStyles.textSm.w400;
}
```

---

## 3. Spacing

```dart
// lib/config/app_spacing.dart

class AppSpacing {
  AppSpacing._();

  static const double space1  =  4.0;  // badge padding-y, tight gaps
  static const double space2  =  8.0;  // button gap, card-row gap, label-input
  static const double space3  = 12.0;  // input padding, dropdown items
  static const double space4  = 16.0;  // grid gap, card body, section spacing
  static const double space5  = 20.0;  // card padding extended, property grid gap
  static const double space6  = 24.0;  // card padding large, container sides, navbar
  static const double space8  = 32.0;  // section margins, page header bottom
  static const double space10 = 40.0;  // hero padding, large section gaps
  static const double space12 = 48.0;  // hero top (desktop)
  static const double space16 = 64.0;  // navbar height, empty state padding-y

  // Vertical rhythm helpers
  static const double sectionGap      = space8;  // sibling sections
  static const double cardGap         = space4;  // card to next element
  static const double headingGap      = space4;  // heading to content
  static const double formFieldGap    = space4;  // between form fields
  static const double labelInputGap   = space2;  // label to input
}
```

---

## 4. Border Radius

```dart
// lib/config/app_radius.dart
import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  static const double sm   =  4.0;   // decorative shapes, micro-elements
  static const double md   =  8.0;   // buttons, inputs, pagination, dropdowns
  static const double lg   = 16.0;   // cards, modals, tables, filters, auth card
  static const double full = 9999.0; // badges, pills, avatar button, search tabs

  // Pre-built BorderRadius (avoid allocating in build methods)
  static final BorderRadius smAll   = BorderRadius.circular(sm);
  static final BorderRadius mdAll   = BorderRadius.circular(md);
  static final BorderRadius lgAll   = BorderRadius.circular(lg);
  static final BorderRadius fullAll = BorderRadius.circular(full);
}
```

---

## 5. Shadows

```dart
// lib/config/app_shadows.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  AppShadows._();

  /// Button hover
  static const BoxShadow sm = BoxShadow(
    offset: Offset(0, 2),
    blurRadius: 8,
    color: AppColors.shadowColor, // 6%
  );

  /// Card hover, stat hover, dropdown
  static const BoxShadow md = BoxShadow(
    offset: Offset(0, 4),
    blurRadius: 16,
    color: AppColors.shadowColor, // 6%
  );

  /// Auth card, modal, prominent elevation
  static const BoxShadow lg = BoxShadow(
    offset: Offset(0, 8),
    blurRadius: 32,
    color: AppColors.shadowHeavy, // 10%
  );

  /// Focus ring (used on inputs and interactive elements)
  static List<BoxShadow> focusRing = const [
    BoxShadow(
      offset: Offset.zero,
      blurRadius: 0,
      spreadRadius: 3,
      color: AppColors.blueRing,
    ),
  ];

  // Convenience lists for BoxDecoration
  static const List<BoxShadow> smList = [sm];
  static const List<BoxShadow> mdList = [md];
  static const List<BoxShadow> lgList = [lg];
}
```

---

## 6. ThemeData Configuration

```dart
// lib/config/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_shadows.dart';

class AppTheme {
  AppTheme._();

  static ThemeData build() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // --- Color Scheme ---
      colorScheme: const ColorScheme.light(
        primary: AppColors.blue500,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.blue100,
        onPrimaryContainer: AppColors.blue600,
        secondary: AppColors.slate900,
        onSecondary: AppColors.white,
        secondaryContainer: AppColors.slate100,
        onSecondaryContainer: AppColors.slate900,
        surface: AppColors.white,
        onSurface: AppColors.slate700,
        surfaceContainerHighest: AppColors.slate50,
        error: AppColors.slate900,       // errors use slate, not red
        onError: AppColors.white,
        outline: AppColors.slate200,
        outlineVariant: AppColors.slate100,
      ),

      scaffoldBackgroundColor: AppColors.slate50,

      // --- AppBar ---
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.slate900,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.shadowColor,
        titleTextStyle: AppTextStyles.textLg.w700.copyWith(color: AppColors.slate900),
        iconTheme: const IconThemeData(color: AppColors.slate700, size: 24),
      ),

      // --- Text ---
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.textXl.w700,  // 24px bold
        headlineMedium: AppTextStyles.textLg.w700, // 18px bold
        headlineSmall: AppTextStyles.textLg.w600,  // 18px semi
        titleLarge: AppTextStyles.textMd.w600,     // 14px semi (card titles)
        titleMedium: AppTextStyles.textMd.w500,    // 14px medium (labels)
        bodyLarge: AppTextStyles.textMd.w400,      // 14px regular
        bodyMedium: AppTextStyles.textMd.w400,     // 14px regular
        bodySmall: AppTextStyles.textSm.w400,      // 12px regular
        labelLarge: AppTextStyles.textMd.w500,     // 14px medium (buttons)
        labelMedium: AppTextStyles.textSm.w600,    // 12px semi (badges)
        labelSmall: AppTextStyles.textSm.w400,     // 12px regular (captions)
      ),

      // --- Elevated Button ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue500,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
          ),
          textStyle: AppTextStyles.textMd.w500,
        ),
      ),

      // --- Outlined Button ---
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.slate700,
          side: const BorderSide(color: AppColors.slate200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
          ),
          textStyle: AppTextStyles.textMd.w500,
        ),
      ),

      // --- Text Button ---
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blue500,
          textStyle: AppTextStyles.textMd.w500,
        ),
      ),

      // --- Input Decoration ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space3,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: const BorderSide(color: AppColors.blue500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: const BorderSide(color: AppColors.blue500),
        ),
        hintStyle: AppTextStyles.textMd.w400.withColor(AppColors.slate400),
        labelStyle: AppTextStyles.textMd.w500.withColor(AppColors.slate700),
        errorStyle: AppTextStyles.textSm.w400.withColor(AppColors.slate900),
      ),

      // --- Card ---
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: const BorderSide(color: AppColors.slate200),
        ),
        margin: EdgeInsets.zero,
      ),

      // --- Divider ---
      dividerTheme: const DividerThemeData(
        color: AppColors.slate200,
        thickness: 1,
        space: 1,
      ),

      // --- Chip (badges) ---
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.slate100,
        labelStyle: AppTextStyles.textSm.w600,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space2,
          vertical: AppSpacing.space1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.fullAll,
        ),
        side: BorderSide.none,
      ),

      // --- Bottom Navigation Bar ---
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.blue500,
        unselectedItemColor: AppColors.slate400,
        selectedLabelStyle: AppTextStyles.textSm.w500,
        unselectedLabelStyle: AppTextStyles.textSm.w400,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // --- Navigation Drawer (admin) ---
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
      ),

      // --- Dialog / Modal ---
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
        ),
        elevation: 0,
        titleTextStyle: AppTextStyles.textLg.w700.copyWith(color: AppColors.slate900),
        contentTextStyle: AppTextStyles.textMd.w400.copyWith(color: AppColors.slate700),
      ),

      // --- SnackBar (flash messages) ---
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.slate900,
        contentTextStyle: AppTextStyles.textMd.w400.copyWith(color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // --- Tab Bar ---
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.blue500,
        unselectedLabelColor: AppColors.slate500,
        indicatorColor: AppColors.blue500,
        labelStyle: AppTextStyles.textMd.w500,
        unselectedLabelStyle: AppTextStyles.textMd.w400,
      ),

      // --- Floating Action Button ---
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.blue500,
        foregroundColor: AppColors.white,
        elevation: 2,
        shape: CircleBorder(),
      ),

      // --- Visual density ---
      visualDensity: VisualDensity.standard,
    );
  }
}
```

**Usage in `main.dart`:**

```dart
MaterialApp(
  title: 'Horoazhon',
  theme: AppTheme.build(),
  // ...
);
```

---

## 7. Data Formatting

```dart
// lib/config/app_formatters.dart
import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final _currencyFull = NumberFormat('#,##0.00', 'fr_FR');
  static final _currencyShort = NumberFormat('#,##0', 'fr_FR');
  static final _dateFmt = DateFormat('dd/MM/yyyy');

  /// "250 000,00 EUR"
  static String formatCurrency(double value) {
    return '${_currencyFull.format(value)} EUR';
  }

  /// "250 000 EUR"
  static String formatCurrencyShort(double value) {
    return '${_currencyShort.format(value)} EUR';
  }

  /// "1 200 EUR/mois"
  static String formatRent(double value) {
    return '${_currencyShort.format(value)} EUR/mois';
  }

  /// "01/03/2026"
  static String formatDate(DateTime date) {
    return _dateFmt.format(date);
  }

  /// "BI-42"
  static String formatBienId(int id) => 'BI-$id';

  /// "CTR-15"
  static String formatContratId(int id) => 'CTR-$id';

  /// "AG-3"
  static String formatAgenceId(int id) => 'AG-$id';

  /// "85 m2" (with superscript handled by widget, not formatter)
  static String formatArea(double area) {
    return '${area.toStringAsFixed(0)} m\u00B2';
  }
}
```

> **Dependency**: add `intl` to `pubspec.yaml`:
> ```yaml
> dependencies:
>   intl: ^0.19.0
> ```

---

## 8. Icon Strategy

Flutter uses **Material Icons** instead of inline SVG. Map the Lucide/Feather style from the web to the closest Material equivalents.

### Size scale

| Token | Pixels | Usage |
|-------|--------|-------|
| `iconXs` | 16 | Inline indicators, badge icons |
| `iconSm` | 20 | Nav items, button icons, list leading |
| `iconMd` | 24 | Default icon size, app bar actions |
| `iconLg` | 40 | Stat card icons (inside colored container) |
| `iconXl` | 48 | Empty state illustrations |

### Constants

```dart
// lib/config/app_icons.dart

class AppIconSizes {
  AppIconSizes._();

  static const double xs = 16;
  static const double sm = 20;
  static const double md = 24;
  static const double lg = 40;
  static const double xl = 48;
}
```

### Common mappings

| Web (Lucide/Feather) | Flutter Material Icon |
|----------------------|-----------------------|
| `home` | `Icons.home_outlined` |
| `building-2` | `Icons.apartment` |
| `map-pin` | `Icons.location_on_outlined` |
| `file-text` | `Icons.description_outlined` |
| `users` | `Icons.people_outlined` |
| `user` | `Icons.person_outlined` |
| `shield` | `Icons.shield_outlined` |
| `settings` | `Icons.settings_outlined` |
| `search` | `Icons.search` |
| `plus` | `Icons.add` |
| `edit` | `Icons.edit_outlined` |
| `trash-2` | `Icons.delete_outlined` |
| `eye` | `Icons.visibility_outlined` |
| `chevron-right` | `Icons.chevron_right` |
| `chevron-down` | `Icons.expand_more` |
| `x` | `Icons.close` |
| `check` | `Icons.check` |
| `log-out` | `Icons.logout` |
| `log-in` | `Icons.login` |
| `phone` | `Icons.phone_outlined` |
| `mail` | `Icons.email_outlined` |
| `calendar` | `Icons.calendar_today_outlined` |
| `image` | `Icons.image_outlined` |
| `euro` | `Icons.euro` |
| `key` | `Icons.key` |
| `filter` | `Icons.filter_list` |
| `arrow-left` | `Icons.arrow_back` |

### Icon containers

For stat cards and feature icons, wrap in a colored container:

```dart
Container(
  width: AppIconSizes.lg,
  height: AppIconSizes.lg,
  decoration: BoxDecoration(
    color: AppColors.blue100, // or variant iconBg
    borderRadius: AppRadius.mdAll,
  ),
  child: const Icon(
    Icons.apartment,
    size: AppIconSizes.md,
    color: AppColors.blue500,
  ),
)
```

---

## 9. Navigation Pattern

### Client / Public: Bottom Navigation Bar

```dart
BottomNavigationBar(
  currentIndex: _currentIndex,
  onTap: _onTabTapped,
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined),       label: 'Accueil'),
    BottomNavigationBarItem(icon: Icon(Icons.apartment),           label: 'Biens'),
    BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: 'Agences'),
    BottomNavigationBarItem(icon: Icon(Icons.person_outlined),     label: 'Profil'),
  ],
)
```

### Admin / Agent: Drawer Navigation

Admin and agent roles use a `Drawer` for management screens:

| Drawer item | Icon | Route |
|-------------|------|-------|
| Tableau de bord | `Icons.dashboard_outlined` | `/admin` |
| Biens | `Icons.apartment` | `/admin/biens` |
| Agences | `Icons.business_outlined` | `/admin/agences` |
| Contrats | `Icons.description_outlined` | `/admin/contrats` |
| Personnes | `Icons.people_outlined` | `/admin/personnes` |
| Utilisateurs | `Icons.manage_accounts_outlined` | `/admin/utilisateurs` |
| Donnees de reference | `Icons.settings_outlined` | `/admin/references` |

### Role-adaptive navigation

```dart
// Determine nav items based on user role
List<BottomNavigationBarItem> getNavItems(String role) {
  final base = [
    const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Accueil'),
    const BottomNavigationBarItem(icon: Icon(Icons.apartment),     label: 'Biens'),
  ];

  if (role == 'CLIENT') {
    return [
      ...base,
      const BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Contrats'),
      const BottomNavigationBarItem(icon: Icon(Icons.person_outlined),      label: 'Profil'),
    ];
  }

  // SUPER_ADMIN, ADMIN_AGENCY, AGENT — use drawer for admin, bottom nav for browsing
  return [
    ...base,
    const BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: 'Agences'),
    const BottomNavigationBarItem(icon: Icon(Icons.person_outlined),      label: 'Profil'),
  ];
}
```

---

## 10. Accessibility

- **Touch targets**: minimum 44px (`MaterialTapTargetSize.padded` or explicit `SizedBox` constraints)
- **Semantics**: use `Semantics` widget for icon-only buttons (`Semantics(label: 'Supprimer', child: IconButton(...))`)
- **Contrast**: all text/background combinations meet WCAG AA (see DESIGN_SYSTEM.md section 11)
- **Focus ring**: handled by Flutter's built-in focus overlay; customize via `MaterialStateProperty` when needed

---

## 11. Testing

Integration and widget tests run on an Android emulator hosted on Windows, bridged to WSL2 via ADB.

Full setup guide: `FLUTTER_TESTING_SETUP.md` (to be created in Phase 3).

Quick reference:
- Widget tests: `flutter test`
- Integration tests: `flutter test integration_test/`
- Golden tests: use `matchesGoldenFile()` with the theme applied via `AppTheme.build()`

---

## File Checklist

When bootstrapping the Flutter project, create these config files:

| File | Class(es) |
|------|-----------|
| `lib/config/app_colors.dart` | `AppColors`, `StatCardColors` |
| `lib/config/app_text_styles.dart` | `AppTextStyles`, `TextStyleX`, `AppTextComposed` |
| `lib/config/app_spacing.dart` | `AppSpacing` |
| `lib/config/app_radius.dart` | `AppRadius` |
| `lib/config/app_shadows.dart` | `AppShadows` |
| `lib/config/app_theme.dart` | `AppTheme` |
| `lib/config/app_formatters.dart` | `AppFormatters` |
| `lib/config/app_icons.dart` | `AppIconSizes` |
